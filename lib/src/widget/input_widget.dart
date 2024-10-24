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
  onlyUpperLetter, //大写字母
  onlyLowerLetter, //小写字母
  idCard, //身份证格式
}

///输入框label样式，有label显示在输入框的上方、输入边框左边、输入边框内
enum InputLabelType {
  top,
  left,
  inside,
}

///输入组件
class InputView extends StatefulWidget {
  const InputView({
    super.key,
    this.inputAllowType = InputAllowType.allText,
    this.defaultValue = '',
    this.label = '',
    this.labelType = InputLabelType.left,
    this.labelFontSize = 16.0,
    this.inputTips = '',
    this.showLengthTip = true, //是否显示输入长度提示
    this.showClearIcon = true,
    this.placeHolder = '',
    this.onlyRead = false,
    this.rightUnit = '',
    this.rightWidget,
    required this.onChanged,
    this.textAlign = TextAlign.left,
    this.fontSize = 16.0,
    this.placeHolderFontSize = 16.0,
    this.fontColor,
    this.minLines = 1,
    this.maxLines = 1,
    this.maxLength,
    this.minLength = 0,
    this.padding = const EdgeInsets.symmetric(horizontal: 0, vertical: 7),
    this.contentPadding =
        const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
    this.backgroundColor = Colors.white,
    this.inputBorderColor = const Color(0xffeeeeee),
    this.required = false,
    this.autoFillPlaceholder = false,
    this.isShowInputBorder = false,
    this.isShowBottomBorder = false,
    this.borderRadius = const BorderRadius.all(Radius.circular(5)),
    this.autoFocus = false,
  });

  ///允许类型
  final InputAllowType inputAllowType;
  final String label;
  final InputLabelType labelType;
  final double labelFontSize;
  final String defaultValue;
  final String inputTips; //提示信息
  final bool showLengthTip; //是否显示输入长度提示
  final bool showClearIcon; //是否显示清除按钮
  final bool onlyRead; //只读
  final String placeHolder; //占位符
  final double placeHolderFontSize;
  final EdgeInsetsGeometry padding; //组件内边距
  final EdgeInsetsGeometry? contentPadding; //内容内边距
  final BorderRadius borderRadius; //边框圆角

  ///文本对齐方式
  final TextAlign textAlign;

  final double fontSize;
  final Color? fontColor;

  ///显示右边单位
  final String rightUnit;

  ///自定义右边组件
  final Widget? rightWidget;

  final int? minLines;
  final int maxLines;
  final int? maxLength;
  final int minLength;
  final ValueChanged<String> onChanged;
  final bool isShowInputBorder; //是否显示输入边框
  final bool isShowBottomBorder; //是否显示底部下划线
  final Color inputBorderColor;
  final Color backgroundColor; //组件背景色
  final bool required;
  final bool autoFillPlaceholder; //点击输入时value为空是否自动填充占位符
  final bool autoFocus; //自动获取焦点

  @override
  State<StatefulWidget> createState() => _InputViewState();
}

class _InputViewState extends State<InputView> {
  String inputText = '';
  TextEditingController controller = TextEditingController();
  String inputAllowValue = '';
  String inputDenyValue = '';
  FocusNode focusNode = FocusNode();
  bool hasKeyboardInput = false;

  @override
  void initState() {
    _inputAllow();
    super.initState();
    controller.text = widget.defaultValue;
    focusNode.addListener(_onFocusChange);
  }

