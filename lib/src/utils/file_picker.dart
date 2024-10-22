import 'dart:typed_data';

import 'package:common_plugin/common_plugin.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';

enum FileType {
  image,
  video,
  audio,
  imageAndVideo,
  file,
  all,
}

class FileSource {
  FileType? type; // 文件类型
  String? path; // 文件路径
  Uint8List? bytes; // 二进制字节流
  AssetEntity? assetEntity;
  String? name; // 文件名
  String? mimeType; // 文件MIME类型（如image/jpeg）
  String? size; // 文件大小（如1024字节）
  String? ext; // 文件扩展名（如jpg）
  String? id; // 文件ID
  Uint8List? thumb; // 缩略图

  FileSource({
    this.type,
    this.path,
    this.bytes,
    this.name,
    this.mimeType,
    this.size,
    this.ext,
    this.id,
    this.thumb,
  });
}

/// 文件选择器，支持图片、视频、音频、文档、文件等接口,用wechat_assets_picker实现
class FilePicker {
  static Future<List<FileSource>> image({
    int maxCount = 9, // 最大选择数量
    bool isMulti = true, // 是否多选
    columnCount = 4, // 显示列数
    bool isCompress = true, // 是否压缩
    int maxWidth = 1280, // 压缩最大宽度
    int maxHeight = 1280, // 压缩最大高度
    int quality = 90, // 压缩质量
  }) async {
    final permission = await PermissionUtils.photos();
    if (!permission) {
      showAlert("没有相册权限，无法选择图片");
      return [];
    }
    return await pick(
      type: FileType.image,
      maxCount: maxCount,
      isMulti: isMulti,
      columnCount: columnCount,
      isImageCompress: isCompress,
      compressImageMaxWidth: maxWidth,
      compressImageMaxHeight: maxHeight,
      compressQuality: quality,
    );
  }

  static Future<List<FileSource>> video({
    int maxCount = 1,
    bool isMulti = false,
    columnCount = 4,
  }) async {
    final permission = await PermissionUtils.photos();
    if (!permission) {
      showAlert("没有相册权限，无法选择视频");
      return [];
    }
    return await pick(
      type: FileType.video,
      maxCount: maxCount,
      isMulti: isMulti,
      columnCount: columnCount,
    );
  }

  static Future<List<FileSource>> audio({
    int maxCount = 1,
    bool isMulti = false,
    columnCount = 4,
  }) async {
    final permission = await PermissionUtils.photos();
    if (!permission) {
      showAlert("没有存储权限，无法选择音频");
      return [];
    }
    return await pick(
      type: FileType.audio,
      maxCount: maxCount,
      isMulti: isMulti,
      columnCount: columnCount,
    );
  }

  static Future<List<FileSource>> file({
    int maxCount = 9,
    bool isMulti = true,
    columnCount = 4,
    bool isImageCompress = true, // 是否压缩图片
    int compressImageMaxWidth = 1280, // 压缩最大宽度
    int compressImageMaxHeight = 1280, // 压缩最大高度
    int compressQuality = 90, // 压缩质量
  }) async {
    final permission = await PermissionUtils.photos();
    if (!permission) {
      showAlert("没有存储访问权限，无法选择文件");
      return [];
    }
    return await pick(
      type: FileType.file,
      maxCount: maxCount,
      isMulti: isMulti,
      columnCount: columnCount,
      isImageCompress: isImageCompress,
      compressImageMaxWidth: compressImageMaxWidth,
      compressImageMaxHeight: compressImageMaxHeight,
      compressQuality: compressQuality,
    );
  }

