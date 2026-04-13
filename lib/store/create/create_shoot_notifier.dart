import 'dart:async';

import 'package:bilbili_project/constants/index.dart';
import 'package:bilbili_project/store/create/create_shoot_persistence.dart';
import 'package:bilbili_project/store/create/create_shoot_state.dart';
import 'package:bilbili_project/viewmodels/Create/index.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 创作 / 拍摄工具栏 / Sheet 数据。
///
/// 非 autoDispose：创作页为 push 路由，避免退出后 notifier 被销毁导致 UI 状态丢失。
/// 偏好字段另写入 [CreateShootPersistence]，杀进程后仍可从磁盘恢复。
final createShootProvider =
    NotifierProvider<CreateShootNotifier, CreateShootState>(
  CreateShootNotifier.new,
);

class CreateShootNotifier extends Notifier<CreateShootState> {
  @override
  CreateShootState build() {
    final base = CreateShootState.initial();
    Future(() async {
      final restored = await CreateShootPersistence.restore(base);
      state = restored;
    });
    return base;
  }

  void _persist() {
    unawaited(CreateShootPersistence.saveSlice(state));
  }

  void setOutSelectedIndex(int index) {
    state = state.copyWith(outSelectedIndex: index);
    _persist();
  }

  void setFlashStatus(FlashStatus status) {
    state = state.copyWith(flashStatus: status);
    _persist();
  }

  void setRecordDuration(RecordDuration duration) {
    final st = state.settingSheetType;
    state = state.copyWith(
      recordDuration: duration,
      settingSheetType: SettingSheetType(
        maxRecordDuration: duration.seconds.toString(),
        aspectRatio: st.aspectRatio,
        useVolumeKeys: st.useVolumeKeys,
        grid: st.grid,
      ),
    );
    _persist();
  }

  void setSpeedMode(bool mode) {
    state = state.copyWith(speedMode: mode);
    _persist();
  }

  void setMicrophoneStatus(MicrophoneStatus status) {
    state = state.copyWith(microphoneStatus: status);
    _persist();
  }

  void setGifStatus(GifStatus status) {
    state = state.copyWith(gifStatus: status);
    _persist();
  }

  void setCameraSelectedIndex(int index) {
    state = state.copyWith(cameraSelectedIndex: index);
    _persist();
  }

  void setUseFrontCamera(bool value) {
    if (state.useFrontCamera == value) return;
    state = state.copyWith(useFrontCamera: value);
    _persist();
  }

  void toggleUseFrontCamera() {
    state = state.copyWith(useFrontCamera: !state.useFrontCamera);
    _persist();
  }

  void setSpeedSelectedIndex(int index) {
    state = state.copyWith(speedSelectedIndex: index);
    _persist();
  }

  void setCountdownType(CountDownType type) {
    state = state.copyWith(countdownType: type);
    _persist();
  }

  void setIsStartCountDown(bool value) {
    state = state.copyWith(isStartCountDown: value);
  }

  void onCountdownFinishedFromSheet() {
    state = state.copyWith(isStartCountDown: false);
  }

  /// 设置 Sheet 回调：须新建 [SettingSheetType]，以便相机侧感知比例等变化。
  void applySettingsFromSheet(SettingSheetType next) {
    final rd = _recordDurationFromSecondsString(next.maxRecordDuration);
    state = state.copyWith(
      settingSheetType: SettingSheetType(
        maxRecordDuration: rd.seconds.toString(),
        aspectRatio: next.aspectRatio,
        useVolumeKeys: next.useVolumeKeys,
        grid: next.grid,
      ),
      recordDuration: rd,
    );
    _persist();
  }

  static RecordDuration _recordDurationFromSecondsString(String raw) {
    final s = raw.trim();
    try {
      return RecordDuration.values.firstWhere(
        (e) => e.seconds.toString() == s,
      );
    } catch (_) {
      return RecordDuration.s15;
    }
  }

  void clearUseVolumeKeys() {
    final st = state.settingSheetType;
    state = state.copyWith(
      settingSheetType: SettingSheetType(
        maxRecordDuration: st.maxRecordDuration,
        aspectRatio: st.aspectRatio,
        useVolumeKeys: false,
        grid: st.grid,
      ),
    );
    _persist();
  }

  /// 与原先父组件 [onRecordStatusChanged] 一致：切换录制流状态时先清空「下一步」就绪。
  void setRecordStatus(RecordStatus status) {
    state = state.copyWith(
      recordStatus: status,
      previewReadyForNext: false,
    );
  }

  void setPreviewReadyForNext(bool ready) {
    state = state.copyWith(previewReadyForNext: ready);
  }

  /// 美颜 / 滤镜 Sheet：[setBeautyOptions] 会就地改 [BeautyItem.value]，再触发一次 state 替换以通知监听方。
  void setBeautyOptions(BeautyItem item, double value, bool beautyFlag) {
    final s = state;
    if (item.type != null) {
      if (beautyFlag) {
        final i = s.beautyOptions.indexWhere((e) => e.type == item.type);
        if (i != -1) {
          s.beautyOptions[i].value = value;
        }
      } else {
        final i = s.filterOptions.indexWhere(
          (e) => e.filterType == item.filterType,
        );
        if (i != -1) {
          s.filterOptions[i].value = value;
        }
      }
    } else {
      if (beautyFlag) {
        for (final e in s.beautyOptions) {
          e.value = 0.0;
        }
      } else {
        for (final e in s.filterOptions) {
          e.value = 0.0;
        }
      }
    }
    state = s.copyWith();
    _persist();
  }

  void resetBeautyOptions(bool beautyFlag) {
    final s = state;
    final original = beautyFlag ? createBeautyList() : createFilterList();
    if (beautyFlag) {
      for (final element in s.beautyOptions) {
        element.value = original
            .firstWhere((item) => item.type == element.type)
            .value;
      }
      state = s.copyWith(selectedBeautyIndex: 0);
    } else {
      for (final element in s.filterOptions) {
        element.value = original
            .firstWhere((item) => item.filterType == element.filterType)
            .value;
      }
      state = s.copyWith(selectedFilterIndex: 0);
    }
    _persist();
  }

  void setSelectedBeautyIndex(int index) {
    state = state.copyWith(selectedBeautyIndex: index);
    _persist();
  }

  void setSelectedFilterIndex(int index) {
    state = state.copyWith(selectedFilterIndex: index);
    _persist();
  }
}
