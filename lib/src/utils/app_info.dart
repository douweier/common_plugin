import 'package:package_info_plus/package_info_plus.dart';

class AppInfo {
  static PackageInfo? appInfo;

  static Future<PackageInfo> getInfo() async {
    if (appInfo != null) return appInfo!;
    appInfo = await PackageInfo.fromPlatform();
    return appInfo ?? PackageInfo(appName: '', version: '', packageName: '', buildNumber: '');
  }
}
