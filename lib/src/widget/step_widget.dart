import 'package:common_plugin/common_plugin.dart';
import 'package:flutter/material.dart';

enum StepType {
  indexed,
  editing,  // 显示编辑图标
  complete, // 显示勾完成图标
  dot,
  disabled,
  error, // 显示感叹号
}

class StepItem {
   StepItem({
    required this.title,
    this.titleFontSize = 14,
    this.icon,
    this.subtitle,
    this.content,
    this.type = StepType.indexed,
    this.isActive = true,
  });

  final String title;
  final double titleFontSize;

  final IconData? icon;

  final Widget? subtitle;

  final Widget? content;

  final StepType type;

  final bool isActive;
}

class StepWidget extends StatefulWidget {
  const StepWidget({
    super.key,
    required this.steps,
    this.physics,
    this.direction = StepperType.horizontal,
    this.currentStep = 0,
    this.isClickShowItem = false,
    this.onStepTapped,
    this.onStepContinue,
    this.onStepCancel,
  }) : assert(0 <= currentStep && currentStep < steps.length);

  final List<StepItem> steps;

  final ScrollPhysics? physics;
  final StepperType direction;

  ///点击item才显示对应的item内容content
  final bool isClickShowItem;
  final int currentStep;
  final ValueChanged<int>? onStepTapped;
  final VoidCallback? onStepContinue;
  final VoidCallback? onStepCancel;

  @override
  State<StepWidget> createState() => _StepperState();
}

class _StepperState extends State<StepWidget> with TickerProviderStateMixin {
  List<GlobalKey>? _keys;
  final Map<int, StepType> _oldStates = <int, StepType>{};

  @override
  void initState() {
    super.initState();
    _keys = List<GlobalKey>.generate(
      widget.steps.length,
      (int i) => GlobalKey(),
    );

    for (int i = 0; i < widget.steps.length; i += 1) {
      _oldStates[i] = widget.steps[i].type;
    }
  }

  @override
  void didUpdateWidget(StepWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    assert(widget.steps.length == oldWidget.steps.length);

    for (int i = 0; i < oldWidget.steps.length; i += 1)
      _oldStates[i] = oldWidget.steps[i].type;
  }

  bool _isFirst(int index) {
    return index == 0;
  }

  bool _isLast(int index) {
    return widget.steps.length - 1 == index;
  }

  bool _isCurrent(int index) {
    return widget.currentStep == index;
  }

  bool _isDark() {
    return Theme.of(context).brightness == Brightness.dark;
  }

  Widget _buildLine(bool visible) {
    return Container(
      width: visible ? 1.0 : 0.0,
      height: 16.0,
      color: Colors.grey.shade400,
    );
  }

  Widget? _buildCircleChild(int index, bool oldState) {
    final StepType? state =
        oldState ? _oldStates[index] : widget.steps[index].type;
    final bool isDarkActive = _isDark() && widget.steps[index].isActive;
    assert(state != null);

    if (widget.steps[index].icon != null) {
      return Icon(
        widget.steps[index].icon,
        color: isDarkActive ? Colors.black87 : Colors.white,
        size: 16.0,
      );
    }

    switch (state) {
      case StepType.indexed:
      case StepType.disabled:
        return Text(
          '${index + 1}',
          style: isDarkActive
              ? const TextStyle(
                  fontSize: 12.0,
                  color: Colors.black87,
                )
              : const TextStyle(
                  fontSize: 12.0,
                  color: Colors.white,
                ),
        );
      case StepType.editing:
        return Icon(
          Icons.edit,
          color: isDarkActive ? Colors.black87 : Colors.white,
          size: 18.0,
        );
      case StepType.complete:
        return Icon(
          Icons.check,
          color: isDarkActive ? Colors.black87 : Colors.white,
          size: 18.0,
        );
      case StepType.error:
        return const Text('!',
            style: TextStyle(
              fontSize: 12.0,
              color: Colors.white,
            ));
      case StepType.dot:
        return const Center();
      case null:
    }
    return null;
  }

