import 'dart:convert';

import 'package:bilbili_project/constants/index.dart';
import 'package:bilbili_project/store/create/create_shoot_state.dart';
import 'package:bilbili_project/viewmodels/Create/index.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 创作拍摄偏好（杀进程后恢复）；不含单次会话字段（录制状态、倒计时进行中等）。
abstract final class CreateShootPersistence {
  // 美颜值转换为Map
  static Map<String, double> _beautyValuesMap(CreateShootState s) {
    final m = <String, double>{};
    for (final e in s.beautyOptions) {
      if (e.type != null) m[e.type!.name] = e.value;
    }
    return m;
  }
  // 滤镜值转换为Map
  static Map<String, double> _filterValuesMap(CreateShootState s) {
    final m = <String, double>{};
    for (final e in s.filterOptions) {
      final k = e.filterType;
      if (k != null) m[k] = e.value;
    }
    return m;
  }
  // 将所有数据转换成Map并保存到本地 （因为jsonEncode只支持dart内置类型，不支持自定义类型如：CreateShootState）
  static Future<void> saveSlice(CreateShootState s) async {
    final p = await SharedPreferences.getInstance();
    final map = <String, dynamic>{
      'outSelectedIndex': s.outSelectedIndex,
      'cameraSelectedIndex': s.cameraSelectedIndex,
      'useFrontCamera': s.useFrontCamera,
      'flashStatus': s.flashStatus.name,
      'recordDuration': s.recordDuration.name,
      'speedMode': s.speedMode,
      'microphoneStatus': s.microphoneStatus.name,
      'gifStatus': s.gifStatus.name,
      'maxRecordDuration': s.settingSheetType.maxRecordDuration,
      'aspectRatio': s.settingSheetType.aspectRatio,
      'useVolumeKeys': s.settingSheetType.useVolumeKeys,
      'grid': s.settingSheetType.grid,
      'countdownDuration': s.countdownType.countdownDuration,
      'speedSelectedIndex': s.speedSelectedIndex,
      'selectedBeautyIndex': s.selectedBeautyIndex,
      'selectedFilterIndex': s.selectedFilterIndex,
      'beautyValues': _beautyValuesMap(s),
      'filterValues': _filterValuesMap(s),
    };
    await p.setString(GlobalConstants.CREATE_SHOOT_PREFS_KEY, jsonEncode(map));
  }

  // 读取本地保存的美颜 / 滤镜数值，做类型安全检查，避免崩溃。
  static Map<String, double>? _readDoubleMap(Map<String, dynamic> m, String k) {
    final v = m[k];
    if (v is! Map) return null;
    final out = <String, double>{};
    for (final e in v.entries) {
      if (e.key is String && e.value is num) {
        out[e.key as String] = (e.value as num).toDouble();
      }
    }
    return out.isEmpty ? null : out;
  }
  
  // 恢复美颜、滤镜的数值 + 选中的索引。
  static CreateShootState _mergeBeautyFilter(
    CreateShootState current,
    Map<String, double>? beautyVals,
    Map<String, double>? filterVals,
    int selBeauty,
    int selFilter,
  ) {
    final beautyOptions = createBeautyList();
    if (beautyVals != null) {
      for (final e in beautyOptions) {
        if (e.type != null) {
          final v = beautyVals[e.type!.name];
          if (v != null) e.value = v;
        }
      }
    }
    final filterOptions = createFilterList();
    if (filterVals != null) {
      for (final e in filterOptions) {
        final k = e.filterType;
        if (k != null) {
          final v = filterVals[k];
          if (v != null) e.value = v;
        }
      }
    }
    int clampI(int v, int max) {
      if (v < 0) return 0;
      if (v > max) return max;
      return v;
    }

    return current.copyWith(
      beautyOptions: beautyOptions,
      filterOptions: filterOptions,
      selectedBeautyIndex: clampI(selBeauty, beautyOptions.length - 1),
      selectedFilterIndex: clampI(selFilter, filterOptions.length - 1),
    );
  }

