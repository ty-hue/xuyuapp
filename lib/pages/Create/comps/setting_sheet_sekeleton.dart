import 'dart:async';

import 'package:bilbili_project/components/select_dots.dart';
import 'package:bilbili_project/viewmodels/Create/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SettingSheetSekeleton extends StatefulWidget {
  final SettingSheetType settingSheetType;
  final ValueChanged<SettingSheetType> onSettingChanged;

  SettingSheetSekeleton({
    Key? key,
    required this.settingSheetType,
    required this.onSettingChanged,
  }) : super(key: key);

  @override
  _SettingSheetSekeletonState createState() => _SettingSheetSekeletonState();
}

class _SettingSheetSekeletonState extends State<SettingSheetSekeleton> {
  late SettingSheetType params;
  List<String> maxRecordDurationLabels = ['15', '60', '180'];
  List<String> aspectRatioLabels = ['9:16', '3:4'];
  int maxRecordDurationSelectedIndex = 0;
  int aspectRatioSelectedIndex = 0;
  Timer? _aspectRatioNotifyTimer;

  void _applyWidgetSettings() {
    params = SettingSheetType(
      maxRecordDuration: widget.settingSheetType.maxRecordDuration,
      aspectRatio: widget.settingSheetType.aspectRatio,
      useVolumeKeys: widget.settingSheetType.useVolumeKeys,
      grid: widget.settingSheetType.grid,
    );
    maxRecordDurationSelectedIndex = _durationSelectedIndex(params.maxRecordDuration);
    aspectRatioSelectedIndex = _aspectSelectedIndex(params.aspectRatio);
  }

  int _durationSelectedIndex(String raw) {
    final s = raw.trim();
    var i = maxRecordDurationLabels.indexOf(s);
    if (i < 0) {
      final n = int.tryParse(s);
      if (n != null) {
        i = maxRecordDurationLabels.indexOf('$n');
      }
    }
    return i >= 0 ? i : 0;
  }

  int _aspectSelectedIndex(String raw) {
    final i = aspectRatioLabels.indexOf(raw.trim());
    return i >= 0 ? i : 0;
  }

  @override
  void initState() {
    super.initState();
    _applyWidgetSettings();
  }

  @override
  void didUpdateWidget(covariant SettingSheetSekeleton oldWidget) {
    super.didUpdateWidget(oldWidget);
    final o = oldWidget.settingSheetType;
    final w = widget.settingSheetType;
    if (o.maxRecordDuration != w.maxRecordDuration ||
        o.aspectRatio != w.aspectRatio ||
        o.useVolumeKeys != w.useVolumeKeys ||
        o.grid != w.grid) {
      setState(_applyWidgetSettings);
    }
  }

  @override
  void dispose() {
    if (_aspectRatioNotifyTimer?.isActive ?? false) {
      _aspectRatioNotifyTimer!.cancel();
      _pushSettingsToParent();
    }
    super.dispose();
  }

  void _pushSettingsToParent() {
    widget.onSettingChanged(
      SettingSheetType(
        maxRecordDuration: params.maxRecordDuration,
        aspectRatio: params.aspectRatio,
        useVolumeKeys: params.useVolumeKeys,
        grid: params.grid,
      ),
    );
  }

  Widget _buildSettingSheetItem({
    double? width,
    required String title,
    bool? value,
    ValueChanged<bool>? onChanged,
    required IconData icon,
    List<String>? labels,
    int? selectedIndex,
    ValueChanged<int>? onSelectChanged,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          spacing: 8.0.w,
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 24.0.sp),
            Text(
              title,
              style: TextStyle(
                color: Colors.white,

                fontSize: 16.0.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        value != null
            ? Switch(value: value, onChanged: onChanged)
            : SelectDots(
                width: width ?? 120.w,
                height: 40.h,
                labels: labels!,
                selectedIndex: selectedIndex ?? 0,
                onChanged: onSelectChanged!,
              ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16.0.r)),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 24.0.w, vertical: 24.0.h),
        color: Color.fromRGBO(38, 38, 38, 1),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildSettingSheetItem(
              title: '最大拍摄时长（秒）',
              icon: Icons.timer,
              width: 160.w,
              labels: maxRecordDurationLabels,
              selectedIndex: maxRecordDurationSelectedIndex,
              onSelectChanged: (val) {
                setState(() {
                  maxRecordDurationSelectedIndex = val;
                  params.maxRecordDuration = maxRecordDurationLabels[val];
                });
                _pushSettingsToParent();
              },
            ),
            SizedBox(height: 20.0.h),
            _buildSettingSheetItem(
              title: '拍摄比例',
              icon: Icons.aspect_ratio,
              width: 110.w,
              labels: aspectRatioLabels,
              selectedIndex: aspectRatioSelectedIndex,
              onSelectChanged: (val) {
                setState(() {
                  aspectRatioSelectedIndex = val;
                  params.aspectRatio = aspectRatioLabels[val];
                });
                // 延后通知父级，避免与 SelectDots 滑块动画同时进行整页/相机重建导致掉帧
                _aspectRatioNotifyTimer?.cancel();
                _aspectRatioNotifyTimer = Timer(
                  const Duration(milliseconds: 320),
                  () {
                    if (!mounted) return;
                    _aspectRatioNotifyTimer = null;
                    _pushSettingsToParent();
                  },
                );
              },
            ),
            SizedBox(height: 20.0.h),
            _buildSettingSheetItem(
              title: '使用音量键拍摄',
              value: params.useVolumeKeys,
              onChanged: (val) {
                setState(() {
                  params.useVolumeKeys = val;
                });
                _pushSettingsToParent();
              },
              icon: Icons.volume_up,
            ),
            SizedBox(height: 20.0.h),
            _buildSettingSheetItem(
              title: '网格',
              value: params.grid,
              onChanged: (val) {
                setState(() {
                  params.grid = val;
                });
                _pushSettingsToParent();
              },
              icon: Icons.grid_on,
            ),
          ],
        ),
      ),
    );
  }
}
