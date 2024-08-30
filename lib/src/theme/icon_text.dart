
import 'package:common_plugin/common_plugin.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class IconText extends StatelessWidget {
  const IconText(
      this.icon, {
        Key? key,
        this.size = 35,
        this.color = ColorTheme.white,
        this.semanticLabel,
        this.textDirection,
        this.shadowShow = true,
        this.shadowColor = Colors.black54,
      }) : super(key: key);

  final IconData icon;

  final double size;

  final Color color;

  final String? semanticLabel;

  final TextDirection? textDirection;

  final bool shadowShow;

  final Color shadowColor;

  @override
  Widget build(BuildContext context) {
    assert(this.textDirection != null || debugCheckHasDirectionality(context));
    final TextDirection textDirection = this.textDirection ?? Directionality.of(context);

    final IconThemeData iconTheme = IconTheme.of(context);

    final double iconSize = size;



    final double iconOpacity = iconTheme.opacity ?? 1.0;
    Color iconColor = color;
    if (iconOpacity != 1.0)
      iconColor = iconColor.withOpacity(iconColor.opacity * iconOpacity);

    Widget iconWidget = RichText(
      overflow: TextOverflow.visible, // Never clip.
      textDirection: textDirection, // Since we already fetched it for the assert...
      text: TextSpan(
        text: String.fromCharCode(icon.codePoint),
        style: TextStyle(
          inherit: false,
          color: iconColor,
          fontSize: iconSize,
          fontFamily: icon.fontFamily,
          package: icon.fontPackage,
          shadows: shadowShow ? [
            BoxShadow(
                color: shadowColor,
                offset: const Offset(1,1),
                blurRadius: 9.0, //阴影模糊程度
                spreadRadius: 0.1, //阴影扩散程度
            ),
          ] : [],
        ),
      ),
    );

    if (icon.matchTextDirection) {
      switch (textDirection) {
        case TextDirection.rtl:
          iconWidget = Transform(
            transform: Matrix4.identity()..scale(-1.0, 1.0, 1.0),
            alignment: Alignment.center,
            transformHitTests: false,
            child: iconWidget,
          );
          break;
        case TextDirection.ltr:
          break;
      }
    }

    return Semantics(
      label: semanticLabel,
      child: ExcludeSemantics(
        child: SizedBox(
          width: iconSize,
          height: iconSize,
          child: Center(
            child: iconWidget,
          ),
        ),
      ),
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(IconDataProperty('icon', icon, ifNull: '<empty>', showName: false));
    properties.add(DoubleProperty('size', size, defaultValue: null));
    properties.add(ColorProperty('color', color, defaultValue: null));
  }
}