  Color _circleColor(int index) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    if (!_isDark()) {
      return widget.steps[index].isActive && index <= widget.currentStep
          ? (index == widget.currentStep
              ? ColorTheme.main
              : ColorTheme.mainLight.withOpacity(0.5))
          : colorScheme.onSurface.withOpacity(0.15);
    } else {
      return widget.steps[index].isActive
          ? colorScheme.secondary
          : colorScheme.surface;
    }
  }

  Widget _buildCircle(int index, bool oldState) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      width: widget.steps[index].type == StepType.dot ? 6.0 : 24.0,
      height: widget.steps[index].type == StepType.dot ? 6.0 : 24.0,
      child: AnimatedContainer(
        curve: Curves.fastOutSlowIn,
        duration: kThemeAnimationDuration,
        decoration: BoxDecoration(
          color: _circleColor(index),
          shape: BoxShape.circle,
        ),
        child: Center(
          child: _buildCircleChild(
              index, oldState && widget.steps[index].type == StepType.error),
        ),
      ),
    );
  }

  Widget _buildTriangle(int index, bool oldState) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      width: 24.0,
      height: 24.0,
      child: Center(
        child: SizedBox(
          width: 24.0,
          height: 24.0 * 0.866025,
          child: CustomPaint(
            painter: _TrianglePainter(
              color: _isDark() ? Colors.red.shade400 : Colors.red,
            ),
            child: Align(
              alignment: const Alignment(0.0, 0.8),
              child: _buildCircleChild(index,
                  oldState && widget.steps[index].type != StepType.error),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIcon(int index) {
    if (widget.steps[index].type != _oldStates[index]) {
      return AnimatedCrossFade(
        firstChild: _buildCircle(index, true),
        secondChild: _buildTriangle(index, true),
        firstCurve: const Interval(0.0, 0.6, curve: Curves.fastOutSlowIn),
        secondCurve: const Interval(0.4, 1.0, curve: Curves.fastOutSlowIn),
        sizeCurve: Curves.fastOutSlowIn,
        crossFadeState: widget.steps[index].type == StepType.error
            ? CrossFadeState.showSecond
            : CrossFadeState.showFirst,
        duration: kThemeAnimationDuration,
      );
    } else {
      if (widget.steps[index].type != StepType.error) {
        return _buildCircle(index, false);
      } else {
        return _buildTriangle(index, false);
      }
    }
  }

  TextStyle? _titleStyle(int index) {
    final ThemeData themeData = Theme.of(context);
    final TextTheme textTheme = themeData.textTheme;

    switch (widget.steps[index].type) {
      case StepType.indexed:
      case StepType.editing:
      case StepType.complete:
        return textTheme.bodyMedium;
      case StepType.disabled:
        return textTheme.bodyMedium
            ?.copyWith(color: _isDark() ? Colors.white30 : Colors.black38);
      case StepType.error:
        return textTheme.bodyMedium
            ?.copyWith(color: _isDark() ? Colors.red.shade400 : Colors.red);
      case StepType.dot:
    }
    return null;
  }

  TextStyle? _subtitleStyle(int index) {
    final ThemeData themeData = Theme.of(context);
    final TextTheme textTheme = themeData.textTheme;

    switch (widget.steps[index].type) {
      case StepType.indexed:
      case StepType.editing:
      case StepType.complete:
        return textTheme.bodySmall;
      case StepType.disabled:
        return textTheme.bodySmall
            ?.copyWith(color: _isDark() ? Colors.white30 : Colors.black38);
      case StepType.error:
        return textTheme.bodySmall
            ?.copyWith(color: _isDark() ? Colors.red.shade400 : Colors.red);
      case StepType.dot:
    }
    return null;
  }

  Widget _buildHeaderText(int index) {
    final List<Widget> children = <Widget>[
      AnimatedDefaultTextStyle(
        style: _titleStyle(index)!,
        duration: kThemeAnimationDuration,
        curve: Curves.fastOutSlowIn,
        child: Text(
          widget.steps[index].title,
          style: TextStyle(
            fontSize: widget.steps[index].titleFontSize,
              color: index <= widget.currentStep
                  ? (index == widget.currentStep
                      ? ColorTheme.main
                      : Colors.black87.withOpacity(0.6))
                  : Colors.grey),
        ),
      ),
    ];

    if (widget.steps[index].subtitle != null) {
      children.add(
        Container(
          margin: const EdgeInsets.only(top: 2.0),
          child: AnimatedDefaultTextStyle(
            style: _subtitleStyle(index)!,
            duration: kThemeAnimationDuration,
            curve: Curves.fastOutSlowIn,
            child: widget.steps[index].subtitle!,
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: children,
    );
  }

  Widget _buildVerticalHeader(int index) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Row(
        children: <Widget>[
          Column(
            children: <Widget>[
              _buildLine(!_isFirst(index)),
              _buildIcon(index),
              _buildLine(!_isLast(index)),
            ],
          ),
          Container(
            margin: const EdgeInsetsDirectional.only(start: 12.0),
            child: _buildHeaderText(index),
          ),
        ],
      ),
    );
  }

  Widget _buildVerticalBody(int index) {
    return Stack(
      children: <Widget>[
        PositionedDirectional(
          start: 24.0,
          top: 0.0,
          bottom: 0.0,
          child: SizedBox(
            width: 24.0,
            child: Center(
              child: SizedBox(
                width: _isLast(index) ? 0.0 : 1.0,
                child: Container(
                  color: Colors.grey.shade400,
                ),
              ),
            ),
          ),
        ),
        AnimatedCrossFade(
          firstChild: Container(height: 0.0),
          secondChild: Container(
            margin: const EdgeInsetsDirectional.only(
              start: 60.0,
              end: 24.0,
              bottom: 24.0,
            ),
            child: Column(
              children: <Widget>[
                if (widget.steps[index].content != null)
                  Row(
                    children: [
                      Expanded(child: widget.steps[index].content!),
                    ],
                  ),
              ],
            ),
          ),
          firstCurve: const Interval(0.0, 0.6, curve: Curves.fastOutSlowIn),
          secondCurve: const Interval(0.4, 1.0, curve: Curves.fastOutSlowIn),
          sizeCurve: Curves.fastOutSlowIn,
          crossFadeState: widget.isClickShowItem
              ? (_isCurrent(index)
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst)
              : CrossFadeState.showSecond,
          duration: kThemeAnimationDuration,
        ),
      ],
    );
  }

  Widget _buildVertical() {
    final List<Widget> children = <Widget>[];

    for (int i = 0; i < widget.steps.length; i += 1) {
      children.add(Column(
        key: _keys![i],
        children: <Widget>[
          InkWell(
            onTap: widget.steps[i].type != StepType.disabled
                ? () {
                    Scrollable.ensureVisible(
                      _keys![i].currentContext!,
                      curve: Curves.fastOutSlowIn,
                      duration: kThemeAnimationDuration,
                    );

                    if (widget.onStepTapped != null) widget.onStepTapped!(i);
                  }
                : null,
            child: _buildVerticalHeader(i),
          ),
          _buildVerticalBody(i),
        ],
      ));
    }

    return ListView(
      shrinkWrap: true,
      physics: widget.physics,
      children: children,
    );
  }

  Widget _buildHorizontal() {
    final List<Widget> children = <Widget>[];
    final List<Widget> textChildren = <Widget>[];

    for (int i = 0; i < widget.steps.length; i += 1) {
      textChildren.add(Expanded(
        child: Center(
          child: _buildHeaderText(i),
        ),
      ));

      Widget child;

      if (i == 0) {
        child = Container(
          margin: EdgeInsets.only(
              left:
                  MediaQuery.of(context).size.width / widget.steps.length / 2 -
                      24.0 / 2),
          child: _buildIcon(i),
        );
      } else if (_isLast(i)) {
        child = Container(
          margin: EdgeInsets.only(
              right:
                  MediaQuery.of(context).size.width / widget.steps.length / 2 -
                      24.0 / 2),
          child: _buildIcon(i),
        );
      } else {
        child = _buildIcon(i);
      }

      children.add(
        InkResponse(
          onTap: widget.steps[i].type != StepType.disabled
              ? () {
                  if (widget.onStepTapped != null) widget.onStepTapped!(i);
                }
              : null,
          child: SizedBox(
            height: 52.0,
            child: Center(
              child: child,
            ),
          ),
        ),
      );

      if (!_isLast(i)) {
        children.add(
          Expanded(
            child: SizedBox(
              height: 52.0,
              child: Center(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 5.0),
                  height: 1.0,
                  color: i < widget.currentStep
                      ? Theme.of(context).primaryColor
                      : Colors.grey.shade400,
                ),
              ),
            ),
          ),
        );
      }
    }

    return Material(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: children,
          ),
          Row(
            children: textChildren,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasMaterial(context));
    assert(debugCheckHasMaterialLocalizations(context));
    assert(() {
      if (context.findAncestorWidgetOfExactType<Stepper>() != null) {
        throw FlutterError(
            'Step error: stepper should not be placed inside another stepper.');
      }
      return true;
    }());
    switch (widget.direction) {
      case StepperType.vertical:
        return _buildVertical();
      case StepperType.horizontal:
        return _buildHorizontal();
    }
  }
}

class _TrianglePainter extends CustomPainter {
  _TrianglePainter({
    required this.color,
  });

  Color color;

  @override
  bool hitTest(Offset point) => true; // Hitting the rectangle is fine enough.

  @override
  bool shouldRepaint(_TrianglePainter oldPainter) {
    return oldPainter.color != color;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final double base = size.width;
    final double halfBase = size.width / 2.0;
    final double height = size.height;
    final List<Offset> points = <Offset>[
      Offset(0.0, height),
      Offset(base, height),
      Offset(halfBase, 0.0),
    ];

    canvas.drawPath(
      Path()..addPolygon(points, true),
      Paint()..color = color,
    );
  }
}
