import 'dart:async';

import 'package:flutter/widgets.dart';

enum SlideDirection { left, right }

/// 滑动进出动画
class SlideInAndOutWidget extends StatefulWidget {
  final Widget child;
  final double? top;
  final double? bottom;
  final double endLeftPosition; // 中间动画停留位置
  final Duration duration; // 停留时间
  ///起始进入方向
  final SlideDirection startFrom;
  ///是否显示移出动画
  final bool showOutAnimation;

  const SlideInAndOutWidget({super.key,
    required this.child,
    this.top,
    this.bottom,
    this.endLeftPosition = 10.0,
    this.duration = const Duration(seconds: 2),
    this.startFrom = SlideDirection.right,
    this.showOutAnimation = true,
  });

  @override
  _SlideInAndOutWidgetState createState() => _SlideInAndOutWidgetState();
}

class _SlideInAndOutWidgetState extends State<SlideInAndOutWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
   Animation<double>? _animation;
  bool _hasBuilt = false;
  bool _isSecondPhase = false;
  late double screenWidth;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000), //进入动画持续时间
    );
    _controller.addListener(() {
      setState(() {});
    });
    if (widget.showOutAnimation) {
      _controller.addStatusListener((status) {
        if (status == AnimationStatus.completed && !_isSecondPhase) {
          Future.delayed(widget.duration, () { //停留时长
            if (mounted) {
              _fadeOutAndSlideOut();
            }
          });
        }
        if (status == AnimationStatus.dismissed) {
          // 如果需要在动画结束后移除组件，可以在这一部分添加逻辑
        }
      });
    }
  }

  initAnimation() {
    _hasBuilt = true;
    screenWidth = MediaQuery.of(context).size.width;
    double beginValue;
    Curve curve = Curves.ease;
    switch (widget.startFrom) {
      case SlideDirection.left:
        beginValue = 0.0; // 从屏幕最左边开始
        break;
      case SlideDirection.right:
        beginValue = screenWidth; // 从屏幕最右边开始
        curve = Curves.easeInCirc;
        break;
    }
    _animation = Tween<double>(begin: beginValue,
        end: widget.endLeftPosition).animate(
      CurvedAnimation(parent: _controller, curve: curve),
    );
    _controller.forward();
  }

  //继续向左移出屏幕
  void _fadeOutAndSlideOut() async {
    if (_isSecondPhase) return;
    _isSecondPhase = true;
    _animation = Tween<double>(
      begin: widget.endLeftPosition,
      end: -screenWidth,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.ease),
    );
    _controller.reset();
    await _controller.forward(); // 重新启动动画
    if (mounted) {
      setState(() {
        _animation = null; // 清理动画引用，准备下一次动画
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _animation?.removeListener(() {});
    _controller.removeStatusListener((status) {});
    _controller.removeListener(() {});
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_hasBuilt) {
      initAnimation();
    }

    return _animation == null ? Container() : AnimatedBuilder(
      animation: _animation!,
      builder: (context, child) {
        return Positioned(
          top: widget.top,
          bottom: widget.bottom,
          left: _animation!.value,
          child: widget.child,
        );
      },
    );
  }
}
