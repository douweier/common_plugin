
import 'package:common_plugin/src/theme/switch.dart';
import 'package:common_plugin/src/theme/theme.dart';
import 'package:flutter/material.dart';

class CardArrow extends StatelessWidget {
  ///默认卡片箭头栏，switchShow=true开启开关栏样式
  const CardArrow({
    super.key,
    this.icon,
    this.text = '',
    this.underText,
    this.fontColor = ColorTheme.font,
    this.fontSize = 16.0,
    this.value = '',
    this.onPressed,
    this.top = 0,
    this.bottom = 0,
    this.required = false,
    this.padding = const EdgeInsets.fromLTRB(16, 13, 16, 13),
    this.switchShow = false,
    this.switchValue,
    this.switchOnChanged,
    this.borderTopShow = true,
    this.borderBottomShow = true,
    this.borderHeight = 1,
    this.showRedDot = false,
    this.backgroundColor = ColorTheme.body,
    this.maxLines = 1,
  });

  ///图标
  final IconData? icon;

  ///左边文字
  final String text;

  ///下面文字提示
  final String? underText;

  final Color fontColor;

  final double fontSize;

  ///右边显示值
  final String value;

  ///箭头链接点击回调
  final void Function()? onPressed;

  ///开关是否开启
  final bool switchShow;

  final bool required;

  ///传入开关初始化值
  final bool? switchValue;

  ///开关值回调
  final void Function(bool)? switchOnChanged;

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

  final Color backgroundColor;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: backgroundColor,
      child: InkWell(
        onTap: onPressed,
        child: Container(
          padding: padding,
          margin: EdgeInsets.only(top: top, bottom: bottom),
          decoration: BoxDecoration(
            border: Border(
              top: borderTopShow
                  ? BorderSide(
                      color: ColorTheme.border,
                      width: borderHeight,
                    )
                  : BorderSide.none,
              bottom: borderBottomShow
                  ? BorderSide(
                      color: ColorTheme.border,
                      width: borderHeight,
                    )
                  : BorderSide.none,
            ),
          ),
          child: switchShow
              ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                      children: [
                        if (icon != null)
                          Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: Icon(
                              icon,
                              size: 25,
                              color: ColorTheme.font,
                            ),
                          ),
                        TextView(
                          text,
                          fontSize: fontSize,
                          color: fontColor,
                        ),
                        if (showRedDot)
                          Container(
                            margin: EdgeInsets.only(left: 10),
                            width: 7,
                            height: 7,
                            decoration: new BoxDecoration(
                              border: new Border.all(color: ColorTheme.red, width: 0.5),
                              color: ColorTheme.red,
                              borderRadius: new BorderRadius.circular((20.0)), //未读消息圆
                            ),
                          ),
                        Expanded(
                          child: Row(
                            textDirection: TextDirection.rtl,
                            children: [
                              SwitchView(
                                value: switchValue ?? false,
                                activeColor: ColorTheme.main,
                                onChanged: switchOnChanged,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  if (underText != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 5.0),
                      child: TextView(
                        underText!,
                        fontSize: 12,
                        color: ColorTheme.grey,
                      ),
                    ),
                ],
              )
              : Padding(
                padding: const EdgeInsets.only(bottom: 5,top: 5),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        if (icon != null)
                          Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: Icon(
                              icon,
                              size: 25,
                              color: ColorTheme.font,
                            ),
                          ),
                        TextView(
                          text,
                          fontSize: fontSize,
                          color: fontColor,
                        ),
                        if (required)
                          Text(" *",style: TextStyle(color: ColorTheme.red,fontSize: 18),),
                        if (showRedDot)
                          Container(
                            margin: EdgeInsets.only(left: 10),
                            width: 7,
                            height: 7,
                            decoration: new BoxDecoration(
                              border: new Border.all(color: ColorTheme.red, width: 0.5),
                              color: ColorTheme.red,
                              borderRadius: new BorderRadius.circular((20.0)),
                            ),
                          ),
                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            textDirection: TextDirection.ltr,
                            children: [
                              Expanded(child: Align(
                                alignment: Alignment.centerRight,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 5),
                                    child: TextView(value,color: ColorTheme.grey,),
                                  ))),
                              Padding(
                                  padding: const EdgeInsets.only(right: 8.0),
                                  child: Icon(
                                    Icons.arrow_forward_ios,
                                    size: 18,
                                    color: Colors.grey,
                                  )),
                            ],
                          ),
                        ),
                      ],
                    ),
                    if (underText != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 5.0),
                        child: TextView(
                          underText!,
                          maxLines: maxLines,
                          color: ColorTheme.grey,
                        ),
                      ),
                  ],
                ),
              ),
        ),
      ),
    );
  }
}
