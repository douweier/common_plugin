import 'package:common_plugin/common_plugin.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppView extends StatelessWidget {
  final String? title;
  final Color? titleFontColor;
  final double titleFontSize;
  final Widget? titleWidget;
  final Widget? body;
  final double? elevation;
  final List<Color>? lineGradColor;
  final List<Widget>? actions;
  final Color? appBarBackColor;
  final Color? backgroundColor;
  final EdgeInsets? padding;
  final Widget? bottomSheet;
  final bool showAppBarBackImage;
  final Widget? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;
  final SystemUiOverlayStyle? systemOverlayStyle;


  const AppView({
    Key? key,
    this.title,
    this.titleFontColor,
    this.titleFontSize = 16,
    this.titleWidget,
    this.body,
    this.padding,
    this.elevation = 1,
    this.lineGradColor,
    this.appBarBackColor,
    this.backgroundColor,
    this.bottomSheet,
    this.actions,
    this.showAppBarBackImage = true,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
    this.systemOverlayStyle = const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ModalRoute<dynamic>? parentRoute = ModalRoute.of(context);
    final bool canPop = parentRoute?.canPop ?? false;

    return Scaffold(
      bottomSheet: bottomSheet,
      appBar: (titleWidget != null || title != null)
          ? AppBar(
              elevation: elevation,
              toolbarHeight: 50,
              title: titleWidget ??
                  Text(
                    title!,
                    style: TextStyle(
                      fontSize: titleFontSize,
                      color: titleFontColor ?? ColorTheme.font,
                    ),
                  ),
              centerTitle: true,
              backgroundColor: appBarBackColor ?? ColorTheme.body,
              shadowColor: ColorTheme.border.withOpacity(.3),
              systemOverlayStyle: systemOverlayStyle,
              flexibleSpace: showAppBarBackImage
                  ? Container(
                      decoration: const BoxDecoration(
                        //           gradient: LinearGradient(colors: lineGradColor ?? MyColor.lineGradBlue),
                        image: DecorationImage(
                          image: AssetImage("assets/images/apptopbg.png",
                              package: "common_plugin"),
                          fit: BoxFit.cover,
                          alignment: Alignment.topLeft,
                        ),
                      ),
                    )
                  : null,
              leading: canPop
                  ? ButtonBack(
                      color: titleFontColor ?? ColorTheme.font,
                      shadowShow: false,
                      size: 22,
                    )
                  : null,
              actions: actions,
            )
          : null,
      body: Container(padding: padding, child: body ?? Container()),
      backgroundColor: backgroundColor ?? ColorTheme.background,
      resizeToAvoidBottomInset: true,
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: floatingActionButtonLocation, // 悬浮按钮位置
      floatingActionButtonAnimator: FloatingActionButtonAnimator.scaling, // 悬浮按钮动画
    );
  }
}
