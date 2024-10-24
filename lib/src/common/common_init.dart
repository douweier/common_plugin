import 'dart:async';
import 'package:common_plugin/common_plugin.dart';
import 'package:common_plugin/src/common/channel.dart';
import 'package:flutter/material.dart';

class CommonInit extends StatefulWidget {
  /// 进入app的首页
  final Widget home;

  /// 初始化加载，如果不为空则必须返回true或不为null才进入home首页，否则直到超时才进入home首页
  final Future<bool> Function()? loading;

  /// 加载超时时间，单位秒
  final int loadingTimeout;

  /// 加载中页面
  final Widget? loadingPage;

  /// 全局通用配置信息，对主题、字体、日志上报、卡片、按钮、输入、选项卡等各种样式及组件进行全局配置，避免每次使用组件都要挨个设置样式和方法配置。
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

/// 全局通用配置
class CommonConfig {

   /// 其它app通过自定义common://方式打开，返回url回调
   Function(String url)? onOpenUrl;

   CommonConfig({
    this.onOpenUrl,
  });
}

class _CommonInitState extends State<CommonInit> with WidgetsBindingObserver {
  bool canPopExitApp = false; //是否可以返回退出app

  bool isBackend = false; //app为true时处于后端运行，false为活跃可见

  /// 加载的初始化是否完成
  bool loadingInitialized = false;

  /// 定时任务的初始化是否完成
  bool _crontabInitialized = false;

  /// 定时任务计时器
  Timer? _crontabTimer;

  /// 监听url
  StreamSubscription<String>? _linkSubscription;

  @override
  void initState() {
    loading();
    WidgetsBinding.instance.addObserver(this);
    super.initState();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    isBackend = state.index == 0 ? false : true;
    if (state.index == 0) { // 应用处于前台
      _crontabTimer?.cancel();
      _crontabTimer = Timer.periodic(const Duration(seconds: 1), (timer) async {
        await crontabInit(context);
      });
      CommonChannel.initialize();
    } else { // 应用处于后台
      _crontabTimer?.cancel();
      CommonChannel.close();
    }
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
        }, timeout: widget.loadingTimeout, showLoading: false);
      }
      if (widget.config?.onOpenUrl != null) {
        CommonChannel.initialize();
        CommonChannel.getInitialLink().then((link) {
          // 获取应用启动时的初始链接
          if (link != null) {
            widget.config?.onOpenUrl?.call(link);
          }
        });
        CommonChannel.onLinkStream.listen((event) {
          // 应用运行时监听链接事件
          widget.config?.onOpenUrl?.call(event);
        });
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
    _crontabTimer?.cancel();
    // 取消订阅链接流
    _linkSubscription?.cancel();
    Sql.close();
    ShowOverScreen.remove();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
}
