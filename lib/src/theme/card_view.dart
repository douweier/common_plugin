import 'package:common_plugin/common_plugin.dart';
import 'package:flutter/material.dart';

class CardView extends StatelessWidget {
  const CardView({
    super.key,
    this.color,
    this.alignment,
    this.width,
    this.height,
    this.shadowColor,
    this.blurRadius = 1.0,
    this.margin,
    this.padding = const EdgeInsets.symmetric(vertical: 15,horizontal: 10),
    required this.child,
    this.semanticContainer = true,
    this.borderRadius = const BorderRadius.all(Radius.circular(5)),
    this.backgroundImage,
    this.showBackgroundImage = true,
    this.title,
    this.titleCenter = false,
    this.titleAlignment = Alignment.topLeft,
    this.titleFontColor = const Color(0xff333333),
    this.titleFontSize = 16.0,
  });

  final Color? color;

  final AlignmentGeometry? alignment;

  final double? width;

  final double? height;

  final Color? shadowColor;

  final double blurRadius; //阴影模糊半径

  final EdgeInsetsGeometry? margin;

  final EdgeInsetsGeometry padding;

  final bool semanticContainer;

  final Widget child;

  final BorderRadiusGeometry borderRadius;

  final String? backgroundImage;

  final bool showBackgroundImage; //是否显示背景图片

  final String? title;

  ///标题居中显示样式
  final bool titleCenter;
  
  ///标题字体颜色
  final Color titleFontColor;
  final double titleFontSize;

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
        margin: margin ?? cardTheme.margin ?? const EdgeInsets.all(5.0),
        padding: padding,
        decoration: BoxDecoration(
          borderRadius: borderRadius,
            boxShadow: [
              BoxShadow(
                  color: shadowColor ?? Colors.grey.withOpacity(0.3),
                  blurRadius: blurRadius, //阴影模糊程度
                  spreadRadius: 1, //阴影扩散程度
                offset: const Offset(0.5, 0.0),
              ),
            ],
          image: showBackgroundImage ? DecorationImage(
            image: AssetImage(backgroundImage ?? "assets/images/screen_bg.png"),
            fit: BoxFit.cover,
            alignment: Alignment.topLeft,
          ) : null,
          color: color ?? cardTheme.color ?? theme.cardColor,
        ),
        child: Column(
          children: [
            if (title != null)
              Container(
                padding: EdgeInsets.only(bottom: 10),
                margin: EdgeInsets.only(bottom: 5),
                alignment: titleAlignment,
                decoration: BoxDecoration(
                  border: Border(
                      bottom: BorderSide(
                        color: ColorTheme.border,
                        width: 1,
                        style: BorderStyle.solid,
                      )),
                ),
                child: Row(
                  children: [
                    if(titleCenter)
                    Expanded(
                      child: Row(
                        children: [
                          Expanded(
                            child: Container(
                              height: 1,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5),
                                gradient: LinearGradient
                                  (
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors:
                                    [
                                      Colors.transparent,
                                      Colors.transparent,
                                      titleFontColor.withOpacity(0.3),
                                    ]
                                ),
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
                    Text("$title",style: TextStyle(fontWeight: FontWeight.w500,color: titleFontColor,fontSize: titleFontSize),),
                    if(titleCenter)
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
                                gradient: LinearGradient
                                  (
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors:
                                    [
                                      titleFontColor.withOpacity(0.3),
                                      Colors.transparent,
                                      Colors.transparent,
                                    ]
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
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
