import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:photo_manager/photo_manager.dart';

class SaveImageUtils {
  // 保存内存中的图片到相册
  Future<void> saveImageToGallery(Uint8List bytes) async {
    final hasPermission = await _requestPermission();
    if (!hasPermission) return;
    await PhotoManager.editor.saveImage(
      bytes,
      filename: 'xuyu_${DateTime.now().millisecondsSinceEpoch}.jpg',
    );
  }

  Future<bool> _requestPermission() async {
    final result = await PhotoManager.requestPermissionExtend();
    if (!result.hasAccess) {
      PhotoManager.openSetting(); // 引导用户去设置
      return false;
    }
    return true;
  }

  Future<void> saveNetworkImage(String url) async {
    final response = await Dio().get(
      url,
      options: Options(responseType: ResponseType.bytes),
    );

    await saveImageToGallery(Uint8List.fromList(response.data));
  }
}

SaveImageUtils saveImageUtils = SaveImageUtils();
