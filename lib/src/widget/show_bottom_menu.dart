import 'package:common_plugin/common_plugin.dart';
import 'package:flutter/material.dart';

// 枚举关闭按钮显示位置样式，默认右上角，有左上角、底部
enum CloseMenuPosition {
  topRight,
  topLeft,
  bottomCenter,
}

Future showBottomMenu({
  required List<MenuItem> menus,
  BuildContext? context,
  String? title, // 弹窗标题
  bool isDismissible = true,
  CloseMenuPosition closeMenuPosition =
      CloseMenuPosition.bottomCenter, // 枚举关闭按钮显示位置样式，默认右上角，有左上角、底部
}) async {
  return await showBottomLayer(
    context: context ?? contextIndex,
    isDismissible: isDismissible,
    title: title,
    showHeader: closeMenuPosition == CloseMenuPosition.topRight ||
        closeMenuPosition == CloseMenuPosition.topLeft,
    closeMenuPosition: closeMenuPosition,
    padding: const EdgeInsets.only(bottom: 0),
    child: Container(
      decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(10),
            topRight: Radius.circular(10),
          )),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
              width: double.infinity,
              child: Column(
                children: menus.map((e) {
                  return Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: TextButton(
                          child: TextView(
                            e.text,
                            fontSize: 16,
                          ),
                          onPressed: () async {
                            back(result: true);
                            if (e.onTap != null) {
                              await e.onTap!();
                            }
                          },
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(color: ColorTheme.border),
                        height: 1,
                      ),
                    ],
                  );
                }).toList(),
              )),
          if (closeMenuPosition == CloseMenuPosition.bottomCenter)
            Column(
              children: [
                Container(
                  decoration: BoxDecoration(color: ColorTheme.border),
                  height: 5,
                ),
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: TextButton(
                    child: const TextView(
                      "取消",
                      fontSize: 16,
                    ),
                    onPressed: () async {
                      back(result: false);
                    },
                  ),
                ),
              ],
            ),
        ],
      ),
    ),
  );
}

/// 底部弹窗，根据child高度自适应，可支持键盘弹出输入且不会被遮挡
Future showBottomLayer({
  required Widget child,
  String? title, // 弹窗标题
  bool showHeader = true, // 是否显示头部，默认显示关闭按钮
  bool showHeaderBorder = true, // 是否显示头部分割线
  BuildContext? context,
  bool isDismissible = true, //是否点击背景关闭
  CloseMenuPosition closeMenuPosition =
      CloseMenuPosition.topRight, // 关闭按钮显示位置样式，默认右上角，有左上角、底部
  double? height,
  double? width,
  Color? backgroundColor, // 窗体背景颜色
  BorderRadius borderRadius = const BorderRadius.only(
    // 窗体圆角
    topLeft: Radius.circular(20),
    topRight: Radius.circular(20),
  ),
  EdgeInsetsGeometry? padding = const EdgeInsets.only(bottom: 20), // 弹窗内边距
}) async {
  return await showModalBottomSheet(
    context: context ?? contextIndex,
    backgroundColor: Colors.transparent,
    isScrollControlled: true, // 是否自适应高度
    isDismissible: isDismissible,
    useSafeArea: true, // 是否使用安全区域
    enableDrag: true, // 是否可以拖动,
    builder: (context) {
      return SingleChildScrollView(
        child: Container(
          height: height,
          width: width,
          margin: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          padding: padding,
          decoration: BoxDecoration(
            color: backgroundColor ?? ColorTheme.white,
            borderRadius: borderRadius,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (showHeader)
                Container(
                    padding: const EdgeInsets.all(10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(
                          width: 40,
                          child: Visibility(
                            visible:
                                closeMenuPosition == CloseMenuPosition.topLeft,
                            child: const ButtonBack(),
                          ),
                        ),
                        Expanded(
                          child: Center(
                            child: TextView(
                              title ?? "",
                              fontSize: 16,
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 40,
                          child: Visibility(
                            visible:
                                closeMenuPosition == CloseMenuPosition.topRight,
                            child: ButtonIcon(
                              icon: Icons.close,
                              color: ColorTheme.fontLight,
                              iconSize: 20,
                              shadowShow: false,
                              backgroundColor: Colors.grey.withOpacity(0.1),
                              onTap: () {
                                Navigator.pop(context);
                              },
                              iconPadding: const EdgeInsets.all(5),
                            ),
                          ),
                        ),
                      ],
                    )),
              if (showHeader && showHeaderBorder)
                const Divider(
                  height: 1,
                ),
              child,
            ],
          ),
        ),
      );
    },
  );
}