  void _inputAllow() {
    if (widget.inputAllowType == InputAllowType.allText) {
      inputAllowValue = '';
    } else if (widget.inputAllowType == InputAllowType.userName) {
      inputDenyValue = "['\"<>]";
    } else if (widget.inputAllowType == InputAllowType.nickName) {
      inputAllowValue = "[a-zA-Z]|[0-9]|[_]|[\u4e00-\u9fa5]|[.@#%^&*]";
    } else if (widget.inputAllowType == InputAllowType.url) {
      inputAllowValue = "[a-zA-Z]|[0-9]|_|[?]|[&]|[=]|[-.@!/:]";
    } else if (widget.inputAllowType == InputAllowType.email) {
      inputAllowValue = "[a-zA-Z]|[0-9]|_|[.@]";
    } else if (widget.inputAllowType == InputAllowType.letter) {
      inputAllowValue = "[a-zA-Z]";
    } else if (widget.inputAllowType == InputAllowType.onlyLowerLetter) {
      inputAllowValue = "[a-z]";
    } else if (widget.inputAllowType == InputAllowType.onlyUpperLetter) {
      inputAllowValue = "[A-Z]";
    } else if (widget.inputAllowType == InputAllowType.onlyNumber) {
      inputAllowValue = "[0-9]";
    } else if (widget.inputAllowType == InputAllowType.money) {
      inputAllowValue = "[0-9]|[.]";
    } else if (widget.inputAllowType == InputAllowType.password) {
      inputAllowValue = "[a-zA-Z]|[0-9]|_|[.@#%^&*]";
    } else if (widget.inputAllowType == InputAllowType.phone) {
      inputAllowValue = "[0-9]";
    } else if (widget.inputAllowType == InputAllowType.onlyInt) {
      inputAllowValue = "[0-9]";
    } else if (widget.inputAllowType == InputAllowType.idCard) {
      inputAllowValue = "[0-9]|[x]|[X]";
    }
  }

  void _onFocusChange() {
    if (!mounted) return;
    if (widget.autoFillPlaceholder) {
      if (focusNode.hasFocus && controller.text.isEmpty) {
        controller.text = widget.placeHolder;
        if (mounted) {
          setState(() {});
        }
      }
    }
    if (!focusNode.hasFocus) {
      FocusScope.of(context).requestFocus(FocusNode()); // 焦点切换到空节点，解决从另外一个页面返回时被重新获得焦点且弹出键盘的问题
    }
  }

  @override
  void dispose() {
    focusNode.removeListener(_onFocusChange);
    focusNode.dispose();
    controller.dispose();
    super.dispose();
  }


