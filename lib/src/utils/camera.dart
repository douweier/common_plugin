import 'dart:io';

import 'package:common_plugin/common_plugin.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart' as camera;
import 'dart:async';

import 'package:flutter/services.dart';

/// 相机拍摄控制器，控制CameraView摄像头开始和结束拍照、录制视频
class CameraController {
  static camera.CameraController? controller;

  /// 拍照
  static Future<String?> takePicture() async {
    if (controller == null) {
      return null;
    }
    try {
      final file = await controller!.takePicture();
      return file.path;
    } catch (e) {
      Logger.error(e.toString(), mark: 'CameraView-takePicture');
      return null;
    }
  }

  /// 开始录制视频
  static Future<void> startVideoRecording() async {
    if (controller == null) {
      return;
    }
    try {
      await controller!.startVideoRecording();
    } catch (e) {
      Logger.error(e.toString(), mark: 'CameraView-startVideoRecording');
    }
  }

  /// 停止录制视频
  static Future<camera.XFile?> stopVideoRecording() async {
    if (controller == null) {
      return null;
    }
    try {
      return await controller!.stopVideoRecording();
    } catch (e) {
      Logger.error(e.toString(), mark: 'CameraView-stopVideoRecording');
      return null;
    }
  }

  /// 切换摄像头
  static Future<void> switchCamera({bool? isFrontCamera}) async {
    final permission = await PermissionUtils.camera();
    if (!permission) {
      showAlert("没有相机权限，无法拍摄");
      return;
    }

    try {
      if (controller != null) {
        await controller!.dispose();
      }
      final cameras = await camera.availableCameras();
      final selectedCamera = (isFrontCamera == null)
          ? (controller?.description.lensDirection ==
                  camera.CameraLensDirection.front
              ? cameras.firstWhere(
                  (cam) => cam.lensDirection == camera.CameraLensDirection.back)
              : cameras.firstWhere((cam) =>
                  cam.lensDirection == camera.CameraLensDirection.front))
          : (isFrontCamera
              ? cameras.firstWhere((cam) =>
                  cam.lensDirection == camera.CameraLensDirection.front)
              : cameras.firstWhere((cam) =>
                  cam.lensDirection == camera.CameraLensDirection.back));
      controller = camera.CameraController(
        selectedCamera,
        camera.ResolutionPreset.high,
        // enableAudio: false,
        imageFormatGroup: Platform.isAndroid
            ? camera.ImageFormatGroup.nv21
            : camera.ImageFormatGroup.bgra8888,
      );
      await controller!.initialize();
    } catch (e) {
      Logger.error(e.toString(), mark: 'CameraView-switchCamera');
    }
  }

  /// 设置摄像头方向
  static Future<void> setCameraOrientation(
      DeviceOrientation orientation) async {
    if (controller == null) {
      return;
    }
    try {
      await controller!.lockCaptureOrientation(orientation);
    } catch (e) {
      Logger.error(e.toString(), mark: 'CameraView-setCameraOrientation');
    }
  }

  /// 打开闪光灯
  static Future<void> toggleFlash({bool? isOpen}) async {
    if (controller == null) {
      return;
    }
    try {
      final flashValue = isOpen == true
          ? camera.FlashMode.torch
          : (controller!.value.flashMode == camera.FlashMode.off
              ? camera.FlashMode.torch
              : camera.FlashMode.off);
      await controller!.setFlashMode(flashValue);
    } catch (e) {
      Logger.error(e.toString(), mark: 'CameraView-toggleFlash');
    }
  }

  static Future<void> stopImageStream() async{
    try {
      await controller?.stopImageStream();
    } catch (e) {
      Logger.error(e.toString(), mark: 'CameraView-stopImageStream');
    }
  }

  /// 释放资源
  static void dispose() {
    controller?.dispose();
    controller = null;
  }
}

