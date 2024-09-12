
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:images_picker/images_picker.dart';
import 'package:common_plugin/common_plugin.dart';

// 图片选取拖拽排序，混合网络图片列表、本地图片列表，回调返回排序的图片列表
class ImagesPickDragSort extends StatefulWidget {
  final List? imageUrls; //传入的网络图片列表
  final int maxImageNum; //最大图片数
  final bool isCrop; //是否裁剪图片
  final double? aspectRatio; //裁剪比例
  final bool isMulti; //是否多选
  final double imageWidth; //图片宽度
  final double imageHeight; //图片高度
  final Widget? emptyIconWidget; //添加图片前显示的图标widget
  final Widget? addIconWidget; //添加图片按钮widget

  ///选取本地的图片列表回调,被删除后的网络图片列表
  final Function(List<ImageItem>) onChanged;

  const ImagesPickDragSort({
    super.key,
    this.maxImageNum = 5,
    required this.onChanged,
    this.isCrop = false,
    this.aspectRatio,
    this.isMulti = false,
    this.imageUrls,
    this.imageWidth = 70,
    this.imageHeight = 70,
    this.emptyIconWidget,
    this.addIconWidget,
  }) : assert(maxImageNum > 0);

  @override
  _ImagesPickDragSortState createState() => _ImagesPickDragSortState();
}

// 图片来源
enum ImageSourceType { network, local }

class ImageItem {
  final String path;
  final ImageSourceType sourceType;

  ImageItem(this.path, this.sourceType);
}

class _ImagesPickDragSortState extends State<ImagesPickDragSort> {
  ImageItem? _movingValue; //正在拖拽的图片
  List<ImageItem> combinedImageList = []; // 混合网络图片列表、本地图片列表


  @override
  void initState() {
    if (widget.imageUrls != null) {
      _updateCombinedList();
    }
    super.initState();
  }

  // @override
  // void didUpdateWidget(ImagesPickDragSort oldWidget) {
  //   super.didUpdateWidget(oldWidget);
  //   if (widget != oldWidget && widget.imageUrls != null) {
  //     _updateCombinedList();
  //     setState(() {});
  //   }
  // }

  void _updateCombinedList() {
    combinedImageList = widget.imageUrls?.map((url) => ImageItem(url, ImageSourceType.network)).toList() ?? [];
  }

  @override
  Widget build(BuildContext context) {


    int mGridCount;
    if (combinedImageList.length == 0) {
      mGridCount = 1;
    } else if (combinedImageList.length > 0 &&
        combinedImageList.length < widget.maxImageNum) {
      mGridCount = combinedImageList.length + 1;
    } else {
      mGridCount = combinedImageList.length;
    }

    if (widget.emptyIconWidget != null && combinedImageList.isEmpty){
      return GestureDetector(
        onTap: () {
          albumImport();
        },
        child: widget.emptyIconWidget,
      );
    }

    return GridView.count(
      shrinkWrap: true,
      primary: false,
      crossAxisCount: 4,
      physics: NeverScrollableScrollPhysics(),
      children: List.generate(mGridCount, (index) {
        if (index == combinedImageList.length) {
          return GestureDetector(
            onTap: () {
              albumImport();
            },
            child:Center(
              child: widget.addIconWidget ?? Image.asset("assets/images/add_menu.png",package: "common_plugin",
                width: widget.imageWidth,
                height: widget.imageHeight,
                fit: BoxFit.cover,
              ),
            ),
          );
        } else {
          // 被选中的图片
          return Center(child: draggableItem(combinedImageList[index], index));
        }
      }),
    );
  }

  //长按触发可拖动的item
  Widget draggableItem(ImageItem item, int index) {
    return LongPressDraggable(
      data: item,
      child: DragTarget(
        builder: (context, candidateData, rejectedData) {
          return baseItem(item, index, item.sourceType == ImageSourceType.network ? Colors.blue.withOpacity(0.2) : Colors.white.withOpacity(0.6), item.sourceType);
        },
        onWillAcceptWithDetails: (moveData) {
          var accept = moveData.data != null;
          if (accept) {
            exchangeItem(moveData.data, item, false);
          }
          return accept;
        },
        onAcceptWithDetails: (moveData) {

          exchangeItem(moveData.data, item, true);
        },
        onLeave: (moveData) {

        },
      ),
      feedback: baseItem(item, index,Colors.lightBlue.withOpacity(0.6), item.sourceType),
      childWhenDragging: null,
      onDragStarted: () {
        setState(() {
          _movingValue = item;
        });
      },
      onDraggableCanceled: (Velocity velocity, Offset offset) {
        setState(() {
          _movingValue = null;
        });
      },
      onDragCompleted: () {
      },
    );
  }

