import 'package:flutter/material.dart';

class ProgressPointBar extends StatelessWidget {
  const ProgressPointBar({
    super.key,
    this.witdh = 158,
    this.height = 6,
    this.activeColor = Colors.white,
    this.bgColor = Colors.white,
    required this.current,
    required this.max,
  });
  final double max;
  final double current;
  final double? witdh;
  final double? height;
  final Color? bgColor;
  final Color? activeColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Stack(
        children: [
          SizedBox(
            height: 20,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: witdh,
                  height: height,
                  decoration: BoxDecoration(
                    color: bgColor!.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(height! / 2.0),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            child: SizedBox(
              height: 20,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  max == 0
                      ? const SizedBox()
                      : Container(
                          width: witdh! * current / max,
                          height: height,
                          decoration: BoxDecoration(
                            color: bgColor,
                            borderRadius: BorderRadius.circular(height! / 2.0),
                          ),
                        ),
                ],
              ),
            ),
          ),
          Visibility(
            visible: current != max,
            child: Positioned(
              left: witdh! * current / max - 6,
              top: 4,
              bottom: 0,
              child: Stack(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: activeColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  SizedBox(
                    width: 12,
                    height: 12,
                    child: Center(
                      child: Container(
                        width: 4,
                        height: 4,
                        decoration: BoxDecoration(
                          color: const Color(0xFF0066FE),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
