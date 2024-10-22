import 'dart:io';
import 'dart:typed_data';

import 'package:common_plugin/common_plugin.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

class ImageCompress {
  static Future<FileSource> compress(
    Uint8List list, {
    // 图片字节流
    int maxWidth = 1280, // 压缩最大宽度
    int maxHeight = 1280, // 压缩最大高度
    int quality = 90, // 压缩质量
    bool autoCorrectionAngle = true, // 是否自动纠正角度
    bool keepExif = false, // 是否保持exif信息
    ImageCompressFormat format = ImageCompressFormat.jpeg,
  }) async {
    Uint8List result = Uint8List(0);
    String fileExtension = 'jpg';
    CompressFormat format0 = CompressFormat.jpeg;
    switch (format) {
      case ImageCompressFormat.jpeg:
        format0 = CompressFormat.jpeg;
        fileExtension = 'jpg';
        break;
      case ImageCompressFormat.png:
        format0 = CompressFormat.png;
        fileExtension = 'png';
        break;
      case ImageCompressFormat.webp:
        format0 = CompressFormat.webp;
        fileExtension = 'webp';
        break;
    }

    try {
      result = await FlutterImageCompress.compressWithList(
        list,
        minHeight: maxHeight,
        minWidth: maxWidth,
        quality: quality,
        rotate: 0,
        format: format0,
        autoCorrectionAngle: autoCorrectionAngle,
        keepExif: keepExif,
      );
      final path = await saveFile(result, fileExtension);
      return FileSource(
        path: path,
        bytes: result,
        name: 'compressed_${DateTime.now().millisecondsSinceEpoch}.$fileExtension',
        mimeType: 'image/$fileExtension',
        size: result.length.toString(),
        ext: fileExtension,
      );
    } catch (e) {
      Logger.error("$e", mark: "ImageCompress compress");
    }
    return FileSource();
  }

  static Future<String?> saveFile(Uint8List list, String fileExtension) async {
    try {
      // 获取临时目录
      final tempDir = await getPathCacheTemp();
      // 生成唯一的文件名
      final filePath = '$tempDir/compressed_${DateTime.now().millisecondsSinceEpoch}.$fileExtension';
      final file = File(filePath);
      await file.writeAsBytes(list);
      return filePath;
    } catch (e) {
      Logger.error("$e", mark: "ImageCompress saveFile");
    }
    return null;
  }
}

enum ImageCompressFormat {
  jpeg,
  png,
  webp,
}
