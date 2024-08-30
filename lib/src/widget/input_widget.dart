

import 'package:common_plugin/common_plugin.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

//输入允许类型
enum InputAllowType {
  userName, //用户名格式
  nickName, //昵称格式
  email, //邮箱格式
  url, //url格式
  allText, //全部格式
  onlyNumber, //数字格式
  money, //金额格式，0.00
  phone, //手机格式
  onlyInt, //整数格式，钻石、金币、积分场景
  password, //密码格式
  letter, //字母格式
  chinese, //中文格式
}

///输入组件
class InputView extends StatefulWidget {
  const InputView({
    super.key,
    this.inputAllowType = InputAllowType.allText,
    this.value = '',
    this.label = '',
    this.labelFontSize = 18.0,
    this.inputTips = '',
    this.placeHolder = '',
    this.inLineOnly = false,
    this.onlyRead = false,
    this.rightUnit = '',
    required this.onChanged,
    this.minLines,
    this.maxLines = 1,
    this.maxLength = 20,
    this.minLength = 0,
    this.padding = const EdgeInsets.symmetric(horizontal: 0),
    this.backgroundColor = Colors.white,
    this.inputBackgroundColor = Colors.white12,
    this.required = false,
    this.autoFillPlaceholder = false,
  });

  ///允许类型
  final InputAllowType inputAllowType;
  final String label;
  final double labelFontSize;
  final String value;
  final String inputTips; //提示信息
  final bool onlyRead; //只读
  final String placeHolder; //占位符
  final EdgeInsetsGeometry padding;

  ///一行显示标签
  final bool inLineOnly;

  ///显示右边单位
  final String rightUnit;
  final int? minLines;
  final int maxLines;
  final int maxLength;
  final int minLength;
  final ValueChanged<String> onChanged;
  final Color backgroundColor;
  final Color inputBackgroundColor;
  final bool required;
  final bool autoFillPlaceholder; //点击输入时value为空是否自动填充占位符

  @override
  _InputViewState createState() => _InputViewState();
}

