import 'package:common_plugin/common_plugin.dart';
import 'package:flutter/material.dart';

/// 选项卡页签模型
class TabItem {
  /// 页签标题
  final String title;

  /// 页签对应的页面视图，可为空
  final Widget pageView;

  TabItem({required this.title, this.pageView = const Center()});
}

/// 自定义导航栏
class TabBarCustom extends StatefulWidget {
  final List<TabItem> tabItems; // 页签列表
  final int initialIndex; // 初始选中页签索引
  final Color? textColor; // 未选中页签文本颜色
  final double fontSize; // 未选中页签文本大小
  final double selectedFontSize; // 选中页签文本大小
  final Color? selectedTextColor; // 选中页签文本颜色
  final Color? indicatorColor; // 边框线颜色
  final Color? backgroundColor; // 背景颜色
  final Function(int) onChanged; // 页面切换回调
  final EdgeInsetsGeometry tabPadding; // 页签内边距
  final EdgeInsetsGeometry margin; // 导航栏外边距
  final double indicatorTop; // 下划线距离顶部高度
  final double indicatorWidth; // 下划线宽度
  final double indicatorRadius; // 下划线圆角
  final Color? bottomBorderColor; // 导航栏底部边框线颜色
  final double bottomBorderWidth; // 导航栏底部边框线宽度
  final double height; // 导航栏高度
  final MainAxisAlignment mainAxisAlignment; // 导航栏对齐方式
  final bool isShowIndicator; // 是否显示选中下划线边框线

  const TabBarCustom({
    super.key,
    required this.tabItems,
    this.initialIndex = 0,
    this.textColor,
    this.selectedTextColor,
    this.fontSize = 16,
    this.selectedFontSize = 16,
    this.indicatorColor,
    this.backgroundColor,
    required this.onChanged,
    this.margin = const EdgeInsets.symmetric(vertical: 0),
    this.tabPadding = const EdgeInsets.symmetric(horizontal: 15),
    this.indicatorTop = 5,
    this.indicatorWidth = 2.5,
    this.indicatorRadius = 5,
    this.bottomBorderColor,
    this.bottomBorderWidth = 1.5,
    this.height = 40,
    this.mainAxisAlignment = MainAxisAlignment.spaceEvenly,
    this.isShowIndicator = true,
  }) : assert(tabItems.length > 0, 'tabs must not be empty');

  @override
  _TabBarCustomState createState() => _TabBarCustomState();
}

class _TabBarCustomState extends State<TabBarCustom> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.height,
      margin: widget.margin,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: widget.backgroundColor,
        border: Border(
          bottom: BorderSide(
            color: widget.bottomBorderColor ?? ColorTheme.border,
            width: widget.bottomBorderWidth,
          ),
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisAlignment: widget.mainAxisAlignment,
          children: [
            ...widget.tabItems.asMap().keys.map(
                  (index) => InkWell(
                    onTap: () {
                      setState(() {
                        _selectedIndex = index;
                        widget.onChanged(index); // 触发页面切换回调
                      });
                    },
                    splashColor: Colors.transparent,
                    child: Padding(
                      padding: widget.tabPadding,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            widget.tabItems[index].title,
                            style: TextStyle(
                              color: _selectedIndex == index
                                  ? widget.selectedTextColor ?? ColorTheme.main
                                  : widget.textColor ?? const Color(0xDD555555),
                              fontSize: widget.fontSize,
                              fontWeight: _selectedIndex == index
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                            ),
                          ),
                          SizedBox(height: widget.indicatorTop),
                          _selectedIndex == index && widget.isShowIndicator
                              ? LayoutBuilder(
                                  // 绘制选中页签的边框线
                                  builder: (context, constraints) {
                                    final textPainter = TextPainter(
                                      text: TextSpan(
                                        text: widget.tabItems[index].title,
                                        style: TextStyle(
                                          fontSize: widget.selectedFontSize,
                                          color: widget.selectedTextColor ??
                                              ColorTheme.main,
                                        ),
                                      ),
                                      textDirection: TextDirection.ltr,
                                    )..layout(maxWidth: constraints.maxWidth);

                                    return Align(
                                      alignment: Alignment.bottomCenter,
                                      child: Container(
                                        width: textPainter.width +
                                            5, // 文本宽度加上一定的边距
                                        height: widget.indicatorWidth, // 下划线高度
                                        decoration: BoxDecoration(
                                          color: widget.indicatorColor ??
                                              ColorTheme.main,
                                          borderRadius: BorderRadius.circular(
                                              widget.indicatorRadius), // 圆角处理
                                        ),
                                      ),
                                    );
                                  },
                                )
                              : SizedBox(
                                  height: widget.indicatorWidth,
                                ),
                        ],
                      ),
                    ),
                  ),
                ),
          ],
        ),
      ),
    );
  }
}
