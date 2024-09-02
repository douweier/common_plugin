import 'package:common_plugin/src/common/context.dart';
import 'package:common_plugin/src/theme/icon_text.dart';
import 'package:common_plugin/src/theme/button.dart';
import 'package:common_plugin/src/theme/theme.dart';
import 'package:flutter/material.dart';

bool isWillPopExitApp = true; //默认开启连续点两次返回退出app

///自定义弹出层
showLayer({
  Widget? child,

  ///点击外部区域关闭窗体
  bool barrierDismissible = true,

  ///点击主体界面关闭窗体
  bool clickBodyClose = false,

  ///窗体对齐
  AlignmentGeometry alignment = Alignment.center,

  ///设置时间多少秒自动关闭窗体，默认一直显示
  int autoCloseTime = 0,
  BuildContext? context,
  Color barrierColor = Colors.black54,
  //barrierDismissible为true在层期间禁用Pop返回
  bool wllPopExitApp = false,
}) {
  isWillPopExitApp = wllPopExitApp;

  OverlayEntry? _overlayEntry;
  context = context ?? contextIndex;

  if (autoCloseTime > 0) {
    Future.delayed(Duration(seconds: autoCloseTime), () {
      if (_overlayEntry != null) {
        isWillPopExitApp = true;
        _overlayEntry?.remove();
        _overlayEntry = null;
      }
    });
  }

  Widget _layerWidget = GestureDetector(
    onTap: () {
      if (_overlayEntry != null && barrierDismissible) {
        isWillPopExitApp = true;
        _overlayEntry?.remove();
        _overlayEntry = null;
      }
    },
    child: PopScope(
      canPop: false,
      child: Material(
        color: Colors.transparent,
        child: Container(
          color: barrierColor,
          width: screenSize.width,
          height: screenSize.height,
          child: Align(
            alignment: alignment,
            child: GestureDetector(
              onTap: () {
                if (_overlayEntry != null && clickBodyClose) {
                  isWillPopExitApp = true;
                  _overlayEntry?.remove();
                  _overlayEntry = null;
                }
              },
              child: child,
            ),
          ),
        ),
      ),
    ),
  );

  if (_overlayEntry == null) {
    _overlayEntry = OverlayEntry(
        builder: (BuildContext context) => SafeArea(child: _layerWidget));
    Overlay.of(context).insert(_overlayEntry!);
  }
}

enum AlertStyle {
  none,
  alert,
  success,
  error,
}

///提醒层
showAlert(
  String text, {
  ///窗体对齐
  AlignmentGeometry alignment = Alignment.bottomCenter,
  Color? fontColor,

  ///提醒样式类型
  AlertStyle alertStyle = AlertStyle.none,

  ///文本前显示图标
  IconData? icon,

  ///图标颜色
  Color? iconColor,

  ///距离顶部距离比重
  double topRatio = 0.1,

  ///距离底部距离比重
  double bottomRatio = 0.3,

  ///垂直内填充间距
  double paddingVertical = 25.0,

  ///水平内填充间距
  double paddingHorizontal = 15.0,

  ///提醒层背景颜色
  Color? backgroundColor,

  ///窗体外区域颜色
  Color barrierColor = Colors.black45,

  ///设置时间多少秒自动关闭窗体，默认一直显示
  int autoCloseTime = 1,
  double? width,
  double radius = 50.0,
  Color borderColor = const Color(0x4DFFFFFF),
  double borderWidth = 2,
  //barrierDismissible为true在层期间禁用Pop返回
  bool isWillPopExitApp = false,
}) {
  if (alertStyle == AlertStyle.error) {
    autoCloseTime = 3;
    backgroundColor = ColorTheme.black.withOpacity(0.5);
    borderColor = ColorTheme.white.withOpacity(0.7);
    icon = Icons.warning_amber_outlined;
    iconColor = ColorTheme.red;
  } else if (alertStyle == AlertStyle.success) {
    icon = Icons.done;
    iconColor = ColorTheme.green.withOpacity(0.7);
  } else if (alertStyle == AlertStyle.alert) {
    backgroundColor = ColorTheme.black.withOpacity(0.5);
  }

  if (width == null) {
    width = text.length * 25.0;
  }

  if (width > screenSize.width * 0.9) {
    width = screenSize.width * 0.9;
  } else if (width < 200) {
    width = 200.0;
  }
  //如果弹出键盘，则居中显示
  if (screenSize.height - MediaQuery.of(contextIndex).viewInsets.bottom <
      screenSize.height * 0.7) {
    alignment = Alignment.center;
  }

  showLayer(
      alignment: alignment,
      clickBodyClose: true,
      barrierDismissible: true,
      barrierColor: barrierColor,
      autoCloseTime: autoCloseTime,
      wllPopExitApp: isWillPopExitApp,
      child: Container(
          constraints: BoxConstraints(
            maxHeight: screenSize.height * 0.7,
            maxWidth: width,
          ),
          margin: EdgeInsets.only(
              bottom: screenSize.height * bottomRatio,
              top: screenSize.height * topRatio),
          padding: EdgeInsets.symmetric(
              vertical: paddingVertical, horizontal: paddingHorizontal),
          decoration: BoxDecoration(
            color: backgroundColor ?? ColorTheme.main.withOpacity(.5),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(radius),
              topRight: Radius.circular(radius),
              bottomLeft: Radius.circular(0),
              bottomRight: Radius.circular(radius),
            ),
            border: new Border.all(color: borderColor, width: borderWidth),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null)
                IconText(
                  icon,
                  color: iconColor!,
                ),
              SizedBox(
                width: 10,
              ),
              Expanded(
                child: TextView(
                  text,
                  color: fontColor ?? ColorTheme.white,
                  maxLines: 10,
                  shadowShow: true,
                ),
              ),
            ],
          )));
}

