import 'dart:async';
import 'package:flutter/services.dart';

class CommonChannel {
  static const MethodChannel _methodChannel = MethodChannel('common_plugin');
  static const EventChannel _eventChannel = EventChannel('common_plugin/events');

  static final StreamController<String> _onLinkStream = StreamController<String>.broadcast();
  static bool _isListening = false;


  /// 初始化插件，设置方法调用处理器并监听事件通道
  static void initialize() {
    if (_isListening) {
      return;
    }
    _isListening = true;
    // 监听事件通道，接收来自原生端的 URL
    _eventChannel.receiveBroadcastStream().listen((event) {
      if (event is String) {
        _onLinkStream.add(event);
      }
    });

    // 设置 MethodCallHandler
    _methodChannel.setMethodCallHandler(_handleMethod);
  }

  /// 处理来自原生端的方法调用
  static Future<void> _handleMethod(MethodCall call) async {

  }

  /// 获取链接的 Stream
  static Stream<String> get onLinkStream => _onLinkStream.stream;

  /// 获取应用启动时的初始链接
  static Future<String?> getInitialLink() async {
    final String? url = await _methodChannel.invokeMethod<String>('getInitialLink');
    return url;
  }

  /// 获取平台版本号
  static Future<String?> getPlatformVersion() async {
    final version = await _methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }

  /// 关闭 StreamController
  static void close() {
    _onLinkStream.close();
    _isListening = false;
  }
}