  //图片item
  Widget baseItem(ImageItem item, int index, Color bgColor, ImageSourceType sourceType) {
    if (item == _movingValue) {
      return Container();
    }
    return Material(
      color: Colors.transparent,
      child: Container(
        width: widget.imageWidth,
        height: widget.imageHeight,
        margin: const EdgeInsets.all(5.0),
        decoration: BoxDecoration(
          color: bgColor,
        ),
        child: Stack(
          children: <Widget>[
            Center(
              child: sourceType == ImageSourceType.network
                  ? CachedNetworkImage(
                imageUrl: item.path,
                fit: BoxFit.cover,
              )
                  : Image.file(
                File(item.path),
                fit: BoxFit.cover,
              ),
            ),
            Align(
              alignment: Alignment.topRight,
              child: InkWell(
                onTap: () {
                  showDialogLayer(content: "操作后不可恢复，确定删除？",onOkCallBack: (){
                    combinedImageList.removeAt(index);
                    widget.onChanged.call(combinedImageList);
                    setState(() {});
                  });
                },
                child: Container(
                  padding: const EdgeInsets.all(3.0),
                  margin: const EdgeInsets.all(2.0),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.4),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.close_rounded, // 删除图标
                    size: 18,
                    color: Colors.white,
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  // 重新排序
  void exchangeItem(moveData, toData, onAccept) {
    setState(() {
      var toIndex = combinedImageList.indexOf(toData);

      combinedImageList.remove(moveData);
      combinedImageList.insert(toIndex, moveData);

      if (onAccept) {
        _movingValue = null;
      }
        // 调用回调，传递整合后的列表
        widget.onChanged(combinedImageList);
    });
  }

  ///相册导入
  Future albumImport() async {
    bool _isOverMax = false;
    if ((combinedImageList.length) >= widget.maxImageNum) {
      showAlert("最多可上传${widget.maxImageNum}张");
      return;
    }
    if (widget.isMulti && !widget.isCrop) {
      List<Media>? image = await ImagesPicker.pick(pickType: PickType.image,count: widget.maxImageNum - (combinedImageList.length));
      if (image != null) {
        bool uploadOk = false;
        image.forEach((element) async {
          if ((combinedImageList.length) < widget.maxImageNum) {
            combinedImageList.add(ImageItem(element.path, ImageSourceType.local));
            widget.onChanged(combinedImageList); // 通知外部更新
          } else {
            _isOverMax = true;
          }
          uploadOk = true;
        });
        await awaitSuccess(() {
          return uploadOk;
        });
        if (_isOverMax) {
          showAlert("最多可上传${widget.maxImageNum}张");
        }
        setState(() {});
      }
    }else{
      List<Media>? image = await ImagesPicker.pick(pickType: PickType.image,count: 1);
      if (image == null){ return;}

      if (widget.isCrop){ // 裁剪
       openTo(CropImageView(
         path: image.first.path,
         aspectRatio: widget.aspectRatio,
         onCallBack: (path,image) async {
           if ((combinedImageList.length) < widget.maxImageNum) {
             combinedImageList.add(ImageItem(path, ImageSourceType.local));
             widget.onChanged(combinedImageList); // 通知外部更新
           } else {
             showAlert("最多可上传${widget.maxImageNum}张");
           }
           setState(() {});
         },
       ));
       return;
      } else {
        if ((combinedImageList.length) < widget.maxImageNum) {
          combinedImageList.add(
              ImageItem(image.first.path, ImageSourceType.local));
          widget.onChanged(combinedImageList); // 通知外部更新
        } else {
          showAlert("最多可上传${widget.maxImageNum}张");
        }
        setState(() {});
      }
    }
  }
}
