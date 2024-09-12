import 'package:common_plugin/common_plugin.dart';
import 'package:flutter/material.dart';

class MenuPopupItem {
  final String text;
  final Color fontColor;
  final double fontSize;
  final FontWeight fontWeight;
  final String? iconAssets;
  final IconData? icon;
  final Function()? onTap;
   MenuPopupItem({required this.text, this.iconAssets, this.icon, this.onTap, this.fontColor = Colors.white, this.fontSize = 14, this.fontWeight = FontWeight.w400,});
}

/// 弹出菜单
class MenuPopup extends StatefulWidget {
  const MenuPopup({
    super.key,
    required this.menus,
    required this.child,
    this.pressType = PressType.longPress,
    this.showArrow = true,
    this.showMenuMaxCount = 6,
    this.backgroundColor = Colors.black,
    this.menuWidth = 130,
    this.onMenuStateChange,
  });



  final List<MenuPopupItem> menus;

  ///在该组件点击或长按弹出菜单actions
  final Widget child;

  ///长按还是单击弹出菜单
  final PressType pressType;

  ///显示箭头标
  final bool showArrow;

  ///该页最多显示多少个菜单项
  final int showMenuMaxCount;

  ///菜单背景色
  final Color backgroundColor;

  ///菜单默认宽度
  final double menuWidth;

  ///弹出菜单回调，true时表示菜单打开，false表示菜单关闭
  final Function(bool)? onMenuStateChange;

  @override
  _MenuPopupState createState() => _MenuPopupState();
}

class _MenuPopupState extends State<MenuPopup> {
  late double width;
  late double height;
  late RenderBox button;
  RenderBox? overlay;
  OverlayEntry? entry;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((call) {
      width = context.size?.width ?? 0;
      height = context.size?.height ?? 0;
      button = context.findRenderObject() as RenderBox;
      overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvokedWithResult: (isPop, result) {
        if (isPop && entry != null) {
          removeOverlay();
        }
      },
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        child: widget.child,
        onTap: () {
          if (widget.pressType == PressType.singleClick) {
            onTap();
          }
        },
        onLongPress: () {
          if (widget.pressType == PressType.longPress) {
            onTap();
          }
        },
      ),
    );
  }

  void onTap() {
    widget.onMenuStateChange?.call(true);
    Widget menuWidget = _MenuPopWidget(
      context,
      height,
      width,
      widget.menus,
      widget.showArrow,
      widget.showMenuMaxCount,
      widget.backgroundColor,
      widget.menuWidth,
      button,
      overlay!,
      (index) {
        removeOverlay();
      },
    );

    entry = OverlayEntry(builder: (context) {
      return menuWidget;
    });
    Overlay.of(context).insert(entry!);
  }

  void removeOverlay() {
    widget.onMenuStateChange?.call(false);
    entry?.remove();
    entry = null;
  }

  @override
  void dispose() {
    super.dispose();
    removeOverlay();
  }
}

enum PressType {
  // 长按
  longPress,
  // 单击
  singleClick,
}

const double _MenuScreenPadding = 8.0;

class _MenuPopWidget extends StatefulWidget {
  final BuildContext btnContext;
  final List<MenuPopupItem> menus;
  final bool showArrow;
  final int _pageMaxChildCount;
  final Color backgroundColor;
  final double menuWidth;
  final double _height;
  final double _width;
  final RenderBox button;
  final RenderBox overlay;
  final ValueChanged<int> onValueCallback;

  _MenuPopWidget(
    this.btnContext,
    this._height,
    this._width,
    this.menus,
    this.showArrow,
    this._pageMaxChildCount,
    this.backgroundColor,
    this.menuWidth,
    this.button,
    this.overlay,
    this.onValueCallback,
  );

  @override
  _MenuPopWidgetState createState() => _MenuPopWidgetState();
}

class _MenuPopWidgetState extends State<_MenuPopWidget> {
  int _curPage = 0;
  final double _arrowWidth = 40;
  final double _separatorWidth = 1;
  final double _triangleHeight = 10;

  late RelativeRect position;

  @override
  void initState() {
    super.initState();
    position = RelativeRect.fromRect(
      Rect.fromPoints(
        widget.button.localToGlobal(Offset.zero, ancestor: widget.overlay),
        widget.button.localToGlobal(Offset.zero, ancestor: widget.overlay),
      ),
      Offset.zero & widget.overlay.size,
    );
  }