  @override
  void didUpdateWidget(InputView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!hasKeyboardInput && widget.defaultValue.isNotEmpty || widget.inputAllowType == InputAllowType.onlyInt) {
      // 输入事件后停止初始化赋值
      controller.text = widget.defaultValue;
    }
  }

  Widget buildLabel() {
    return Row(
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
            fontSize: 14,
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: widget.padding,
      decoration: BoxDecoration(
        border: widget.isShowBottomBorder
            ? Border(
                bottom: BorderSide(
                  color: widget.inputBorderColor,
                  width: 1,
                ),
              )
            : null,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.labelType == InputLabelType.top && widget.label.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 5.0),
              child: buildLabel(),
            ),
          Row(
            children: [
              if (widget.labelType == InputLabelType.left &&
                  widget.label.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: buildLabel(),
                ),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: widget.backgroundColor,
                    borderRadius: widget.borderRadius,
                    border: widget.isShowInputBorder
                        ? Border.all(color: widget.inputBorderColor, width: 0.2)
                        : null,
                  ),
                  child: Row(
                    children: [
                      if (widget.labelType == InputLabelType.inside &&
                          widget.label.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(left: 10.0, right: 5),
                          child: buildLabel(),
                        ),
                      Expanded(
                        child: TextField(
                          controller: controller,
                          minLines: widget.minLines,
                          maxLines:
                              widget.inputAllowType == InputAllowType.password
                                  ? 1
                                  : widget.maxLines,
                          cursorColor: Colors.lightBlue,
                          readOnly: widget.onlyRead,
                          textAlign: widget.textAlign,
                          style: TextStyle(
                            color: widget.fontColor,
                            fontSize: widget.fontSize,
                          ),
                          focusNode: focusNode,
                          autofocus: widget.autoFocus,
                          obscureText:
                              widget.inputAllowType == InputAllowType.password,
                          inputFormatters: [
                            if (inputDenyValue != '')
                              FilteringTextInputFormatter.deny(
                                  RegExp(inputDenyValue)),
                            if (inputAllowValue != '')
                              FilteringTextInputFormatter.allow(
                                  RegExp(inputAllowValue)),
                            if (widget.maxLength != null)
                              LengthLimitingTextInputFormatter(
                                  widget.maxLength), //最大长度
                          ],
                          decoration: InputDecoration(
                            filled: false, // 不填充背景
                            // fillColor: widget.inputBackgroundColor,
                            contentPadding: widget.contentPadding,
                            enabledBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                  color: Colors.transparent, width: 0.1),
                              borderRadius: widget.borderRadius,
                            ),
                            focusedBorder: const OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Colors.transparent, width: 0.1),
                              // borderRadius: BorderRadius.all(Radius.circular(5)),
                            ),
                            // isCollapsed: true,
                            hintText: widget.placeHolder,
                            hintStyle: TextStyle(
                                fontSize: widget.placeHolderFontSize,
                                color: ColorTheme.grey,
                                fontWeight: FontWeight.w400),
                          ),
                          onChanged: (s) {
                            hasKeyboardInput = true;
                            inputText = s;
                            if (widget.maxLength != null) {
                              if (s.length > widget.maxLength!) {
                                inputText = s.substring(0, widget.maxLength);
                                showAlert('超过了最大字数限制',
                                    alignment: Alignment.center);
                              }
                            }
                            //如果为onlyInt类型，如果超过length长度超过1个以上以0开头就去掉第一个0
                            if (widget.inputAllowType ==
                                    InputAllowType.onlyInt &&
                                inputText.length > 1) {
                              if (inputText.startsWith('0')) {
                                inputText = inputText.substring(1);
                              }
                            } else if (widget.inputAllowType ==
                                InputAllowType.money) {
                              List<String> parts = inputText.split('.');
                              if (parts.length > 2) {
                                inputText = '${parts.first}.${parts[1]}';
                              }

                              if (inputText.startsWith('0') &&
                                  inputText.length > 1) {
                                inputText = inputText.substring(1);
                              }
                              if (inputText.startsWith('.')) {
                                inputText = '0$inputText';
                              }
                              // 限制小数点后最多两位
                              final int decimalIndex = inputText.indexOf('.');
                              if (decimalIndex != -1) {
                                final int fractionLength =
                                    inputText.length - decimalIndex - 1;
                                if (fractionLength > 2) {
                                  inputText =
                                      inputText.substring(0, decimalIndex + 3);
                                }
                              }
                            }
                            if (controller.text != inputText) {
                              // 避免重复触发
                              controller.text = inputText;
                            }
                            if (mounted) {
                              setState(() {});
                            }

                            widget.onChanged(inputText);
                          },
                        ),
                      ),
                      if (widget.showClearIcon && controller.text.isNotEmpty && !widget.onlyRead)
                        InkWell(
                          onTap: () {
                            controller.clear();
                            setState(() {});
                            widget.onChanged('');
                          },
                          child: Container(
                              margin: const EdgeInsets.only(right: 10),
                              padding: const EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                color: Colors.black87.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(50),
                              ),
                              child: const Icon(
                                Icons.clear_rounded,
                                color: Colors.white,
                                size: 13,
                              )),
                        ),
                      if (widget.showLengthTip && widget.maxLines <= 1 &&
                          widget.maxLength != null &&
                          controller.text.isNotEmpty)
                        Column(
                          children: [
                            TextView(
                              '${widget.maxLength}',
                              fontSize: 10,
                              color: ColorTheme.grey,
                            ),
                            Container(
                              width: 10,
                              height: 0.5,
                              color: ColorTheme.grey,
                            ),
                            TextView(
                              '${inputText.length}',
                              color: (inputText.length) > widget.maxLength!
                                  ? ColorTheme.red
                                  : ColorTheme.main,
                              fontSize: 10,
                            ),
                          ],
                        ),
                      if (widget.rightWidget != null) widget.rightWidget!,
                      if (widget.rightUnit.isNotEmpty)
                        Row(
                          children: [
                            Container(
                              width: 1,
                              height: 20,
                              margin: const EdgeInsets.only(right: 5),
                              color: ColorTheme.border,
                            ),
                            Text(widget.rightUnit),
                            const SizedBox(
                              width: 5,
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          if (widget.inputTips != '' ||
              (widget.maxLength != null && widget.maxLines > 1))
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
                        (widget.maxLength != null &&
                                (inputText.length) > (widget.maxLength ?? 0))
                            ? '超过了最大字数，请减少输入'
                            : widget.inputTips,
                        maxLines: 3,
                        color: ColorTheme.grey,
                      ),
                    ),
                  ),
                  if (widget.maxLength != null && widget.maxLines > 1)
                    Row(
                      children: [
                        TextView(
                          '${inputText.length}',
                          color: (inputText.length) > widget.maxLength!
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
