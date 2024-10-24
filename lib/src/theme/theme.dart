import 'package:flutter/material.dart';

class ColorTheme {
  ///默认主题颜色
  static Color main = const Color(0xff0aa6e8);

  ///淡一点高亮主题颜色
  static Color mainLight = const Color(0xff0ac9ff);

  ///主体内容背景颜色
  static Color body = const Color(0xffffffff);

  ///图标主题颜色
  static Color icon = const Color(0xffcccccc);

  ///字体主要颜色
  static Color font = const Color(0xff333333);

  ///浅黑
  static Color fontLight = const Color(0xff666666);

  ///默认背景颜色
  static Color background = const Color(0xfff5f5f5);

  ///边框颜色
  static Color border = const Color(0xfff0f0f0);

  ///白色
  static Color white = const Color(0xffffffff);

  ///黑色
  static Color black = const Color(0xff000000);

  ///黄色
  static Color yellow = const Color(0xfffcd205);

  ///红色
  static Color red = const Color(0xffec082a);

  ///错误
  static Color error = const Color(0xffec082a);

  ///紫色
  static Color purple = const Color(0xffe3086e);

  ///绿色
  static Color green = const Color(0xff4bb608);

  ///橙色
  static Color orange = const Color(0xfffa7a39);

  ///灰色
  static Color grey = const Color(0xff999999);

  ///灰色
  static Color btnBackground = const Color(0xff0066FE);

  ///蓝渐变颜色
  static List<Color> lineGradBlue = [
    const Color(0xff0db5e5),
    const Color(0xff0aa6e8)
  ];

  ///蓝渐变颜色
  static List<Color> lineGradRed = [
    const Color(0xfff60576),
    const Color(0xffe80a63)
  ];

  ///透明渐变颜色
  static List<Color> lineGradBlueOpacity = [
    const Color(0xff0ac9ff).withOpacity(0.6),
    const Color(0xff0aa6e8).withOpacity(0.8)
  ];
}

///默认字体样式
class TextStyleTheme {
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
  final Color? color;
  final double fontSize;
  final FontWeight fontWeight;
  final bool italic; //是否斜体
  /// 字间距，如0.5
  final double? letterSpacing;
  /// 行间距，例如1.7
  final double? lineHeight;
  /// 最大行数，默认1，0不限制
  final int maxLines;
  /// 标题、昵称简单设置字数长度，就能避免文本溢出的布局问题
  final int maxLength;
  final TextOverflow overflow;
  final bool shadowShow;
  final Color shadowColor;
  final IconData? icon;
  const TextView(
    this.text, {
    super.key,
    this.color,
    this.fontSize = 14,
    this.fontWeight = FontWeight.w400,
    this.italic = false,
    this.letterSpacing,
    this.lineHeight,
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
      truncatedText = text.length > maxLength ? '${text.substring(0, maxLength)}...' : text;
    }
    return RichText(
      maxLines: maxLines == 0 ? null : maxLines,
      overflow: overflow,
      text: TextSpan(
        text: icon != null
            ? String.fromCharCode(icon!.codePoint)
            : (truncatedText ?? text),
        style: TextStyle(
          color: color ?? ColorTheme.font,
          inherit: false,
          fontSize: fontSize,
          fontWeight: fontWeight,
          fontFamily: icon != null ? 'iconFont' : '',
          fontStyle: italic ? FontStyle.italic : null,
          decoration: TextDecoration.none,
          letterSpacing: letterSpacing,
          height: lineHeight,
          package: icon?.fontPackage,
          shadows: shadowShow
              ? [
                  BoxShadow(
                      color: shadowColor,
                      offset: const Offset(0.1, 0.1),
                      blurRadius: 2.0, //阴影模糊程度
                      spreadRadius: 0.3 //阴影扩散程度
                      ),
                ]
              : [],
        ),
      ),
    );
  }
}
