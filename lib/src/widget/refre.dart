
import 'package:flutter/material.dart';


typedef CallWidgetFun = Widget Function(
  Widget child,
  Function(DragUpdateDetails details) invokeScroll,
  Function() stopScroll,
  Function() upDate,
);

class Refre extends StatefulWidget {
  Refre({
    this.child,
    this.onRefresh,
    this.pullUpRefresh,
    this.initRefresh = true,
  });

  final CallWidgetFun? child;
  final RefreshCallback? onRefresh;
  final RefreshCallback? pullUpRefresh; //上拉
  final bool initRefresh;

  @override
  _RefreState createState() => _RefreState();
}

class _RefreState extends State<Refre> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _sizeFactor;
  late AnimationController _keepAnimationController;
  late Animation<double> _keepSizeFactor;

  // Animatable<double> _oneToZeroTween = Tween<double>(begin: 1.0, end: 0.0);
  double _scrollValue = 0.0;
  bool start = false;
  double isOverScroll = 0.0;
  bool refresh = false;

  bool _scrollNotification(ScrollNotification scrollnotification) {
    double size = 0.0;



    if (scrollnotification.metrics.axis == Axis.vertical) {
      ///上拉事件
      if (scrollnotification.metrics.extentAfter < 50.0){
        widget.pullUpRefresh!();
      }

      if (scrollnotification is OverscrollNotification) {
        start = true;
        isOverScroll += 0.1;
      }

      if (scrollnotification is ScrollStartNotification) {
        if (scrollnotification.metrics.pixels == 0) {
          size = 0.0;
        }
      } else if (scrollnotification is ScrollEndNotification) {
        start = false;
        isOverScroll = 0.0;
        if (refresh) {
          widget.onRefresh!().then((value) {
            if (_keepAnimationController.toString().indexOf("DISPOSED") == -1) {
              _keepAnimationController.forward().then((value) {
                refresh = false;
                _keepAnimationController.reset();
                if (mounted) {
                  setState(() {});
                }
              });
            }
          });
        }
      }

      if (scrollnotification is ScrollUpdateNotification) {
        if (scrollnotification.metrics.pixels < size && size == 0.0) {
          start = true;
        } else {
          start = false;
        }
        isOverScroll = 0.0;
      }

      // && scrollnotification.metrics.pixels == 0
      // because this code send some bug

      if (scrollnotification is OverscrollNotification) {
        if (start && scrollnotification.metrics.pixels <= scrollnotification.metrics.maxScrollExtent && scrollnotification.overscroll < 0) {
          _animationController.reset();
          _scrollValue = isOverScroll * 10;
                  if (!refresh) {
            if (_scrollValue.abs() > 49) {
              refresh = true;
            }
          }
          if (mounted) {
            setState(() {});
          }
        } else {
          _scrollValue = 0.0;
          if (mounted) {
            setState(() {});
          }
        }
      } else {
        _scrollValue = 0.0;
        if (mounted) {
          setState(() {});
        }
      }
    }

    return false;
  }

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(vsync: this, duration: Duration(milliseconds: 300));
    _sizeFactor = Tween(begin: 1.0, end: 0.0).animate(_animationController);
    _keepAnimationController = AnimationController(vsync: this, duration: Duration(milliseconds: 300));
    _keepSizeFactor = Tween(begin: 1.0, end: 0.0).animate(_keepAnimationController);
    if (widget.initRefresh) {
      _show();
    } else {
      widget.onRefresh!();
    }
  }

  _upOutside(DragUpdateDetails details) {
    if (details.delta.dy > 0) {
      _animationController.reset();
      _scrollValue = details.localPosition.dy / 5;
    } else {
      _scrollValue = 0;
    }
    if (mounted) {
      setState(() {});
    }
  }

  _stopOutside() {
    _animationController.value = 0;
    if (_scrollValue >= 50) {
      _keepAnimationController.reset();
      refresh = true;

      if (mounted) {
        setState(() {});
      }

      widget.onRefresh!().then((value) {
        if (mounted) {
          _keepAnimationController.forward().then((value) {
            _scrollValue = 0;
            refresh = false;
            _keepAnimationController = AnimationController(vsync: this, duration: Duration(milliseconds: 300));
            _keepSizeFactor = Tween(begin: 1.0, end: 0.0).animate(_keepAnimationController);
            WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
              if (mounted) {
                setState(() {});
              }
            });
          });
        }
      });
    } else {
      _animationController.forward();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _keepAnimationController.dispose();
    super.dispose();
  }

  _show() {
    _scrollValue = 51;
    refresh = false;
    _stopOutside();
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: _scrollNotification,
      child: widget.child!(
          !refresh
              ? SizeTransition(
                  sizeFactor: _sizeFactor,
                  child: Row(crossAxisAlignment: CrossAxisAlignment.center, mainAxisAlignment: MainAxisAlignment.center, children: [
                    Text('正在努力加载', style: TextStyle(color: Color(0xffD7D7D7), fontSize: _scrollValue.abs() > 50 ? 14 : .3 * _scrollValue.abs())),
                    SizedBox(width: 10),
                    Image.asset('assets/images/load_animate.gif', height: _scrollValue.abs() > 50 ? 50 : _scrollValue.abs())
                  ]))
              : SizeTransition(
                  sizeFactor: _keepSizeFactor,
                  child: Row(crossAxisAlignment: CrossAxisAlignment.center, mainAxisAlignment: MainAxisAlignment.center, children: [
                    Text('正在努力加载', style: TextStyle(color: Color(0xffD7D7D7))),
                    SizedBox(width: 10),
                    Image.asset('assets/images/load_animate.gif', height: 50)
                  ])),
          _upOutside,
          _stopOutside,
          _show),
    );
  }
}
