import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:common_plugin/common_plugin.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import "package:intl/intl.dart";



///效验数据是否为空为零或为null
bool isEmptyOrNull(dynamic value) {
  if (value == null || value == 0 || value == "0") {
    return true;
  }

  if (value is String || value is List || value is Map) {
    return value.isEmpty;
  }

  return false;
}

/// 间接等待数据获取成功，用于内部未知造成直接返回null的情况
///等待条件或操作成功才执行后续代码，避免空数据导致报错
///检查条件满足不为null、false跳出循环等待，直接返回数据，超时30秒跳出
///    dynamic value;
///    中间这里为数据获取逻辑
///    result = await awaitDataSuccess((){return value;},timeout:30);
///
Future<dynamic> awaitSuccess(Function valueReturn,
    {int timeout = 30,
    int waitTimeShowLading = 300, // 毫秒，超过指定时间显示加载动画
     }) async {
  int count = 0;
  final maxCount = timeout * 40; // 换算超时的循环次数
  dynamic result;
  late Timer timer;
  timer = Timer(Duration(milliseconds: waitTimeShowLading), (){
    ShowOverScreen.show(LoadingPage(
      onlyShowIcon: true,
      showAppScaffold: false,
    ),autoCloseTime: timeout);
  });
  await Future.doWhile(() async {
    result = valueReturn();
    if (result != null && result != false) {
      ShowOverScreen.remove();
      if (timer.isActive) timer.cancel();
      return false; // 条件满足，跳出循环
    }
    count++;
    if (count > maxCount) {
      return false;
    }
    // 每次循环间隔 50 毫秒
    await Future.delayed(const Duration(milliseconds: 25));
    return true;
  });
  return result;
}

/// 等待指定超时时间后显示加载动画
Future<T> awaitTimeShowLoading<T>(
    Future<T> Function() future,
    {
      BuildContext? context,
      int waitTime = 300, // 毫秒，超过指定时间显示加载动画
      int timeout = 30, // 秒，超时取消时间
    }) async {
  final completer = Completer<T>();
  late Timer timer;
  timer = Timer(Duration(milliseconds: waitTime), (){
    ShowOverScreen.show(LoadingPage(
      onlyShowIcon: true,
      showAppScaffold: false,
    ),autoCloseTime: timeout);
  });

  try {
    final result = await future().timeout(Duration(seconds: timeout));
    completer.complete(result);
    ShowOverScreen.remove();
    if (timer.isActive) timer.cancel();
  } on TimeoutException catch (_) {
    if (timer.isActive) timer.cancel();
    showDebug('加载超时');
  } on Exception catch (e, stackTrace) {
    ShowOverScreen.remove();
    if (timer.isActive) timer.cancel();
    completer.completeError(e, stackTrace);
  }
  return completer.future;
}

/// double 金额格式化
String moneyFormat(double value) {
  NumberFormat format = NumberFormat("0.00");
  return format.format(value);
}

/// 打印自设标识调试信息，通过自定义前缀快速检索输出数据
void showDebug(dynamic value, {String? mark}) {
  if (!kDebugMode) return; // 只在开发环境模式下打印信息
  final effectiveMark = mark != null ? "-$mark:" : ":";
  String jsonString;
  try {
    // 如果 value 是一个 Map 或 List 类型的对象，则将其转换为 JSON 字符串。
    if (value is Map || value is List) {
      jsonString = jsonEncode(value);
    } else {
      jsonString = value.toString();
    }
  } on JsonUnsupportedObjectError catch (error) {
    throw Exception(
      '无法将对象 ${value.runtimeType} 转换为 JSON：${error.toString()}',
    );
  }
  log("\n\n-----------  tishi$effectiveMark  ----------\n$jsonString\n---------------------------------------------\n");
}


///全局Context路由
openTo(
    T, {
      bool checkLogin = false,
      BuildContext? context,
      bool removeAllRoute = false,
    }) async {
  context ??= contextIndex;

  if (removeAllRoute) {
    return await Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (build) {
      return T;
    }),(route) => false);
  }else {
    return await Navigator.of(context).push(MaterialPageRoute(builder: (build) {
      return T;
    }));
  }
}

/// 重启app openToName(Routes.appInit); removeAllRoute = true清除路由，用户不能后退
openToName(String routes,{BuildContext? context,bool removeAllRoute = false}) async {
  context ??= contextIndex;
  if (removeAllRoute){
   await Navigator.of(context).pushNamedAndRemoveUntil(routes, (router) => false);
  }
  else{
   await Navigator.of(context).pushNamed(routes);
  }
}

/// 返回
back<T extends Object?>({T? result,BuildContext? context,}) {
  Navigator.of(context ?? contextIndex).pop(result);
}
