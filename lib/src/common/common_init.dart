import 'dart:async';
import 'package:common_plugin/common_plugin.dart';
import 'package:flutter/material.dart';

class CommonInit extends StatefulWidget {
  /// 进入app的首页
  final Widget home;

  /// 初始化加载，如果不为空则必须返回true或不为null才进入home首页，否则直到超时才进入home首页
  final Future<bool> Function()? loading;

  /// 加载超时时间，单位秒
  final int loadingTimeout;

  // 加载中页面
  final Widget? loadingPage;

  // 全局通用配置信息，对主题、字体、日志上报、卡片、按钮、输入、选项卡等各种样式及组件进行全局配置，避免每次使用组件都要挨个设置样式和方法配置。
  final CommonConfig? config;

  const CommonInit({
    super.key,
    required this.home,
    this.loading,
    this.loadingTimeout = 30,
    this.loadingPage,
    this.config,
  });

  @override
  State<CommonInit> createState() => _CommonInitState();
}

class CommonConfig {}

class _CommonInitState extends State<CommonInit> with WidgetsBindingObserver {
  bool canPopExitApp = false; //是否可以返回退出app

  bool isBackend = false; //app为true时处于后端运行，false为活跃可见

  ///加载的初始化是否完成
  bool loadingInitialized = false;

  ///定时任务的初始化是否完成
  bool _crontabInitialized = false;

  ///定时任务计时器
  Timer? _crontabTimer;

  @override
  void initState() {
    loading();
    WidgetsBinding.instance.addObserver(this);
    super.initState();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    isBackend = state.index == 0 ? false : true;
    super.didChangeAppLifecycleState(state);
  }

  @override
  Widget build(BuildContext context) {
    Contexts.init(context);

    return PopScope(
      canPop: canPopExitApp,
      child: loadingInitialized
          ? widget.home
          : (widget.loadingPage != null
              ? widget.loadingPage!
              : const LoadingPage(
                  onlyShowIcon: true,
                )),
      onPopInvokedWithResult: (bool isWillPopExitApp, _) async {
        if (!canPopExitApp) {
          setState(() {
            canPopExitApp = true;
          });
          showAlert('再次按下返回退出', isWillPopExitApp: true);
          await Future.delayed(const Duration(seconds: 1), () {
            if (mounted) {
              setState(() {
                canPopExitApp = false;
              });
            }
          });
        }
      },
    );
  }

  ///加载的初始化
  Future loading() async {
    if (loadingInitialized) {
      return;
    }
    try {
      await AppInfo.getInfo();
      if (widget.loading != null) {
        dynamic res;
        widget.loading?.call().then((value) => res = value);
        await awaitWhileSuccess(() {
          return res;
        }, timeout: widget.loadingTimeout,showLoading: false);
      }
    } catch (e) {
      Logger.error("$e", mark: "loading-error");
    }
    loadingInitialized = true;
    if (mounted) {
      setState(() {});
    }

    if (!_crontabInitialized && _crontabTimer == null) {
      _crontabInitialized = true;
      _crontabTimer = Timer.periodic(const Duration(seconds: 1), (timer) async {
        await crontabInit(context);
      });
    }
  }

  ///定时任务事件处理 (频率每秒)
  Future crontabInit(BuildContext context) async {}

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _crontabTimer?.cancel();
    Sql.close();
    ShowOverScreen.remove();
    super.dispose();
  }
}
