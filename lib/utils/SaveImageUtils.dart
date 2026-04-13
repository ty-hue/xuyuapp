import 'dart:io';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:photo_manager/photo_manager.dart';

class SaveImageUtils {
  String _draftTitle() => 'xuyu_${DateTime.now().millisecondsSinceEpoch}';

  /// 保存内存 JPEG 到相册；成功返回新建 [AssetEntity]（可立刻做缩略图，不依赖相册索引延迟）。
  Future<AssetEntity?> saveImageToGallery(Uint8List bytes) async {
    final hasPermission = await requestPermission();
    if (!hasPermission) return null;
    try {
      return await PhotoManager.editor.saveImage(
        bytes,
        filename: '${_draftTitle()}.jpg',
      );
    } catch (_) {
      return null;
    }
  }

  /// 将本地图片文件写入相册（拷贝一份）。
  Future<AssetEntity?> saveImageFromPathToGallery(String filePath) async {
    final hasPermission = await requestPermission();
    if (!hasPermission) return null;
    final f = File(filePath);
    if (!await f.exists()) return null;
    try {
      return await PhotoManager.editor.saveImageWithPath(
        filePath,
        title: _draftTitle(),
      );
    } catch (_) {
      return null;
    }
  }

  /// 将本地视频文件写入相册。
  Future<AssetEntity?> saveVideoFromPathToGallery(String filePath) async {
    final hasPermission = await requestPermission();
    if (!hasPermission) return null;
    final f = File(filePath);
    if (!await f.exists()) return null;
    try {
      return await PhotoManager.editor.saveVideo(
        f,
        title: _draftTitle(),
      );
    } catch (_) {
      return null;
    }
  }

  /// 相册中已选的资源再保存一份到相册（草稿）；与「存草稿」语义一致。
  Future<AssetEntity?> saveAssetEntityDraft(AssetEntity entity) async {
    final hasPermission = await requestPermission();
    if (!hasPermission) return null;
    try {
      if (entity.type == AssetType.video) {
        final f = await entity.file;
        if (f == null || !await f.exists()) return null;
        return await PhotoManager.editor.saveVideo(f, title: _draftTitle());
      }
      final f = await entity.originFile;
      if (f == null || !await f.exists()) return null;
      return await PhotoManager.editor.saveImageWithPath(f.path, title: _draftTitle());
    } catch (_) {
      return null;
    }
  }

  Future<bool> requestPermission() async {
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
