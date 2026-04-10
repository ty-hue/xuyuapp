import 'package:bilbili_project/constants/index.dart';
import 'package:flutter/material.dart';

bool _createSheetImagePrecacheScheduled = false;

/// 在进入创作页后尽早调用：并行 [precacheImage]，避免首次打开各类 sheet 时同步解码导致掉帧、
/// Modal 滑入动画像「闪一下」而非平滑过渡；后续打开走 [ImageCache] 即正常。
void scheduleCreateSheetImagePrecache(BuildContext context) {
  if (_createSheetImagePrecacheScheduled) return;
  _createSheetImagePrecacheScheduled = true;
  WidgetsBinding.instance.addPostFrameCallback((_) async {
    if (!context.mounted) return;
    final paths = createSheetPrecacheAssetPaths();
    if (paths.isEmpty) return;
    try {
      // 分批预解码，避免 Future.wait 一次性占满主线程、与相机预览抢时间片。
      for (var i = 0; i < paths.length; i++) {
        if (!context.mounted) return;
        await precacheImage(AssetImage(paths[i]), context);
        if (i % 5 == 4) {
          await Future<void>.delayed(Duration.zero);
        }
      }
    } catch (_) {}
  });
}
