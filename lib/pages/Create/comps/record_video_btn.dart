import 'package:bilbili_project/viewmodels/Create/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class RecordVideoButton extends StatefulWidget {
  final VoidCallback startRecording;
  final VoidCallback stopRecording;
  final RecordStatus recordStatus;
  RecordVideoButton({
    Key? key,
    required this.startRecording,
    required this.stopRecording,
    required this.recordStatus,
  });

  @override
  _RecordVideoButtonState createState() => _RecordVideoButtonState();
}

class _RecordVideoButtonState extends State<RecordVideoButton>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Stopwatch _stopwatch;

  @override
  void initState() {
    super.initState();
    _stopwatch = Stopwatch();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 60), // 假设录制时间为60秒
    );
    _controller.addListener(() {
      if (mounted) {
        setState(() {});
      }
    });
  }

  // 开始录制
  void _startRecording() {
    widget.startRecording();

    _stopwatch.start();
    _controller.forward(from: 0.0);
  }

  // 停止录制
  void _stopRecording() {
    _stopwatch.stop();
    _controller.stop();
    widget.stopRecording();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (widget.recordStatus == RecordStatus.recording) {
          _stopRecording();
        } else {
          _startRecording();
        }
      },
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 圆形进度条
          AnimatedContainer(
            duration: Duration(milliseconds: 300),
            width: widget.recordStatus == RecordStatus.recording
                ? 100.0.w
                : 66.0.w,
            height: widget.recordStatus == RecordStatus.recording
                ? 100.0.h
                : 66.0.h,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: widget.recordStatus == RecordStatus.recording
                  ? Color.fromRGBO(88, 95, 140, 1)
                  : Colors.transparent,
            ),
            child: CircularProgressIndicator(
              value: _controller.value,
              strokeWidth: 6.0.w,
              backgroundColor: widget.recordStatus == RecordStatus.recording
                  ? Colors.transparent
                  : Colors.white,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
            ),
          ),

          AnimatedContainer(
            duration: Duration(milliseconds: 300),
            width: widget.recordStatus == RecordStatus.recording
                ? 48.0.w
                : 54.0.w,
            height: widget.recordStatus == RecordStatus.recording
                ? 48.0.h
                : 54.0.h,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          ),
          // 录制按钮
          AnimatedContainer(
            duration: Duration(milliseconds: 300),
            width: widget.recordStatus == RecordStatus.recording
                ? 24.0.w
                : 54.0.w,
            height: widget.recordStatus == RecordStatus.recording
                ? 24.0.h
                : 54.0.h,
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: widget.recordStatus == RecordStatus.recording
                  ? BorderRadius.circular(4.0.r)
                  : BorderRadius.circular(27.0.r),
            ),
          ),
        ],
      ),
    );
  }
}
