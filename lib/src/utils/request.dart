
import 'package:common_plugin/common_plugin.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class ResponseBack {
  dynamic data = '';
  bool isSuccess = false;
  bool isSuccessHasData = false; //请求成功，且有数据

  ///requestBack.type == ResponseType.success 成功，apiError网站返回错误，notLogin没有登录，networkFailure网络故障，other其它
  StateType type = StateType.unknown;
  int statusCode = 0; //返回状态码
  String message = '';
}

enum StateType {
  success,
  apiError,
  notLogin,
  networkFailure,
  unknown
}

class UrlClient {
  static final dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 30),
    sendTimeout: const Duration(seconds: 30),
  ));
  static final CookieJar _cookie = CookieJar();
  static List<String> _cookies = [];


  static Future<ResponseBack> request(
      String path, {
        BuildContext? context,
        /// get,post,put,delete
        String method = "POST",
        Map<String, dynamic>? queryParameters,
        Map<String, dynamic>? data,
        Map<String, dynamic>? headers,
        void Function(int count, int total)? onReceiveProgress,
        void Function(int count, int total)? onSendProgress,
        bool showLoading = true,
        int? timeout,
      }) async {
    ResponseBack requestBack = ResponseBack();

    if (timeout != null){
      dio.options.connectTimeout = Duration(seconds: timeout);
      dio.options.receiveTimeout = Duration(seconds: timeout);
      dio.options.sendTimeout = Duration(seconds: timeout);
    }
    try {


      if (_cookies.isNotEmpty) {
        dio.interceptors.add(CookieManager(_cookie));
        dio.options.headers["Cookie"] = _cookies.join("; ");
      }

      Response res;

      if (showLoading) {
        res = await awaitTimeShowLoading(() async {
            return await dio.request(
                path,
                options: Options(method: method, headers: headers),
                queryParameters: queryParameters,
                data: data,
                cancelToken: CancelToken(),
                onReceiveProgress: onReceiveProgress,
                onSendProgress: onSendProgress
            );
        },timeout: timeout ?? 30);
      } else {
        res = await dio.request(
            path,
            options: Options(method: method, headers: headers),
            queryParameters: queryParameters,
            data: data,
            cancelToken: CancelToken(),
            onReceiveProgress: onReceiveProgress,
            onSendProgress: onSendProgress
        );
      }

      if (res.headers.map["set-cookie"] is List &&
          res.headers.map["set-cookie"]!.isNotEmpty) {
        List<String>? setCookieHeaders = res.headers.map["set-cookie"];
        _cookies = setCookieHeaders!
            .map((e) => e.split(";")[0])
            .toList();
      }
      requestBack.statusCode = res.statusCode ?? 0;
      if (res.statusCode == 200) {
        if (kDebugMode) {
          print("api-url:$path");
          print("$data");
          print("api-Response-data:${res.data}");
        }
        ShowOverScreen.remove();

        requestBack.data = res.data;
        requestBack.isSuccess = true;
        requestBack.type = StateType.success;
        return Future.value(requestBack);
      } else {
        showDebug('$res',mark: "api-error");
        return Future.error(res);
      }
    } on DioException catch (dioError) {
      if (kDebugMode) {
        showDebug(dioError.requestOptions.uri, mark: "api-request-error");
        print("request-headers:${dioError.requestOptions.headers}");
        print("request-data:${dioError.requestOptions.data}");
        print("request-queryParameters:${dioError.requestOptions
            .queryParameters}");
        print("response-statusCode:${dioError.response?.statusCode}");
        print("response-data:${dioError.response?.data}");
        print("error-message:${dioError.error}");
      }
      if (dioError.type == DioExceptionType.connectionTimeout ||
          dioError.type == DioExceptionType.receiveTimeout ||
          dioError.type == DioExceptionType.sendTimeout ||
          dioError.type == DioExceptionType.connectionError) {
        requestBack.type = StateType.networkFailure;
        showAlert('连接网络失败，请检查网络');
      } else if (dioError.type == DioExceptionType.badResponse) {
        requestBack.type = StateType.apiError;
      } else if (dioError.type == DioExceptionType.unknown) {
        requestBack.type = StateType.unknown;
      }
      requestBack.statusCode = dioError.response?.statusCode ?? 0;
      return Future.value(requestBack);
    } catch (e) {
      print("未知错误: $e");
      requestBack.type = StateType.unknown;
      requestBack.statusCode = 0;
      return Future.value(requestBack);
    }
  }
}
