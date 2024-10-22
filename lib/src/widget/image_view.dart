import 'dart:async';
import 'dart:io';
import 'package:common_plugin/common_plugin.dart';
import 'package:flutter/material.dart';

/// 图片预览, 支持本地图片、网络图片、文件图片, 支持双击放大缩小, 支持手势缩放、平移、拖拽，外界可自由控制指定索引图片浏览，支持自动播放、停止播放、播放指示器等
class ImageView extends StatefulWidget {
  final List imageList; // 图片列表
  final ImageSourceType imageType; // 对应 imageList 的类型
  final int initialIndex; // 初始索引
  final Widget? bottomButtonWidget; // 底部按钮
  final void Function(int index)? onChanged; // 图片切换回调
  final ImageViewController? controller; // 控制器
  final bool autoPlay; // 是否自动播放
  final Duration autoPlayInterval; // 播放间隔

  const ImageView({
    super.key,
    required this.imageList,
    this.imageType = ImageSourceType.network,
    this.initialIndex = 0,
    this.bottomButtonWidget,
    this.onChanged,
    this.controller,
    this.autoPlay = false,
    this.autoPlayInterval = const Duration(seconds: 3),
  });

  @override
  State<ImageView> createState() => _ImageViewState();
}

// 图片来源
enum ImageSourceType { network, local, asset }

class ImageViewController {
  _ImageViewState? _imageViewState;

  void _bindState(_ImageViewState state) {
    _imageViewState = state;
  }

  void jumpToIndex(int index) {
    _imageViewState?._jumpToIndex(index);
  }

  void startAutoPlay(Duration interval) {
    _imageViewState?._startAutoPlay(interval);
  }

  void stopAutoPlay() {
    _imageViewState?._stopAutoPlay();
  }
}

class _ImageViewState extends State<ImageView> {
  late PageController _pageController;
  int _currentIndex = 0;
  TransformationController transformationController =
      TransformationController();
  TapDownDetails? doubleTapDetails;
  Timer? _autoPlayTimer;
  bool isAutoPlaying = false;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
    widget.controller?._bindState(this); // 绑定控制器

    if (widget.autoPlay) {
      _startAutoPlay(widget.autoPlayInterval);
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    transformationController.dispose();
    _stopAutoPlay();
    super.dispose();
  }

  Widget _buildImage(String path, ImageSourceType type) {
    switch (type) {
      case ImageSourceType.asset:
        return Image.asset(path, fit: BoxFit.contain);
      case ImageSourceType.local:
        return Image.file(File(path), fit: BoxFit.contain);
      case ImageSourceType.network:
        return ImageLoad(path, fit: BoxFit.contain);
      default:
        return Container();
    }
  }

  void _handleDoubleTap() {
    if (transformationController.value != Matrix4.identity()) {
      // 如果已经放大，则重置为初始状态
      transformationController.value = Matrix4.identity();
    } else {
      if (doubleTapDetails != null) {
        // 捕捉到双击位置，以双击位置为中心放大
        final position = doubleTapDetails!.localPosition;
        const scale = 2.0;
        final x = -position.dx * (scale - 1);
        final y = -position.dy * (scale - 1);

        transformationController.value = Matrix4.identity()
          ..translate(x, y)
          ..scale(scale);
      } else {
        // 如果没有捕捉到双击位置，则默认放大于图片中心
        transformationController.value = Matrix4.identity()
          ..translate(-(screenSize.width) / 2, (-screenSize.height) / 2)
          ..scale(2.0);
      }
    }
  }

  void _jumpToIndex(int index) {
    if (index >= 0 && index < widget.imageList.length) {
      _currentIndex = index;
      if (isAutoPlaying && index == 0) {
        // 从最后一张跳转到第一张时，animateToPage方法存在问题无法解决，采用无动画跳转
        _pageController.jumpToPage(index);
      } else {
        _pageController.animateToPage(
          index,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
      setState(() {});
    }
  }

  void _startAutoPlay(Duration interval) {
    _autoPlayTimer?.cancel();
    _autoPlayTimer = Timer.periodic(interval, (timer) {
      int nextIndex = _currentIndex;
      if (_currentIndex == widget.imageList.length - 1) {
        nextIndex = 0;
      } else {
        nextIndex++;
      }
      isAutoPlaying = true;
      _jumpToIndex(nextIndex);
    });
  }

  void _stopAutoPlay() {
    _autoPlayTimer?.cancel();
    _autoPlayTimer = null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: () => Navigator.of(context).pop(),
        child: Stack(
          children: [
            PageView.builder(
              controller: _pageController,
              itemCount: widget.imageList.length,
              onPageChanged: (index) {
                if (isAutoPlaying) {
                  isAutoPlaying = false;
                } else {
                  // 用户手动切换，停止自动播放
                  _stopAutoPlay();
                }

                if (widget.onChanged != null) {
                  widget.onChanged!(index);
                }
                setState(() {
                  _currentIndex = index;
                });
              },
              itemBuilder: (context, index) {
                return GestureDetector(
                  onDoubleTapDown: (details) {
                    doubleTapDetails = details;
                  },
                  onDoubleTap: _handleDoubleTap,
                  child: InteractiveViewer(
                    transformationController: transformationController,
                    panEnabled: true,
                    scaleEnabled: true,
                    child:
                        _buildImage(widget.imageList[index], widget.imageType),
                  ),
                );
              },
            ),
            if (widget.imageList.length > 1)
              Positioned(
                bottom: 70, // 调整指示器位置
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(widget.imageList.length, (index) {
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      width: _currentIndex == index ? 10 : 6,
                      height: _currentIndex == index ? 10 : 6,
                      decoration: BoxDecoration(
                        color: _currentIndex == index
                            ? Colors.white
                            : Colors.white54,
                        shape: BoxShape.circle,
                      ),
                    );
                  }),
                ),
              ),
            Positioned(
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
                child: SizedBox(
                    width: screenSize.width,
                    child: Center(
                        child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (widget.bottomButtonWidget != null)
                          Padding(
                            padding: const EdgeInsets.only(right: 15),
                            child: widget.bottomButtonWidget!,
                          ),
                        // if (widget.imageType != ImageSourceType.local)
                        //  ButtonView(
                        //    onPressed: () {
                        //      _downloadImage(
                        //        widget.imageList[_currentIndex],
                        //        widget.imageType,
                        //      );
                        //    },
                        //    text: '下载',
                        //    backgroundColor: Colors.white.withOpacity(0.2),
                        //    icon: const Icon(Icons.downloading,color: Colors.white,size: 20,),
                        //    width: 110,
                        //    height: 35,
                        //    margin: const EdgeInsets.only(right: 15),
                        //    fontColor: Colors.white,
                        //  ),
                      ],
                    )))),
            Positioned(
              bottom: MediaQuery.of(context).viewInsets.bottom + 10,
              child: ButtonBack(
                backgroundColor: Colors.white.withOpacity(0.2),
                iconColor: Colors.white,
                showRoundBackground: true,
                shadowShow: false,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
