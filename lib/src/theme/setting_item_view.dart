
import 'package:common_plugin/src/theme/radio.dart';
import 'package:common_plugin/src/theme/switch.dart';
import 'package:common_plugin/src/theme/theme.dart';
import 'package:flutter/material.dart';

class SettingItemView extends StatefulWidget {
  ///默认卡片箭头栏，switchShow=true开启开关栏样式
  const SettingItemView({
    super.key,
    this.icon,
    this.iconWidget,
    this.label = '',
    this.underText,
    this.fontColor,
    this.fontSize = 16.0,
    this.valueFontSize = 16.0,
    this.value = '',
    this.valueWidget,
    this.onPressed,
    this.readOnly = false,
    this.top = 0,
    this.bottom = 0,
    this.required = false,
    this.padding = const EdgeInsets.symmetric(horizontal: 0, vertical: 15),
    this.switchShow = false,
    this.switchValue,
    this.switchOnChanged,
    this.radioShow = false,
    this.radioOnChanged,
    this.radioValue,
    this.borderTopShow = false,
    this.borderBottomShow = true,
    this.borderHeight = 1,
    this.showRedDot = false,
    this.backgroundColor,
    this.maxLines = 1,
  });

  ///图标
  final IconData? icon;

  ///图标组件
  final Widget? iconWidget;

  ///左边文字
  final String label;

  ///下面文字提示
  final String? underText;

  final Color? fontColor;

  final double fontSize;
  final double valueFontSize;

  ///右边显示值
  final String value;

  /// 自定义右边显示值
  final Widget? valueWidget;

  ///箭头链接点击回调
  final void Function()? onPressed;

  ///只读模式，只显示值，不显示角标点击
  final bool readOnly;

  ///是否必填
  final bool required;

  ///开关是否开启
  final bool switchShow;

  ///传入开关初始化值
  final bool? switchValue;

  ///开关值回调
  final void Function(bool)? switchOnChanged;

  ///是否启用单选
  final bool radioShow;
  final Function(bool selected)? radioOnChanged;
  final bool? radioValue;

  ///组件距离顶部距离
  final double top;

  ///组件距离底部距离
  final double bottom;

  ///组件内部距离
  final EdgeInsetsGeometry padding;

  ///上边框是否显示
  final bool borderTopShow;

  ///下边框是否显示
  final bool borderBottomShow;

  ///上下边框厚度
  final double borderHeight;

  ///显示红色小圆点
  final bool showRedDot;

  final Color? backgroundColor;
  final int maxLines;
  @override
  State<StatefulWidget> createState() => _SettingItemViewState();
}

class _SettingItemViewState extends State<SettingItemView> {
  bool switchValue = false;
  bool radioValue = false;

  @override
  void initState() {
    super.initState();
    switchValue = widget.switchValue ?? false;
    radioValue = widget.radioValue ?? false;
  }

  @override
  void didUpdateWidget(covariant SettingItemView oldWidget) {
    if (widget.switchValue != oldWidget.switchValue) {
      setState(() {
        switchValue = widget.switchValue ?? false;
      });
    } else if (widget.radioValue != oldWidget.radioValue) {
      setState(() {
        radioValue = widget.radioValue ?? false;
      });
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: widget.radioShow
          ? (() {
              setState(() {
                radioValue = !radioValue;
              });
              widget.radioOnChanged?.call(radioValue);
            })
          : (widget.switchShow
              ? (() {
                  setState(() {
                    switchValue = !switchValue;
                  });
                  widget.switchOnChanged?.call(switchValue);
                })
              : widget.onPressed),
      child: Container(
        padding: widget.padding,
        margin: EdgeInsets.only(top: widget.top, bottom: widget.bottom),
        decoration: BoxDecoration(
          color: widget.backgroundColor,
          border: Border(
            top: widget.borderTopShow
                ? BorderSide(
                    color: ColorTheme.border,
                    width: widget.borderHeight,
                  )
                : BorderSide.none,
            bottom: widget.borderBottomShow
                ? BorderSide(
                    color: ColorTheme.border,
                    width: widget.borderHeight,
                  )
                : BorderSide.none,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.only(bottom: 5, top: 5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  if (widget.iconWidget != null)
                    Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: widget.iconWidget,
                    ),
                  if (widget.icon != null && widget.iconWidget == null)
                    Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: Icon(
                        widget.icon,
                        size: 25,
                        color: ColorTheme.font,
                      ),
                    ),
                  TextView(
                    widget.label,
                    fontSize: widget.fontSize,
                    color: widget.fontColor ?? ColorTheme.font,
                  ),
                  if (widget.required && !widget.switchShow)
                    Text(
                      " *",
                      style: TextStyle(color: ColorTheme.red, fontSize: 14),
                    ),
                  if (widget.showRedDot)
                    Container(
                      margin: const EdgeInsets.only(left: 10),
                      width: 7,
                      height: 7,
                      decoration: BoxDecoration(
                        border: Border.all(color: ColorTheme.red, width: 0.5),
                        color: ColorTheme.red,
                        borderRadius: BorderRadius.circular((20.0)), //未读消息圆
                      ),
                    ),
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (widget.switchShow)
                          SwitchView(
                            value: switchValue,
                            activeColor: ColorTheme.main,
                            onChanged: widget.switchOnChanged,
                          ),
                        if (widget.radioShow)
                          RadioView(
                            isSelected: radioValue,
                            onChanged: (value) {
                              setState(() {
                                radioValue = value;
                              });
                              widget.radioOnChanged?.call(radioValue);
                            },
                          ),
                        if (!widget.switchShow && !widget.radioShow)
                          Expanded(
                            child: Row(
                              children: [
                                Expanded(
                                    child: Align(
                                        alignment: Alignment.centerRight,
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 5),
                                          child: widget.valueWidget ??
                                              TextView(
                                                widget.value,
                                                color: ColorTheme.grey,
                                                fontSize: widget.valueFontSize,
                                              ),
                                        ))),
                                if (!widget.readOnly)
                                  const Padding(
                                      padding: EdgeInsets.only(right: 8.0),
                                      child: Icon(
                                        Icons.arrow_forward_ios_rounded,
                                        size: 18,
                                        color: Colors.grey,
                                      )),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              if (widget.underText != null)
                Padding(
                  padding: const EdgeInsets.only(top: 5.0),
                  child: TextView(
                    widget.underText!,
                    maxLines: widget.maxLines,
                    fontSize: 12,
                    color: ColorTheme.grey,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
