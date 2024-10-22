import 'package:common_plugin/common_plugin.dart';
import 'package:flutter/material.dart';

/// 滑动条
class SliderView extends StatefulWidget {
  final double value; // 滑块值
  final ValueChanged<double> onChanged; // 滑动回调
  final ValueChanged<double>? onChangeStart; // 滑动开始回调
  final ValueChanged<double>? onChangeEnd; // 滑动结束回调
  final double min; // 滑块范围, 最小值
  final double max; // 滑块范围, 最大值
  final double thumbRadius; // 滑块半径
  final Color? activeColor; // 激活颜色
  final Color? inactiveColor; // 未激活颜色
  final Color? thumbColor; // thumb颜色

  const SliderView({
    super.key,
    required this.value,
    required this.onChanged,
    this.onChangeStart,
    this.onChangeEnd,
    this.min = 0.0,
    this.max = 1.0,
    this.thumbRadius = 10.0,
    this.activeColor,
    this.inactiveColor,
    this.thumbColor,
  });

  @override
  State<SliderView> createState() => _SliderViewState();
}

class _SliderViewState extends State<SliderView> {
  double _offset = 0.0;
  late double _sliderWidth;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateOffset();
    });
  }

  void _updateOffset() {
    final RenderBox? renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox != null && renderBox.hasSize) {
      _sliderWidth = renderBox.size.width;
      if (widget.max != widget.min) {
        setState(() {
          _offset = ((widget.value - widget.min) / (widget.max - widget.min)) * _sliderWidth;
          _offset = _offset.clamp(0.0, _sliderWidth);
        });
      }
    }
  }

  void _handlePanStart(DragStartDetails details) {
    if (widget.onChangeStart != null) {
      widget.onChangeStart!(widget.value);
    }
  }

  void _handlePanUpdate(DragUpdateDetails details) {
    setState(() {
      _offset += details.delta.dx;
      _offset = _offset.clamp(0.0, _sliderWidth);
      if (_sliderWidth != 0) {
        double newValue = widget.min + (_offset / _sliderWidth) * (widget.max - widget.min);
        newValue = newValue.clamp(widget.min, widget.max);
        widget.onChanged(newValue);
      }
    });
  }

  void _handlePanEnd(DragEndDetails details) {
    if (widget.onChangeEnd != null) {
      double finalValue = widget.min + (_offset / _sliderWidth) * (widget.max - widget.min);
      finalValue = finalValue.clamp(widget.min, widget.max);
      widget.onChangeEnd!(finalValue);
    }
  }

  void _handleTap(TapDownDetails details) {
    final RenderBox? renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox != null && renderBox.hasSize) {
      final localPosition = renderBox.globalToLocal(details.globalPosition);
      double newOffset = localPosition.dx.clamp(0.0, _sliderWidth);
      setState(() {
        _offset = newOffset;
        if (_sliderWidth != 0) {
          double newValue = widget.min + (_offset / _sliderWidth) * (widget.max - widget.min);
          newValue = newValue.clamp(widget.min, widget.max);
          widget.onChanged(newValue);
          if (widget.onChangeEnd != null) {
            widget.onChangeEnd!(newValue);
          }
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      _sliderWidth = constraints.maxWidth;
      if (widget.max != widget.min) {
        _offset = ((widget.value - widget.min) / (widget.max - widget.min)) * _sliderWidth;
        _offset = _offset.clamp(0.0, _sliderWidth);
      } else {
        _offset = 0.0;
      }
      return GestureDetector(
        onPanStart: _handlePanStart,
        onPanUpdate: _handlePanUpdate,
        onPanEnd: _handlePanEnd,
        onTapDown: _handleTap,
        child: CustomPaint(
          size: Size(constraints.maxWidth, widget.thumbRadius * 2),
          painter: _SliderPainter(
            offset: _offset,
            thumbRadius: widget.thumbRadius,
            activeColor: widget.activeColor ?? ColorTheme.main,
            inactiveColor: widget.inactiveColor ?? Colors.white.withOpacity(0.3),
            thumbColor: widget.thumbColor ?? (widget.activeColor ?? ColorTheme.main),
          ),
        ),
      );
    });
  }
}

class _SliderPainter extends CustomPainter {
  final double offset;
  final double thumbRadius;
  final Color activeColor;
  final Color inactiveColor;
  final Color thumbColor;

  _SliderPainter({
    required this.offset,
    required this.thumbRadius,
    required this.activeColor,
    required this.inactiveColor,
    required this.thumbColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint inactivePaint = Paint()
      ..color = inactiveColor
      ..strokeWidth = 4.0
      ..strokeCap = StrokeCap.round;

    final Paint activePaint = Paint()
      ..color = activeColor
      ..strokeWidth = 4.0
      ..strokeCap = StrokeCap.round;

    // 绘制背景线
    canvas.drawLine(
        Offset(thumbRadius, size.height / 2),
        Offset(size.width - thumbRadius, size.height / 2),
        inactivePaint);

    // 绘制激活部分线
    canvas.drawLine(
        Offset(thumbRadius, size.height / 2),
        Offset(offset, size.height / 2),
        activePaint);

    // 绘制半透明外圈
    final Paint outerThumbPaint = Paint()
      ..color = thumbColor.withOpacity(0.3) // 半透明
      ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset(offset, size.height / 2), thumbRadius + 2, outerThumbPaint);

    // 绘制thumb
    final Paint thumbPaint = Paint()..color = thumbColor;
    canvas.drawCircle(Offset(offset, size.height / 2), thumbRadius, thumbPaint);
  }

  @override
  bool shouldRepaint(covariant _SliderPainter oldDelegate) {
    return oldDelegate.offset != offset ||
        oldDelegate.thumbRadius != thumbRadius ||
        oldDelegate.activeColor != activeColor ||
        oldDelegate.inactiveColor != inactiveColor ||
        oldDelegate.thumbColor != thumbColor;
  }
}