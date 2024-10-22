import 'package:common_plugin/common_plugin.dart';
import 'package:flutter/material.dart';

class RadioView extends StatefulWidget {
  final String? label; // 标签
  final Widget? labelWidget; // 标签自定义组件
  final bool isSelected; // 是否选中
  final bool onlySelected;  // true只能选中，false可以取消和选中
  final bool isDotStyle;  // true为圆点样式，false为勾选样式
  final bool readOnly; // 是否只读
  final double size; // 大小
  final EdgeInsetsGeometry padding; // 内边距
  final Color? selectedColor; // 选中颜色
  final Color? unselectedColor; // 未选中颜色
  final Function(bool selected)? onChanged; // 回调
  final IconData selectedIcon; // 选中图标
  final IconData unselectedIcon; // 未选中图标

  const RadioView({
    super.key,
    this.label,
    this.labelWidget,
    this.isSelected = false,
    this.onlySelected = false,
    this.isDotStyle = false,
    this.readOnly = false,
    this.size = 22.0,
    this.padding = const EdgeInsets.symmetric(vertical: 5,horizontal: 10),
    this.selectedColor,
    this.unselectedColor,
    this.onChanged,
    this.selectedIcon = Icons.check_rounded,
    this.unselectedIcon = Icons.radio_button_off,
  });

  @override
  State<RadioView> createState() => _RadioViewState();
}

class _RadioViewState extends State<RadioView> {
  late bool _isSelected;
  AnimateController? controller;

  @override
  void initState() {
    super.initState();
    controller = AnimateController();
    _isSelected = widget.isSelected;
  }

  void _toggleSelection() {
    if (widget.readOnly) return;
    if (widget.onlySelected && _isSelected) return;
      if (widget.onlySelected) {
        _isSelected = true;
      } else {
        _isSelected = !_isSelected;
      }
      widget.onChanged?.call(_isSelected);
      if (_isSelected) {
        controller?.start();
      }
  }


  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: _toggleSelection,
      child: Padding(
        padding: widget.padding,
        child: Row(
          children: [
            AnimateView(
                controller: controller,
                beginValue: 0.6,
                endValue: 0,
                duration: const Duration(milliseconds: 800),
                builder: (value) {
                  if (widget.isDotStyle) {
                    return Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: _isSelected
                            ? [
                                BoxShadow(
                                  color: widget.selectedColor ??
                                      ColorTheme.main.withOpacity(value),
                                  spreadRadius: 1,
                                  blurRadius: 3,
                                  offset: const Offset(0, 0),
                                ),
                              ]
                            : [],
                      ),
                      child: Center(
                        child: _isSelected
                            ? Icon(
                                Icons.radio_button_checked_rounded,
                                color: widget.unselectedColor ?? ColorTheme.main,
                                size: widget.size,
                              )
                            : Icon(
                                widget.unselectedIcon,
                                color: widget.unselectedColor ?? Colors.black26,
                                size: widget.size,
                              ),
                      ),
                    );
                   }
                  return Container(
                    padding: _isSelected ? const EdgeInsets.all(3) : null,
                    decoration: BoxDecoration(
                      color: _isSelected
                          ? (widget.selectedColor ?? ColorTheme.main)
                          : null,
                      shape: BoxShape.circle,
                      boxShadow: _isSelected
                          ? [
                              BoxShadow(
                                color: widget.selectedColor ??
                                    ColorTheme.main.withOpacity(value),
                                spreadRadius: 3,
                                blurRadius: 2,
                                offset: const Offset(0, 0),
                              ),
                            ]
                          : [],
                    ),
                    child: Center(
                      child: _isSelected
                          ? Icon(
                              widget.selectedIcon,
                              color: Colors.white,
                              size: widget.size * 0.7,
                            )
                          : Icon(
                              widget.unselectedIcon,
                              color: widget.unselectedColor ?? Colors.black26,
                              size: widget.size,
                            ),
                    ),
                  );
                }),
            if (widget.labelWidget != null)
            widget.labelWidget!,
            if (widget.label != null)
            Padding(
              padding: const EdgeInsets.only(left: 6),
              child: TextView(widget.label!,color: ColorTheme.fontLight,),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void didUpdateWidget(RadioView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isSelected != _isSelected) {
      _isSelected = widget.isSelected;
      if (_isSelected) {
        controller?.start();
      }
    }
  }
}
