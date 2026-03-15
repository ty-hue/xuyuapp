import 'dart:async';

import 'package:bilbili_project/utils/TimeUtils.dart';
import 'package:bilbili_project/viewmodels/Create/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class Timekeeping extends StatefulWidget {
  final RecordDuration recordDuration;
  final VoidCallback stopRecording;
  Timekeeping({Key? key, required this.recordDuration, required this.stopRecording}) : super(key: key);

  @override
  _TimekeepingState createState() => _TimekeepingState();
}

class _TimekeepingState extends State<Timekeeping> {
  String get totalRecordDuration =>
      Timeutils.formatDuration(widget.recordDuration.seconds.toDouble() * 1000);
  double currentRecordDuration = 0;
  late Timer timer;
  @override
  void initState() {
    super.initState();
    // 使用定时器更新当前时长
    timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (currentRecordDuration >= widget.recordDuration.seconds) {
        timer.cancel();
        widget.stopRecording();
        return;
      }
      setState(() {
        currentRecordDuration += 1;
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    // 取消定时器
    timer.cancel();
  }
  // 格式化当前时长
  String get formattedCurrentDuration =>
      Timeutils.formatDuration(currentRecordDuration * 1000);
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          formattedCurrentDuration,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
            decoration: TextDecoration.none,
            color: Colors.white,
          ),
        ),
        Text(
          '/',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
            decoration: TextDecoration.none,
            color: Colors.white,
          ),
        ),
        Text(
          totalRecordDuration,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
            decoration: TextDecoration.none,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}
