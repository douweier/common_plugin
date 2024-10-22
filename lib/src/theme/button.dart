import 'package:common_plugin/common_plugin.dart';
import 'package:flutter/material.dart';

class ButtonView extends StatefulWidget {
  ///自动根据字数计算按钮宽高间距,如果存在child则text和image无效
  const ButtonView({
    super.key,
    this.text,
    this.isOutLineButton = false,
    this.isDisable = false,
    this.isDisableFastClick = true,
    this.fastClickTime = 800,
    this.icon,
    this.image,
    this.child,
    this.onPressed,
    this.onLongPress,
    this.width,
    this.height,
    this.backgroundColor,
    this.fontColor,
    this.fontSize = 14,
    this.fontWeight = FontWeight.w400,
    this.borderRadius = 50,
    this.borderColor,
    this.padding,
    this.margin,
    this.gradientColors,
    this.showShadow = true,
  });

  final String? image;
  final Widget? icon;
  final String? text;

  ///outLineButton=true为边框轮廓按钮，false默认蓝色主题背景按钮
  final bool isOutLineButton;

  /// 是否禁用按钮
  final bool isDisable;
  final bool isDisableFastClick; //禁用快速点击
  final int fastClickTime; //单位毫秒,800毫秒内不可重复点击
  final Widget? child;
  final VoidCallback? onPressed;
  final Function()? onLongPress;
  final double? width;
  final double? height;
  final Color? backgroundColor;
  final Color? fontColor;
  final double fontSize;
  final FontWeight fontWeight;

  final bool showShadow;

  ///圆角值 borderRadius = 50
  final double? borderRadius;

  ///边框颜色
  final Color? borderColor;

  ///padding = const EdgeInsets.only(left: 15,right: 15,top: 7,bottom: 9)
  final EdgeInsetsGeometry? padding;

  ///margin = const EdgeInsets.only(right: 10)
  final EdgeInsetsGeometry? margin;

  ///渐变颜色 LinearGradient(colors:[Color(0xff0db5e5), Color(0xff0aa6e8)])
  final LinearGradient? gradientColors;

  @override
  State<ButtonView> createState() => _ButtonViewState();
}

class _ButtonViewState extends State<ButtonView> {
  bool isDisableClick = false;

  @override
  void initState() {
    super.initState();
  }

  void _onPressed() async {
    if (widget.isDisableFastClick) {
      setState(() {
        isDisableClick = true;
      });
      widget.onPressed?.call();
      Future.delayed(Duration(milliseconds: widget.fastClickTime), () {
        if (mounted) {
          setState(() {
            isDisableClick = false;
          });
        }
      });
    } else {
      widget.onPressed?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (widget.isDisable || isDisableClick) ? (){} : _onPressed,
      onLongPress: widget.onLongPress,
      behavior: HitTestBehavior.opaque,
      child: Container(
          alignment: Alignment.center,
          width: widget.width,
          height: widget.height,
          padding: widget.padding ??
              ((widget.icon != null && widget.text == null)
                  ? const EdgeInsets.all(10)
                  : const EdgeInsets.symmetric(vertical: 5, horizontal: 15)),
          margin: widget.margin,
          decoration: BoxDecoration(
            color: widget.gradientColors == null
                ? (widget.isDisable
                    ? ColorTheme.background
                    : widget.isOutLineButton
                        ? Colors.white
                        : (widget.backgroundColor ??
                            (widget.child != null ? null : ColorTheme.main)))
                : null,
            borderRadius: BorderRadius.circular(widget.borderRadius ?? 0),
            border: Border.fromBorderSide(BorderSide(
                color: widget.isDisable
                    ? ColorTheme.border
                    : (widget.borderColor ??
                        (widget.isOutLineButton
                            ? ColorTheme.border
                            : Colors.transparent)),
                width: 1)),
            gradient: widget.gradientColors,
            boxShadow: (!widget.showShadow || widget.isOutLineButton)
                ? []
                : [
                    const BoxShadow(
                        color: Colors.black12,
                        offset: Offset(1, -1),
                        blurRadius: 1.0, //阴影模糊程度
                        spreadRadius: 0.1 //阴影扩散程度
                        ),
                  ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              if (widget.child != null) widget.child!,
              if (widget.image != null && widget.child == null)
                Padding(
                  padding: const EdgeInsets.only(right: 5.0),
                  child: Image.asset(
                    widget.image!,
                    color: widget.fontColor ??
                        (widget.isOutLineButton
                            ? ColorTheme.font
                            : ColorTheme.white),
                    fit: BoxFit.cover,
                    width: widget.height != null ? widget.height! * 0.5 : 15,
                    height: widget.height != null ? widget.height! * 0.5 : 15,
                  ),
                ),
              if (widget.icon != null && widget.child == null)
                Padding(
                  padding:
                      EdgeInsets.only(right: (widget.text != null) ? 5.0 : 0),
                  child: widget.icon,
                ),
              if (widget.text != null && widget.child == null)
                isDisableClick ? LoadingPage(onlyShowIcon: true,iconSize: widget.fontSize,showAppScaffold: false,) : Container(
                  constraints: BoxConstraints(
                    maxWidth: screenSize.width * 0.9,
                  ),
                  child: TextView(
                    widget.text!,
                    color: widget.isDisable
                        ? ColorTheme.grey
                        : (widget.fontColor ??
                            (widget.isOutLineButton
                                ? ColorTheme.font
                                : ColorTheme.white)),
                    fontSize: widget.fontSize,
                    fontWeight: widget.fontWeight,
                  ),
                ),
            ],
          )),
    );
  }
}

