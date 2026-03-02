import 'package:permission_handler/permission_handler.dart';

class Permissionutils {
  // 检查相机权限
  static Future<PermissionStatus> checkCameraPermission() async {
    final PermissionStatus status = await Permission.camera.status;
    if (status.isGranted) {
      print('摄像头权限已授权');
    } else if (status.isDenied) {
      print('摄像头权限未授权');
    } else if (status.isPermanentlyDenied) {
      print('摄像头权限被永久拒绝');
    }
    return status;
  }

  // 检查麦克风权限
  static Future<PermissionStatus> checkMicrophonePermission() async {
    final PermissionStatus status = await Permission.microphone.status;
    if (status.isGranted) {
      print('麦克风权限已授权');
    } else if (status.isDenied) {
      print('麦克风权限未授权');
    } else if (status.isPermanentlyDenied) {
      print('麦克风权限被永久拒绝');
    }
    return status;
  }
  // 检查图片读写权限
  static Future<PermissionStatus> checkPhotoPermission() async {
    final PermissionStatus status = await Permission.photos.status;
    if (status.isGranted) {
      print('图片读写权限已授权');
    } else if (status.isDenied) {
      print('图片读写权限未授权');
    } else if (status.isPermanentlyDenied) {
      print('图片读写权限被永久拒绝');
    }
    return status;
  }
  // 请求图片读写权限
  static Future<PermissionStatus> requestPhotoPermission() async {
    final PermissionStatus status = await Permission.photos.request();
    print(status);
    return status;
  }
  // 请求相机权限
  static Future<PermissionStatus> requestCameraPermission() async {
    final PermissionStatus status = await Permission.camera.request();
    print(status);
    return status;
  }

  // 请求麦克风权限
  static Future<PermissionStatus> requestMicrophonePermission() async {
    final PermissionStatus status = await Permission.microphone.request();
    print(status);
    return status;
  }
}