  static Future<List<FileSource>> all({
    int maxCount = 9,
    bool isMulti = true,
    columnCount = 4,
    bool isImageCompress = true, // 是否压缩图片
    int compressImageMaxWidth = 1280, // 压缩最大宽度
    int compressImageMaxHeight = 1280, // 压缩最大高度
    int compressQuality = 90, // 压缩质量
  }) async {
    final permission = await PermissionUtils.photos();
    if (!permission) {
      showAlert("没有存储访问权限，无法选择文件");
      return [];
    }
    return await pick(
      type: FileType.all,
      maxCount: maxCount,
      isMulti: isMulti,
      columnCount: columnCount,
      isImageCompress: isImageCompress,
      compressImageMaxWidth: compressImageMaxWidth,
      compressImageMaxHeight: compressImageMaxHeight,
      compressQuality: compressQuality,
    );
  }

  static Future<List<FileSource>> imageAndVideo({
    int maxCount = 9,
    bool isMulti = true,
    columnCount = 4,
    bool isImageCompress = true, // 是否压缩图片
    int compressImageMaxWidth = 1280, // 压缩最大宽度
    int compressImageMaxHeight = 1280, // 压缩最大高度
    int compressQuality = 90, // 压缩质量
  }) async {
    final permission = await PermissionUtils.photos();
    if (!permission) {
      showAlert("没有相册访问权限，无法选择文件");
      // return [];
    }
    return await pick(
      type: FileType.imageAndVideo,
      maxCount: maxCount,
      isMulti: isMulti,
      columnCount: columnCount,
      isImageCompress: isImageCompress,
      compressImageMaxWidth: compressImageMaxWidth,
      compressImageMaxHeight: compressImageMaxHeight,
      compressQuality: compressQuality,
    );
  }

  static Future<List<FileSource>> pick({
    FileType type = FileType.all,
    int maxCount = 9,
    bool isMulti = true,
    columnCount = 4,
    bool isImageCompress = true, // 是否压缩图片
    int compressImageMaxWidth = 1280, // 压缩最大宽度
    int compressImageMaxHeight = 1280, // 压缩最大高度
    int compressQuality = 90, // 压缩质量
  }) async {
    RequestType requestType = RequestType.all;
    switch (type) {
      case FileType.image:
        requestType = RequestType.image;
        break;
      case FileType.video:
        requestType = RequestType.video;
        break;
      case FileType.audio:
        requestType = RequestType.audio;
        break;
      case FileType.imageAndVideo:
        requestType = RequestType.common;
        break;
      case FileType.file:
        requestType = RequestType.all;
        break;
      case FileType.all:
        requestType = RequestType.all;
    }
    final List<AssetEntity>? result = await AssetPicker.pickAssets(
      contextIndex,
      pickerConfig: AssetPickerConfig(
          maxAssets: maxCount,
          requestType: requestType,
          gridCount: columnCount,
          textDelegate: const AssetPickerTextDelegate(),
          themeColor: ColorTheme.main,
          pathNameBuilder: (AssetPathEntity path) => switch (path) {
                final p when p.isAll => '最近',
                _ => path.name,
              }),
    );
    List<FileSource> list = [];
    for (final asset in result ?? []) {
      final file = await asset.file;
      dynamic thumbnailData;
      if (type == FileType.video ||
          type == FileType.image ||
          type == FileType.imageAndVideo) {
        thumbnailData = await asset.thumbnailData;
      }
      Uint8List originBytes = await asset.originBytes ?? Uint8List(0);
      String path = file?.path ?? '';
      String ext = asset.title?.split('.').last ?? '';

      if (isImageCompress) {
        if (type == FileType.image ||
            ext == 'jpg' ||
            ext == 'jpeg' ||
            ext == 'png' ||
            ext == 'webp') {
          final files = await ImageCompress.compress(originBytes,
              maxWidth: compressImageMaxWidth,
              maxHeight: compressImageMaxHeight,
              quality: compressQuality);
          originBytes = files.bytes ?? Uint8List(0);
          path = files.path ?? '';
        }
      }

      list.add(FileSource(
        path: path,
        type: type,
        bytes: originBytes,
        name: asset.title,
        mimeType: asset.mimeType,
        size: asset.size.toString(),
        ext: ext,
        id: asset.id,
        thumb: thumbnailData,
      ));
    }
    return list;
  }
}
