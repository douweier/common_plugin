import 'dart:io';
import 'dart:typed_data';

import 'package:common_plugin/common_plugin.dart';
import 'package:crop_your_image/crop_your_image.dart';
import 'package:flutter/material.dart';

/// 裁剪图片,本地图片或Uint8List如果都为空则打开本地图片选取
class ImageCropView extends StatefulWidget {
  final String? path;
  final Uint8List? image;
  final String toolbarTitle; // 顶部标题
  /// 裁剪比例，宽高比，1.0为正方形,4/3为4:3，16/9为16:9
  final double? aspectRatio;
  final Function(String path, Uint8List image)?
      onCallBack; // 回调返回裁剪后的图片，如不填写将pop返回文件路径
  final bool isCompress; // 是否压缩图片
  final int compressMaxWidth; // 压缩最大宽度
  final int compressMaxHeight; // 压缩最大高度
  final int compressQuality; // 压缩质量

  const ImageCropView({
    super.key,
    this.image,
    this.path,
    this.toolbarTitle = "裁剪图片",
    this.onCallBack,
    this.aspectRatio,
    this.isCompress = true,
    this.compressMaxWidth = 1280,
    this.compressMaxHeight = 1280,
    this.compressQuality = 90,
  });

  @override
  State<ImageCropView> createState() => _ImageCropViewState();
}

class _ImageCropViewState extends State<ImageCropView> {
  final _cropController = CropController();
  Uint8List? image;
  double? aspectRatio;

  bool _isCropVisible = true;
  bool isSubmit = false; // 是否点了提交

  void _updateAspectRatio(double newAspectRatio) {
    setState(() {
      if (newAspectRatio == 0) {
        Navigator.pop(context);
        toNav(ImageCropView(
          path: widget.path,
          image: widget.image,
          toolbarTitle: widget.toolbarTitle,
          onCallBack: widget.onCallBack,
          isCompress: widget.isCompress,
          compressMaxWidth: widget.compressMaxWidth,
          compressMaxHeight: widget.compressMaxHeight,
        ));
      }
      aspectRatio = newAspectRatio;
      _isCropVisible = false;
    });

    // 使用延迟100毫秒后再显示Crop组件，确保比例更新生效
    Future.delayed(const Duration(milliseconds: 100), () {
      setState(() {
        _isCropVisible = true;
      });
    });
  }

  @override
  void initState() {
    super.initState();
    init();
  }

