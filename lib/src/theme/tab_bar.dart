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
/// 选项卡样式，1、下划线边框指示，2、圆角按钮背景指示
enum TabBarStyle {line, button,}

/// 自定义导航栏，指示器平滑过渡动画，超出屏幕范围自动居中于容器
class TabBarCustom extends StatefulWidget {
  final List<TabItem> tabItems; // 页签列表
  final TabBarStyle tabBarStyle; // 导航栏样式
  final int initialIndex; // 初始选中页签索引
  final Color? textColor; // 未选中页签文本颜色
  final double fontSize; // 未选中页签文本大小
  final double selectedFontSize; // 选中页签文本大小
  final Color? selectedTextColor; // 选中页签文本颜色
  final Color? indicatorColor; // 边框线颜色
  final Color? backgroundColor; // 背景颜色
  final Function(int) onChanged; // 页面切换回调
  final EdgeInsetsGeometry tabPadding; // 页签内边距
  final double indicatorWidth; // 下划线宽度
  final double indicatorRadius; // 下划线圆角
  final Color? bottomBorderColor; // 导航栏底部边框线颜色
  final double bottomBorderWidth; // 导航栏底部边框线宽度
  final double? height; // 导航栏高度
  final MainAxisAlignment mainAxisAlignment; // 导航栏对齐方式
  final bool isShowIndicator; // 是否显示选中下划线边框线

  const TabBarCustom({
    super.key,
    required this.tabItems,
    this.tabBarStyle = TabBarStyle.line,
    this.initialIndex = 0,
    this.textColor,
    this.selectedTextColor,
    this.fontSize = 16,
    this.selectedFontSize = 16,
    this.indicatorColor,
    this.backgroundColor,
    required this.onChanged,
    this.tabPadding = const EdgeInsets.symmetric(vertical: 10,horizontal: 15),
    this.indicatorWidth = 2.5,
    this.indicatorRadius = 5,
    this.bottomBorderColor,
    this.bottomBorderWidth = 1.5,
    this.height,
    this.mainAxisAlignment = MainAxisAlignment.spaceEvenly,
    this.isShowIndicator = true,
  });

  @override
  State<TabBarCustom> createState() => _TabBarCustomState();
}

class _TabBarCustomState extends State<TabBarCustom> {
  int _selectedIndex = 0;
  final ScrollController _scrollController = ScrollController();
  final List<GlobalKey> _tabKeys = [];

  // 指示器的位置
  double _indicatorLeft = screenSize.width/2;
  // 指示器的宽度
  double _indicatorWidthValue = 50;

  double _indicatorHeightValue = 30;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
    _tabKeys.addAll(List.generate(widget.tabItems.length, (_) => GlobalKey()));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToCenter(_selectedIndex);
      _updateIndicator();
    });
    _scrollController.addListener(_handleScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _scrollController.removeListener(_handleScroll);
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant TabBarCustom oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.tabItems.length != oldWidget.tabItems.length) {
      _tabKeys.clear();
      _tabKeys.addAll(List.generate(widget.tabItems.length, (_) => GlobalKey()));
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _updateIndicator();
      });
    }
  }

  void _handleScroll() {
    if (!_scrollController.position.outOfRange) {
      _updateIndicator();
    }
  }

  void _scrollToCenter(int index) {
    if (_tabKeys[index].currentContext == null) return;
    final RenderBox renderBox = _tabKeys[index].currentContext!.findRenderObject() as RenderBox;
    final size = renderBox.size;
    _indicatorHeightValue = size.height;
    final position = renderBox.localToGlobal(Offset.zero, ancestor: context.findRenderObject());
    final viewWidth = _scrollController.position.viewportDimension; // 组件视图的宽度
    final tabCenter = position.dx + size.width / 2;
    final offset = _scrollController.offset + tabCenter - viewWidth / 2;
    _scrollController.animateTo(
      offset.clamp(
        _scrollController.position.minScrollExtent,
        _scrollController.position.maxScrollExtent,
      ),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeIn,
    ).then((value) {
      _updateIndicator();
    });
  }

  // 更新指示器的位置和宽度
  void _updateIndicator() {
    if (_tabKeys[_selectedIndex].currentContext == null) return;
    final RenderBox selectedTabRenderBox = _tabKeys[_selectedIndex].currentContext!.findRenderObject() as RenderBox;
    final RenderBox stackRenderBox = context.findRenderObject() as RenderBox;

    // 获取选中Tab相对于TabBar的本地位置
    final Offset selectedTabLocalPosition = selectedTabRenderBox.localToGlobal(Offset.zero, ancestor: stackRenderBox);

    setState(() {
      // 设置指示器左侧位置为选中Tab的本地位置
      _indicatorLeft = selectedTabLocalPosition.dx;
      // 设置指示器宽度为选中Tab的宽度
      _indicatorWidthValue = selectedTabRenderBox.size.width;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.height,
      decoration: widget.tabBarStyle == TabBarStyle.button ? BoxDecoration(
        color: widget.backgroundColor ?? ColorTheme.background,
        borderRadius: BorderRadius.circular(50),
      ) : BoxDecoration(
        color: widget.backgroundColor,
        border: Border(
          bottom: BorderSide(
            color: widget.bottomBorderColor ?? ColorTheme.border,
            width: widget.bottomBorderWidth,
          ),
        ),
      ),
      child: Stack(
        children: [
          if (widget.tabBarStyle == TabBarStyle.button)
          AnimatedPositioned(
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
            left: _indicatorLeft,
            child: Container(
              width: _indicatorWidthValue,
              height: widget.height ?? _indicatorHeightValue,
              padding: const EdgeInsets.all(2.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(50),
                  border: Border.all(
                    color: ColorTheme.border,
                    width: 1,
                  ),
                ),
              ),
            ),
          ),
          if (widget.tabBarStyle == TabBarStyle.line && widget.isShowIndicator)
            AnimatedPositioned(
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeInOut,
              left: _indicatorLeft,
              bottom: 0,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: widget.tabPadding.horizontal/2),
                child: Container(
                  width: _indicatorWidthValue - widget.tabPadding.horizontal,
                  height: widget.indicatorWidth,
                  decoration: BoxDecoration(
                    color: widget.indicatorColor ?? ColorTheme.main,
                    borderRadius: BorderRadius.circular(widget.indicatorRadius),
                  ),
                ),
              ),
            ),
          SingleChildScrollView(
            controller: _scrollController,
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: widget.mainAxisAlignment,
              children: [
                ...widget.tabItems.asMap().keys.map(
                      (index) => InkWell(
                    key: _tabKeys[index],
                    onTap: () {
                      setState(() {
                        _selectedIndex = index;
                        widget.onChanged(index); // 触发页面切换回调
                        _scrollToCenter(index); // 滚动到选中的Tab
                      });
                    },
                    splashColor: Colors.transparent,
                    child: Padding(
                      padding: widget.tabPadding,
                      child: Text(
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
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}