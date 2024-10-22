import 'package:common_plugin/common_plugin.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:flutter/material.dart';

class ResponseBack {
  dynamic data;
  bool isSuccess;
  bool isSuccessHasData; //请求成功，且有数据

  ///requestBack.type == ResponseType.success 成功，apiError网站返回错误，notLogin没有登录，networkFailure网络故障，other其它
  StateType type;
  int statusCode; //返回状态码
  String message;
  ResponseBack(
      {this.data = '',
        this.isSuccess = false,
        this.isSuccessHasData = false,
        this.type = StateType.unknown,
        this.statusCode = 0,
        this.message = ''});
}

enum StateType { success, apiError, notLogin, networkFailure, unknown }

///请求类型
enum UrlMethod {
  post("POST"),
  get("GET"),
  put("PUT"),
  delete("DELETE"),
  head("HEAD");

  final String type;
  const UrlMethod(this.type);
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
      String path, // url地址或路径
          {
        BuildContext? context,

        /// data参数不为空默认post方式请求，query参数不为空默认为get，手动可填写UrlMethod.post
        UrlMethod? method,

        /// 查询参数，拼接为url问号后面参数部分，不为空默认get请求参数
        Map<String, dynamic>? queryParameters,

        /// 不为空默认post请求参数
        Object? data,

        /// 请求头
        Map<String, dynamic>? headers,

        /// 上传文件路径列表
        List<String>? filePaths,

        /// 完成进度回调
        void Function(int count, int total)? onReceiveProgress,

        /// 上传进度回调
        void Function(int count, int total)? onSendProgress,

        /// 显示加载动画
        bool showLoading = true,

        /// 超时时间，单位秒
        int? timeout,

        /// 响应类型,是否为字节流，默认json
        bool isResponseBytes = false,
      }) async {
    ResponseBack requestBack = ResponseBack();

    if (method == null) {
      if (data != null) {
        method = UrlMethod.post;
      } else if (queryParameters != null) {
        method = UrlMethod.get;
      } else {
        method = UrlMethod.post;
      }
    }

    if (queryParameters != null) {
      queryParameters.removeWhere((key, value) => value == null);
    }
    if (data != null && data is Map) {
      data.removeWhere((key, value) => value == null);
    }

    if (timeout != null) {
      dio.options.connectTimeout = Duration(seconds: timeout);
      dio.options.receiveTimeout = Duration(seconds: timeout);
      dio.options.sendTimeout = Duration(seconds: timeout);
    }
    try {
      // 处理文件
      if (filePaths != null) {
        FormData formData = FormData.fromMap({});
        for (var file in filePaths) {
          final filePath = file;
          final fileName = filePath.split('/').last;
          formData.files.add(MapEntry("file",
              await MultipartFile.fromFile(filePath, filename: fileName)));
        }
        headers ??= {};
        headers['Content-Type'] = 'multipart/form-data';
        data = formData;
      }

      if (_cookies.isNotEmpty) {
        dio.interceptors.add(CookieManager(_cookie));
        dio.options.headers["Cookie"] = _cookies.join("; ");
      }

      Response res;

      if (showLoading) {
        final request = await awaitTimeShowLoading(() async {
          return await dio.request(
            path,
            options: Options(
                method: method?.type,
                headers: headers,
                responseType: isResponseBytes ? ResponseType.bytes : null),
            queryParameters: queryParameters,
            data: data,
            cancelToken: CancelToken(),
            onReceiveProgress: onReceiveProgress,
            onSendProgress: onSendProgress,
          );
        }, timeout: timeout ?? 30);
        if (request != null) {
          res = request;
        } else {
          requestBack.type = StateType.networkFailure;
          return Future.value(requestBack);
        }
      } else {
        res = await dio.request(path,
            options: Options(
                method: method.type,
                headers: headers,
                responseType: isResponseBytes ? ResponseType.bytes : null),
            queryParameters: queryParameters,
            data: data,
            cancelToken: CancelToken(),
            onReceiveProgress: onReceiveProgress,
            onSendProgress: onSendProgress);
      }

      if (res.headers.map["set-cookie"] is List &&
          res.headers.map["set-cookie"]!.isNotEmpty) {
        List<String>? setCookieHeaders = res.headers.map["set-cookie"];
        _cookies = setCookieHeaders!.map((e) => e.split(";")[0]).toList();
      }
      requestBack.statusCode = res.statusCode ?? 0;
      if (res.statusCode == 200) {
        Logger.info(
          """
  url:  $path${queryParameters != null ? "\n  query:  $queryParameters" : ""}${data != null ? "\n  data:  $data" : ""}
  method:  ${method.type}
  response-data:  ${res.data.toString().length > 2000 ? '${res.data.toString().substring(0, 2000)}...' : res.data.toString()}""",
          mark: "api-request",
        );
        ShowOverScreen.remove();

        if (method == UrlMethod.head) {
          requestBack.data = res.headers.map;
        } else {
          requestBack.data = res.data;
        }
        requestBack.isSuccess = true;
        requestBack.type = StateType.success;
        return Future.value(requestBack);
      } else {
        requestBack.data = res.data;
        Logger.error('$res', mark: "api-error");
        return Future.error(res);
      }
    } on DioException catch (dioError) {
      Logger.error("""
  url:  ${dioError.requestOptions.uri}
  query:  $queryParameters
  data:  $data
  method:  ${method.type}
  headers:  $headers
  
  response-statusCode:  ${dioError.response?.statusCode}
  error-message:  ${dioError.message}
  error:  ${dioError.error}
  response-data:  ${dioError.response?.data}""", mark: "api-request-error");
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
      Logger.error("未知错误: $e", mark: "api-request-error");
      requestBack.type = StateType.unknown;
      requestBack.statusCode = 0;
      return Future.value(requestBack);
    }
  }
}
