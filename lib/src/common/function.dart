import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:common_plugin/common_plugin.dart';
import 'package:flutter/material.dart';
import "package:intl/intl.dart";
import 'package:path_provider/path_provider.dart';

///效验数据是否为空为零或为null
bool isEmptyOrNull(dynamic value) {
  if (value == null || value == 0 || value == "0") {
    return true;
  }

  if (value is String && value.trim().isEmpty) {
    return true;
  }

  if (value is List || value is Map) {
    return value.isEmpty;
  }

  return false;
}


///   循环检查变量值直到条件满足不为null、false跳出循环等待，直接返回数据，超时30秒跳出
///    dynamic value;
///    中间这里为数据获取逻辑
///    result = await awaitWhileSuccess((){return value;},timeout:30); // 注意return内不能直接放方法，不然多次执行，必须为数据值
///
Future<T> awaitWhileSuccess<T>(
 T Function() valueReturn, {
  int timeout = 30,
  int waitTimeShowLading = 300, // 毫秒，超过指定时间显示加载动画
  bool showLoading = true, // 是否显示加载动画
}) async {
  int count = 0;
  final maxCount = timeout * 40; // 换算超时的循环次数
  dynamic result;
  Timer? timer;
  if (showLoading) {
    timer = Timer(Duration(milliseconds: waitTimeShowLading), () {
      ShowOverScreen.show(
          const LoadingPage(
            onlyShowIcon: true,
            showAppScaffold: false,
          ),
          autoCloseTime: timeout);
    });
  }
  try {
    await Future.doWhile(() async {
      result = valueReturn();
      if (result != null && result != false) {
        if (showLoading) {
          ShowOverScreen.remove();
          if (timer != null) timer.cancel();
        }
        return false; // 条件满足，跳出循环
      }
      count++;
      if (count > maxCount) {
        return false;
      }
      // 每次循环间隔 50 毫秒
      await Future.delayed(const Duration(milliseconds: 25));
      return true;
    }).timeout(Duration(seconds: timeout), onTimeout: () {
      // 超时处理逻辑
      if (showLoading) {
      ShowOverScreen.remove();
      if (timer != null) timer.cancel();
      }
      Logger.warn('请求超时', mark: 'awaitSuccess');
      return result;
    });
  } catch (e) {
    if (showLoading) {
      ShowOverScreen.remove();
      if (timer != null) timer.cancel();
    }
    Logger.error('error: $e', mark: 'awaitSuccess');
    return result;
  }
  return result;
}

/// 等待指定超时时间后显示加载动画
Future<T?> awaitTimeShowLoading<T>(
  Future<T> Function() future, {
  BuildContext? context,
  int waitTime = 300, // 毫秒，超过指定时间显示加载动画
  int timeout = 30, // 秒，超时取消时间
}) async {
  final completer = Completer<T?>();
  late Timer timer;
  timer = Timer(Duration(milliseconds: waitTime), () {
    ShowOverScreen.show(
        const LoadingPage(
          onlyShowIcon: true,
          showAppScaffold: false,
        ),
        autoCloseTime: timeout);
  });

  try {
    final result = await future().timeout(Duration(seconds: timeout));
    completer.complete(result);
    ShowOverScreen.remove();
    if (timer.isActive) timer.cancel();
  } on TimeoutException catch (_) {
    if (timer.isActive) timer.cancel();
    Logger.warn('加载超时', mark: 'awaitTimeShowLoading');
    completer.complete();
  } on Exception catch (e, stackTrace) {
    ShowOverScreen.remove();
    if (timer.isActive) timer.cancel();
    Logger.error('加载失败：$e\n$stackTrace', mark: 'awaitTimeShowLoading');
    completer.complete();
  }
  return completer.future;
}

/// 金额格式化为2位小数，解析int、double、String等类型，onlyOne=true只保留一位小数
String moneyFormat(dynamic value, {bool onlyOne = false}) {
  if (isEmptyOrNull(value)) {
    value = 0;
  } else if (value is String) {
    value = double.parse(value);
  } else if (value is int) {
    value = value.toDouble();
  } else {
    value = 0;
  }
  if (onlyOne) {
    NumberFormat format = NumberFormat("0.0");
    return format.format(value);
  }
  NumberFormat format = NumberFormat("0.00");
  return format.format(value);
}

/// 将任何对象类型转为字符串
String toStringWithAll(Object? object) {
  String value = '';
  try {
    if (object is String) {
      value = object;
    } else if (object is Map || object is List) {
      value = jsonEncode(object);
    } else {
      value = object.toString();
    }
  } catch (e) {
    Logger.error('无法将对象 ${object.runtimeType} 转换：$e', mark: 'toStringWithAll');
  }
  return value;
}

/// 打开导航页面
toNav(
  T, {
  bool checkLogin = false,
  BuildContext? context,
  bool removeAllRoute = false, // 清除所有路由，用户不能后退
  bool removeReplace = false, // 替换当前路由
}) async {
  context ??= contextIndex;

  if (removeAllRoute) {
    return await Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (build) {
      return T;
    }), (route) => false);
  } else if (removeReplace) {
    return await Navigator.of(context).pushReplacement(MaterialPageRoute(
      builder: (context) => T,
    ));
  } else {
    return await Navigator.of(context).push(MaterialPageRoute(builder: (build) {
      return T;
    }));
  }
}

/// 重启app toNavName(Routes.appInit); removeAllRoute = true清除路由，用户不能后退
toNavName(String routes,
    {BuildContext? context, bool removeAllRoute = false}) async {
  context ??= contextIndex;
  if (removeAllRoute) {
    await Navigator.of(context)
        .pushNamedAndRemoveUntil(routes, (router) => false);
  } else {
    await Navigator.of(context).pushNamed(routes);
  }
}

/// 返回
back<T extends Object?>({
  T? result,
  BuildContext? context,
}) {
  Navigator.of(context ?? contextIndex).pop(result);
}

///获取用户保存的文件目录
Future<String> getPathUserFile() async {
  var cachePath =
      Directory("${(await getApplicationDocumentsDirectory()).path}/file");
  if (!cachePath.existsSync()) {
    cachePath.create();
  }
  return cachePath.path;
}

///获取下载文件缓存目录
Future<String> getPathDownload() async {
  var cachePath =
      Directory("${(await getApplicationDocumentsDirectory()).path}/download");
  if (!cachePath.existsSync()) {
    cachePath.create();
  }
  return cachePath.path;
}

///获取永久缓存目录，由app管理缓存
Future<String> getPathCache() async {
  var cachePath =
      Directory("${(await getApplicationDocumentsDirectory()).path}/cache");
  if (!cachePath.existsSync()) {
    cachePath.create();
  }
  return cachePath.path;
}

///获取临时缓存总目录，会被系统自动清理
Future<String> getPathCacheTemp() async {
  var cachePath = Directory("${(await getTemporaryDirectory()).path}/cache");
  if (!cachePath.existsSync()) {
    cachePath.create();
  }
  return cachePath.path;
}
