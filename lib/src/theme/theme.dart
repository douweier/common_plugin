
import 'package:flutter/material.dart';

class ColorTheme {
  ///默认主题颜色
  static const Color main = Color(0xff0aa6e8);

  ///淡一点高亮主题颜色
  static const Color mainLight = Color(0xff0ac9ff);

  ///主体内容背景颜色
  static const Color body = Color(0xffffffff);

  ///字体主要颜色
  static const Color font = Color(0xff333333);

  ///默认背景颜色
  static const Color background = Color(0xfff7f7f7);

  ///边框颜色
  static const Color border = Color(0xfff0f0f0);

  ///白色
  static const Color white = Color(0xffffffff);

  ///黑色
  static const Color black = Color(0xff000000);

  ///黄色
  static const Color yellow = Color(0xfffcd205);

  ///红色
  static const Color red = Color(0xffec082a);

  ///错误
  static const Color error = Color(0xffec082a);

  ///紫色
  static const Color purple = Color(0xffe3086e);

  ///绿色
  static const Color green = Color(0xff4bb608);

  ///灰色
  static const Color grey = Color(0xff999999);

  ///蓝渐变颜色
  static const List<Color> lineGradBlue = [
    Color(0xff0db5e5),
    Color(0xff0aa6e8)
  ];

  ///蓝渐变颜色
  static const List<Color> lineGradRed = [
    Color(0xfff60576),
    Color(0xffe80a63)
  ];

  ///透明渐变颜色
  static List<Color> lineGradBlueOpacity = [
    Color(0xff0ac9ff).withOpacity(0.6),
    Color(0xff0aa6e8).withOpacity(0.8)
  ];
}

///默认字体样式
class MyTextStyle {
  static TextStyle whiteText({double size = 16}) {
    return TextStyle(color: Colors.white, fontSize: size);
  }

  static TextStyle blackText({double size = 16}) {
    return TextStyle(color: Colors.black12, fontSize: size);
  }
}

///默认文本样式
class TextView extends StatelessWidget {
  final String text;
  final Color color;
  final double fontSize;
  final FontWeight fontWeight;
  final int maxLines;
  final int maxLength;
  final TextOverflow overflow;
  final bool shadowShow;
  final Color shadowColor;
  final IconData? icon;
  TextView(
    this.text, {
    this.color = ColorTheme.font,
    this.fontSize = 14,
    this.fontWeight = FontWeight.w400,
    this.maxLength = 0,
    this.maxLines = 1,
    this.overflow = TextOverflow.ellipsis,
    this.shadowShow = false,
    this.shadowColor = Colors.black54,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    String? truncatedText;
    if (maxLength > 0 && text.length > maxLength) {
       truncatedText = text.length > maxLength
          ? text.substring(0, maxLength) + '...'
          : text;
    }
    return RichText(
      maxLines: maxLines,
      overflow: overflow,
      text: TextSpan(
        text: icon != null ? String.fromCharCode(icon!.codePoint) : (truncatedText ?? text),
        style: TextStyle(
            color: color,
            inherit: false,
            fontSize: fontSize,
            fontWeight: fontWeight,
            fontFamily: icon != null ? 'iconFont' : '',
            decoration: TextDecoration.none,
            package: icon?.fontPackage,
            shadows: shadowShow ? [
              BoxShadow(
                  color: shadowColor,
                  offset: Offset(0.1,0.1),
                  blurRadius: 2.0, //阴影模糊程度
                  spreadRadius: 0.3 //阴影扩散程度
              ),
            ] : [],
        ),
      ),
    );
  }
}
