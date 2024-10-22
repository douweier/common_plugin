import 'dart:ui';

import 'package:flutter/material.dart';

enum ShapeType {
  square, // 方形
  circle, // 圆形
  roundedRectangle, // 圆角矩形
}

/// 虚线边框装饰, 支持圆点和虚线，均匀分布组件边缘
class DashedBorder extends StatelessWidget {
  final Widget child; // 子组件
  final double dashWidth; // 虚线步长宽度，当isDot为true，则dashWidth为圆点半径
  final double dashGap; // 虚线步长间距
  final Color color;
  final double strokeWidth; // 虚线宽度
  final BorderRadius? borderRadius; // 圆角,BorderRadius.circular(50)
  final ShapeType? shape; // 形状，ShapeType.circle圆形
  final bool isDot; // 是否为圆点

  const DashedBorder({
    super.key,
    required this.child,
    this.dashWidth = 4.0,
    this.dashGap = 9.0,
    this.color = const Color(0xffcccccc),
    this.strokeWidth = 1.0,
    this.borderRadius,
    this.shape,
    this.isDot = false, // 默认使用虚线
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DashedBorderPainter(
        dashWidth: dashWidth,
        dashGap: dashGap,
        color: color,
        strokeWidth: strokeWidth,
        borderRadius: borderRadius,
        shape: shape,
        isDot: isDot,
      ),
      child: child,
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  final double dashWidth;
  final double dashGap;
  final Color color;
  final double strokeWidth;
  final BorderRadius? borderRadius;
  final ShapeType? shape;
  final bool isDot;

  _DashedBorderPainter({
    required this.dashWidth,
    required this.dashGap,
    required this.color,
    required this.strokeWidth,
    this.borderRadius,
    this.shape,
    required this.isDot,
  });

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    Path path = Path();

    if (shape == ShapeType.circle) {
      final radius =
          size.width < size.height ? size.width / 2 : size.height / 2;
      path.addOval(Rect.fromCircle(
          center: Offset(size.width / 2, size.height / 2),
          radius: radius - strokeWidth / 2));
    } else if (shape == ShapeType.square) {
      path.addRRect((BorderRadius.circular(0)).toRRect(Rect.fromLTWH(0, 0, size.width, size.height)));
    } else if (borderRadius != null || shape == ShapeType.roundedRectangle) {
      path.addRRect((borderRadius ?? BorderRadius.circular(10)).toRRect(Rect.fromLTWH(0, 0, size.width, size.height)));
    } else {
      path.addRect(Rect.fromLTWH(0, 0, size.width, size.height));
    }

    if (isDot) {
      _drawDots(canvas, path, paint);
    } else {
      _drawDashedPath(canvas, path, paint);
    }
  }

  void _drawDashedPath(Canvas canvas, Path path, Paint paint) {
    final Path dashedPath = Path();

    for (final PathMetric metric in path.computeMetrics()) {
      final double totalLength = metric.length;
      // 计算能够放置多少个完整的虚线段
      final int dashCount = (totalLength / (dashWidth + dashGap)).floor();
      if (dashCount == 0) return; // 避免除以零

      // 计算调整后的间隔，以便虚线均匀分布
      final double adjustedDashGap =
          (totalLength - (dashCount * dashWidth)) / dashCount;

      double distance = 0.0;

      for (int i = 0; i < dashCount; i++) {
        final double start = distance;
        final double end = distance + dashWidth;
        dashedPath.addPath(
            metric.extractPath(
                start, end > metric.length ? metric.length : end),
            Offset.zero);
        distance += dashWidth + adjustedDashGap;
      }
    }

    canvas.drawPath(dashedPath, paint);
  }

  void _drawDots(Canvas canvas, Path path, Paint paint) {
    for (final PathMetric metric in path.computeMetrics()) {
      final double totalLength = metric.length;
      // 使用dashWidth作为圆点的直径，dashGap作为间距
      final double dotDiameter = dashWidth;
      final double spacing = dashGap;

      // 计算能够放置多少个圆点
      final int dotCount = (totalLength / (dotDiameter + spacing)).floor();
      if (dotCount == 0) return; // 避免除以零

      // 计算调整后的间隔，以便圆点均匀分布
      final double adjustedSpacing =
          (totalLength - (dotCount * dotDiameter)) / dotCount;

      double distance = 0.0;

      for (int i = 0; i < dotCount; i++) {
        final Tangent? tangent =
            metric.getTangentForOffset(distance + dotDiameter / 2);
        if (tangent != null) {
          canvas.drawCircle(tangent.position, dotDiameter / 2, paint);
        }
        distance += dotDiameter + adjustedSpacing;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedBorderPainter oldDelegate) {
    return oldDelegate.dashWidth != dashWidth ||
        oldDelegate.dashGap != dashGap ||
        oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.borderRadius != borderRadius ||
        oldDelegate.shape != shape ||
        oldDelegate.isDot != isDot;
  }
}
