import 'package:common_plugin/common_plugin.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppView extends StatefulWidget {
  final String? title; // 导航栏标题
  final Color? titleFontColor;
  final double titleFontSize;
  final Widget? titleWidget; // 导航栏标题自定义组件
  final Widget? body; // 主体内容
  final double? elevation; // 导航栏阴影
  final List<Color>? lineGradColor;
  final List<Widget>? actions; // 导航栏右侧按钮
  final Color? appBarBackColor;
  final Color? backgroundColor;
  final Widget? bottomSheet; // 底部浮动层
  final bool showAppBarBackImage; // 是否显示顶部背景图片
  final Widget? floatingActionButton; // 悬浮按钮
  final FloatingActionButtonLocation? floatingActionButtonLocation; // 悬浮按钮位置
  final SystemUiOverlayStyle? systemOverlayStyle; // 状态栏样式
  final bool resizeToAvoidBottomInset; // 是否避免输入框被遮挡
  final bool isExtendBodyBehindAppBar; // appBar是否浮动在body上，方便设置背景层浮动效果
  final Widget? background;    // 背景层组件

  /// 初始化获取数据,自动判断数据是否正在加载、数据为空的状态显示
  /// initGetData() async {
  //     final res = await toUrl('/url');
  //     if (res.isSuccess) {
  //       setState(() {});
  //       return res.data;
  //     }
  //   }
  final Function()? initGetData;

  const AppView({
    super.key,
    this.title,
    this.titleFontColor,
    this.titleFontSize = 16,
    this.titleWidget,
    this.body,
    this.initGetData,
    this.elevation = 1,
    this.lineGradColor,
    this.appBarBackColor,
    this.backgroundColor,
    this.bottomSheet,
    this.actions,
    this.showAppBarBackImage = true,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
    this.resizeToAvoidBottomInset = true,
    this.isExtendBodyBehindAppBar = false,
    this.background,
    this.systemOverlayStyle = const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  });

  @override
  State<AppView> createState() => _AppViewState();
}

class _AppViewState extends State<AppView> {
  bool isEmptyData = false; // 没有数据
  bool isLoading = false; // 是否正在加载数据
  Widget? bodyWidget;

  @override
  void initState() {
    _initData();
    super.initState();
  }

  @override
  dispose() {
    super.dispose();
  }

  void _initData() async {
    if (widget.initGetData != null) {
      isLoading = true;
      var res = await widget.initGetData!();
      if (!isEmptyOrNull(res)) {
        isEmptyData = false;
      } else {
        isEmptyData = true;
      }
      isLoading = false;
      if (mounted) {
        setState(() {});
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final ModalRoute<dynamic>? parentRoute = ModalRoute.of(context);
    final bool canPop = parentRoute?.canPop ?? false;

    if (isLoading) {
      bodyWidget = const Center(child: TextView("加载数据中..."));
    } else if (isEmptyData) {
      bodyWidget = Container(
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              "assets/images/icon_data_empty.png",
              width: 60,
              fit: BoxFit.cover,
              package: "common_plugin",
            ),
            const TextView("暂无更多数据"),
          ],
        ),
      );
    } else {
      bodyWidget = widget.body;
    }

    return Scaffold(
      extendBodyBehindAppBar: widget.isExtendBodyBehindAppBar, // appBar是否浮动在body上，方便设置背景层浮动效果
      bottomSheet: widget.bottomSheet, // 底部浮动层
      appBar: (widget.titleWidget != null || widget.title != null)
          ? AppBar(
              elevation: widget.isExtendBodyBehindAppBar ? 0 : widget.elevation,
              toolbarHeight: 50,
              title: widget.titleWidget ??
                  Text(
                    widget.title!,
                    style: TextStyle(
                      fontSize: widget.titleFontSize,
                      color: widget.titleFontColor ?? ColorTheme.font,
                    ),
                  ),
              centerTitle: true,
              backgroundColor: widget.isExtendBodyBehindAppBar ? Colors.transparent : (widget.appBarBackColor ?? ColorTheme.body),
              shadowColor: widget.isExtendBodyBehindAppBar ? null : ColorTheme.border.withOpacity(.3),
              systemOverlayStyle: widget.systemOverlayStyle,
              flexibleSpace: widget.isExtendBodyBehindAppBar ? null : (widget.showAppBarBackImage
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
                  : null),
              leading: canPop
                  ? ButtonBack(
                      iconColor: widget.titleFontColor ?? ColorTheme.font,
                      shadowShow: false,
                      size: 22,
                    )
                  : null,
              actions: widget.actions,
            )
          : null,
      body: Stack(
        children: [
          if (widget.background != null)
            widget.background!,
          Padding(
            padding: EdgeInsets.only(top: widget.isExtendBodyBehindAppBar ? MediaQuery.of(context).padding.top + 50 : 0.0),
            child: bodyWidget ?? Container(),
          ),
        ],
      ),
      backgroundColor: widget.backgroundColor ?? ColorTheme.background,
      resizeToAvoidBottomInset: widget.resizeToAvoidBottomInset,
      floatingActionButton: widget.floatingActionButton,
      floatingActionButtonLocation:
          widget.floatingActionButtonLocation, // 悬浮按钮位置
      floatingActionButtonAnimator:
          FloatingActionButtonAnimator.scaling, // 悬浮按钮动画
    );
  }
}