class ButtonBack extends StatelessWidget {
  const ButtonBack(
      {super.key,
      this.iconColor,
      this.isWhiteBackground = false,
      this.backgroundColor,
      this.onPressed,
      this.size = 22,
      this.showRoundBackground = false,
      this.shadowShow = false});

  final Color? iconColor;
  final bool isWhiteBackground; // 背景是否为白色，默认为黑色背景白色图标
  final Color? backgroundColor;

  final VoidCallback? onPressed;
  final double size;
  final bool shadowShow;
  final bool showRoundBackground;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Container(
        padding: const EdgeInsets.all(7),
        decoration: showRoundBackground
            ? BoxDecoration(
                color: backgroundColor ?? (isWhiteBackground ? ColorTheme.white : Colors.black54),
                borderRadius: BorderRadius.circular(50),
                boxShadow: isWhiteBackground ? const [
                  BoxShadow(
                      color: Colors.grey,
                      offset: Offset(1, 1),
                      blurRadius: 1.0,
                      spreadRadius: 0.1
                      ),
                ] : [],
              )
            : null,
        child: IconText(
          Icons.arrow_back_ios_rounded,
          size: size,
          color: iconColor ?? (showRoundBackground ? (isWhiteBackground ? ColorTheme.font : ColorTheme.white) : ColorTheme.fontLight),
          shadowShow: shadowShow,
        ),
      ),
      onPressed: () {
        if (onPressed != null) {
          onPressed?.call();
        } else {
          Navigator.maybePop(context);
        }
      },
    );
  }
}

class ButtonIcon extends StatelessWidget {
  const ButtonIcon(
      {super.key,
      this.icon,
      this.iconWidget,
      this.color,
      this.backgroundColor,
      this.showBackgroundColor = true,
      this.onTap,
      this.iconSize = 24,
      this.iconPadding = const EdgeInsets.all(7),
      this.iconMargin,
      this.text,
      this.fontColor,
      this.fontSize = 14,
      this.shadowShow = false,
      this.shadowColor = Colors.black54});

  final IconData? icon;
  final Widget? iconWidget;
  final Color? color;
  final Color? backgroundColor;
  final EdgeInsetsGeometry iconPadding;
  final EdgeInsetsGeometry? iconMargin;

  final Function()? onTap;
  final double iconSize;
  final bool showBackgroundColor;
  final bool shadowShow;
  final Color shadowColor;
  final String? text;
  final Color? fontColor;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          iconWidget != null
              ? iconWidget!
              : Container(
                  margin: iconMargin ??
                      (text != null ? const EdgeInsets.only(bottom: 10) : null),
                  padding: showBackgroundColor ? iconPadding : null,
                  decoration: BoxDecoration(
                    color: backgroundColor ??
                        (showBackgroundColor
                            ? ColorTheme.white.withOpacity(0.2)
                            : null),
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: IconText(
                    icon!,
                    color: color ?? ColorTheme.white,
                    size: iconSize,
                    shadowShow: shadowShow,
                    shadowColor: shadowColor,
                  ),
                ),
          if (text != null)
            TextView(
              text!,
              color: fontColor ?? (ColorTheme.white),
              fontSize: fontSize,
            ),
        ],
      ),
    );
  }
}