/// type=0默认显示醒目蓝色ok和cancel按钮，  1只提示ok按钮，  2安全提示，不引导用户选择
/// 对话框弹出层
Future showDialogLayer({
  String? content,
  String cancel = "取消",
  String ok = "确定",
  String? title,
  int type = 0,
  Widget? child,
  Color backgroundColor = const Color(0xe6ffffff),
  Function()? onOkCallBack,
  Function()? onCancelCallBack,
  double? maxWidth,
  double? maxHeight,
  bool barrierDismissible = true,
  bool clickBodyClose = false,
  BuildContext? context,
  Color barrierColor = Colors.black12,
}) async {
  isWillPopExitApp = false; //barrierDismissible为true在层期间禁用Pop返回

  OverlayEntry? _overlayEntry;

  context = context ?? contextIndex;

  Widget _layerWidget = GestureDetector(
    onTap: () {
      if (_overlayEntry != null && barrierDismissible) {
        isWillPopExitApp = true;
        _overlayEntry?.remove();
        _overlayEntry = null;
      }
    },
    child: Container(
      color: barrierColor,
      child: Center(
        child: GestureDetector(
          onTap: () {
            if (clickBodyClose) {
              if (_overlayEntry != null) {
                isWillPopExitApp = true;
                _overlayEntry?.remove();
                _overlayEntry = null;
              }
            }
          },
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(5)),
              color: backgroundColor,
              boxShadow: [
                BoxShadow(
                    color: Colors.black45,
                    offset: Offset(5, -8),
                    blurRadius: 10.0, //阴影模糊程度
                    spreadRadius: 0.7 //阴影扩散程度
                    ),
              ],
            ),
            padding:
                const EdgeInsets.only(top: 25, bottom: 7, left: 10, right: 10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (title?.isNotEmpty ?? false)
                  Padding(
                    padding: const EdgeInsets.only(left: 16, right: 16, top: 0),
                    child: Column(
                      children: [
                        TextView(title ?? "", color: Color(0xff444444)),
                        SizedBox(
                          height: 5,
                        ),
                        Divider(),
                      ],
                    ),
                  ),
                Container(
                  padding: EdgeInsets.only(
                    right: 10,
                    left: 10,
                    top: (title?.isNotEmpty ?? false) ? 10 : 20,
                  ),
                  child: Scrollbar(
                    // 为Scrollbar指定一个控制器，与SingleChildScrollView共享
                    controller: ScrollController(),
                    thickness: 4.0, // 可选，自定义滚动条厚度
                    radius: const Radius.circular(2.0), // 可选，滚动条圆角
                    child: SingleChildScrollView(
                      controller: ScrollController(),
                      child: child != null
                          ? child
                          : TextView(
                              "${content}",
                              maxLines: 6,
                            ),
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.only(top: 20),
                  height: 50,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      if (type != 1)
                        ButtonView(
                          text: cancel,
                          onPressed: () {
                            if (onCancelCallBack != null) {
                              onCancelCallBack.call();
                            }
                            if (_overlayEntry != null) {
                              isWillPopExitApp = true;
                              _overlayEntry?.remove();
                              _overlayEntry = null;
                            }
                          },
                          borderColor: Colors.black12,
                          backgroundColor: Colors.white,
                          fontColor: ColorTheme.font,
                          fontSize: 14,
                          width: 120,
                          height: 38,
                        ),
                      ButtonView(
                        text: ok,
                        onPressed: () {
                          if (_overlayEntry != null) {
                            isWillPopExitApp = true;
                            _overlayEntry?.remove();
                            _overlayEntry = null;
                          }
                          if (onOkCallBack != null) {
                            onOkCallBack.call();
                          }
                        },
                        fontSize: 14,
                        backgroundColor:
                            type == 2 ? Colors.white : ColorTheme.main,
                        borderColor:
                            type == 2 ? Colors.black12 : Colors.transparent,
                        fontColor: type == 2 ? Colors.red : Colors.white,
                        width: 120,
                        height: 38,
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    ),
  );

  if (_overlayEntry == null) {
    _overlayEntry = OverlayEntry(
        builder: (BuildContext context) => Material(
            color: Colors.transparent, child: SafeArea(child: _layerWidget)));
    Overlay.of(context).insert(_overlayEntry!);
  }
}

class ShowDragLayer {
  static OverlayEntry? _holder;

  static Widget? child;

  static bool showShadow = true;

  static BorderRadiusGeometry borderRadius = BorderRadius.circular(5);

  static double? top;

  static void set({bool? showShadow2, BorderRadiusGeometry? borderRadius2}) {
    if (showShadow2 != null) {
      showShadow = showShadow2;
    }
    if (borderRadius2 != null) {
      borderRadius = borderRadius2;
    }
    Future.delayed(const Duration(milliseconds: 100));
    _holder?.markNeedsBuild();
  }

  static void remove() {
    if (_holder != null) {
      _holder?.remove();
      _holder = null;
    }
  }

  static void show(
      {BuildContext? context,
      @required Widget? child,
      bool showShadow = true,
      BorderRadiusGeometry? borderRadius}) {
    ShowDragLayer.child = child;
    ShowDragLayer.showShadow = showShadow;
    if (borderRadius != null) {
      ShowDragLayer.borderRadius = borderRadius;
    }

    remove();
    //创建一个OverlayEntry对象
    OverlayEntry overlayEntry = new OverlayEntry(builder: (context) {
      return new Positioned(
          top: top ?? MediaQuery.of(context).size.height * 0.3,
          left: 10,
          child: _buildDraggable(context));
    });

    //往Overlay中插入插入OverlayEntry

    Overlay.of(context ?? contextIndex).insert(overlayEntry);

    _holder = overlayEntry;
  }

  static _buildDraggable(context) {
    return new Draggable(
      ///默认释放状态显示Widget
      child: Material(
        color: Colors.transparent,
        child: Container(
            decoration: BoxDecoration(
              borderRadius: borderRadius,
              boxShadow: showShadow
                  ? [
                      BoxShadow(
                          color: Colors.black45,
                          blurRadius: 10.0, //阴影模糊程度
                          spreadRadius: 0.3 //阴影扩散程度
                          ),
                    ]
                  : [],
            ),
            child: child),
      ),

      ///按住窗体显示的Widget
      feedback: Container(
          decoration: BoxDecoration(
            borderRadius: borderRadius,
            boxShadow: showShadow
                ? [
                    BoxShadow(
                        color: Colors.lightBlue,
                        blurRadius: 10.0, //阴影模糊程度
                        spreadRadius: 0.3 //阴影扩散程度
                        ),
                  ]
                : [],
          ),
          child: child),
      onDragStarted: () {
        print('onDragStarted:');
      },
      onDragEnd: (detail) {
        print('onDragEnd:${detail.offset}');
        createDragTarget(offset: detail.offset, context: context);
      },
      childWhenDragging: Container(),
    );
  }

  static void refresh() {
    _holder?.markNeedsBuild();
  }

  static void createDragTarget(
      {Offset offset = const Offset(0, 0), BuildContext? context}) {
    if (_holder != null) {
      _holder?.remove();
    }

    _holder = OverlayEntry(builder: (context) {
      bool isLeft = true;
      if (offset.dx + 10 > MediaQuery.of(context).size.width / 2) {
        isLeft = false;
      }

      double maxY = MediaQuery.of(context).size.height - 500;

      return Positioned(
          top: (offset.dy < 70
              ? 70
              : offset.dy < maxY
                  ? offset.dy
                  : maxY),
          left: isLeft ? 10 : null,
          right: isLeft ? null : 10,
          child: DragTarget(
            onWillAcceptWithDetails: (data) {
              print('onWillAccept: $data');
              return true;
            },
            onAcceptWithDetails: (data) {
              print('onAccept: $data');
              // refresh();
            },
            onLeave: (data) {
              print('onLeave');
            },
            builder: (BuildContext context, List incoming, List rejected) {
              return _buildDraggable(context);
            },
          ));
    });

    Overlay.of(context ?? contextIndex).insert(_holder!);
  }
}
