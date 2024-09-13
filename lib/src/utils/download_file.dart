import 'dart:async';
import 'dart:io';
import 'package:common_plugin/src/common/function.dart';
import 'package:common_plugin/src/utils/float_task_progress.dart';
import 'package:common_plugin/src/widget/show_layer.dart';
import 'package:dio/dio.dart';

Future downLoadFile(
  String url,
{
  String? savePath, //保存路径，包含文件名
  void Function(int received, int total)? onReceiveProgress,
  bool isShowProgress = true,
}
) async {
  if (savePath == null) {
    //根据url获取文件名
    var fileName = url.split("/").last;
    fileName = fileName.replaceAll(" ", "");
    fileName = fileName.split("?").first;
    if (fileName.isEmpty) {
      fileName = "file_${DateTime.now().millisecondsSinceEpoch}"; //随机生成文件名
    }
    savePath = await getPathDownload() + "/" + fileName;
  }
  ShowDragLayer.show(child: DownloadTaskProgress());
  await DownloadManage.download(
    url,
    savePath!,
    onReceiveProgress: onReceiveProgress,
  );
}

class DownloadManage {
  /// 用于记录下载的url，避免重复下载
  static var downloadingUrls = Map<String, CancelToken>();

  /// 当前正在下载Url
  static String currentDownloadUrl = '';
  ///文件大小
  static int fileSize = 1;

  ///已接收大小
  static int receiveSize = 0;

  ///下载Id
  static int? taskId;

  ///下载状态 (1正在下载，2下载完成，3下载失败)
  static int state = 0;

  ///下载用时
  static int downloadTime = 0;

  ///文件保存路径
  static String? fileSavePath;


  /// 断点下载大文件
  static Future<void> download(
    String url,
    String savePath, {
      void Function(int received, int total)? onReceiveProgress,
    void Function(DioException)? failed,
  }) async {
    int downloadStart = 0;
    bool fileExists = false;
    File f = File(savePath);

    currentDownloadUrl = url;
    downloadTime = 0;
    state = 1;
    receiveSize = 0;
    fileSize = 1;
    fileSavePath = savePath;

    if (await f.exists()) {
      downloadStart = f.lengthSync();
      fileExists = true;
       f.deleteSync();
    }



    print("开始：$downloadStart");
    if (fileExists && downloadingUrls.containsKey(url)) {
      if (state != 2) {
        f.delete();
      }
      // else {
      //   return;
      // }
    }
    var dio = Dio();
    CancelToken cancelToken = CancelToken();
    downloadingUrls[url] = cancelToken;
    try {
      await dio.download(
        url,
        savePath,
        cancelToken: cancelToken,
        options: Options(
          /// 以流的方式接收响应数据
          responseType: ResponseType.stream,
          followRedirects: false,
          headers: {
            /// 分段下载重点位置
            "range": "bytes=$downloadStart-",
          },
        ),
        onReceiveProgress: (received, total) {
          if (total != -1) {
            receiveSize = (received~/1024~/1024).toInt();
            fileSize = (total~/1024~/1024).toInt();
            if (fileSize<1){fileSize=1;}
            if (received==total){
              state = 2;
              downloadingUrls.remove(url);
            } else {
              state = 1;
              downloadTime++;
            }
            onReceiveProgress?.call(received, total);
          }
        },
      );
      cancelToken.whenCancel.then((_) async {
        state = 0;
      });
    } on DioException catch (error) {
      /// 请求已发出，服务器用状态代码响应它不在200的范围内
      if (CancelToken.isCancel(error)) {
        state = 0;
        print("下载取消");
      } else {
        state = 3;
        failed?.call(error);
      }
      downloadingUrls.remove(url);
    }
  }


  /// 取消下载任务
  static Future<void> cancelDownload({String? url}) async {
    fileSize = 0;
    receiveSize = 0;
    state = 0;
    downloadingUrls[url ?? currentDownloadUrl]?.cancel();
    downloadingUrls.remove(url ?? currentDownloadUrl);
    fileSavePath = null;

    if (fileSavePath != null) {
      File file = File(fileSavePath!);
      if (await file.exists()) {
        file.deleteSync();
      }
    }
  }
}