  init() async {
    aspectRatio = widget.aspectRatio;
    if (widget.path != null) {
      File imgFile = File(widget.path!);
      image = Uint8List.fromList(await imgFile.readAsBytes());
    } else if (widget.image != null) {
      image = widget.image;
    } else if (widget.path == null && widget.image == null) {
      if (image == null) {
        final imagePick = await FilePicker.image(maxCount: 1, isCompress: false);
        if (isEmptyOrNull(imagePick)) {
            Navigator.pop(context);
          return;
        }
        image = imagePick.first.bytes;
      }
    }
    if (widget.isCompress) {
      final files = await ImageCompress.compress(image!,
          maxWidth: widget.compressMaxWidth,
          maxHeight: widget.compressMaxHeight,
          quality: widget.compressQuality
      );
      image = files.bytes;
    }
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    if (image == null) {
      return const LoadingPage(backgroundColor: Colors.black,);
    }
    ;

    return AppView(
      title: widget.toolbarTitle,
      backgroundColor: Colors.black,
      actions: [
        ButtonView(
          text: "确定",
          isDisable: isSubmit,
          width: 80,
          height: 30,
          backgroundColor:
              _isCropVisible ? ColorTheme.main : ColorTheme.background,
          margin: const EdgeInsets.only(right: 10),
          onPressed: () async {
            if (isSubmit) {
              return;
            }
            if (!_isCropVisible) {
              showAlert("等待图片加载完成");
              return;
            }
            setState(() {
              isSubmit = true;
            });
            showAlert("正在裁剪中...");
            _cropController.crop();
          },
        ),
      ],
      body: Column(
        children: [
          Expanded(
            child: !_isCropVisible
                ? Container()
                : Crop(
                    onCropped: (image) async {
                      //图片大小不能低于20kb
                      if (image.lengthInBytes < 20 * 1024) {
                        showAlert("图片过小，请重新裁剪");
                        return;
                      }
                      final path = await ImageCompress.saveFile(image, "jpg");
                      if (widget.onCallBack != null) {
                        widget.onCallBack!(path ?? "", image);
                        Navigator.of(context).pop(path);
                      } else {
                        Navigator.of(context).pop(path);
                      }
                    },
                    image: image!,
                    controller: _cropController,
                    withCircleUi: false,
                    baseColor: ColorTheme.black, // 背景色
                    aspectRatio: aspectRatio,
                    fixCropRect: false,
                    interactive: true,
                    progressIndicator: const LoadingPage(
                      text: "图像加载中...",
                      showAppScaffold: false,
                    ),
                    willUpdateScale: (scale) {
                      if (scale < 0.5 || scale > 2.0) {
                        return false;
                      }
                      return true;
                    },
                  ),
          ),
          if (widget.aspectRatio == null)
            Padding(
              padding: const EdgeInsets.all(15),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    // 自由
                    InkWell(
                      onTap: () {
                        _updateAspectRatio(0);
                      },
                      child: Container(
                        width: 40,
                        height: 30,
                        margin: EdgeInsets.symmetric(horizontal: 10),
                        alignment: Alignment.center,
                        padding: EdgeInsets.all(3),
                        child: TextView(
                          "自由",
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    // 1:1
                    InkWell(
                      onTap: () {
                        _updateAspectRatio(1 / 1);
                      },
                      child: Container(
                        width: 30,
                        height: 30,
                        margin: EdgeInsets.symmetric(horizontal: 10),
                        alignment: Alignment.center,
                        padding: EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          border: Border.all(
                            width: 2,
                            color: ColorTheme.main,
                          ),
                        ),
                        child: TextView(
                          "1:1",
                          color: Colors.white,
                          fontSize: 8,
                        ),
                      ),
                    ),
                    // 4:3
                    InkWell(
                      onTap: () {
                        _updateAspectRatio(4 / 3);
                      },
                      child: Container(
                        width: 40,
                        height: 30,
                        margin: EdgeInsets.symmetric(horizontal: 10),
                        alignment: Alignment.center,
                        padding: EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          border: Border.all(
                            width: 2,
                            color: ColorTheme.main,
                          ),
                        ),
                        child: TextView(
                          "4:3",
                          color: Colors.white,
                          fontSize: 8,
                        ),
                      ),
                    ),
                    // 3:4
                    InkWell(
                      onTap: () {
                        _updateAspectRatio(3 / 4);
                      },
                      child: Container(
                        width: 30,
                        height: 40,
                        margin: EdgeInsets.symmetric(horizontal: 10),
                        alignment: Alignment.center,
                        padding: EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          border: Border.all(
                            width: 2,
                            color: ColorTheme.main,
                          ),
                        ),
                        child: TextView(
                          "3:4",
                          color: Colors.white,
                          fontSize: 8,
                        ),
                      ),
                    ),
                    // 9:16
                    InkWell(
                      onTap: () {
                        _updateAspectRatio(9 / 16);
                      },
                      child: Container(
                        width: 22.5, //根据宽高比例计算出宽度，宽高最大为40
                        height: 40,
                        margin: EdgeInsets.symmetric(horizontal: 10),
                        alignment: Alignment.center,
                        padding: EdgeInsets.all(1),
                        decoration: BoxDecoration(
                          border: Border.all(
                            width: 2,
                            color: ColorTheme.main,
                          ),
                        ),
                        child: TextView(
                          "9:16",
                          color: Colors.white,
                          fontSize: 8,
                        ),
                      ),
                    ),
                    // 16:9
                    InkWell(
                      onTap: () {
                        _updateAspectRatio(16 / 9);
                      },
                      child: Container(
                        width: 40,
                        height: 22.5,
                        margin: EdgeInsets.symmetric(horizontal: 10),
                        alignment: Alignment.center,
                        padding: EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          border: Border.all(
                            width: 2,
                            color: ColorTheme.main,
                          ),
                        ),
                        child: TextView(
                          "16:9",
                          color: Colors.white,
                          fontSize: 8,
                        ),
                      ),
                    ),
                    // 3:2
                    InkWell(
                      onTap: () {
                        _updateAspectRatio(3 / 2);
                      },
                      child: Container(
                        width: 40,
                        height: 26.6,
                        margin: EdgeInsets.symmetric(horizontal: 10),
                        alignment: Alignment.center,
                        padding: EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          border: Border.all(
                            width: 2,
                            color: ColorTheme.main,
                          ),
                        ),
                        child: TextView(
                          "3:2",
                          color: Colors.white,
                          fontSize: 8,
                        ),
                      ),
                    ),
                    // 2:3
                    InkWell(
                      onTap: () {
                        _updateAspectRatio(2 / 3);
                      },
                      child: Container(
                        width: 26.6,
                        height: 40,
                        margin: EdgeInsets.symmetric(horizontal: 10),
                        alignment: Alignment.center,
                        padding: EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          border: Border.all(
                            width: 2,
                            color: ColorTheme.main,
                          ),
                        ),
                        child: TextView(
                          "2:3",
                          color: Colors.white,
                          fontSize: 8,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
        ],
      ),
    );
  }
}
