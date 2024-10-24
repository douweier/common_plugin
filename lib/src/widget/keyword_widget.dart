import 'package:common_plugin/common_plugin.dart';
import 'package:flutter/material.dart';

class KeywordWidget extends StatefulWidget {
  const KeywordWidget({
    super.key,
    this.hintText = "",
    required this.value,
    required this.onChange,
  });

  final String value;
  final String hintText;
  final Function(String value) onChange;

  @override
  State<KeywordWidget> createState() => _KeywordWidgetState();
}

class _KeywordWidgetState extends State<KeywordWidget> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();

    _controller = TextEditingController(text: widget.value);

    _controller.addListener(() {});
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      color: ColorTheme.white,
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                  color: ColorTheme.background,
                  borderRadius: BorderRadius.circular(50)),
              child: TextField(
                maxLines: null,
                controller: _controller,
                textAlign: TextAlign.start,
                cursorColor: Colors.lightBlue,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.transparent,
                  border: InputBorder.none,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 0, vertical: 12),
                  isCollapsed: true,
                  hintText: widget.hintText,
                  icon: Image.asset(
                    "assets/images/keyword_search.png",
                    width: 24,
                    height: 24,
                    fit: BoxFit.contain,
                  ),
                  hintStyle: TextStyle(
                      fontSize: 16,
                      color: ColorTheme.grey,
                      fontWeight: FontWeight.w400),
                ),
                onChanged: widget.onChange,
              ),
            ),
          ),
          // TextButton(
          //   style: TextButton.styleFrom(
          //       padding: const EdgeInsets.symmetric(horizontal: 6)),
          //   onPressed: () {
          //     setState(() {
          //       _controller.text = "";
          //     });
          //   },
          //   child: Text(
          //     "取消",
          //     style: TextStyle(
          //       color: ColorTheme.font,
          //     ),
          //   ),
          // )
        ],
      ),
    );
  }
}
