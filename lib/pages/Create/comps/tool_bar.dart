import 'package:bilbili_project/utils/ToastUtils.dart';
import 'package:bilbili_project/viewmodels/Create/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ToolBar extends StatefulWidget {
  final FlashStatus flashStatus;
  final RecordDuration recordDuration;
  final ValueChanged<FlashStatus> onFlashStatusChanged;
  final ValueChanged<RecordDuration> onRecordDurationChanged;
  final bool speedMode;
  final ValueChanged<bool> onSpeedModeChanged;
  final VoidCallback onRotateChanged;
  final VoidCallback onSettingChanged;
  // 美颜
  final VoidCallback onBeautyChanged;
  // 滤镜
  final VoidCallback onFilterChanged;
  // 倒计时
  final VoidCallback onCountDownChanged;
  // 麦克风
  final MicrophoneStatus microphoneStatus;
  final ValueChanged<MicrophoneStatus> onMicrophoneStatusChanged;
  // 动图
  final GifStatus gifStatus;
  final ValueChanged<GifStatus> onGifStatusChanged;

  ToolBar({
    Key? key,
    required this.flashStatus,
    required this.recordDuration,
    required this.onFlashStatusChanged,
    required this.onRecordDurationChanged,
    required this.speedMode,
    required this.onSpeedModeChanged,
    required this.onRotateChanged,
    required this.onSettingChanged,
    required this.onBeautyChanged,
    required this.onFilterChanged,
    required this.onCountDownChanged,
    required this.microphoneStatus,
    required this.onMicrophoneStatusChanged,
    required this.gifStatus,
    required this.onGifStatusChanged,
  }) : super(key: key);

  @override
  _ToolBarState createState() => _ToolBarState();
}

class _ToolBarState extends State<ToolBar> {
  // 闪光灯图标
  IconData get flashIcon {
    switch (widget.flashStatus) {
      case FlashStatus.off:
        return Icons.flash_off_sharp;
      case FlashStatus.on:
        return Icons.flash_on_sharp;
      case FlashStatus.auto:
        return Icons.flash_auto_sharp;
    }
  }

  // 拍摄时长图标
  IconData get recordDurationIcon {
    switch (widget.recordDuration) {
      case RecordDuration.s15:
        return Icons.flash_off_sharp;
      case RecordDuration.s60:
        return Icons.flash_on_sharp;
      case RecordDuration.s180:
        return Icons.flash_auto_sharp;
    }
  }

  // 快慢速
  IconData get speedModeIcon {
    return widget.speedMode ? Icons.speed_sharp : Icons.low_priority;
  }

  // 麦克风图标
  IconData get microphoneIcon {
    return widget.microphoneStatus == MicrophoneStatus.on
        ? Icons.mic_sharp
        : Icons.mic_off_sharp;
  }

  // 动图图标
  IconData get gifIcon {
    return widget.gifStatus == GifStatus.on ? Icons.gif_sharp : Icons.abc_sharp;
  }

