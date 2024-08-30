
import 'dart:math';
import 'package:common_plugin/src/theme/icon_text.dart';
import 'package:common_plugin/src/theme/theme.dart';
import 'package:flutter/material.dart';



class StarWidget extends StatefulWidget {
  StarWidget({
    this.backStar = const IconText(Icons.star_rate_sharp,color: Colors.black12,shadowShow: false,size: 24,),
    this.selectStar = const IconText(Icons.star_rate_sharp,color: ColorTheme.yellow,shadowShow: false,size: 24,),
    this.starCount = 5,
    this.value = 0.0,
    this.step = 0.5,
    this.rounded = false,
    this.starWidth = 30.0,
    this.starMargin = 0.0,
    this.miniStars = 0.0,
    this.readOnly = false,
    this.onChanged,
    this.afterSelectEndChange = true,
    this.showFormatMark = false,
    this.markFontColor = ColorTheme.main,
  });

  /// 未选中背景的星星.
  final Widget backStar;

  /// 选中高亮的星星.
  final Widget selectStar;

  /// 星星数量.
  final int starCount;

  /// 默认需要显示的星星数量(支持小数).
  final double value;

  /// 分阶, 范围0.01-1.0, 0.01表示任意星, 1.0表示整星星, 0.5表示半星, 范围内自定义.
  final double step;

  /// 星星的宽度.
  final double starWidth;


  /// 两个星星中间的间距.
  final double starMargin;

  /// 最低分, 字面意思.
  final double miniStars;

  /// 只读不可选
  final bool readOnly;

  /// 选中数值发生变化的回调.
  final void Function(double value)? onChanged;

  ///  true仅在用户操作结束后回调.false则在拖动时会实时回调反馈
  final bool afterSelectEndChange;

  /// 四舍五入
  /// 默认false: 举例: step=1, 实际选择2.4则结果为: 3. step=0.5, 实际选择2.2则结果为2.5.("进一法")
  /// 为true时:  举例: step=1, 实际选择2.4则结果为: 2. step=0.5, 实际选择2.2则结果为2.0.("四舍五入-取最近值")
  final bool rounded;

  ///是否显示格式化标签文字, readOnly 为true 供展示时，只显示高、中、低，可选的时候显示非常好、好、一般、差、非常差
  final bool showFormatMark;
  final Color markFontColor;

  @override
  _StarWidgetState createState() => _StarWidgetState();
}

class _StarWidgetState extends State<StarWidget> {
   late double _miniStars;

   late double _currentStars;

   late double _step;

  @override
  void initState() {
    super.initState();

    /// 限制0.01 <= step <= 1.0
    _step = min(1.0, widget.step);
    _step = max(0.01, widget.step);

    /// 限制最低星不高于最高星
    _miniStars = min(widget.miniStars, widget.starCount * 1.0);

    /// 限制当前星不高于最高星
    _currentStars = min(widget.value, widget.starCount * 1.0);

    /// 限制当前星不低于最低星
    _currentStars = max(widget.value, widget.miniStars);

    this.setupRealStars(_currentStars, false, false, false);
  }

   ///显示评分对应文字
    String getScoreMark(double value){
     String _mark = "非常好";
     if (value > 4.5){
       _mark = "非常好";
     } else if (value > 3.9 && value < 4.6){
       _mark = "好";
     } else if (value > 2.9 && value < 4.0){
       _mark = "一般";
     } else if (value > 1.9 && value < 3.0){
       _mark = "差";
     } else if (value < 2.0){
       _mark = "非常差";
     }
     return _mark;
   }

   ///显示评分对应文字格式化
    String getScoreMarkFormat(double value){
     String _mark = "高";
     if (value > 4.5){
       _mark = "高";
     }else if (value > 2.9 && value < 4.6){
       _mark = "中";
     } else if (value < 3.0){
       _mark = "低";
     }
     return _mark;
   }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Listener(
          onPointerDown: (event) {
            if (widget.readOnly) {
              return;
            }
            this.calculateSelectedStars(event.localPosition.dx, false);
          },
          onPointerMove: (event) {
            if (widget.readOnly) {
              return;
            }
            this.calculateSelectedStars(event.localPosition.dx, false);
          },
          onPointerUp: (event) {
            if (widget.readOnly) {
              return;
            }
            this.calculateSelectedStars(event.localPosition.dx, true);
          },
          child: Row(
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: getStars(widget.starCount, false),
              ),
              if (widget.showFormatMark)
              Padding(
                padding: const EdgeInsets.only(left: 5.0),
                child: Text(widget.readOnly ? getScoreMarkFormat(_currentStars) : getScoreMark(_currentStars),style: TextStyle(color: widget.markFontColor),),
              ),
            ],
          ),
        ),
        IgnorePointer(
          child: ClipRect(
            clipper: StarsClipper(this.getRealWidth()),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: getStars(widget.starCount, true),
            ),
          ),
        ),
      ],
    );
  }

  /// 计算实际选择了多少分
  void calculateSelectedStars(double width, bool needCallback) {
    /// 1.找到属于哪一颗星星
    var starIndex = (width / (widget.starWidth + widget.starMargin)).floor();

    /// 2.获取点击位置在星星的具体x坐标
    var locationX = min(
        width - starIndex * (widget.starWidth + widget.starMargin),
        widget.starWidth);

    /// 3.计算具体选中的分值.
    var selectedStars = starIndex + locationX / widget.starWidth;

    /// print("实际选择的分值为: " + selectedStars.toString());
    /// 4.计算实际得分
    this.setupRealStars(selectedStars, true, true, needCallback);
  }

  void setupRealStars(
      double selectedStars, bool useStep, bool reload, bool needCallback) {
    var realStars = min(widget.starCount, selectedStars);
    realStars = max(_miniStars, realStars);
    var i = realStars.floor();

    if (useStep == true) {
      var decimalNumber = (realStars - i);
      int floor = (decimalNumber / _step).floor();
      double remainder = decimalNumber % _step;

      if (widget.rounded == true) {
        /// 取最近值
        realStars = i + floor * _step + ((remainder > _step * 0.5) ? _step : 0);
      } else {
        /// 进一法
        realStars = i + floor * _step + ((remainder > 0.0) ? _step : 0);
      }
    }
    _currentStars = (realStars * 100).floor() / 100;

    if (reload == true) {
      setState(() {});

      if (needCallback == false && widget.afterSelectEndChange) {
        return;
      }

      if (widget.onChanged == null) {
        return;
      }
      // widget.starsChanged(_currentStars, selectedStars);
      widget.onChanged!(_currentStars);
    }
  }

  double getRealWidth() {
    var i = _currentStars.floor();
    var width = (widget.starWidth + widget.starMargin) * i +
        (_currentStars - i) * widget.starWidth;
    return width;
  }

  List<Widget> getStars(int count, bool selected) {
    return List.generate(max(count * 2 - 1, 0), (index) {
      if (index % 2 == 0) {
        return Container(
          width: widget.starWidth,
          height: widget.starWidth,
          child: selected ? widget.selectStar : widget.backStar,
        );
      }

      return Container(
        width: widget.starMargin,
        height: widget.starWidth,
        color: Colors.transparent,
      );
    });
  }
}

class StarsClipper extends CustomClipper<Rect> {
  StarsClipper(this.width);

  double width;

  @override
  Rect getClip(Size size) {
    return Rect.fromLTRB(0, 0, width, size.height);
  }

  @override
  bool shouldReclip(covariant CustomClipper<Rect> oldClipper) {
    if (oldClipper is StarsClipper) {
      return oldClipper.width != this.width;
    }
    return false;
  }
}