import 'package:common_plugin/src/theme/theme.dart';
import 'package:flutter/material.dart';

/// 圆点闪烁动画，用于头像在线状态
class DotFlashAnimation extends StatefulWidget {
  final Duration duration;
  final double width;
  final double height;
  final Color? color;
  final Color? color2;
  final bool isChangeColor; //是否变色动画

  const DotFlashAnimation({
    Key? key,
    this.duration = const Duration(milliseconds: 1000),
    this.width = 8,
    this.height = 8,
    this.color,
    this.color2,
    this.isChangeColor = true,
  }) : super(key: key);

  @override
  _DotFlashAnimationState createState() => _DotFlashAnimationState();
}

class _DotFlashAnimationState extends State<DotFlashAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  late Animation<Color?> _colorAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    _animation = Tween<double>(begin: 1, end: 0.4).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
    // 添加一个监听器来在动画结束时重启动画
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _controller.reverse(); // 当动画完成正向播放时，反向播放
      } else if (status == AnimationStatus.dismissed) {
        _controller.forward(); // 当动画完成反向播放时，正向播放
      }
    });
    _controller.forward();

    ColorTween _colorTween = ColorTween(
      begin: widget.color ?? ColorTheme.green,
      end: widget.color2 ?? ColorTheme.mainLight, // 如果isChangeColor为true，则切换到白色，否则保持不变
    );
    _colorAnimation = _colorTween.animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _controller.removeStatusListener((status) {});
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.scale(
          scale: _animation.value,
          child: Container(
            width: widget.width,
            height: widget.height,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _colorAnimation.value,
            ),
          ),
        );
      },
    );
  }
}