  @override
  Widget build(BuildContext context) {
    //统计该页面 child 的数量
    int _curPageChildCount =
        (_curPage + 1) * widget._pageMaxChildCount > widget.menus.length
            ? widget.menus.length % widget._pageMaxChildCount
            : widget._pageMaxChildCount;

    double _curArrowWidth = 0;
    int _curArrowCount = 0; // 计算箭头数量

    if (widget.menus.length > widget._pageMaxChildCount) {
      // 数据长度大于 widget._pageMaxChildCount
      if (_curPage == 0) {
        // 如果是第一页
        _curArrowWidth = _arrowWidth;
        _curArrowCount = 1;
      } else {
        // 如果不是第一页 则需要也显示左箭头
        _curArrowWidth = _arrowWidth * 2;
        _curArrowCount = 2;
      }
    }

    double _curPageWidth = widget.menuWidth +
        (_curPageChildCount - 1 + _curArrowCount) * _separatorWidth +
        _curArrowWidth;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        widget.onValueCallback(-1);
      },
      child: MediaQuery.removePadding(
        context: context,
        removeTop: true,
        removeBottom: true,
        removeLeft: true,
        removeRight: true,
        child: Builder(
          builder: (BuildContext context) {
            //计算箭头true在上面，false在下面
            var isInverted = (position.top +
                    (MediaQuery.of(context).size.height -
                            position.top -
                            position.bottom) /
                        2 -
                    ((widget.menus.length) * 50 + _triangleHeight)) <
                ((widget.menus.length) * 50 + _triangleHeight);
            return CustomSingleChildLayout(
              // 这里计算偏移量
              delegate: _PopupMenuRouteLayout(
                  position,
                  (widget.menus.length) * 50 + _triangleHeight,
                  Directionality.of(widget.btnContext),
                  widget._width,
                  widget.menuWidth,
                  widget._height),
              child: SizedBox(
                height: (widget.menus.length) * 50 + _triangleHeight + 20,
                width: _curPageWidth,
                child: Container(
                  decoration: const BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 3,
                        offset: Offset(5, 5),
                        spreadRadius:0,
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        widget.showArrow
                            ? isInverted
                                ? ((widget.menus.length) * 50 +
                                                    _triangleHeight) /
                                                position.top <
                                            0.8 &&
                                        widget.menus.length > 4
                                    ? Container()
                                    : CustomPaint(
                                        size:
                                            Size(_curPageWidth, _triangleHeight),
                                        painter: TrianglePainter(
                                          color: widget.backgroundColor,
                                          position: position,
                                          isInverted: true,
                                          size: widget.button.size,
                                          screenWidth:
                                              MediaQuery.of(context).size.width,
                                        ),
                                      )
                                : Container()
                            : Container(),
                        Expanded(
                          child: Stack(
                            children: <Widget>[
                              ClipRRect(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(5)),
                                child: Container(
                                  color: widget.backgroundColor,
                                ),
                              ),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  _buildList(_curPageChildCount, _curPageWidth,
                                      _curArrowWidth, _curArrowCount),
                                ],
                              ),
                            ],
                          ),
                        ),
                        widget.showArrow
                            ? isInverted
                                ? Container()
                                : CustomPaint(
                                    size: Size(_curPageWidth, _triangleHeight),
                                    painter: TrianglePainter(
                                      color: widget.backgroundColor,
                                      position: position,
                                      size: widget.button.size,
                                      screenWidth:
                                          MediaQuery.of(context).size.width,
                                    ),
                                  )
                            : Container(),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildList(int _curPageChildCount, double _curPageWidth,
      double _curArrowWidth, int _curArrowCount) {
    return ListView.separated(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      scrollDirection: Axis.vertical,
      itemCount: _curPageChildCount,
      itemBuilder: (BuildContext context, int index) {
        MenuPopupItem item = widget.menus[_curPage * widget._pageMaxChildCount + index];
        return InkWell(
          onTap: (){
            if (item.onTap != null) {
              item.onTap!();
            }
            widget.onValueCallback(-1);
          },
          child: SizedBox(
            width: (_curPageWidth -
                    _curArrowWidth -
                    (_curPageChildCount - 1 + _curArrowCount) *
                        _separatorWidth) /
                _curPageChildCount,
            height: 50,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.only(left: 20,right: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    if (item.iconAssets != null || item.icon != null)
                      Padding(
                        padding: const EdgeInsets.only(right: 15),
                        child: item.iconAssets != null ? Image.asset(
                          item.iconAssets!,
                          width: 20.0,
                          height: 20.0,
                        ) : Container(
                          width: 20.0,
                          height: 20.0,
                            color: item.fontColor,
                            child: Icon(item.icon,)),
                      ),
                    TextView(
                      item.text,
                      color: item.fontColor,
                      fontSize: item.fontSize,
                      fontWeight: item.fontWeight,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
      separatorBuilder: (BuildContext context, int index) {
        return Container(
          width: widget.menuWidth,
          height: 1,
          color: Colors.grey.withOpacity(0.1),
        );
      },
    );
  }
}

class _PopupMenuRouteLayout extends SingleChildLayoutDelegate {
  _PopupMenuRouteLayout(this.position, this.selectedItemOffset,
      this.textDirection, this.width, this.menuWidth, this.height);

  final RelativeRect position;

  final double selectedItemOffset;

  final TextDirection textDirection;

  final double width;
  final double height;
  final double menuWidth;

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) {
    return BoxConstraints.loose(Size(
        constraints.biggest.width - _MenuScreenPadding * 2.0,
        constraints.biggest.height - _MenuScreenPadding * 2.0));
  }

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    double y;
    y = position.top +
        (size.height - position.top - position.bottom) / 2.0 -
        selectedItemOffset;

    if (position.top +
            (size.height - position.top - position.bottom) / 2 -
            (selectedItemOffset) <
        (selectedItemOffset)) {
      y = position.top;
      if (y < _MenuScreenPadding)
        y = _MenuScreenPadding;
      else if (y + childSize.height >
          size.height - _MenuScreenPadding) //计算超出范围即屏幕居中显示
        y = size.height - childSize.height;
      else if (y < childSize.height * 2) {
        y = position.top + height;
      }
    }

    ///childSize按钮尺寸，size.height屏幕高度，position.top按钮元素距离顶部位置，height元素高度

    ///判断child占用屏幕70%空间和起始位置距离屏幕顶部不到70px，即居中显示
    if (((height/size.height) > 0.7) && position.top < 100) {
      y = size.height / 2 - childSize.height / 2;
    }

    double x;

    if (childSize.width < width) {
      x = position.left + (width - childSize.width) / 2;
    } else {
      if (position.left > size.width - (position.left + width)) {
        if (size.width - (position.left + width) >
            childSize.width / 2 + _MenuScreenPadding) {
          x = position.left - (childSize.width - width) / 2;
        } else {
          x = position.left + width - childSize.width;
        }
      } else if (position.left < size.width - (position.left + width)) {
        if (position.left > childSize.width / 2 + _MenuScreenPadding) {
          x = position.left - (childSize.width - width) / 2;
        } else
          x = position.left;
      } else {
        x = position.right - width / 2 - childSize.width / 2;
      }
    }

    return Offset(x, y);
  }

  @override
  bool shouldRelayout(_PopupMenuRouteLayout oldDelegate) {
    return position != oldDelegate.position;
  }
}

class TrianglePainter extends CustomPainter {
  late Paint _paint;
  final Color color;
  final RelativeRect position;
  final Size size;
  final double radius;
  final bool isInverted;
  final double screenWidth;

  TrianglePainter({
    required this.color,
    required this.position,
    required this.size,
    required this.screenWidth,
    this.radius = 20,
    this.isInverted = false,
  }) {
    _paint = Paint()
      ..style = PaintingStyle.fill
      ..color = color
      ..strokeWidth = 10
      ..isAntiAlias = true;
  }

  @override
  void paint(Canvas canvas, Size size) {
    var path = Path();

    if (size.width > this.size.width) {
      if (position.left + this.size.width / 2 > position.right) {
        if (screenWidth - (position.left + this.size.width) >
            size.width / 2 + _MenuScreenPadding) {
          path.moveTo(size.width / 2, isInverted ? 0 : size.height);
          path.lineTo(
              size.width / 2 - radius / 2, isInverted ? size.height : 0);
          path.lineTo(
              size.width / 2 + radius / 2, isInverted ? size.height : 0);
        } else {
          path.moveTo(size.width - this.size.width + this.size.width / 2,
              isInverted ? 0 : size.height);
          path.lineTo(
              size.width - this.size.width + this.size.width / 2 - radius / 2,
              isInverted ? size.height : 0);
          path.lineTo(
              size.width - this.size.width + this.size.width / 2 + radius / 2,
              isInverted ? size.height : 0);
        }
      } else {
        if (position.left > size.width / 2 + _MenuScreenPadding) {
          path.moveTo(size.width / 2, isInverted ? 0 : size.height);
          path.lineTo(
              size.width / 2 - radius / 2, isInverted ? size.height : 0);
          path.lineTo(
              size.width / 2 + radius / 2, isInverted ? size.height : 0);
        } else {
          path.moveTo(this.size.width / 2, isInverted ? 0 : size.height);
          path.lineTo(
              this.size.width / 2 - radius / 2, isInverted ? size.height : 0);
          path.lineTo(
              this.size.width / 2 + radius / 2, isInverted ? size.height : 0);
        }
      }
    } else {
      path.moveTo(size.width / 2, isInverted ? 0 : size.height);
      path.lineTo(size.width / 2 - radius / 2, isInverted ? size.height : 0);
      path.lineTo(size.width / 2 + radius / 2, isInverted ? size.height : 0);
    }

    path.close();

    canvas.drawPath(
      path,
      _paint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}


/// 下拉菜单选择，显示弹出指示图标
class MenuSelect extends StatefulWidget {
  const MenuSelect({
    super.key,
    required this.text,
    required this.menus,
    this.textFontSize = 14,
    this.textFontColor,
    this.textSelectedFontSize = 14,
    this.selectedTextFontColor,
    this.showArrow = true,
    this.arrowIcon = Icons.arrow_drop_down,
    this.arrowIconUp = Icons.arrow_drop_up,
    this.arrowIconColor,
    this.arrowIconUpColor,
    this.arrowIconSize = 24,
    this.arrowIconUpSize = 24,
    this.showMenuMaxCount = 6,
    this.menuBackgroundColor = Colors.black,
    this.menuWidth = 120,
  });

  /// 按钮文字标题
  final String text;

  /// 文字字体大小
  final double textFontSize;

  /// 文字颜色
  final Color? textFontColor;
  /// 选中文字字体大小
  final double textSelectedFontSize;
  /// 选中文字颜色
  final Color? selectedTextFontColor;

  /// 弹出菜单项列表
  final List<MenuPopupItem> menus;

  ///显示箭头标指示，默认三角向下，弹出后显示三角向上
  final bool showArrow;

  ///弹出前指示图标
  final IconData arrowIcon;
  final double? arrowIconSize;
  final Color? arrowIconColor;

  ///弹出后指示图标
  final IconData arrowIconUp;
  final Color? arrowIconUpColor;
  final double? arrowIconUpSize;

  ///该页最多显示多少个菜单项
  final int showMenuMaxCount;

  ///菜单背景色
  final Color menuBackgroundColor;

  ///菜单默认宽度
  final double menuWidth;
  @override
  State<StatefulWidget> createState() => _MenuSelectState();
}
class _MenuSelectState extends State<MenuSelect> {
  bool _isShowMenu = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MenuPopup(
            menus: widget.menus,
            showMenuMaxCount: widget.showMenuMaxCount,
            backgroundColor: widget.menuBackgroundColor,
            menuWidth: widget.menuWidth,
            pressType: PressType.singleClick,
            onMenuStateChange: (state){
              setState(() {
                _isShowMenu = state;
              });
            },
            child: Row(
              children: [
                TextView(widget.text, fontSize: _isShowMenu ? widget.textSelectedFontSize : widget.textFontSize, color: _isShowMenu ? widget.selectedTextFontColor ?? ColorTheme.main : widget.textFontColor),
                if (widget.showArrow)
                Container(
                      margin: const EdgeInsets.only(left: 5),
                      child: Icon(
                        _isShowMenu ? widget.arrowIconUp : widget.arrowIcon,
                        size: _isShowMenu ? widget.arrowIconUpSize : widget.arrowIconSize,
                        color: _isShowMenu
                            ? widget.arrowIconUpColor ?? ColorTheme.main
                            : widget.arrowIconColor ?? ColorTheme.font,
                      ),
                    ),
              ],
            ),
          );
  }
}
