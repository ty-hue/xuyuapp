import 'package:bilbili_project/pages/Create/comps/auto_center_scroll_tabbar.dart';
import 'package:bilbili_project/pages/Create/comps/tool_bar.dart';
import 'package:bilbili_project/viewmodels/Create/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class CameraView extends StatefulWidget {
  final double topVal;
  final String? fromUrl;
  final GifStatus gifStatus;
  final ValueChanged<GifStatus> onGifStatusChanged;
  final MicrophoneStatus microphoneStatus;
  final ValueChanged<MicrophoneStatus> onMicrophoneStatusChanged;
  final VoidCallback openCountDownSheet;
  final VoidCallback openSettingSheet;
  final bool speedMode;
  final ValueChanged<bool> onSpeedModeChanged;
  final FlashStatus flashStatus;
  final ValueChanged<FlashStatus> onFlashStatusChanged;
  final RecordDuration recordDuration;
  final ValueChanged<RecordDuration> onRecordDurationChanged;
  final int cameraSelectedIndex;
  final ValueChanged<int> onInSelectedIndexChanged;
  final List<String> cameraOptions;
  CameraView({
    Key? key,
    required this.topVal,
    this.fromUrl,
    required this.gifStatus,
    required this.onGifStatusChanged,
    required this.microphoneStatus,
    required this.onMicrophoneStatusChanged,
    required this.openCountDownSheet,
    required this.openSettingSheet,
    required this.speedMode,
    required this.onSpeedModeChanged,
    required this.flashStatus,
    required this.onFlashStatusChanged,
    required this.recordDuration,
    required this.onRecordDurationChanged,
    required this.cameraSelectedIndex,
    required this.onInSelectedIndexChanged,
    required this.cameraOptions,
  }) : super(key: key);

  @override
  _CameraViewState createState() => _CameraViewState();
}

class _CameraViewState extends State<CameraView> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.pink,
      child: Stack(
        children: [
          Positioned(
            left: 20.0.w,
            top: widget.topVal,
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 10.0.h),
              child: GestureDetector(
                onTap: () {
                  if (widget.fromUrl != null) {
                    context.pop(widget.fromUrl);
                  } else {
                    context.pop();
                  }
                },
                child: Icon(Icons.close, color: Colors.white, size: 26.0.sp),
              ),
            ),
          ),
          Positioned(
            top: widget.topVal,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () {
                    print('选择音乐');
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      vertical: 10.0.h,
                      horizontal: 12.0.w,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8.0.r),
                      color: Colors.black.withOpacity(0.4),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      spacing: 2.0.w,
                      children: [
                        Icon(
                          Icons.music_note,
                          color: Colors.white,
                          size: 20.0.sp,
                        ),
                        Text(
                          '选择音乐',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14.0.sp,
                            decoration: TextDecoration.none, // ⭐关键
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            right: 0.w,
            top: widget.topVal + 10.h,
            child: ToolBar(
              gifStatus: widget.gifStatus,
              onGifStatusChanged: (status) {
                widget.onGifStatusChanged(status);
              },
              microphoneStatus: widget.microphoneStatus,
              onMicrophoneStatusChanged: (status) {
                widget.onMicrophoneStatusChanged(status);
              },
              onCountDownChanged: () {
                widget.openCountDownSheet();
              },
              onSettingChanged: widget.openSettingSheet,
              onBeautyChanged: () {
                print('美颜');
              },
              onFilterChanged: () {
                print('滤镜');
              },
              onRotateChanged: () {
                print('旋转');
              },
              speedMode: widget.speedMode,
              onSpeedModeChanged: (mode) {
                widget.onSpeedModeChanged(mode);
              },
              flashStatus: widget.flashStatus,
              recordDuration: widget.recordDuration,
              onFlashStatusChanged: (status) {
                widget.onFlashStatusChanged(status);
              },
              onRecordDurationChanged: (duration) {
                widget.onRecordDurationChanged(duration);
              },
            ),
          ),
          Positioned(
            bottom: 20.0.h,
            left: 0,
            right: 0,
            child: Container(
              child: Column(
                spacing: 24.0.h,
                mainAxisSize: MainAxisSize.min,
                children: [
                  AutoCenterScrollTabBar(
                    itemSpacing: 20.0.w,
                    highlightHeight: 22.0.h,
                    highlightColor: Colors.white,
                    itemPadding: EdgeInsets.symmetric(horizontal: 2.0.w),
                    activeStyle: TextStyle(
                      fontSize: 14.0.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      decoration: TextDecoration.none,
                    ),
                    inactiveStyle: TextStyle(
                      fontSize: 14.0.sp,
                      color: Colors.white,
                      decoration: TextDecoration.none,
                    ),
                    initialIndex: widget.cameraSelectedIndex,
                    tabs: widget.cameraOptions,
                    onChanged: widget.onInSelectedIndexChanged,
                  ),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          spacing: 4.0.h,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8.0.r),
                              child: Image.asset(
                                'lib/assets/app_logo.png',
                                width: 50.0.w,
                                height: 50.0.h,
                              ),
                            ),
                            Text(
                              '特效',
                              style: TextStyle(
                                fontSize: 14.0.sp,
                                color: Colors.white,
                                decoration: TextDecoration.none,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          alignment: Alignment.topCenter,
                          child: GestureDetector(
                            onTap:(){
                               print('开始录制');
                            },
                            child: Container(
                            alignment: Alignment.center,
                            width: 64.0.w,
                            height: 64.0.h,
                            decoration: BoxDecoration(
                              color: Colors.transparent,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white,
                                width: 3.0.w,
                              ),
                            ),
                            child: Container(
                              width: 48.0.w,
                              height: 48.0.h,
                              decoration: BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                          )
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          spacing: 4.0.h,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8.0.r),
                              child: Image.asset(
                                'lib/assets/app_logo.png',
                                width: 50.0.w,
                                height: 50.0.h,
                              ),
                            ),
                            Text(
                              '相册',
                              style: TextStyle(
                                fontSize: 14.0.sp,
                                color: Colors.white,
                                decoration: TextDecoration.none,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