  static Future<CreateShootState> restore(CreateShootState base) async {
    final p = await SharedPreferences.getInstance();
    final raw = p.getString(GlobalConstants.CREATE_SHOOT_PREFS_KEY);
    if (raw == null || raw.isEmpty) return base;

    Map<String, dynamic> m;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map) return base;
      m = Map<String, dynamic>.from(decoded);
    } catch (_) {
      return base;
    }

    int readInt(String k, int fallback) {
      final v = m[k];
      if (v is int) return v;
      if (v is num) return v.toInt();
      return fallback;
    }

    bool readBool(String k, bool fallback) {
      final v = m[k];
      if (v is bool) return v;
      return fallback;
    }

    String? readStr(String k) {
      final v = m[k];
      return v is String ? v : null;
    }

    /// 设置项「最大拍摄时长」在 JSON 里可能是字符串 `"60"` 或数字 `60`。
    String? readMaxRecordDurationRaw() {
      final v = m['maxRecordDuration'];
      if (v is String) return v;
      if (v is num) return v.toInt().toString();
      return null;
    }

    T enumByName<T extends Enum>(List<T> values, String? name, T fallback) {
      if (name == null) return fallback;
      try {
        return values.byName(name);
      } catch (_) {
        return fallback;
      }
    }

    RecordDuration readRecordDuration() {
      // 与设置 Sheet 一致：以「秒」字符串为单一事实来源，避免旧数据里 recordDuration 枚举与 maxRecordDuration 打架
      final md = readMaxRecordDurationRaw();
      if (md != null) {
        final trimmed = md.trim();
        try {
          return RecordDuration.values.firstWhere(
            (e) => e.seconds.toString() == trimmed,
          );
        } catch (_) {}
      }
      final name = readStr('recordDuration');
      if (name != null) {
        try {
          return RecordDuration.values.byName(name);
        } catch (_) {}
      }
      return base.recordDuration;
    }

    final rd = readRecordDuration();
    final st0 = base.settingSheetType;

    int clampIndex(int v, int max) {
      if (v < 0) return 0;
      if (v > max) return max;
      return v;
    }

    var merged = base.copyWith(
      outSelectedIndex: clampIndex(readInt('outSelectedIndex', base.outSelectedIndex), 2),
      cameraSelectedIndex:
          clampIndex(readInt('cameraSelectedIndex', base.cameraSelectedIndex), 1),
      useFrontCamera: readBool('useFrontCamera', base.useFrontCamera),
      flashStatus: enumByName(FlashStatus.values, readStr('flashStatus'), base.flashStatus),
      recordDuration: rd,
      speedMode: readBool('speedMode', base.speedMode),
      microphoneStatus: enumByName(
        MicrophoneStatus.values,
        readStr('microphoneStatus'),
        base.microphoneStatus,
      ),
      gifStatus: enumByName(GifStatus.values, readStr('gifStatus'), base.gifStatus),
      settingSheetType: SettingSheetType(
        maxRecordDuration: rd.seconds.toString(),
        aspectRatio: readStr('aspectRatio') ?? st0.aspectRatio,
        useVolumeKeys: readBool('useVolumeKeys', st0.useVolumeKeys),
        grid: readBool('grid', st0.grid),
      ),
      countdownType: CountDownType(
        countdownDuration:
            readStr('countdownDuration') ?? base.countdownType.countdownDuration,
      ),
      speedSelectedIndex:
          clampIndex(readInt('speedSelectedIndex', base.speedSelectedIndex), 4),
    );

    final bMap = _readDoubleMap(m, 'beautyValues');
    final fMap = _readDoubleMap(m, 'filterValues');
    final selB = m.containsKey('selectedBeautyIndex')
        ? readInt('selectedBeautyIndex', merged.selectedBeautyIndex)
        : merged.selectedBeautyIndex;
    final selF = m.containsKey('selectedFilterIndex')
        ? readInt('selectedFilterIndex', merged.selectedFilterIndex)
        : merged.selectedFilterIndex;

    if (bMap != null || fMap != null || m.containsKey('selectedBeautyIndex') || m.containsKey('selectedFilterIndex')) {
      merged = _mergeBeautyFilter(merged, bMap, fMap, selB, selF);
    }

    return merged;
  }
}
