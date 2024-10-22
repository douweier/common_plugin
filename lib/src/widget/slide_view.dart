import 'package:common_plugin/common_plugin.dart';
import 'package:flutter/material.dart';

/// 滑出面板, 支持左右上下滑动，自适应面板及主体内容布局
class SlideView extends StatefulWidget {
  final Widget child; // 主内容
  final bool isShow; // 是否显示滑出面板，比如需要登录状态才能显示的控制
  final Direction direction; // 菜单滑出方向
  final List<MenuItem>? actions; // 菜单列表
  final Widget? slideWidget; // 自定义显示滑出面板
  final double? width; // 滑出面板的宽度
  final double? height; // 滑出面板的高度
  final Color backgroundColor; // 背景色
  final Duration animationDuration; // 动画时长

  const SlideView({
    super.key,
    required this.child,
    this.isShow = true,
    this.direction = Direction.right,
    this.actions,
    this.slideWidget,
    this.width,
    this.height,
    this.backgroundColor = Colors.white,
    this.animationDuration = const Duration(milliseconds: 800),
  });

  @override
  State<SlideView> createState() => _SlideViewState();
}

class _SlideViewState extends State<SlideView>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _childAnimation;
  late Animation<double> _panelAnimation;
  late bool _isAnimating;
  bool isShowCardView = false; // 是否正在显示滑出面板

  final GlobalKey _childKey = GlobalKey(); // 用于获取主体内容高度
  final GlobalKey _panelKey = GlobalKey(); // 用于获取滑出面板高度
  double _childHeight = 0;
  double _panelWidth = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.animationDuration,
    );

    _childAnimation =
        CurvedAnimation(parent: _controller, curve: Curves.fastEaseInToSlowEaseOut);
    _panelAnimation =
        CurvedAnimation(parent: _controller, curve: Curves.fastEaseInToSlowEaseOut);
    _isAnimating = false;

    WidgetsBinding.instance.addPostFrameCallback(_getChildHeight);
  }

  void _getChildHeight(Duration _) {
    final RenderBox? renderBox = _childKey.currentContext?.findRenderObject() as RenderBox?;
    final RenderBox? renderPanelBox = _panelKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox != null && renderPanelBox != null) {
      setState(() {
        _childHeight = renderBox.size.height;
        _panelWidth = renderPanelBox.size.width;
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _openPanel() {
    setState(() {
      isShowCardView = true;
      _isAnimating = true;
      _controller.forward().then((_) {
        if (mounted) {
          setState(() {
            _isAnimating = false;
          });
        }
      });
    });
  }

  void _closePanel() {
    setState(() {
      isShowCardView = false;
      _isAnimating = true;
      _controller.reverse().then((_) {
        if (mounted) {
          setState(() {
            _isAnimating = false;
          });
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onHorizontalDragUpdate: (widget.isShow && (widget.direction == Direction.left || widget.direction == Direction.right)) ? (details) {
        if (_isAnimating ||
            widget.direction == Direction.top ||
            widget.direction == Direction.bottom) return;
        double delta = details.delta.dx / (widget.width ?? _panelWidth);
        if (widget.direction == Direction.left) {
          _controller.value += delta;
        } else {
          _controller.value -= delta;
        }
      } : null,
      onHorizontalDragEnd: (widget.isShow && (widget.direction == Direction.left || widget.direction == Direction.right)) ? (details) {
        if (_isAnimating ||
            widget.direction == Direction.top ||
            widget.direction == Direction.bottom) return;
        if (_controller.value > (!isShowCardView ? 0.1 : 0.9)) {
          _openPanel();
        } else {
          _closePanel();
        }
      } : null,
      onVerticalDragUpdate: (widget.isShow && (widget.direction == Direction.top || widget.direction == Direction.bottom))
          ? (details) {
        if (_isAnimating ||
            widget.direction == Direction.left ||
            widget.direction == Direction.right) return;
        double delta = details.delta.dy / (widget.height ?? _childHeight);
        if (widget.direction == Direction.top) {
          _controller.value += delta;
        } else {
          _controller.value -= delta;
        }
      } : null,
      onVerticalDragEnd: (widget.isShow && (widget.direction == Direction.top || widget.direction == Direction.bottom))
          ? (details) {
        if (_isAnimating ||
            widget.direction == Direction.left ||
            widget.direction == Direction.right) return;
        if (_controller.value > (!isShowCardView ? 0.1 : 0.9)) {
          _openPanel();
        } else {
          _closePanel();
        }
      } : null,
      child: Stack(
        children: [
          // 主体内容
          AnimatedBuilder(
            animation: _childAnimation,
            builder: (context, child) {
              double offset;
              switch (widget.direction) {
                case Direction.left:
                  offset = (_childAnimation.value * _panelWidth);
                  break;
                case Direction.right:
                  offset = -(_childAnimation.value * _panelWidth);
                  break;
                case Direction.top:
                  offset = -(_childAnimation.value * _childHeight);
                  break;
                case Direction.bottom:
                  offset = _childAnimation.value * _childHeight;
                  break;
              }
              return Transform.translate(
                offset: widget.direction == Direction.left ||
                    widget.direction == Direction.right
                    ? Offset(offset, 0)
                    : Offset(0, offset),
                child: Container(
                  key: _childKey,
                  child: widget.child,
                ),
              );
            },
          ),
          // 滑出面板
          if(widget.isShow)
          AnimatedBuilder(
            animation: _panelAnimation,
            builder: (context, child) {
              double offset;
              switch (widget.direction) {
                case Direction.left:
                  offset = -_panelWidth * (1 - _panelAnimation.value);
                  break;
                case Direction.right:
                  offset = MediaQuery.of(context).size.width -
                      (widget.width ?? _panelWidth) * _panelAnimation.value;
                  break;
                case Direction.top:
                  offset = -(_childHeight) * (1 - _panelAnimation.value);
                  break;
                case Direction.bottom:
                  offset = MediaQuery.of(context).size.height -
                      (_childHeight) * _panelAnimation.value;
                  break;
              }
              return Transform.translate(
                offset: widget.direction == Direction.left ||
                    widget.direction == Direction.right
                    ? Offset(offset, 0)
                    : Offset(0, offset),
                child: SizedBox(
                  width: widget.width,
                  height: widget.height ?? _childHeight,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5),
                    child: Container(
                      key: _panelKey,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: widget.backgroundColor,
                        boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.3),
                              blurRadius: 1, //阴影模糊程度
                              spreadRadius: 0.1, //阴影扩散程度
                              offset: const Offset(0.5, 0.0),
                            ),
                        ],
                      ),
                      margin: widget.direction == Direction.left ? const EdgeInsets.only(left: 7) : const EdgeInsets.only(right: 7),
                      padding: const EdgeInsets.symmetric(horizontal: 15,vertical: 15),
                      child: IntrinsicWidth(
                        child: widget.slideWidget ??
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                if (widget.actions != null)
                                  for (var item in widget.actions!)
                                    _buildMenuItem(
                                        item, widget.actions!.indexOf(item)),
                              ],
                            ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(MenuItem item, int index) {
    return InkWell(
      onTap: item.onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          border: Border(
            right: index == widget.actions!.length - 1
                ? BorderSide.none
                : BorderSide(color: ColorTheme.border),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (item.icon != null)
              Icon(item.icon, color: item.fontColor, size: 22),
            if (item.iconAssets != null)
              Image.asset(item.iconAssets!,
                  color: item.fontColor, width: item.fontSize),
            const SizedBox(height: 10),
            Text(
              item.text,
              style: TextStyle(
                color: item.fontColor,
                fontSize: item.fontSize,
                fontWeight: item.fontWeight,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

enum Direction {
  left,
  right,
  top,
  bottom,
}
