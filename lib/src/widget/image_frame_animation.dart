
import 'package:flutter/material.dart';

/// 帧动画
class ImageFrameAnimation extends StatefulWidget {
  final List imageAssets; //图片资源列表
  final double? width; //图片宽度
  final double? height; //图片高度
  final bool isLoop; //是否循环播放,默认为false播放完一次
  ///帧数图片播放完毕后返回true
  final ValueChanged<bool>? onCompletion; //回调
  final int interval; //每帧间隔时间
  final int endInterval; //播放完间隔时间
  final bool isStart; //控制是否播放,默认为true
  final String? package; //资源包名


  const ImageFrameAnimation(this.imageAssets,
      {Key? key, this.width, this.height, this.isStart = true,this.interval = 150,this.endInterval = 0, this.onCompletion, this.isLoop = false, this.package}) : super(key: key);


  @override
  ImageFrameAnimationState createState() => ImageFrameAnimationState();

}

class ImageFrameAnimationState extends State<ImageFrameAnimation>
    with SingleTickerProviderStateMixin {
 late Animation<double> _animation;
 late AnimationController _controller;
  late int interval;

  @override
  void initState() {
    super.initState();

      interval = widget.interval;
    final int imageCount = widget.imageAssets.length;
    final int maxTime = interval * imageCount;

    // 动画start
    _controller = AnimationController(
        duration: Duration(milliseconds: maxTime), vsync: this);
    _controller.addStatusListener((AnimationStatus status) async {
      if (status == AnimationStatus.completed) {
        if (widget.isLoop) {
           if (widget.endInterval > 0){
             await Future.delayed(Duration(milliseconds: widget.endInterval), () {
               WidgetsBinding.instance.addPostFrameCallback((_) {
                 if (mounted) {
                   _controller.forward(from: 0.0);
                 }
               });
            });
           }else{
            _controller.forward(from: 0.0);
          }
        } else {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (widget.onCompletion != null && mounted) {
              widget.onCompletion?.call(true);
            }
          });
        }
      }
    });

    _animation = Tween<double>(begin: 0, end: imageCount.toDouble())
        .animate(_controller)
      ..addListener(() {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            setState(() {});
          }
        });
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(ImageFrameAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isStart != oldWidget.isStart) {
      if (widget.isStart) {
        _controller.forward();
      } else {
        _controller.stop();
      }
    }
  }

  stop() {
    _controller.stop();
  }

  start() {
    _controller.forward();
  }


 @override
 Widget build(BuildContext context) {
   // 判断是否开始动画
   if (widget.isStart) {
     start();
   } else {
     stop();
   }
   // 当图片列表为空时，避免执行动画逻辑
   if (widget.imageAssets.isEmpty) {
     return Container(); // 可以替换为适当的提示信息
   }

   int ix = _animation.value.floor() % widget.imageAssets.length;
   List<Widget> images = [];
   for (int i = 0; i < widget.imageAssets.length; ++i) {
     if (i != ix) {
       images.add(Image.asset(
         widget.imageAssets[i],
         width: 0,
         height: 0,
         package: widget.package,
       ));
     }
   }
   images.add(Image.asset(
     widget.imageAssets[ix],
     width: widget.width,
     height: widget.height,
     package: widget.package,
   ));


   return Stack(alignment: AlignmentDirectional.center, children: images);
 }
}