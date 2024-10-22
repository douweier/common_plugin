import 'dart:io';
import 'dart:math' as math;
import 'package:common_plugin/common_plugin.dart';
import 'package:url_launcher/url_launcher.dart';

class AppUpgrade {
  ///提醒用户是否升级新版本,true提醒升级,false不再提醒，除非手动点击检测新版后再次打开
  static bool remindUpgrade = true;

  static Future<bool> checkUpgrade({
    required String newVersion, //新版本
    required String downloadUrl, //下载地址
    String? versionDesc, //版本描述
    bool isMastUpdate = false, //强制升级
    String? createTime, //新版发布时间
    bool isCheckAndUpgrade = true, //false会被用户设置的remindUpgrade是否提醒升级打断
    bool showTip = true, //是否显示提示新版
  }) async {
    final appInfo = await AppInfo.getInfo();
    final hasNewAppVersion = compareVersions(
      appInfo.version,
      newVersion,
    );
    if (!isCheckAndUpgrade && !isMastUpdate) {
      // 获取用户设置是否需要升级
      remindUpgrade = await Sql.getKeyData('remindUpgrade') == true;
      if (!remindUpgrade) {
        return hasNewAppVersion;
      }
    } else {
      remindUpgrade = true;
      await Sql.saveKeyData('remindUpgrade', "true");
    }

    if (DownloadManage.state == 1) {
      showAlert('已在下载中，请稍后');
      return hasNewAppVersion;
    }

    if (!hasNewAppVersion) {
      if (showTip) {
        showAlert('暂未发现新版本');
      }
      return hasNewAppVersion;
    }

    if (Platform.isAndroid) {
      showDialogLayer(
          title:
              '${createTime != null ? "$createTime发布了新版本" : '更新了版本'} v$newVersion',
          content: versionDesc ?? '是否需要更新到最新版本',
          ok: '我要升级',
          cancel: '暂不',
          type: isMastUpdate ? 1 : 0,
          isOnlyOneShow: true,
          barrierDismissible: isMastUpdate ? false : true,
          onCancelCallBack: () async {
            remindUpgrade = false;
            await Sql.saveKeyData('remindUpgrade', "false");
          },
          onOkCallBack: () {
            _downloading(downloadUrl, newVersion, appInfo.appName , isMastUpdate: isMastUpdate);
          });
    } else if (Platform.isIOS) {
      showDialogLayer(
          title:
              '${createTime != null ? "$createTime发布了新版本" : '更新了版本'} v$newVersion',
          content: versionDesc ?? '是否需要更新到最新版本',
          ok: '我要升级',
          cancel: '暂不',
          type: isMastUpdate ? 1 : 0,
          isOnlyOneShow: true,
          barrierDismissible: isMastUpdate ? false : true,
          onCancelCallBack: () {
            remindUpgrade = false;
            Sql.saveKeyData('remindUpgrade', "false");
          },
          onOkCallBack: () async {
            // 'https://apps.apple.com/app/id$appId'
            if (await canLaunchUrl(Uri.parse(downloadUrl))) {
              await launchUrl(
                Uri.parse(downloadUrl),
              );
            } else {
              throw '打开出错 $downloadUrl';
            }
          });
    }
    return hasNewAppVersion;
  }


  ///下载apk
  static Future<void> _downloading(String url, String version, String appName,
      {bool isMastUpdate = false}) async {
    var savePath = await getPathDownload();
    await downLoadFile(
      url,
      savePath: '$savePath/$appName-$version.apk',
      isMastDownload: isMastUpdate,
      isInstall: true,
    );
  }

  /// 比较两个版本号的函数
  static bool compareVersions(String? currentVersion, String? newVersion) {
    if (currentVersion == null || newVersion == null) {
      return true; // 为空也返回true让其安装
    }

    try {
      // 辅助函数：提取数字部分的版本号
      String extractNumericVersion(String version) {
        // 去除前缀中的非数字和非点号字符
        version = version.replaceAll(RegExp(r'^[^\d.]*'), '').trim();

        // 如果存在 '-' 或 '+'，则只保留之前的部分（去除后缀，如 beta、rc 等）
        if (version.contains('-') || version.contains('+')) {
          version = version.split(RegExp(r'[-+]')).first.trim();
        }

        return version.isEmpty ? '0' : version;
      }

      // 提取并清理版本号
      String cleanCurrentVersion = extractNumericVersion(currentVersion);
      String cleanNewVersion = extractNumericVersion(newVersion);

      List<String> currentParts = cleanCurrentVersion.split('.');
      List<String> newParts = cleanNewVersion.split('.');

      int maxLength = math.max(currentParts.length, newParts.length);

      // 标准化版本号，确保长度一致
      while (currentParts.length < maxLength) {
        currentParts.add('0');
      }
      while (newParts.length < maxLength) {
        newParts.add('0');
      }

      // 逐段比较
      for (int i = 0; i < maxLength; i++) {
        int currentPart = int.tryParse(currentParts[i]) ?? 0;
        int newPart = int.tryParse(newParts[i]) ?? 0;

        if (newPart > currentPart) return true; // 新版本大于当前版本
        if (newPart < currentPart) return false; // 新版本小于当前版本
      }
      return false; // 版本号相同
    } catch (e) {
      Logger.error('Error: $e', mark: "compareVersions");
    }

    return false;
  }
}
