// 枚举闪光灯状态
enum FlashStatus { on, off, auto }

enum PFBeautyFiterType {
  faceWhitenStrength,
  faceRuddyStrength,
  faceBlurStrength,
  faceEyeBrighten,
  faceSharpenStrength,
  eyeStrength,
  faceThinning,
  faceNarrow,
  faceChin,
  faceV,
  faceNoseBridge,
  faceForehead,
  faceMouth,
  facePhiltrum,
  faceLongNose,
  faceEyeSpace,
  faceSmile,
  faceCanthus,
  portraitBackgroundBlur,
}

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
  CountDownType({required this.countdownDuration});
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

// 贴纸选项类型（name 为原生 AR 管线 id；label 为界面展示文案）
class StickerItem {
  final String name;
  final String bundleName;
  final String icon;
  /// 若为空则 UI 使用 [name]
  final String? label;
  final int type;
  final String anchorType;
  final double scale;
  final double offsetX;
  final double offsetY;

  StickerItem({
    required this.name,
    required this.bundleName,
    required this.icon,
    this.label,
    this.type = 3,
    this.anchorType = 'face',
    this.scale = 1.0,
    this.offsetX = 0.0,
    this.offsetY = 0.0,
  });
}

// 录制状态
enum RecordStatus { normal, recording, end }

// 播放状态
enum PlayStatus { normal, loading, pause }
