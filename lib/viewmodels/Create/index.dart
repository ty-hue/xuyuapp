// 枚举闪光灯状态
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
