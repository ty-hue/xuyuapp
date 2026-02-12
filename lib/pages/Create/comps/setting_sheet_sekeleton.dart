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
  @override
  void initState() {
    super.initState();
    params = widget.settingSheetType;
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
                widget.onSettingChanged(params);
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
                widget.onSettingChanged(params);
              },
            ),
            SizedBox(height: 20.0.h),
            _buildSettingSheetItem(
              title: '使用音量键拍摄',
              value: widget.settingSheetType.useVolumeKeys,
              onChanged: (val) {
                setState(() {
                  params.useVolumeKeys = val;
                });
                widget.onSettingChanged(params);
              },
              icon: Icons.volume_up,
            ),
            SizedBox(height: 20.0.h),
            _buildSettingSheetItem(
              title: '网格',
              value: widget.settingSheetType.grid,
              onChanged: (val) {
                setState(() {
                  params.grid = val;
                });
                widget.onSettingChanged(params);
              },
              icon: Icons.grid_on,
            ),
          ],
        ),
      ),
    );
  }
}
