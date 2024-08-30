import 'dart:io';
import 'dart:typed_data';

import 'package:common_plugin/common_plugin.dart';
import 'package:crop_your_image/crop_your_image.dart';
import 'package:flutter/material.dart';
import 'package:images_picker/images_picker.dart';
import 'package:path_provider/path_provider.dart';

// 裁剪图片,本地图片或Uint8List如果都为空则打开本地图片选取
class CropImageView extends StatefulWidget {
 final String? path;
 final Uint8List? image;
 final String toolbarTitle; // 顶部标题
 final double? aspectRatio; // 裁剪比例，宽高比，1.0为正方形,4/3为4:3，16/9为16:9
 final Function(String path,Uint8List image)? onCallBack;  // 回调返回裁剪后的图片，如不填写将pop返回文件路径
  const CropImageView({Key? key,
    this.image,
    this.path,
    this.toolbarTitle = "裁剪图片",
    this.onCallBack,
    this.aspectRatio,
  }) : super(key: key);

  @override
  State<CropImageView> createState() => _CropImageViewState();
}

class _CropImageViewState extends State<CropImageView> {

  final _cropController = CropController();
  Uint8List? image;
  double? aspectRatio;

  bool _isCropVisible = true;

  void _updateAspectRatio(double newAspectRatio) {
    setState(() {
       if (newAspectRatio == 0){
         Navigator.pop(context);
         openTo(CropImageView(
           path: widget.path,
           image: widget.image,
           toolbarTitle: widget.toolbarTitle,
           onCallBack: widget.onCallBack,
         ));
      }
      aspectRatio = newAspectRatio;
      _isCropVisible = false;
    });

    // 使用延迟10秒后再显示Crop组件，确保比例更新生效
    Future.delayed(Duration(milliseconds:20),(){
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
    if (widget.path != null){
      File imgFile = File(widget.path!);
      image = Uint8List.fromList(await imgFile.readAsBytes());
    }else{
      image = widget.image;
    }
    if (widget.path == null && widget.image == null){
      if (image == null){
        List<Media>? imagePick = await ImagesPicker.pick(pickType: PickType.image,count: 1);
        if (imagePick == null){
          Navigator.pop(context);
          return;
        }
        File imgFile = File(imagePick.first.path);
        image = Uint8List.fromList(await imgFile.readAsBytes());
      }
    }
    setState(() {});
  }



  @override
  Widget build(BuildContext context) {
    if (image == null){
      return Container();
    };

    return AppView(
      title: widget.toolbarTitle,
      backgroundColor: Colors.black,
      actions: [
        ButtonView(
          text: "确定",
          width: 80,
          height: 30,
          margin: EdgeInsets.only(right: 10),
          onPressed: () async {
            _cropController.crop();
          },
        ),
      ],
      body: Container(
        child: Column(
          children: [
            Expanded(
              child: !_isCropVisible ? Container() : Crop(
                onCropped: (image) async {
                  //图片大小不能低于20kb
                  if (image.lengthInBytes < 20 * 1024){
                    showAlert("图片过小，请重新裁剪");
                    return;
                  }
                  final String dir = (await getTemporaryDirectory()).path;
                  final String fullPath = '$dir/${DateTime.now().millisecond}.png';
                  File capturedFile = File(fullPath);
                  await capturedFile.writeAsBytes(image);
                  if (widget.onCallBack != null){
                    widget.onCallBack!(capturedFile.path,image);
                    Navigator.of(context).pop(capturedFile.path);
                  } else{
                    Navigator.of(context).pop(capturedFile.path);
                  }
                },
                image: image!,
                controller: _cropController,
                withCircleUi: false,
                baseColor: ColorTheme.black, // 背景色
                aspectRatio: aspectRatio,
                fixCropRect: false,
                interactive: true,
                willUpdateScale: (scale){
                  if (scale < 0.5 || scale > 2.0){
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
                        child: TextView("自由",color: Colors.white,fontSize: 14,),
                      ),
                    ),
                    // 1:1
                    InkWell(
                      onTap: () {
                        _updateAspectRatio(1/1);
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
                        child: TextView("1:1",color: Colors.white,fontSize: 8,),
                      ),
                    ),
                    // 4:3
                    InkWell(
                      onTap: () {
                        _updateAspectRatio(4/3);
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
                        child: TextView("4:3",color: Colors.white,fontSize: 8,),
                      ),
                    ),
                    // 3:4
                    InkWell(
                      onTap: () {
                        _updateAspectRatio(3/4);
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
                        child: TextView("3:4",color: Colors.white,fontSize: 8,),
                      ),
                    ),
                    // 9:16
                    InkWell(
                      onTap: () {
                        _updateAspectRatio(9/16);
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
                        child: TextView("9:16",color: Colors.white,fontSize: 8,),
                      ),
                    ),
                    // 16:9
                    InkWell(
                      onTap: () {
                        _updateAspectRatio(16/9);
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
                        child: TextView("16:9",color: Colors.white,fontSize: 8,),
                      ),
                    ),
                    // 3:2
                    InkWell(
                      onTap: () {
                        _updateAspectRatio(3/2);
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
                        child: TextView("3:2",color: Colors.white,fontSize: 8,),
                      ),
                    ),
                    // 2:3
                    InkWell(
                      onTap: () {
                        _updateAspectRatio(2/3);
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
                        child: TextView("2:3",color: Colors.white,fontSize: 8,),
                      ),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

