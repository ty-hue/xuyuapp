import 'package:bilbili_project/constants/index.dart';
import 'package:bilbili_project/viewmodels/Create/index.dart';

/// 创作页 / 拍摄工具栏 / 相关 Sheet 的共享状态（Riverpod）。
class CreateShootState {
  const CreateShootState({
    required this.outSelectedIndex,
    required this.flashStatus,
    required this.recordDuration,
    required this.speedMode,
    required this.microphoneStatus,
    required this.gifStatus,
    required this.settingSheetType,
    required this.countdownType,
    required this.isStartCountDown,
    required this.cameraSelectedIndex,
    required this.useFrontCamera,
    required this.speedSelectedIndex,
    required this.recordStatus,
    required this.previewReadyForNext,
    required this.beautyOptions,
    required this.filterOptions,
    required this.selectedBeautyIndex,
    required this.selectedFilterIndex,
  });

  final int outSelectedIndex;
  final FlashStatus flashStatus;
  final RecordDuration recordDuration;
  final bool speedMode;
  final MicrophoneStatus microphoneStatus;
  final GifStatus gifStatus;
  final SettingSheetType settingSheetType;
  final CountDownType countdownType;
  final bool isStartCountDown;
  final int cameraSelectedIndex;
  /// 相机朝向：true 前置，false 后置（与原生前/后摄一致）。
  final bool useFrontCamera;
  final int speedSelectedIndex;
  final RecordStatus recordStatus;
  final bool previewReadyForNext;
  final List<BeautyItem> beautyOptions;
  final List<BeautyItem> filterOptions;
  final int selectedBeautyIndex;
  final int selectedFilterIndex;

  factory CreateShootState.initial() {
    return CreateShootState(
      outSelectedIndex: 0,
      flashStatus: FlashStatus.off,
      recordDuration: RecordDuration.s15,
      speedMode: false,
      microphoneStatus: MicrophoneStatus.off,
      gifStatus: GifStatus.off,
      settingSheetType: SettingSheetType(
        maxRecordDuration: '15',
        aspectRatio: '9:16',
        useVolumeKeys: false,
        grid: false,
      ),
      countdownType: CountDownType(countdownDuration: '3秒'),
      isStartCountDown: false,
      cameraSelectedIndex: 0,
      useFrontCamera: true,
      speedSelectedIndex: 2,
      recordStatus: RecordStatus.normal,
      previewReadyForNext: false,
      beautyOptions: createBeautyList(),
      filterOptions: createFilterList(),
      selectedBeautyIndex: 0,
      selectedFilterIndex: 0,
    );
  }

  CreateShootState copyWith({
    int? outSelectedIndex,
    FlashStatus? flashStatus,
    RecordDuration? recordDuration,
    bool? speedMode,
    MicrophoneStatus? microphoneStatus,
    GifStatus? gifStatus,
    SettingSheetType? settingSheetType,
    CountDownType? countdownType,
    bool? isStartCountDown,
    int? cameraSelectedIndex,
    bool? useFrontCamera,
    int? speedSelectedIndex,
    RecordStatus? recordStatus,
    bool? previewReadyForNext,
    List<BeautyItem>? beautyOptions,
    List<BeautyItem>? filterOptions,
    int? selectedBeautyIndex,
    int? selectedFilterIndex,
  }) {
    return CreateShootState(
      outSelectedIndex: outSelectedIndex ?? this.outSelectedIndex,
      flashStatus: flashStatus ?? this.flashStatus,
      recordDuration: recordDuration ?? this.recordDuration,
      speedMode: speedMode ?? this.speedMode,
      microphoneStatus: microphoneStatus ?? this.microphoneStatus,
      gifStatus: gifStatus ?? this.gifStatus,
      settingSheetType: settingSheetType ?? this.settingSheetType,
      countdownType: countdownType ?? this.countdownType,
      isStartCountDown: isStartCountDown ?? this.isStartCountDown,
      cameraSelectedIndex: cameraSelectedIndex ?? this.cameraSelectedIndex,
      useFrontCamera: useFrontCamera ?? this.useFrontCamera,
      speedSelectedIndex: speedSelectedIndex ?? this.speedSelectedIndex,
      recordStatus: recordStatus ?? this.recordStatus,
      previewReadyForNext: previewReadyForNext ?? this.previewReadyForNext,
      beautyOptions: beautyOptions ?? this.beautyOptions,
      filterOptions: filterOptions ?? this.filterOptions,
      selectedBeautyIndex: selectedBeautyIndex ?? this.selectedBeautyIndex,
      selectedFilterIndex: selectedFilterIndex ?? this.selectedFilterIndex,
    );
  }
}

/// 创作页底部与模式文案（与 UI 绑定，非业务可变状态）。
abstract final class CreateShootLabels {
  static const List<String> outerTabs = ['文字', '相机', '创作灵感'];
  static const List<String> cameraModeTabs = ['照片', '视频'];
  static const List<String> speedLabels = ['极慢', '慢', '标准', '快', '极快'];
}
