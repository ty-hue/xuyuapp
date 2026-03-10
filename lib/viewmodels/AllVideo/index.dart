import 'dart:typed_data';

import 'package:photo_manager/photo_manager.dart';

class VideoItem {
  final int albumIndex; // 相册索引
  final int videoIndex; // 视频索引
  final Uint8List thumbnailBytes; // 视频缩略图
  final String duration; // 视频时长
  VideoItem({
    required this.albumIndex,
    required this.videoIndex,
    required this.thumbnailBytes,
    required this.duration,
  });
}

class AlbumItem {
  final AssetPathEntity album; // 相册实例 (从中可获取相册名称，所以这里名称不单独做一个字段了)
  final int videoCount; // 视频数量
  final Uint8List thumbnailBytes; // 相册缩略图

  AlbumItem({
    required this.album,
    required this.videoCount,
    required this.thumbnailBytes,
  });
}
