import 'package:common_plugin/common_plugin.dart';
import 'package:flutter/material.dart';

enum LoadingType {
  loading, //加载中
  notFound, //找不到页面
  noData, //无数据
  networkFailure, //网络错误
  error, //其它错误
}

///屏幕显示加载动画,可以在任意页面直接弹出
showLoadingOverScreen(
    {int autoCloseTime = 10,
    LoadingType type = LoadingType.loading,
    String? text,
    bool onlyShowIcon = true}) {
  ShowOverScreen.show(LoadingPage(
    onlyShowIcon: onlyShowIcon,
    showAppScaffold: false,
    text: text,
  ));
  Future.delayed(Duration(seconds: autoCloseTime), () {
    ShowOverScreen.remove();
  });
}

///加载页面
class LoadingPage extends StatelessWidget {
  final LoadingType? type;
  final bool onlyShowIcon;

  ///是否只显示图标

  ///显示的文字
  final String? text;

  final Color? backgroundColor;
  final Color? fontColor;

  ///图标大小
  final double? iconSize;
  final bool showAppBar;  // 是否显示appbar，避免页面没有返回按钮
  final bool showAppScaffold; //是否显示Scaffold，避免页面没有相关主题出现界面问题
  const LoadingPage(
      {super.key,
      this.type = LoadingType.loading,
      this.onlyShowIcon = false,
      this.backgroundColor,
      this.fontColor,
      this.text,
      this.iconSize = 50,
      this.showAppBar = false,
      this.showAppScaffold = true});

  @override
  Widget build(BuildContext context) {
    Widget body = Container();
    if (type == LoadingType.loading) {
      body = Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ImageFrameAnimation(
              const [
                "assets/images/loading_01.png",
                "assets/images/loading_02.png",
                "assets/images/loading_03.png",
                "assets/images/loading_04.png",
                "assets/images/loading_05.png",
                "assets/images/loading_06.png",
                "assets/images/loading_07.png",
                "assets/images/loading_08.png",
                "assets/images/loading_09.png",
                "assets/images/loading_10.png",
              ],
              package: "common_plugin",
              width: iconSize,
              height: iconSize,
              isLoop: true,
              interval: 200,
            ),
            if (!onlyShowIcon)
              Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  margin: const EdgeInsets.only(top: 10),
                  child: TextView(text ?? "正在加载...",color: fontColor,)),
          ],
        ),
      );
    } else if (type == LoadingType.noData) {
      body = Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              "assets/images/icon_data_empty.png",
              width: iconSize,
              height: iconSize,
              package: "common_plugin",
            ),
            if (!onlyShowIcon)
              Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  margin: const EdgeInsets.only(top: 10),
                  child: TextView(text ?? "暂时没有数据",color: fontColor)),
          ],
        ),
      );
    } else if (type == LoadingType.networkFailure) {
      body = Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              "assets/images/warn.png",
              width: iconSize,
              height: iconSize,
              package: "common_plugin",
            ),
            if (!onlyShowIcon)
              Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  margin: const EdgeInsets.only(top: 10),
                  child: TextView(text ?? "网络故障了",color: fontColor)),
          ],
        ),
      );
    } else if (type == LoadingType.notFound) {
      body = Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              "assets/images/warn.png",
              width: iconSize,
              height: iconSize,
              package: "common_plugin",
            ),
            if (!onlyShowIcon)
              Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  margin: const EdgeInsets.only(top: 10),
                  child: TextView(text ?? "找不到这个页面了",color: fontColor)),
          ],
        ),
      );
    } else if (type == LoadingType.error) {
      body = Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              "assets/images/warn.png",
              width: iconSize,
              height: iconSize,
              package: "common_plugin",
            ),
            if (!onlyShowIcon)
              Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  margin: const EdgeInsets.only(top: 10),
                  child: TextView(text ?? "加载失败",color: fontColor)),
          ],
        ),
      );
    }

    if (showAppScaffold) {
      return AppView(
        title: showAppBar ? "" : null,
        backgroundColor: backgroundColor,
        body: body,
      );
    }
    return body;
  }
}
