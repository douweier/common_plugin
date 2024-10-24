import 'package:common_plugin/common_plugin.dart';
import 'package:flutter/material.dart';

/// 自定义开关，可以自由设置轨道高度，鼠标移入、触摸过度动画
class SwitchView extends StatefulWidget {
  const SwitchView({
    super.key,
    this.trackHeight = 15.0,
    this.activeColor,
    this.inactiveThumbColor,
    this.inactiveTrackColor,
    this.activeThumbColor,
    this.value = false,
    this.readonly = false,
    this.onChanged,
  });

  final double trackHeight;
  final Color? activeColor;
  final Color? inactiveThumbColor;
  final Color? inactiveTrackColor;
  final Color? activeThumbColor;
  final bool value;
  final bool readonly;
  final ValueChanged<bool>? onChanged;

  @override
  State<SwitchView> createState() => _SwitchViewState();
}

class _SwitchViewState extends State<SwitchView> with SingleTickerProviderStateMixin {
  bool _switchValue = false;
  bool _isTouchedOrHovered = false;
  late final AnimationController _animationController;
  late final Animation<double> _offsetAnimation;
   late Color activeColor;
   late Color inactiveThumbColor;
   late Color inactiveTrackColor;
   late Color activeThumbColor;

  @override
  void initState() {
    super.initState();
    _switchValue = widget.value;
    activeColor = widget.activeColor ?? ColorTheme.main;
    inactiveThumbColor = widget.inactiveThumbColor ?? ColorTheme.grey;
    inactiveTrackColor = widget.inactiveTrackColor ?? ColorTheme.grey;
    if (widget.readonly) {
      inactiveThumbColor = inactiveThumbColor.withOpacity(0.4);
      inactiveTrackColor = inactiveTrackColor.withOpacity(0.4);
    }
    activeThumbColor = widget.activeThumbColor ?? ColorTheme.main;
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..addListener(() {
      if (mounted) {
        setState(() {});
      }
    });
    if (_switchValue) {
      _animationController.forward(from: 1.0);
    }
    _offsetAnimation = Tween<double>(begin: 0.0, end: widget.trackHeight + 4).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.ease),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _animationController.removeListener(() { });
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isTouchedOrHovered = true), // 鼠标进入时
      onExit: (_) => setState(() => _isTouchedOrHovered = false), // 鼠标离开时
      child: GestureDetector(
        onTap: () {
          _onTap();
        },
        onTapDown: (details) => setState(() => _isTouchedOrHovered = true), // 触摸开始时
        child: SizedBox(
          height: widget.trackHeight + 15,
          child: Stack(
            children: [
              // 轨道
              Align(
                alignment: Alignment.center,
                child: Container(
                  height: widget.trackHeight,
                  width: widget.trackHeight * 2.5,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(widget.trackHeight / 2),
                    color: _switchValue ? activeColor.withOpacity(0.4) : inactiveTrackColor.withOpacity(0.4),
                  ),
                ),
              ),
              // 按钮（thumb）
              Center(
                child: Transform.translate(
                  offset: Offset(_offsetAnimation.value, 0),
                  child: Container(
                    padding:  _isTouchedOrHovered
                        ? const EdgeInsets.all(5)
                        : EdgeInsets.zero, // 按钮按下时显示边缘透明背景
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: activeColor.withOpacity(0.2),
                    ),
                    child: Container(
                      height: widget.trackHeight+6,
                      width: widget.trackHeight+6,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _switchValue ? activeThumbColor : inactiveThumbColor,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onTap() {
    if (widget.readonly) {
      return;
    }
      _switchValue = !_switchValue;
      if (widget.onChanged != null) {
        widget.onChanged!(_switchValue);
      }
    if (_switchValue) {
      _animationController.forward().then((_) {
        if (mounted) {
          setState(() => _isTouchedOrHovered = false);
        }
      });
    } else {
      _animationController.reverse().then((_) {
        if (mounted) {
          setState(() => _isTouchedOrHovered = false);
        }
      });
    }
  }

  @override
  void didUpdateWidget(SwitchView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != _switchValue && !widget.readonly) {
      _switchValue = widget.value;
      if (_switchValue) {
        _animationController.forward(from: 1.0);
      } else {
        _animationController.reverse(from: 0.0);
      }
    }
  }
}