/// 相机拍摄界面
class CameraView extends StatefulWidget {
  final Function(String path)? onCallback; // 相机拍摄回调
  final bool isShowBar; // 是否显示拍摄按钮栏
  final bool isFrontCamera; // 是否启用前置摄像头，默认为false后置摄像头
  final bool isShowSwitchCamera; // 是否显示摄像头切换
  final Widget? child; // 层叠于摄像头预览界面

  const CameraView({
    super.key,
    this.onCallback,
    this.child,
    this.isShowBar = true,
    this.isFrontCamera = false,
    this.isShowSwitchCamera = true,
  });

  @override
  State<CameraView> createState() => _CameraViewState();
}

class _CameraViewState extends State<CameraView> {
  bool _isCameraInitialized = false;
  bool isFlashOn = false; // 是否开启闪光灯

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future _initializeCamera() async {
    await CameraController.switchCamera(isFrontCamera: widget.isFrontCamera);
    setState(() {
      _isCameraInitialized = true;
    });
  }

  Future<void> _takePicture() async {
    if (!CameraController.controller!.value.isInitialized) {
      return;
    }

    if (CameraController.controller!.value.isTakingPicture) {
      return;
    }
    final file = await CameraController.takePicture();
    if (file == null) return;
    Navigator.pop(context);
    widget.onCallback?.call(file);
  }

  @override
  void dispose() {
    _stopImageStream();
    CameraController.dispose();
    super.dispose();
  }

  Future<void> _stopImageStream() async {
    try {
      await CameraController.stopImageStream();
    } catch (e) {
      Logger.error("停止图像流失败: $e", mark: "CameraView_stopImageStream");
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppView(
      backgroundColor: Colors.black,
      body: _isCameraInitialized
          ? Stack(
              children: [
                const SizedBox(
                  height: double.infinity,
                  width: double.infinity,
                ),
                SizedBox(
                  width: double.infinity,
                  child: camera.CameraPreview(
                    CameraController.controller!,
                  ),
                ),
                SizedBox(
                    height: double.infinity,
                    width: double.infinity,
                    child: widget.child),
                if (widget.isShowBar && !widget.isFrontCamera)
                  Positioned(
                    top: 30,
                    left: 30,
                    child: !isFlashOn
                        ? IconButton(
                            icon: const Icon(Icons.flash_off_rounded,
                                color: Colors.white),
                            onPressed: () async {
                              await CameraController.toggleFlash(isOpen: true);
                              isFlashOn = true;
                              setState(() {});
                            },
                          )
                        : IconButton(
                            icon: const Icon(Icons.flash_on_rounded,
                                color: Colors.white),
                            onPressed: () async {
                              await CameraController.toggleFlash(isOpen: false);
                              isFlashOn = false;
                              setState(() {});
                            },
                          ),
                  ),
                if (widget.isShowBar == true)
                  Positioned(
                    bottom: 50,
                    left: 0,
                    right: 0,
                    child: SafeArea(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Row(
                            children: [
                              widget.isShowSwitchCamera == true
                                  ? Container(
                                      width: 50,
                                      height: 50,
                                      padding: const EdgeInsets.all(2),
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                            color:
                                                Colors.white.withOpacity(0.5),
                                            width: 2),
                                      ),
                                      child: IconButton(
                                        icon: const Icon(
                                            Icons.flip_camera_android_outlined,
                                            color: Colors.white),
                                        onPressed: () async {
                                          await CameraController.switchCamera();
                                          setState(() {});
                                        },
                                      ),
                                    )
                                  : const SizedBox(
                                      width: 50,
                                    ),
                            ],
                          ),
                          InkWell(
                            onTap: _takePicture,
                            child: Container(
                              width: 65,
                              height: 65,
                              padding: const EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                    color: ColorTheme.white.withOpacity(0.5),
                                    width: 3),
                              ),
                              child: Container(
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          const Row(children: [
                            SizedBox(
                              width: 50,
                            )
                          ])
                        ],
                      ),
                    ),
                  ),
              ],
            )
          : const LoadingPage(showAppScaffold: false),
    );
  }
}
