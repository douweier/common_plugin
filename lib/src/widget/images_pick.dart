import 'dart:io';

import 'package:flutter/material.dart';
import 'package:common_plugin/common_plugin.dart';

// 图片选取拖拽排序，混合网络图片列表、本地图片列表，回调返回排序的图片列表
class ImagesPickDragSort extends StatefulWidget {
  final List? imageUrls; //传入的网络图片列表
  final Future<String?> Function(String path)? onUpload; //新增本地图片后上传到服务器接口
  final int maxImageNum; //最大图片数
  final bool isCrop; //是否裁剪图片
  final double? aspectRatio; //裁剪比例
  final bool isMulti; //是否多选
  final double imageWidth; //图片宽度
  final double imageHeight; //图片高度
  final bool isShowNumWithAdd; //是否在添加图标内显示上传图片数，0/10
  final Widget? emptyIconWidget; //添加图片前显示的图标widget
  final Widget? addIconWidget; //添加图片按钮widget
  final String? textWithAdd; //添加图片按钮内文字，用于区分上传类型场景
  final bool isBorderDot; //虚线边框是否为小圆点，false为线性
  final bool isCompress; //是否压缩图片
  final int compressMaxWidth; //压缩最大宽度
  final int compressMaxHeight; //压缩最大高度
  final int compressQuality; //压缩质量
  final bool readOnly; //是否只读

  ///选取本地的图片列表回调,被删除后的网络图片列表
  final Function(List<ImageItem>) onChanged;

  const ImagesPickDragSort({
    super.key,
    this.maxImageNum = 10,
    required this.onChanged,
    this.isCrop = false,
    this.aspectRatio,
    this.isMulti = false,
    this.imageUrls,
    this.onUpload,
    this.isShowNumWithAdd = false,
    this.imageWidth = 70,
    this.imageHeight = 70,
    this.emptyIconWidget,
    this.addIconWidget,
    this.textWithAdd,
    this.readOnly = false,
    this.isBorderDot = false,
    this.isCompress = true,
    this.compressMaxWidth = 1280,
    this.compressMaxHeight = 1280,
    this.compressQuality = 90,
  });

