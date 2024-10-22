import 'package:common_plugin/common_plugin.dart';
import 'package:flutter/material.dart';

//枚举CardView的title标题样式，默认风格为居中样式，居左时就是标题前一条竖线
enum CardTitleStyle { center, left, none }

class CardView extends StatelessWidget {
  const CardView({
    super.key,
    this.color,
    this.alignment,
    this.width,
    this.height,
    this.isShowShadow = true,
    this.shadowColor,
    this.blurRadius = 1.0,
    this.margin,
    this.padding = const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
    required this.child,
    this.semanticContainer = true,
    this.borderRadius = const BorderRadius.all(Radius.circular(5)),
    this.backgroundImage,
    this.showBackgroundImage = false,
    this.title,
    this.titleRightWidget,
    this.isShowTitleBorder = true,
    this.titleStyle = CardTitleStyle.center,
    this.titleAlignment = Alignment.topLeft,
    this.titleFontColor = const Color(0xff333333),
    this.titleFontSize = 16.0,
    this.titleFontWeight = FontWeight.w500,
  });

  final Color? color;

  final AlignmentGeometry? alignment;

  final double? width;

  final double? height;

  final Color? shadowColor;

  final bool isShowShadow;

  final double blurRadius; //阴影模糊半径

  final EdgeInsetsGeometry? margin;

  final EdgeInsetsGeometry padding;

  final bool semanticContainer;

  final Widget child;

  final BorderRadiusGeometry borderRadius;

  final String? backgroundImage;

  final bool showBackgroundImage; //是否显示背景图片

  final String? title;

  ///标题栏右边的widget
  final Widget? titleRightWidget;

  ///标题样式，CardTitleStyle.center为居中两边放射线，CardTitleStyle.left为居左竖线样式
  final CardTitleStyle titleStyle;

  final bool isShowTitleBorder; //是否显示标题下分割的边框线

  ///标题字体颜色
  final Color titleFontColor;
  final double titleFontSize;

  final FontWeight titleFontWeight;

  final AlignmentGeometry titleAlignment;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final CardTheme cardTheme = CardTheme.of(context);

    return Semantics(
      container: semanticContainer,
      child: Container(
        alignment: alignment,
        width: width,
        height: height,
        margin: margin ??
            cardTheme.margin ??
            const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
        padding: padding,
        decoration: BoxDecoration(
          borderRadius: borderRadius,
          boxShadow: [
            if (isShowShadow)
              BoxShadow(
                color: shadowColor ?? Colors.grey.withOpacity(0.3),
                blurRadius: blurRadius, //阴影模糊程度
                spreadRadius: 0.1, //阴影扩散程度
                offset: const Offset(0.5, 0.0),
              ),
          ],
          image: showBackgroundImage
              ? DecorationImage(
                  image: backgroundImage != null
                      ? AssetImage(backgroundImage!)
                      : AssetImage("assets/images/screen_bg.png",
                          package: "common_plugin"),
                  fit: BoxFit.fitWidth,
                  alignment: Alignment.topCenter,
                )
              : null,
          color: color ?? cardTheme.color ?? theme.cardColor,
        ),
        child: Column(
          children: [
            if (title != null)
              Container(
                padding: EdgeInsets.only(bottom: 10),
                margin: EdgeInsets.only(bottom: 5),
                alignment: titleAlignment,
                decoration: isShowTitleBorder
                    ? BoxDecoration(
                        border: Border(
                            bottom: BorderSide(
                          color: ColorTheme.border,
                          width: 1,
                          style: BorderStyle.solid,
                        )),
                      )
                    : null,
                child: Row(
                  children: [
                    if (titleStyle == CardTitleStyle.left)
                      Container(
                        decoration: BoxDecoration(
                          color: ColorTheme.main,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        width: 3,
                        height: 20,
                        margin: EdgeInsets.only(right: 10),
                      ),
                    if (titleStyle == CardTitleStyle.center)
                      Expanded(
                        child: Row(
                          children: [
                            Expanded(
                              child: Container(
                                height: 1,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5),
                                  gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        Colors.transparent,
                                        Colors.transparent,
                                        titleFontColor.withOpacity(0.3),
                                      ]),
                                ),
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.only(right: 10),
                              padding: EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                color: titleFontColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Container(
                                height: 4,
                                width: 4,
                                decoration: BoxDecoration(
                                  color: titleFontColor.withOpacity(0.4),
                                  borderRadius: BorderRadius.circular(5),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    Text(
                      "$title",
                      style: TextStyle(
                          fontWeight: titleFontWeight,
                          color: titleFontColor,
                          fontSize: titleFontSize),
                    ),
                    if (titleStyle == CardTitleStyle.center)
                      Expanded(
                        child: Row(
                          children: [
                            Container(
                              margin: EdgeInsets.only(left: 10),
                              padding: EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                color: titleFontColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Container(
                                height: 4,
                                width: 4,
                                decoration: BoxDecoration(
                                  color: titleFontColor.withOpacity(0.4),
                                  borderRadius: BorderRadius.circular(5),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Container(
                                height: 1,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5),
                                  gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        titleFontColor.withOpacity(0.3),
                                        Colors.transparent,
                                        Colors.transparent,
                                      ]),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    if (titleRightWidget != null)
                      Expanded(
                          child: Align(
                              alignment: Alignment.centerRight,
                              child: titleRightWidget!)),
                  ],
                ),
              ),
            child,
          ],
        ),
      ),
    );
  }
}
