// 枚举闪光灯状态
import 'package:pixelfree/pixelfree_platform_interface.dart';

enum FlashStatus { on, off, auto }

// 枚举拍摄时长
enum RecordDuration {
  s15("15秒", 15),
  s60("60秒", 60),
  s180("3分钟", 180);

  final String label;
  final int seconds;

  const RecordDuration(this.label, this.seconds);
}

// 麦克风
enum MicrophoneStatus { on, off }

// 动图
enum GifStatus { on, off }

// 设置sheet参数类型
class SettingSheetType {
  String maxRecordDuration; // 最大拍摄时长
  String aspectRatio; // 拍摄比例
  bool useVolumeKeys; // 使用音量键拍摄
  bool grid; // 网格
  SettingSheetType({
    required this.maxRecordDuration,
    required this.aspectRatio,
    required this.useVolumeKeys,
    required this.grid,
  });
}

// 倒计时sheet参数类型
class CountDownType {
  String countdownDuration;
  String mode; // 拍摄比例
  CountDownType({required this.countdownDuration, required this.mode});
}

// 美颜和滤镜选项类型
class BeautyItem {
  String title;
  String icon;
  PFBeautyFiterType? type;
  double value;
  String? filterType;
  BeautyItem({
    required this.title,
    required this.icon,
    this.type,
    this.filterType,
    required this.value,
  });
}

// 贴纸选项类型
class StickerItem {
  final String name; // 显示名称
  final String bundleName; // bundle文件名
  final String icon; // 本地icon路径
  final int type; // 固定3

  StickerItem({
    required this.name,
    required this.bundleName,
    required this.icon,
    this.type = 3,
  });
}
