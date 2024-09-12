import 'package:flutter/material.dart';

/// 直播中头像动画
class LiveAvatarAnimation extends StatefulWidget {
  final Widget child; // 传入的圆形头像Widget
  final bool isAnimation; // 是否显示动画
  final Color borderColor; // 边框颜色

  const LiveAvatarAnimation({super.key, required this.child, this.isAnimation = true, this.borderColor = Colors.red});

  @override
  _LiveAvatarAnimationState createState() => _LiveAvatarAnimationState();
}

class _LiveAvatarAnimationState extends State<LiveAvatarAnimation>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  late final Animation<double> _borderRadiusAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimation();
  }

  // 动画设置抽离
  void _setupAnimation() {
    if (widget.isAnimation) {
      _animationController = AnimationController(
        duration: const Duration(seconds: 2),
        vsync: this,
      );
      _borderRadiusAnimation = Tween<double>(begin: 1, end: 0).animate(
        CurvedAnimation(
          parent: _animationController,
          curve: Curves.linearToEaseOut,
        ),
      );
      _animationController.repeat();
    }
  }

  @override
  void dispose() {
    if (widget.isAnimation) {
      _animationController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isAnimation) {
      return widget.child;
    }
    return AnimatedBuilder(
      animation: _animationController,
      builder: (BuildContext context, Widget? child) {
        return Padding(
          padding: EdgeInsets.all(_borderRadiusAnimation.value * 5),
          child: Container(
            padding: EdgeInsets.all(_borderRadiusAnimation.value * 5),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: widget.borderColor.withOpacity(_borderRadiusAnimation.value),
                width: _borderRadiusAnimation.value * 2.0, // 边框宽度随动画变化
              ),
            ),
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: widget.borderColor,
                  width: 2.0, // 边框宽度随动画变化
                ),
              ),
              child: widget.child,
            ),
          ),
        );
      },
    );
  }
}
