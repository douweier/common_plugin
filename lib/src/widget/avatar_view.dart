import 'package:common_plugin/common_plugin.dart';
import 'package:common_plugin/src/widget/live_avatar_animation.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

//头像组件，带认证、直播中动画、在线状态
//网络缓存、占位、加载、错误处理
class AvatarView extends StatefulWidget {
  /// 图片组件
  final Widget? imageWidget;

  /// 网络图片，image或url必须选择一种类型
  final String? url;

  final double? height;

  final double? width;

  final BorderRadius borderRadius;

  final Color borderColor;

  final double borderWidth; //边框宽度

  final bool showBorder;

  ///认证显示组件
  final Widget? authWidget;

  ///是否正在直播
  final bool isLiveNow;

  ///是否在线
  final bool isOnline;

  ///默认占位头像图片
  final Widget? imageDefaultWidget;

  const AvatarView({
    super.key,
    this.height,
    this.width,
    this.borderRadius = const BorderRadius.all(Radius.circular(100)),
    this.borderColor = const Color(0x80ffffff),
    this.borderWidth = 2,
    this.showBorder = true,
    this.authWidget,
    this.isLiveNow = false,
    this.isOnline = false,
    this.imageWidget,
    this.imageDefaultWidget,
    this.url,
  });

  @override
  _AvatarViewState createState() => _AvatarViewState();
  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DoubleProperty('height', height));
    properties.add(DoubleProperty('width', width));
    properties
        .add(DiagnosticsProperty<BorderRadius>('borderRadius', borderRadius));
  }
}

class _AvatarViewState extends State<AvatarView> {
  double authSize = 20;
  double width = 70;
  double height = 70;

  @override
  void initState() {
    if (widget.width != null) {
      width = widget.width!;
    }
    if (widget.height != null) {
      height = widget.height!;
    }

    ///认证图标大小
    if (width >= 70) {
      authSize = 22;
    } else if (width >= 55 && width < 70) {
      authSize = 15;
    } else {
      authSize = width / 3;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Widget _imageWidget = ClipRRect(
      borderRadius: widget.borderRadius,
      child: (null != widget.imageWidget)
          ? widget.imageWidget!
          : ImageLoad(
              widget.url ?? "",
              width: width,
              height: height,
              placeholder: Container(),
              errorWidget: widget.imageDefaultWidget ??
                  Image.asset("assets/images/avatar_default.png",
                      package: "common_plugin"),
              fit: BoxFit.cover,
            ),
    );

    return Stack(
      children: [
        SizedBox(
          width: width,
          height: height,
          child: widget.isLiveNow
              ? LiveAvatarAnimation(
                  isAnimation: widget.isLiveNow,
                  child: _imageWidget,
                )
              : _imageWidget,
        ),
        // 透明边框
        if (widget.showBorder)
          Positioned(
            child: Container(
              width: width,
              height: height,
              decoration: BoxDecoration(
                borderRadius: widget.borderRadius,
                border: Border.fromBorderSide(BorderSide(
                  color: widget.isLiveNow
                      ? Colors.transparent
                      : widget.borderColor,
                  width: widget.borderWidth,
                )),
              ),
            ),
          ),
        if (widget.authWidget != null && !widget.isLiveNow)
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              width: authSize,
              height: authSize,
              alignment: Alignment.topRight,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.all(Radius.circular(100)),
              ),
              child: widget.authWidget,
            ),
          ),
        if (widget.isLiveNow)
          Positioned(
            bottom: 0,
            left: width * 0.1,
            child: Container(
              width: width * 0.8,
              alignment: Alignment.center,
              padding: EdgeInsets.symmetric(vertical: 1),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.8),
                borderRadius: const BorderRadius.all(Radius.circular(50)),
              ),
              child: Text('直播中',
                  style: TextStyle(
                      fontSize: authSize / 1.6, color: ColorTheme.red)),
            ),
          ),
        if (widget.isOnline)
          Positioned(
              top: 0,
              right: authSize / 2,
              child: DotFlashAnimation(
                width: authSize / 2,
                height: authSize / 2,
              )),
      ],
    );
  }
}
