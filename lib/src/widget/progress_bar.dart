import 'package:flutter/material.dart';

class ProgressBar extends StatelessWidget {
  final double max;
  final double current;
  final double? witdh;
  final double? height;
  final Color? bgColor;
  final Color? activeColor;
  const ProgressBar({
    super.key,
    this.witdh = 38,
    this.height = 6,
    this.activeColor = const Color(0xFF0066FE),
    this.bgColor = const Color(0xFFE8E8E8),
    required this.current,
    required this.max,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Stack(
        children: [
          Container(
            width: witdh,
            height: height,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(height! / 2.0),
            ),
          ),
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            child: Container(
              width: witdh! * current / max,
              decoration: BoxDecoration(
                color: activeColor,
                borderRadius: BorderRadius.circular(height! / 2.0),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
