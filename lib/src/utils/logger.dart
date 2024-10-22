import 'dart:developer';

import 'package:common_plugin/common_plugin.dart';
import 'package:flutter/foundation.dart';

// 日志类型枚举
enum LogType { info, debug, warn, error }

/// 日志记录，调试、信息、警告、错误等类型输出控制台，可自定义标记，以便快速检索，设置上报警告、错误接口，方便追踪及排查问题。
/// 检索技巧：搜索“logger”查看所有类型日志，搜索log-error，查看所有错误
class Logger {
  /// 通用标记，方便定位所有日志
  static String _commonMark = 'logger';

  /// 上报处理回调函数
  static void Function(String message, LogType type, String mark)?
  _reportHandler;

  /// 配置接口
  static void setConfig({
    /// 上报处理回调函数
    Function(
        String message, // 日志内容
        LogType type, // 默认警告、错误类型上报
        String mark, // 日志标记，比如发生错误的方法名
        )? reportHandler,
    String? mark, // 设置通用标记，方便定位所有日志
  }) {
    if (reportHandler != null) {
      _reportHandler = reportHandler;
    }
    if (mark != null) {
      _commonMark = mark;
    }
  }

  /// 打印信息日志
  static void info(Object? message, {String? mark}) {
    final text = toStringWithAll(message);
    mark = mark == null ? "log-info" : "log-info  $mark";
    _log(text, mark: mark);
  }

  /// 打印调试日志
  static void debug(Object? message, {String? mark}) {
    final text = toStringWithAll(message);
    mark = mark == null ? "log-debug" : "log-debug  $mark";
    _log(text, mark: mark);
  }

  /// 打印警告日志
  static void warn(Object? message, {String? mark}) {
    final text = toStringWithAll(message);
    mark = mark == null ? "log-warn" : "log-warn  $mark";
    _log(text, mark: "💡  $mark");
    if (!kDebugMode && _reportHandler != null) {
      _reportHandler!(text, LogType.warn, mark);
    }
  }

  /// 打印错误日志,mark可定义发生错误的方法名
  static void error(Object? message, {String? mark}) {
    final text = toStringWithAll(message);
    mark = mark == null ? "log-error" : "log-error  $mark";
    _log(text, mark: "🔴  $mark");
    if (!kDebugMode && _reportHandler != null) {
      _reportHandler!(text, LogType.error, mark);
    }
  }

  /// 内部日志处理方法
  static void _log(Object? message, {String mark = "log-info"}) {
    if (kDebugMode) {
      String startDash = "${'-' * 20}    $mark    ${'-' * 18}>>";
      String endDash = "${'-' * (startDash.length - 2)}<<";
      if (startDash.length > 130) {
        startDash = "${'-' * 40}>>\n    $mark\n";
        endDash = "${'-' * 40}<<";
      }
      // 构造日志消息
      log(
        "\n$startDash\n$message\n$endDash\n",
        name: _commonMark,
      );
    }
  }
}
