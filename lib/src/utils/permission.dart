
import 'package:permission_handler/permission_handler.dart';

class PermissionUtils {
  static Future<bool> requestPermission(Permission permission) async {
    if (await permission.isGranted) {
      return true;
    }
    final status = await permission.request();
    return status.isGranted;
  }

 static Future<bool> camera() async {
    return await requestPermission(Permission.camera); // 相机
  }

  static Future<bool> location() async {
    return await requestPermission(Permission.location); // 定位
  }

  /// 33以下版本只需要Permission.storage权限就能访问相册，33及以上需要同时请求Permission.photos
  static Future<bool> storage() async {
    return await requestPermission(Permission.storage); // 存储
  }

  static Future<bool> microphone() async {
    return await requestPermission(Permission.microphone); // 麦克风
  }


  /// 32以上SDK版本需要在AndroidManifest.xml中添加以下权限
  /// <uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>
  /// <uses-permission android:name="android.permission.READ_MEDIA_IMAGES"/>
  static Future<bool> photos() async {
    final storageStatus = await requestPermission(Permission.storage); // 存储
    await requestPermission(Permission.photos);  // 相册
    return storageStatus;
  }

  static Future<bool> contacts() async {
    return await requestPermission(Permission.contacts); // 通讯录
  }

  static Future<bool> phone() async {
    return await requestPermission(Permission.phone); // 电话
  }

  static Future<bool> sms() async {
    return await requestPermission(Permission.sms); // 短信
  }

  static Future<bool> notification() async {
    return await requestPermission(Permission.notification); // 通知
  }

  static Future<bool> bluetooth() async {
    return await requestPermission(Permission.bluetooth); // 蓝牙
  }

  static Future<bool> sensors() async {
    return await requestPermission(Permission.sensors); // 传感器
  }

  static Future<bool> ignoreBatteryOptimizations() async {
    return await requestPermission(Permission.ignoreBatteryOptimizations); // 忽略电池优化
  }

  static Future<bool> accessMediaLocation() async {
    return await requestPermission(Permission.accessMediaLocation); // 访问媒体文件的位置
  }

  static Future<bool> installPackages() async {
    return await requestPermission(Permission.requestInstallPackages); // 允许安装未知来源应用
  }

}