class _InputViewState extends State<InputView> {
  String inputText = '';
  TextEditingController controller = TextEditingController();
  String inputAllowValue = '';
  String inputDenyValue = '';
  FocusNode focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    controller.text = widget.value;
    if (widget.autoFillPlaceholder) {
      focusNode.addListener(_onFocusChange);
    }
  }

  void _onFocusChange() {
    if (focusNode.hasFocus && controller.text.isEmpty) {
      controller.text = widget.placeHolder;
      if (mounted) {
        setState(() {});
      }
    }
  }

  @override
  void dispose() {
    if (widget.autoFillPlaceholder) {
      focusNode.dispose();
    }
    super.dispose();
  }

  @override
  void didUpdateWidget(InputView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget != oldWidget && widget.value != '') {
      controller.text = widget.value;
      if (mounted) {
        setState(() {});
      }
    }
  }

  Widget buildLabel() {
    return Container(
        padding: EdgeInsets.only(right: 5),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            TextView(
              widget.label,
              color: ColorTheme.font,
              fontSize: widget.labelFontSize,
            ),
            if (widget.required)
              TextView(
                " *",
                color: ColorTheme.red,
                fontSize: widget.labelFontSize,
              ),
          ],
        ));
  }

  @override
  Widget build(BuildContext context) {
    if (widget.inputAllowType == InputAllowType.allText) {
      inputAllowValue = '';
    } else if (widget.inputAllowType == InputAllowType.userName) {
      inputAllowValue = "[a-zA-Z]|[0-9]|[_]";
    } else if (widget.inputAllowType == InputAllowType.nickName) {
      inputDenyValue = "[\'\"<>]";
    } else if (widget.inputAllowType == InputAllowType.url) {
      inputAllowValue = "[a-zA-Z]|[0-9]|_|[?]|[&]|[=]|[-.@!/:]";
    } else if (widget.inputAllowType == InputAllowType.email) {
      inputAllowValue = "[a-zA-Z]|[0-9]|_|[.@]";
    } else if (widget.inputAllowType == InputAllowType.letter) {
      inputAllowValue = "[a-zA-Z]";
    } else if (widget.inputAllowType == InputAllowType.onlyNumber) {
      inputAllowValue = "[0-9]";
    } else if (widget.inputAllowType == InputAllowType.money) {
      inputAllowValue = "[0-9]|[.]";
    } else if (widget.inputAllowType == InputAllowType.chinese) {
      inputAllowValue = "[\u4e00-\u9fa5]";
    } else if (widget.inputAllowType == InputAllowType.password) {
      inputAllowValue = "[a-zA-Z]|[0-9]|_|[.@#%^&*]";
    } else if (widget.inputAllowType == InputAllowType.phone) {
      inputAllowValue = "[0-9]";
    } else if (widget.inputAllowType == InputAllowType.onlyInt) {
      inputAllowValue = "[0-9]";
    }

    return Container(
      padding: widget.padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!widget.inLineOnly && widget.label.isNotEmpty) buildLabel(),
          Container(
            decoration: BoxDecoration(
              color: widget.backgroundColor,
              borderRadius: const BorderRadius.all(const Radius.circular(5)),
              border: new Border.all(color: ColorTheme.border, width: 0.5),
            ),
            child: Row(
              children: [
                if (widget.inLineOnly && widget.label.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: buildLabel(),
                  ),
                Expanded(
                  child: TextField(
                    controller: controller,
                    minLines: widget.minLines,
                    maxLines: widget.inputAllowType == InputAllowType.password ? 1 : widget.maxLines,
                    cursorColor: Colors.lightBlue,
                    readOnly: widget.onlyRead,
                    focusNode: focusNode,
                    obscureText: widget.inputAllowType == InputAllowType.password,
                    inputFormatters: [
                      if (inputDenyValue != '')
                        FilteringTextInputFormatter.deny(
                            RegExp(inputDenyValue)),
                      if (inputAllowValue != '')
                        FilteringTextInputFormatter.allow(
                            RegExp(inputAllowValue)),
                      // WhitelistingTextInputFormatter(RegExp(
                      // "[a-zA-Z]|[\u4e00-\u9fa5]|[0-9]")),
                      LengthLimitingTextInputFormatter(widget.maxLength), //最大长度
                    ],
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: widget.inputBackgroundColor,
                      contentPadding: EdgeInsets.all(13),
                      enabledBorder: const OutlineInputBorder(
                        borderSide:
                            const BorderSide(color: Colors.black12, width: 0.0),
                        borderRadius:
                            const BorderRadius.all(const Radius.circular(5)),
                      ),
                      // focusedBorder: const OutlineInputBorder(
                      //   borderSide: const BorderSide(color: Colors.white, width: 0.0),
                      //   borderRadius: const BorderRadius.all(const Radius.circular(5)),
                      // ),
                      // border: OutlineInputBorder(
                      //   borderSide: const BorderSide(color: Colors.white, width: 0.0),
                      //   borderRadius: const BorderRadius.all(const Radius.circular(5)),
                      // ),
                      isCollapsed: true,
                      hintText: widget.placeHolder,
                      hintStyle: TextStyle(
                          fontSize: 16,
                          color: ColorTheme.grey,
                          fontWeight: FontWeight.w400),
                    ),
                    onChanged: (s) {
                      setState(() {
                        inputText = s;
                        if (inputText.length > widget.maxLength) {
                          showAlert('超过了最大字数限制',alignment: Alignment.center);
                        }
                        //如果为onlyInt类型，如果超过length长度超过1个以上以0开头就去掉第一个0
                        if (widget.inputAllowType == InputAllowType.onlyInt && inputText.length > 1) {
                          if (inputText.startsWith('0')) {
                            inputText = inputText.substring(1);
                          }
                        } else if (widget.inputAllowType == InputAllowType.money) {
                          List<String> parts = inputText.split('.');
                          if (parts.length > 2) {
                            inputText = parts.first + '.' + parts[1];
                          }

                          if (inputText.startsWith('0')  && inputText.length > 1) {
                            inputText = inputText.substring(1);
                          }
                          if (inputText.startsWith('.')) {
                            inputText = '0' + inputText;
                          }
                          // 限制小数点后最多两位
                          final int decimalIndex = inputText.indexOf('.');
                          if (decimalIndex != -1) {
                            final int fractionLength = inputText.length - decimalIndex - 1;
                            if (fractionLength > 2) {
                              inputText = inputText.substring(0, decimalIndex + 3);
                            }
                          }


                        }
                        widget.onChanged(s);
                      });
                    },
                  ),
                ),
                if (widget.rightUnit.isNotEmpty)
                  Row(
                    children: [
                      Container(
                        width: 1,
                        height: 20,
                        margin: EdgeInsets.only(right: 5),
                        color: ColorTheme.border,
                      ),
                      Text("${widget.rightUnit}"),
                      SizedBox(
                        width: 5,
                      ),
                    ],
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 5.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 18.0),
                    child: TextView(
                      (inputText.length) > widget.maxLength
                          ? '超过了最大字数，请减少输入'
                          : widget.inputTips,
                      maxLines: 3,
                      color: ColorTheme.grey,
                    ),
                  ),
                ),
                if (!widget.inLineOnly)
                  Row(
                    children: [
                      TextView(
                        '${inputText.length}',
                        color: (inputText.length) > widget.maxLength
                            ? ColorTheme.red
                            : ColorTheme.main,
                        fontSize: 14,
                      ),
                      TextView(
                        '/${widget.maxLength}',
                        fontSize: 14,
                        color: ColorTheme.grey,
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
