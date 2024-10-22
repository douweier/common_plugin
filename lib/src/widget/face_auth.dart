import 'dart:async';

import 'package:common_plugin/common_plugin.dart';
import 'package:flutter/material.dart';

/// 人脸采集认证
class FaceAuthView extends StatefulWidget {
  /// 采集人脸数据回调，返回ResponseBack，isSuccess为认证结果状态，如果含有错误以message反馈显示
  final Future<ResponseBack> Function(String path)
      onCallback; // 采集人脸数据回调，并return认证结果以便当前页面处理
  final int timeout = 30; // 采集超时时间
  const FaceAuthView({super.key, required this.onCallback});

  @override
  State<FaceAuthView> createState() => _FaceAuthViewState();
}

class _FaceAuthViewState extends State<FaceAuthView> {
  String? imagePath;
  Timer? _timer;
  int _start = 0;
  bool isNowAuthing = false; // 正在认证识别中
  bool isStartAuthing = false; // 开始认证中，包含全部流程
  String authStatusDescription = "请正对手机摄像头，保持不动";
  Color authStatusColor = Colors.black;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    CameraController.controller?.dispose();
    _timer?.cancel();
    _timer = null;
    super.dispose();
  }

  void _startTimer() {
    if (_timer != null && _timer?.isActive == true) {
      return;
    }
    if (mounted) {
      setState(() {
        isStartAuthing = true;
        authStatusDescription = "请正对手机摄像头，保持不动";
        authStatusColor = Colors.black;
        _start = 5;
      });
    }
    try {
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) async {
        if (_start <= 0) {
          _timer?.cancel();
          _timer = null;
          if (mounted) {
            authStatusDescription = "正在认证中 ...";
            authStatusColor = ColorTheme.main;
            setState(() {});
          }
          final path = await CameraController.takePicture();
          if (path == null) {
            authStatusDescription = "请调整好姿势正对屏幕";
            authStatusColor = Colors.red;
            isStartAuthing = false;
            showDialogLayer(content: "认证失败了，请调整好姿势正对屏幕", type: 1);
          } else {
            if (mounted) {
              setState(() {
                isNowAuthing = true;
                authStatusDescription = "等待认证结果 ...";
                authStatusColor = ColorTheme.main;
              });
            }
            _onCallback(path);
          }
        } else {
          _start--;
        }
        if (mounted) {
          setState(() {});
        }
      });
    } catch (e) {
      _timer?.cancel();
      _timer = null;
      _start = 0;
      if (mounted) {
        isStartAuthing = false;
        isNowAuthing = false;
        authStatusDescription = "认证时发生了错误";
        authStatusColor = ColorTheme.red;
        setState(() {});
      }
      Logger.error("$e", mark: "FaceAuthView");
    }
  }

  void _onCallback(String path) async {
    dynamic res = await awaitTimeShowLoading(() {
      return widget.onCallback.call(path);
    }, timeout: widget.timeout);
    res ??= ResponseBack();
    if (res != null && res.isSuccess) {
      authStatusDescription = "认证成功";
      authStatusColor = ColorTheme.green;
      showAlert("认证成功");
      back();
    } else {
      isStartAuthing = false;
      isNowAuthing = false;
      authStatusDescription =
          isEmptyOrNull(res.message) ? "认证失败，请注意人脸是否清晰" : res.message;
      authStatusColor = Colors.red;
      showDialogLayer(content: authStatusDescription, type: 1);
      if (mounted) {
        setState(() {});
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isNowAuthing) {
      return AppView(
        body: Center(
            child: Padding(
          padding: const EdgeInsets.only(bottom: 80),
          child: TextView(
            authStatusDescription,
            fontSize: 18,
          ),
        )),
      );
    }
    return CameraView(
      isFrontCamera: true,
      isShowBar: false,
      child: Stack(
        children: [
          // 添加圆形遮罩层
          Positioned.fill(
            child: ClipPath(
              clipper: CircleClipper(radius: screenSize.width / 2 - 10),
              child: Container(
                color: Colors.white.withOpacity(0.9),
                padding: const EdgeInsets.all(8),
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: ColorTheme.mainLight, width: 2),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
          ),
          Center(
              child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: EdgeInsets.only(
                    top: MediaQuery.of(context).padding.top +
                        ((screenSize.height - screenSize.width) / 4)),
                child: TextView(
                  authStatusDescription,
                  fontSize: 20,
                  color: authStatusColor,
                ),
              ),
              if (_start > 0) _buildShowCountDown(),
              Column(
                children: [
                  ButtonView(
                    text: "开始认证",
                    height: 40,
                    fastClickTime: 7000,
                    isDisable: isStartAuthing,
                    margin: const EdgeInsets.symmetric(horizontal: 35),
                    onPressed: () {
                      _startTimer();
                    },
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  ButtonView(
                    text: "退出认证",
                    height: 40,
                    isOutLineButton: true,
                    fastClickTime: 5000,
                    margin: EdgeInsets.only(
                        left: 35,
                        right: 35,
                        bottom: MediaQuery.of(context).padding.bottom + 30),
                    onPressed: () {
                      back();
                    },
                  ),
                ],
              ),
            ],
          )),
        ],
      ),
    );
  }

  Widget _buildShowCountDown() {
    return Center(
      child: Text(
        '$_start',
        style: const TextStyle(color: Colors.white, fontSize: 60),
      ),
    );
  }
}

// 创建圆形透明区域
class CircleClipper extends CustomClipper<Path> {
  final double radius;

  CircleClipper({this.radius = 150});

  @override
  Path getClip(Size size) {
    Path path = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addOval(Rect.fromCircle(
          center: Offset(size.width / 2, size.height / 2), radius: radius))
      ..fillType = PathFillType.evenOdd;
    return path;
  }

  @override
  bool shouldReclip(CircleClipper oldClipper) => false;
}
