
import 'package:common_plugin/common_plugin.dart';
import 'package:flutter/widgets.dart';

///屏幕显示widget层,可以在任意页面直接弹出
class ShowOverScreen {
  static OverlayEntry? overlayEntry;

  static void show( Widget child, {
    BuildContext? context,
    int? autoCloseTime,
  }) {
      if (overlayEntry == null) {
        overlayEntry = OverlayEntry(
            builder: (BuildContext context) => SafeArea(child: child));
        Overlay.of(context ?? contextIndex).insert(overlayEntry!);
        if (autoCloseTime != null) {
          Future.delayed(Duration(seconds: autoCloseTime), () {
            ShowOverScreen.remove();
          });
        }
      }
  }

  static void remove() {
    if (overlayEntry != null) {
          overlayEntry?.remove();
          overlayEntry = null;
        }
  }
}
