import 'package:bilbili_project/components/select_dots.dart';
import 'package:bilbili_project/viewmodels/Create/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CountDownSheetSekeleton extends StatefulWidget {
  final CountDownType countDownType;
  final ValueChanged<CountDownType> onCountDownChanged;

  CountDownSheetSekeleton({
    Key? key,
    required this.countDownType,
    required this.onCountDownChanged,
  }) : super(key: key);

  @override
  _CountDownSheetSekeletonState createState() =>
      _CountDownSheetSekeletonState();
}

class _CountDownSheetSekeletonState extends State<CountDownSheetSekeleton> {
  late CountDownType params;
  List<String> countdownDurationLabels = ['3秒', '10秒'];
  List<String> modeLabels = ['照片', '视频'];
  int countdownDurationSelectedIndex = 0;
  int modeSelectedIndex = 0;
  @override
  void initState() {
    super.initState();
    params = widget.countDownType;
  }

  Widget _buildSettingSheetItem({
    double? width,
    required String title,
    bool? value,
    ValueChanged<bool>? onChanged,
    List<String>? labels,
    int? selectedIndex,
    ValueChanged<int>? onSelectChanged,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          title,
          style: TextStyle(
            color: Colors.white,

            fontSize: 16.0.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
        value != null
            ? Switch(value: value, onChanged: onChanged)
            : SelectDots(
                bgColor: Color.fromRGBO(28, 36, 36, 1),
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
        color: Color.fromRGBO(9, 12, 11, 1),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildSettingSheetItem(
              title: '倒计时',
              width: 110.w,
              labels: countdownDurationLabels,
              selectedIndex: countdownDurationSelectedIndex,
              onSelectChanged: (val) {
                setState(() {
                  countdownDurationSelectedIndex = val;
                  params.countdownDuration = countdownDurationLabels[val];
                });
                widget.onCountDownChanged(params);
              },
            ),
            SizedBox(height: 20.0.h),
            _buildSettingSheetItem(
              title: '拍摄模式',
              width: 110.w,
              labels: modeLabels,
              selectedIndex: modeSelectedIndex,
              onSelectChanged: (val) {
                setState(() {
                  modeSelectedIndex = val;
                  params.mode = modeLabels[val];
                });
                widget.onCountDownChanged(params);
              },
            ),
            SizedBox(height: 20.0.h),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color.fromRGBO(229,40,77, 1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0.r),
                  ),
                ),
                child: Text(
                  '开始拍摄',
                  style: TextStyle(
                    fontSize: 16.0.sp,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
                
                onPressed: () {
                  print('开始拍摄');
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
