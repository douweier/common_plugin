import 'package:flutter/material.dart';

/// 动画组件，可以在任何需要动画的地方轻松添加动画效果，而无需重复编写动画控制器和监听器的代码。
/// 只需传递起始值、结束值、持续时间和构建器函数，即可实现复杂的动画效果。
class AnimateView extends StatefulWidget {
  final AnimateController? controller; // 动画控制器，用于控制动画的开始、暂停和结束
  final double beginValue; // 动画的起始值
  final double endValue; // 动画的结束值
  final Duration duration; // 动画的持续时间
  final Widget Function(double value) builder; // 构建器函数，用于根据动画值构建动画效果的部件
  final Curve curve; // 动画的曲线，用于控制动画的速度变化

  const AnimateView({
    super.key,
    required this.beginValue,
    required this.endValue,
    required this.builder,
    this.controller,
    this.duration = const Duration(milliseconds: 500),
    this.curve = Curves.easeInOut,
  });

  @override
  State<AnimateView> createState() => _AnimateViewState();
}

class AnimateController {
  _AnimateViewState? _animateViewState;

  void _bindState(_AnimateViewState state) {
    _animateViewState = state;
  }

  /// 暂停动画
  void stop() {
    _animateViewState?._controller.stop();
  }

  /// 开始动画
  void start() {
    if (_animateViewState != null) {
      if (_animateViewState?._controller.status == AnimationStatus.completed) {
        _animateViewState?._controller.reset();
      }
      _animateViewState?._controller.forward();
    }
  }

  /// 反转动画
  void reverse() {
    _animateViewState?._controller.reverse();
  }

  /// 重置动画
  void reset() {
    _animateViewState?._controller.reset();
  }

}

class _AnimateViewState extends State<AnimateView> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation _animation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    Tween tween;
    try {
      tween = Tween(begin: widget.beginValue, end: widget.endValue);
    } catch (e) {
      throw FlutterError('无法创建 Tween。请确保 T 支持 Tween 动画。');
    }

    // 使用曲线包装 AnimationController
    final curvedAnimation = CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    );

    widget.controller?._bindState(this);

    _animation = tween.animate(curvedAnimation);

    // 启动动画
    _controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) => widget.builder(_animation.value),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}