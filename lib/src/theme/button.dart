import 'package:common_plugin/common_plugin.dart';
import 'package:flutter/material.dart';

class ButtonView extends StatelessWidget {
  ///封装按钮
  ///自动根据字数计算按钮宽高间距,如果存在child则text和image无效
  ButtonView({
    this.text,
    this.isOutLineButton = false,
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
  Widget build(BuildContext context) {

    return GestureDetector(
      onTap: onPressed,
      onLongPress: onLongPress,
      behavior: HitTestBehavior.opaque,
      child: Container(
          alignment: Alignment.center,
          width: width,
          height: height,
          padding: padding ?? ((icon != null && text == null) ? EdgeInsets.all(10) : EdgeInsets.symmetric(vertical: 5,horizontal: 15)),
          margin: margin,
          decoration: BoxDecoration(
            color: gradientColors == null
                ? (isOutLineButton
                    ? Colors.white
                    : (backgroundColor ??
                        (child != null ? null : ColorTheme.main)))
                : null,
            borderRadius: BorderRadius.circular(borderRadius ?? 0),
            border: Border.fromBorderSide(BorderSide(
                color: borderColor ??
                    (isOutLineButton ? ColorTheme.border : Colors.transparent),
                width: 1)),
            gradient: gradientColors,
            boxShadow: !showShadow
                ? []
                : [
                    BoxShadow(
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
              if (child != null) child!,
              if (image != null && child == null)
                Padding(
                  padding: const EdgeInsets.only(right: 5.0),
                  child: Image.asset(
                    image!,
                    color: fontColor ?? (isOutLineButton ? ColorTheme.font : ColorTheme.white),
                    fit: BoxFit.cover,
                    width: height != null ? height! * 0.5 : 15,
                    height: height != null ? height! * 0.5 : 15,
                  ),
                ),
              if (icon != null && child == null)
                Padding(
                  padding: EdgeInsets.only(right: (text != null) ? 5.0 : 0),
                  child: icon,
                ),
              if (text != null && child == null)
                Container(
                  constraints: BoxConstraints(
                    maxWidth: screenSize.width * 0.9,
                  ),
                  child: TextView(
                    text!,
                    color: fontColor ?? (isOutLineButton ? ColorTheme.font : ColorTheme.white),
                    fontSize: fontSize,
                    fontWeight: fontWeight,
                  ),
                ),
            ],
          )),
    );
  }

  ///渐变按钮
  static Widget gradient(String text,
      {Color? fontColor,
      double? fontSize,
      FontWeight? fontWeight,
      Function()? onTap,
      Function()? onLongPress,
      double? width,
      double? height,
      EdgeInsetsGeometry? padding,
      Color? backgroundColor,
      double? borderRadius,
      Color? colorLeft,
      Color? colorRight}) {
    return InkWell(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
          alignment: Alignment.center,
          width: width ?? (15.0 * (text.length + 2)),
          height: height ?? (25.0 + (text.length + 2)),
          padding: padding ?? EdgeInsets.only(bottom: 2),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(borderRadius ?? 50), //圆角
            gradient: (colorLeft != null && colorRight != null)
                ? LinearGradient(colors: [colorLeft, colorRight])
                : LinearGradient(colors: ColorTheme.lineGradBlue),
          ),
          child: TextView(
            text,
            color: fontColor ?? Colors.white,
          )),
    );
  }
}

class ButtonBack extends StatelessWidget {
  const ButtonBack(
      {Key? key,
      this.color,
      this.onPressed,
      this.size = 24,
      this.shadowShow = true})
      : super(key: key);

  final Color? color;

  final VoidCallback? onPressed;
  final double size;
  final bool shadowShow;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: IconText(
        Icons.arrow_back_ios_rounded,
        size: size,
        color: color ?? ColorTheme.white,
        shadowShow: shadowShow,
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
  const ButtonIcon(this.icon,
      {Key? key,
      this.color,
      this.backgroundColor,
      this.showBackgroundColor = true,
      this.onTap,
      this.iconSize = 24,
      this.iconPadding = const EdgeInsets.all(15),
      this.iconMargin,
      this.text,
      this.fontColor,
      this.fontSize = 14,
      this.shadowShow = true,
      this.shadowColor = Colors.black54})
      : super(key: key);

  final IconData icon;
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
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            margin: iconMargin ??
                (text != null ? const EdgeInsets.only(bottom: 10) : null),
            padding: showBackgroundColor ? iconPadding : null,
            decoration: BoxDecoration(
              color: backgroundColor ??
                  (showBackgroundColor ? ColorTheme.white.withOpacity(0.2) : null),
              borderRadius: BorderRadius.circular(50),
            ),
            child: IconText(
              icon,
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
