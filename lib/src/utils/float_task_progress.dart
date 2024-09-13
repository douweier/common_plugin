import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'dart:math';

import 'package:common_plugin/common_plugin.dart';

/// 下载进度条
class DownloadTaskProgress extends StatefulWidget {
  DownloadTaskProgress();

  @override
  State<StatefulWidget> createState() {
    return DownloadTaskProgressState();
  }
}

class DownloadTaskProgressState extends State<DownloadTaskProgress> {
  late ProgressBackPainter painter;

  //静止状态下的offset
  Offset idleOffset = Offset(0, 60);

  //本次移动的offset
  Offset moveOffset = const Offset(0, 60);

  //最后一次down事件的offset
  Offset lastStartOffset = const Offset(0, 0);

  late Timer? _timer;

  ///下载进度
  double progressValue = 0;

  ///是否停止任务
  bool stopTask = false;

  ///下方文字提醒任务状态
  bool remind = false;

  ///是否显示详情对话框
  bool showDialog = true;

  ///预计剩余下载时间
  int surplusTime = 0;

  ///平均MB/S 速度
  double speed = 0;

  ///任务用时
  int useTime = 0;

  ///统计5秒内的速率
  int countLastTime = 0;

  ///统计最近文件传输的文件大小
  int lastFileSize = 0;

  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _timer = null;
    super.dispose();
  }

  Future _init() async {
    painter = ProgressBackPainter();

    if (DownloadManage.state == 1 && !stopTask) {
      _timer = Timer.periodic(Duration(seconds: 1), (timer) async {
        useTime++;

        if (stopTask || DownloadManage.state != 1) {
          _timer?.cancel();
          _timer = null;
          toRemind();
        }

        if (DownloadManage.state == 1) {
          progressValue = DownloadManage.receiveSize / DownloadManage.fileSize;
          speed = (DownloadManage.receiveSize - lastFileSize).toDouble();
          lastFileSize = DownloadManage.receiveSize;
          surplusTime = (speed > 0)
              ? (DownloadManage.fileSize - DownloadManage.receiveSize) ~/ speed
              : surplusTime;
        }
        if (mounted) {
          setState(() {});
        }
      });
    }
  }

  Future toRemind() async {
    remind = true;
    ShowDragLayer.borderRadius = BorderRadius.circular(5);
    ShowDragLayer.top = screenSize.height * 0.3;
    ShowDragLayer.refresh();
    if (mounted) {
      setState(() {});
    }
    Future.delayed(Duration(seconds: 10), () {
      remind = false;
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (DownloadManage.state != 1) {
      return buildDialogStop();
    }

    return !showDialog
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                  width: 50,
                  height: 50,
                  child: Stack(
                    children: [
                      Center(
                        child: SizedBox(
                          width: 50,
                          height: 50,
                          child: CircularProgressIndicator(
                            backgroundColor: Colors.grey[200]?.withOpacity(0.5),
                            valueColor:
                                AlwaysStoppedAnimation(Colors.lightBlueAccent),
                            value: progressValue,
                            strokeWidth: 4,
                          ),
                        ),
                      ),
                      Center(
                        child: GestureDetector(
                          onTap: () {
                            showDialog = true;
                            ShowDragLayer.top = screenSize.height * 0.3;
                            ShowDragLayer.set(
                                borderRadius2: BorderRadius.circular(5));
                            setState(() {});
                          },
                          child: CustomPaint(
                            child: Container(
                              width: 48,
                              height: 48,
                              alignment: Alignment.center,
                              child: TextView(
                                "${DownloadManage.fileSize > 0 ? (DownloadManage.receiveSize / DownloadManage.fileSize * 100).floor() : 0}%",
                                color: ColorTheme.white,
                                shadowShow: true,
                              ),
                            ),
                            painter: painter,
                          ),
                        ),
                      ),
                    ],
                  )),
              if (remind)
                Container(
                  margin: EdgeInsets.only(top: 10),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      color: Colors.black.withOpacity(.4),
                      padding: EdgeInsets.symmetric(
                        vertical: 4,
                        horizontal: 10,
                      ),
                      constraints: BoxConstraints(
                        minWidth: 70,
                      ),
                      alignment: Alignment.center,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          TextView(
                            DownloadManage.state == 2 ? "下载完成了" : "下载失败了",
                            color: ColorTheme.white,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          )
        : buildDialog();
  }

  Widget buildDialog() {
    return Container(
      alignment: Alignment.center,
      child: Container(
        decoration: BoxDecoration(
          color: ColorTheme.body,
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
        constraints: BoxConstraints(
          maxWidth: screenSize.width * 0.95,
          maxHeight: screenSize.height * 0.85,
        ),
        padding: const EdgeInsets.only(top: 10, bottom: 7, left: 10, right: 10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 5,
              width: 60,
              margin: EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                border: Border.all(color: ColorTheme.grey.withOpacity(.3)),
                color: ColorTheme.grey.withOpacity(.1),
                borderRadius: BorderRadius.circular(50),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, top: 0),
              child: Column(
                children: [
                  TextView("传输进度", color: Color(0xff444444)),
                  SizedBox(
                    height: 5,
                  ),
                  Divider(),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.only(
                right: 10,
                left: 10,
                top: 10,
              ),
              child: Column(
                children: [
                  SizedBox(
                    height: 10,
                  ),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: ColorTheme.grey.withOpacity(.3)),
                      color: ColorTheme.grey.withOpacity(.3),
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                      child: LinearProgressIndicator(
                        backgroundColor: Colors.grey[200]?.withOpacity(0.5),
                        color: ColorTheme.green,
                        valueColor: AlwaysStoppedAnimation(ColorTheme.mainLight),
                        value: progressValue,
                        minHeight: 18,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextView(
                        '进度：${DownloadManage.receiveSize}MB/${DownloadManage.fileSize}MB',
                        color: ColorTheme.grey,
                      ),
                      SizedBox(
                        width: 20,
                      ),
                      TextView(
                        '${speed.toStringAsFixed(1)}MB/s',
                        color: ColorTheme.grey,
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Container(
                    child: TextView(
                      "    请不要离开app，你可以缩小窗口，下载完成了再告诉你",
                      maxLines: 3,
                    ),
                  )
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.only(top: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ButtonView(
                    text: "取消下载",
                    onPressed: () {
                      DownloadManage.cancelDownload();
                      _timer?.cancel();
                      ShowDragLayer.remove();
                    },
                    borderColor: Colors.black12,
                    backgroundColor: Colors.white,
                    fontColor: ColorTheme.font,
                    fontSize: 14,
                    width: 120,
                    height: 38,
                  ),
                  ButtonView(
                    text: '缩小窗口',
                    fontColor: ColorTheme.white,
                    onPressed: () {
                      showDialog = false;
                      ShowDragLayer.top = screenSize.height * 0.6;
                      ShowDragLayer.set(
                          borderRadius2: BorderRadius.circular(50));
                      setState(() {});
                    },
                    fontSize: 14,
                    width: 120,
                    height: 38,
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget buildDialogStop() {
    return Container(
      alignment: Alignment.center,
      child: Container(
        decoration: BoxDecoration(
          color: ColorTheme.body,
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
        constraints: BoxConstraints(
          maxWidth: screenSize.width * 0.95,
          maxHeight: screenSize.height * 0.85,
        ),
        padding: const EdgeInsets.only(top: 10, bottom: 7, left: 10, right: 10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 5,
              width: 60,
              margin: EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                border: Border.all(color: ColorTheme.grey.withOpacity(.3)),
                color: ColorTheme.grey.withOpacity(.1),
                borderRadius: BorderRadius.circular(50),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, top: 0),
              child: Column(
                children: [
                  TextView("下载通知", color: Color(0xff444444)),
                  SizedBox(
                    height: 5,
                  ),
                  Divider(),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.only(
                right: 10,
                left: 10,
                top: 10,
              ),
              child: Column(
                children: [
                  IconText(
                    DownloadManage.state == 2
                        ? Icons.file_download_done_rounded
                        : Icons.error_outline_outlined,
                    color:
                        DownloadManage.state == 2 ? ColorTheme.green : ColorTheme.red,
                    shadowShow: false,
                    size: 50,
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Container(
                    child: TextView(
                      DownloadManage.state == 2 ? "下载完成了，是否需要安装" : "呀，下载失败了",
                      maxLines: 3,
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.only(top: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  if (DownloadManage.state == 2)
                    ButtonView(
                      text: "不用了",
                      onPressed: () {
                        DownloadManage.cancelDownload();
                        _timer?.cancel();
                        ShowDragLayer.remove();
                      },
                      borderColor: Colors.black12,
                      backgroundColor: Colors.white,
                      fontColor: ColorTheme.font,
                      fontSize: 14,
                      width: 120,
                      height: 38,
                    ),
                  ButtonView(
                    text: DownloadManage.state == 2 ? '马上打开' : "知道了",
                    fontColor: ColorTheme.white,
                    onPressed: () async {
                      if (DownloadManage.state == 2) {
                        await OpenFile.open(
                            File(DownloadManage.fileSavePath!).path);
                      }
                      _timer?.cancel();
                      ShowDragLayer.remove();
                    },
                    fontSize: 14,
                    width: 120,
                    height: 38,
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

class ProgressBackPainter extends CustomPainter {
  var painter = Paint();
  var painterColor = Colors.black.withOpacity(0.4);

  @override
  void paint(Canvas canvas, Size size) {
    painter.color = painterColor;
    canvas.drawCircle(Offset(size.width / 2, size.height / 2),
        min(size.height, size.width) / 2, painter);
  }

  @override
  bool shouldRepaint(ProgressBackPainter oldDelegate) {
    return oldDelegate.painterColor != painterColor;
  }
}