  // 是否展开工具栏
  bool isExpandToolsBar = false;
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onVerticalDragUpdate: (details) {
            final dy = details.delta.dy;

            // 手指向上滑（dy < 0）→ 展开
            if (dy < 0 && !isExpandToolsBar) {
              setState(() => isExpandToolsBar = true);
            }
          },
          child: AnimatedContainer(
            duration: Duration(milliseconds: 300),
            width: 64.0.w,
            height: isExpandToolsBar
                ? MediaQuery.of(context).size.height * 0.46
                : MediaQuery.of(context).size.height * 0.40,
            child: ListView(
              physics: const NeverScrollableScrollPhysics(),
              padding: EdgeInsets.zero,
              children: [
                GestureDetector(
                  onTap: () {
                    widget.onRotateChanged();
                  },
                  child: Column(
                    spacing: 2.0.h,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        FontAwesomeIcons.refresh,
                        color: Colors.white,
                        size: 22.0.sp,
                      ),
                      Text(
                        '翻转',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13.0.sp,
                          decoration: TextDecoration.none, // ⭐关键
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 12.0.h),
                GestureDetector(
                  onTap: () {
                    switch (widget.flashStatus) {
                      case FlashStatus.off:
                        widget.onFlashStatusChanged(FlashStatus.on);
                        break;
                      case FlashStatus.on:
                        widget.onFlashStatusChanged(FlashStatus.auto);
                        break;
                      case FlashStatus.auto:
                        widget.onFlashStatusChanged(FlashStatus.off);
                        break;
                    }
                  },
                  child: Column(
                    spacing: 2.0.h,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(flashIcon, color: Colors.white, size: 22.0.sp),
                      Text(
                        '闪光灯',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13.0.sp,
                          decoration: TextDecoration.none, // ⭐关键
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 12.0.h),
                GestureDetector(
                  onTap: () {
                    widget.onSettingChanged();
                  },
                  child: Column(
                    spacing: 2.0.h,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.settings_sharp,
                        color: Colors.white,
                        size: 22.0.sp,
                      ),
                      Text(
                        '设置',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13.0.sp,
                          decoration: TextDecoration.none, // ⭐关键
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 12.0.h),
                GestureDetector(
                  onTap: () {
                    widget.onMicrophoneStatusChanged(
                      widget.microphoneStatus == MicrophoneStatus.off
                          ? MicrophoneStatus.on
                          : MicrophoneStatus.off,
                    );
                  },
                  child: Column(
                    spacing: 2.0.h,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        microphoneIcon,
                        color: widget.microphoneStatus == MicrophoneStatus.off
                            ? Colors.red
                            : Colors.white,
                        size: 22.0.sp,
                      ),
                      Text(
                        '麦克风',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13.0.sp,
                          decoration: TextDecoration.none, // ⭐关键
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 12.0.h),
                GestureDetector(
                  onTap: () {
                    widget.onGifStatusChanged(
                      widget.gifStatus == GifStatus.off
                          ? GifStatus.on
                          : GifStatus.off,
                    );
                  },
                  child: Column(
                    spacing: 2.0.h,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(gifIcon, color: Colors.white, size: 22.0.sp),
                      Text(
                        '动图',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13.0.sp,
                          decoration: TextDecoration.none, // ⭐关键
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 12.0.h),

                GestureDetector(
                  onTap: () {
                    switch (widget.recordDuration) {
                      case RecordDuration.s15:
                        widget.onRecordDurationChanged(RecordDuration.s60);
                        ToastUtils.showToastReplace(context, msg: '最大拍摄时长60秒');
                        break;
                      case RecordDuration.s60:
                        widget.onRecordDurationChanged(RecordDuration.s180);
                        ToastUtils.showToastReplace(context, msg: '最大拍摄时长3分钟');
                        break;
                      case RecordDuration.s180:
                        widget.onRecordDurationChanged(RecordDuration.s15);
                        ToastUtils.showToastReplace(context, msg: '最大拍摄时长15秒');
                        break;
                    }
                  },
                  child: Column(
                    spacing: 2.0.h,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        recordDurationIcon,
                        color: Colors.white,
                        size: 22.0.sp,
                      ),
                      Text(
                        '时长',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13.0.sp,
                          decoration: TextDecoration.none, // ⭐关键
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 12.0.h),
                GestureDetector(
                  onTap: () {
                    widget.onCountDownChanged();
                  },
                  child: Column(
                    spacing: 2.0.h,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.timer_sharp,
                        color: Colors.white,
                        size: 22.0.sp,
                      ),
                      Text(
                        '倒计时',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13.0.sp,
                          decoration: TextDecoration.none, // ⭐关键
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 12.0.h),
                GestureDetector(
                  onTap: () {
                    widget.onBeautyChanged();
                  },
                  child: Column(
                    spacing: 2.0.h,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.filter_alt_sharp,
                        color: Colors.white,
                        size: 22.0.sp,
                      ),
                      Text(
                        '美颜',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13.0.sp,
                          decoration: TextDecoration.none, // ⭐关键
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 12.0.h),
                GestureDetector(
                  onTap: () {
                    widget.onFilterChanged();
                  },
                  child: Column(
                    spacing: 2.0.h,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.filter_alt_sharp,
                        color: Colors.white,
                        size: 22.0.sp,
                      ),
                      Text(
                        '滤镜',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13.0.sp,
                          decoration: TextDecoration.none, // ⭐关键
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 12.0.h),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      widget.onSpeedModeChanged(!widget.speedMode);
                    });
                  },
                  child: Column(
                    spacing: 2.0.h,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(speedModeIcon, color: Colors.white, size: 22.0.sp),
                      Text(
                        '快慢速',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13.0.sp,
                          decoration: TextDecoration.none, // ⭐关键
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        GestureDetector(
          onTap: () {
            print('更多');
            setState(() {
              isExpandToolsBar = !isExpandToolsBar;
            });
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                alignment: Alignment.center,
                height: 30.0.h,
                width: 30.0.w,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15.0.r),
                  color: Colors.white.withOpacity(0.2),
                ),
                // 向下的箭头 （不是三角形）
                child: Icon(
                  isExpandToolsBar
                      ? FontAwesomeIcons.angleUp
                      : FontAwesomeIcons.angleDown,
                  color: Colors.white,
                  size: 18.0.sp,
                ),
              ),
              Text(
                isExpandToolsBar ? '收起' : '更多',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13.0.sp,
                  decoration: TextDecoration.none, // ⭐关键
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
