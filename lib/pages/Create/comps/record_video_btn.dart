import 'package:bilbili_project/viewmodels/Create/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 与 [TakePhotoButton] 一致：未录制时外径 72（再 ×1.4），与拍照按钮同大。
const double _kCaptureBtnScale = 1.4;

class RecordVideoButton extends StatefulWidget {
  final VoidCallback startRecording;
  final VoidCallback stopRecording;
  final RecordStatus recordStatus;
  final RecordDuration recordDuration;
  RecordVideoButton({
    Key? key,
    required this.startRecording,
    required this.stopRecording,
    required this.recordStatus,
    required this.recordDuration,
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
      duration: Duration(seconds: widget.recordDuration.seconds), // 假设录制时间为60秒
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

  static const Duration _kStateTransition = Duration(milliseconds: 300);

  /// 录制态外圈、内层圆环必须正方形，否则 [CircularProgressIndicator] 会被拉成椭圆（图2）。
  static const Color _kRecordingOuterTint = Color.fromRGBO(0, 0, 0, 0.45);

  @override
  Widget build(BuildContext context) {
    final recording = widget.recordStatus == RecordStatus.recording;
    final s = _kCaptureBtnScale;
    // 录制中外圈边长：宽高都用 .w，保证正圆 + 细红弧贴在圆周上（对齐参考图1）
    final double recOuterSide = 100.0.w * s;

    return GestureDetector(
      onTap: () {
        if (recording) {
          _stopRecording();
        } else {
          _startRecording();
        }
      },
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          // 外层：未录制同 [TakePhotoButton]；录制中为半透明深色圆 + 红色环形进度（非实心紫底）。
          AnimatedContainer(
            duration: _kStateTransition,
            curve: Curves.easeInOutCubic,
            width: recording ? recOuterSide : 72.0.w * s,
            height: recording ? recOuterSide : 72.0.h * s,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: recording ? _kRecordingOuterTint : Colors.transparent,
              border: recording
                  ? null
                  : Border.all(
                      color: Colors.white,
                      width: 6.0.w * s,
                    ),
            ),
            child: recording
                ? CircularProgressIndicator(
                    value: _controller.value,
                    strokeWidth: 3.2.w * s,
                    backgroundColor: Colors.transparent,
                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.red),
                  )
                : null,
          ),
          AnimatedContainer(
            duration: _kStateTransition,
            curve: Curves.easeInOutCubic,
            width: recording ? 48.0.w * s : 54.0.w * s,
            height: recording ? 48.0.w * s : 54.0.h * s,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          ),
          AnimatedContainer(
            duration: _kStateTransition,
            curve: Curves.easeInOutCubic,
            width: recording ? 24.0.w * s : 54.0.w * s,
            height: recording ? 24.0.w * s : 54.0.h * s,
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(
                recording ? (4.0 * s).r : (27.0 * s).r,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
