import 'package:common_plugin/common_plugin.dart';
import 'package:flutter/material.dart';

/// 使用示例
// toNav(InputEditView(
//   name: "简介",
//   placeHolder: "请输入简介",
//   inputTips: "填写简介让用户更好的了解您",
//   onCallback: (text) {
//     showAlert(text);
//   },
// ));

/// 内容编辑界面组件，用于输入详细内容
class InputEditView extends StatefulWidget {
  final String? defaultText; // 默认内容
  /// 组件名称，用于显示标题、内容提示等， 注意：不含修改、查看，组件已有默认值
  final String name;
  final String? title; // 自定义标题，默认name值
  final Widget? titleWidget; // 自定义标题组件
  final Function(String)? onCallback; // 确定按钮回调
  final bool isRequired; // 是否必填，内容为空不能点确定
  final String buttonText; // 按钮文字
  final Widget? buttonWidget; // 自定义按钮组件

  ///允许类型
  final InputAllowType inputAllowType;
  final String placeHolder; // 占位符提示文
  final String inputTips; //提示信息
  final bool isOnlyRead; // 是否只读
  final int? minLines;
  final int maxLines;
  final int? maxLength;
  final int minLength;
  final bool isShowInputBorder; //是否显示输入边框
  final Color inputBorderColor;
  final Color backgroundColor; //组件背景色
  final Color inputBackgroundColor; //输入框背景色
  final bool autoFillPlaceholder; //点击输入时value为空是否自动填充占位符
  final bool autoFocus; //自动获取焦点

  const InputEditView({
    super.key,
    required this.name,
    this.title,
    this.titleWidget,
    this.defaultText,
    this.onCallback,
    this.isRequired = false,
    this.buttonText = '确定',
    this.buttonWidget,
    this.inputAllowType = InputAllowType.allText,
    this.placeHolder = '点击进行输入',
    this.inputTips = '',
    this.isOnlyRead = false,
    this.minLines,
    this.maxLines = 10,
    this.maxLength,
    this.minLength = 0,
    this.isShowInputBorder = true,
    this.inputBorderColor = const Color(0xffe5e5e5),
    this.backgroundColor = Colors.white,
    this.inputBackgroundColor = Colors.white,
    this.autoFillPlaceholder = false,
    this.autoFocus = false,
    String? text,
  });

  @override
  State<StatefulWidget> createState() => _InputEditViewState();
}

class _InputEditViewState extends State<InputEditView> {
  String text = '';
  bool onlyRead = false;
  String defaultText = '';

  @override
  void initState() {
    super.initState();
    text = widget.defaultText ?? '';
    defaultText = widget.defaultText ?? '';
    onlyRead = widget.isOnlyRead;
  }

  @override
  dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppView(
      title:
          widget.title ?? (onlyRead ? '查看${widget.name}' : '修改${widget.name}'),
      titleWidget: widget.titleWidget,
      actions: !onlyRead
          ? [
              widget.buttonWidget ??
                  ButtonView(
                    text: widget.buttonText,
                    width: 80,
                    height: 33,
                    margin: const EdgeInsets.only(right: 10),
                    backgroundColor: (text.isEmpty && widget.isRequired)
                        ? ColorTheme.background
                        : ColorTheme.main,
                    showShadow: false,
                    onPressed: () async {
                      if (isEmptyOrNull(text) && widget.isRequired) {
                        showAlert('${widget.name}不能为空');
                        return;
                      }
                      widget.onCallback?.call(text);
                      Future.delayed(const Duration(milliseconds: 200), ()
                      {
                        if (mounted) {
                          Navigator.of(context).pop();
                        }
                      });
                    },
                  ),
            ]
          : [],
      backgroundColor: widget.backgroundColor,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 20),
          child: InputView(
            defaultValue: defaultText,
            placeHolder: widget.placeHolder,
            onlyRead: onlyRead,
            inputAllowType: widget.inputAllowType,
            maxLength: widget.maxLength,
            minLength: widget.minLength,
            minLines: widget.minLines,
            maxLines: widget.maxLines,
            isShowInputBorder: widget.isShowInputBorder,
            inputBorderColor: widget.inputBorderColor,
            backgroundColor: widget.inputBackgroundColor,
            autoFillPlaceholder: widget.autoFillPlaceholder,
            inputTips: widget.inputTips,
            autoFocus: widget.autoFocus,
            onChanged: (String value) {
              if (mounted) {
                setState(() {
                  text = value;
                });
              }
            },
          ),
        ),
      ),
    );
  }
}