  @override
  State<StatefulWidget> createState() => _ImagesPickDragSortState();
}

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

  void _updateCombinedList() {
    combinedImageList = (widget.imageUrls ?? [])
        .map((url) => url.trim())
        .where((url) => url.isNotEmpty)
        .map((url) => ImageItem(url, ImageSourceType.network))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    int mGridCount;
    if (widget.readOnly) {
      mGridCount = combinedImageList.length;
    } else if (combinedImageList.isEmpty) {
      mGridCount = 1;
    } else if (combinedImageList.isNotEmpty &&
        combinedImageList.length < widget.maxImageNum) {
      mGridCount = combinedImageList.length + 1;
    } else {
      mGridCount = combinedImageList.length;
    }

    if (widget.emptyIconWidget != null && combinedImageList.isEmpty) {
      return GestureDetector(
        onTap: () {
          albumImport();
        },
        child: widget.emptyIconWidget,
      );
    }

    return MediaQuery.removePadding(
      context: context,
      removeTop: true,
      removeBottom: true,
      child: GridView.count(
        shrinkWrap: true,
        primary: false,
        crossAxisCount: 4,
        physics: const NeverScrollableScrollPhysics(),
        children: List.generate(mGridCount, (index) {
          if (index == combinedImageList.length) {
            return GestureDetector(
              onTap: () {
                albumImport();
              },
              child: Center(
                child: widget.addIconWidget ??
                    DashedBorder(
                        shape: ShapeType.roundedRectangle,
                        dashGap: 5,
                        dashWidth: widget.isBorderDot ? 0.5 : 4,
                        isDot: widget.isBorderDot,
                        borderRadius: BorderRadius.circular(5),
                        child: SizedBox(
                            width: widget.imageWidth,
                            height: widget.imageHeight,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.add_rounded,
                                  color: Colors.grey,
                                  size: 35,
                                ),
                                if (widget.isShowNumWithAdd &&
                                    combinedImageList.isNotEmpty)
                                  Text(
                                    "${combinedImageList.length}/${widget.maxImageNum}",
                                    style: const TextStyle(
                                        color: Colors.grey, fontSize: 10),
                                  ),
                                if (widget.textWithAdd != null &&
                                    combinedImageList.isEmpty)
                                  Text(
                                    widget.textWithAdd!,
                                    style: const TextStyle(
                                        color: Colors.grey, fontSize: 10),
                                  )
                              ],
                            ))),
              ),
            );
          } else {
            // 被选中的图片
            return Center(
                child: draggableItem(combinedImageList[index], index));
          }
        }),
      ),
    );
  }

  //长按触发可拖动的item
  Widget draggableItem(ImageItem item, int index) {
    return LongPressDraggable(
      data: item,
      feedback: baseItem(
          item, index, Colors.lightBlue.withOpacity(0.6), item.sourceType),
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
      onDragCompleted: () {},
      child: DragTarget(
        builder: (context, candidateData, rejectedData) {
          return baseItem(
              item,
              index,
              item.sourceType == ImageSourceType.network
                  ? Colors.blue.withOpacity(0.2)
                  : Colors.white.withOpacity(0.6),
              item.sourceType);
        },
        onWillAcceptWithDetails: (moveData) {
          // 开始拖动
          var accept = moveData.data != null;
          if (accept) {
            exchangeItem(moveData.data, item, false);
          }
          return accept;
        },
        onAcceptWithDetails: (moveData) {
          // 拖动结束
          exchangeItem(moveData.data, item, true);
          // 调用回调，传递整合后的列表
          widget.onChanged(combinedImageList);
        },
        onLeave: (moveData) {},
      ),
    );
  }

  //图片item
  Widget baseItem(
      ImageItem item, int index, Color bgColor, ImageSourceType sourceType) {
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
            InkWell(
              onTap: (){
                 toNav(ImageView(imageList: [item.path],imageType: sourceType,));
              },
              child: Center(
                child: sourceType == ImageSourceType.network
                    ? ImageLoad(
                        item.path,
                        fit: BoxFit.cover,
                      )
                    : Image.file(
                        File(item.path),
                        fit: BoxFit.cover,
                      ),
              ),
            ),
            Align(
              alignment: Alignment.topRight,
              child: InkWell(
                onTap: () {
                  showDialogLayer(
                      content: "操作后不可恢复，确定删除？",
                      onOkCallBack: () {
                        combinedImageList.removeAt(index);
                        widget.onChanged.call(combinedImageList);
                        setState(() {});
                      });
                },
                child: widget.readOnly
                    ? const SizedBox()
                    : Container(
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
    });
  }

  ///相册导入
  Future albumImport() async {
    bool isOverMax = false;
    if ((combinedImageList.length) >= widget.maxImageNum) {
      showAlert("最多可上传${widget.maxImageNum}张");
      return;
    }
    if (widget.isMulti && !widget.isCrop) {
      final image = await FilePicker.image(
          maxCount: widget.maxImageNum - (combinedImageList.length),
          isCompress: widget.isCompress,
          quality: widget.compressQuality,
          maxHeight: widget.compressMaxHeight,
          maxWidth: widget.compressMaxWidth,
      );
      if (image.isNotEmpty) {
        bool uploadOk = false;
        for (var element in image) {
          if ((combinedImageList.length) < widget.maxImageNum) {
            await updateImage(path: element.path);
          } else {
            isOverMax = true;
            break;
          }
          uploadOk = true;
        }
        await awaitWhileSuccess(() async {
          return uploadOk;
        });
        if (isOverMax) {
          showAlert("最多可上传${widget.maxImageNum}张");
        }
        widget.onChanged(combinedImageList); // 通知外部更新
        setState(() {});
      }
    } else {
      final image = await FilePicker.image(
          maxCount: 1,
          isCompress: widget.isCompress,
          quality: widget.compressQuality,
          maxHeight: widget.compressMaxHeight,
          maxWidth: widget.compressMaxWidth);
      if (image.isEmpty) {
        return;
      }
      if (widget.isCrop) {
        // 裁剪
        toNav(ImageCropView(
          image: image.first.bytes!,
          aspectRatio: widget.aspectRatio,
          onCallBack: (path, image) async {
            final uploadOk = await updateImage(path: path);
            if (uploadOk) {
              widget.onChanged(combinedImageList);
              setState(() {});
            }
          },
        ));
      } else {
        final uploadOk = await updateImage(path: image.first.path);
        if (uploadOk) {
          widget.onChanged(combinedImageList);
          setState(() {});
        }
      }
    }
  }

  Future<bool> updateImage({required String? path}) async {
    if (isEmptyOrNull(path)) return false;
    if (widget.onUpload != null) {
      final uploadUrl = await widget.onUpload!(path!);
      if (!isEmptyOrNull(uploadUrl)) {
        combinedImageList.add(ImageItem(uploadUrl!, ImageSourceType.network));
        if (mounted) {
          setState(() {});
        }
        return true;
      }
    } else {
      combinedImageList.add(ImageItem(path!, ImageSourceType.local));
      if (mounted) {
        setState(() {});
      }
      return true;
    }
    return false;
  }
}
