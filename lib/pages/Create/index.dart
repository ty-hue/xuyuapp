import 'package:bilbili_project/pages/Create/comps/setting_sheet_sekeleton.dart';
import 'package:bilbili_project/pages/Create/comps/tool_bar.dart';
import 'package:bilbili_project/utils/SheetUtils.dart';
import 'package:bilbili_project/viewmodels/Create/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class CreatePage extends StatefulWidget {
  final String? fromUrl;
  CreatePage({Key? key, this.fromUrl}) : super(key: key);

  @override
  State<CreatePage> createState() => _CreatePageState();
}

class _CreatePageState extends State<CreatePage> {
  bool isExpandToolsBar = false; // 是否展开工具栏
  FlashStatus flashStatus = FlashStatus.off; // 闪光灯状态 默认关闭
  RecordDuration recordDuration = RecordDuration.s15; // 拍摄时长 默认短 (分段拍模式专用)
  bool speedMode = false; // 快慢速
  MicrophoneStatus microphoneStatus = MicrophoneStatus.off; // 麦克风状态 默认关闭
  GifStatus gifStatus = GifStatus.off; // 动图状态 默认关闭
  SettingSheetType settingSheetType = SettingSheetType(
    maxRecordDuration: '16',
    aspectRatio: '9:16',
    useVolumeKeys: false,
    grid: false,
  ); // settings sheet参数
  void onChangeSettingSheetParams(SettingSheetType type) {
    setState(() {
      settingSheetType = type;
    });
  }

  void openSettingSheet() {
    SheetUtils(SettingSheetSekeleton(settingSheetType: settingSheetType, onSettingChanged: onChangeSettingSheetParams)).openAsyncSheet(context: context);
  }

  @override
  Widget build(BuildContext context) {
    final double topVal = MediaQuery.of(context).padding.top + 10.h;
    return Column(
      children: [
        Expanded(
          child: Container(
            color: Colors.pink,
            child: Stack(
              children: [
                Positioned(
                  left: 20.0.w,
                  top: topVal,
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
                      child: Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 26.0.sp,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: topVal,
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
                  top: topVal + 10.h,
                  child: ToolBar(
                    gifStatus: gifStatus,
                    onGifStatusChanged: (status) {
                      setState(() {
                        gifStatus = status;
                      });
                    },
                    microphoneStatus: microphoneStatus,
                    onMicrophoneStatusChanged: (status) {
                      setState(() {
                        microphoneStatus = status;
                      });
                    },
                    onCountDownChanged: () {
                      print('倒计时');
                    },
                    onSettingChanged: openSettingSheet,
                    onBeautyChanged: () {
                      print('美颜');
                    },
                    onFilterChanged: () {
                      print('滤镜');
                    },
                    onRotateChanged: () {
                      print('旋转');
                    },
                    speedMode: speedMode,
                    onSpeedModeChanged: (mode) {
                      setState(() {
                        speedMode = mode;
                      });
                    },
                    flashStatus: flashStatus,
                    recordDuration: recordDuration,
                    onFlashStatusChanged: (status) {
                      setState(() {
                        flashStatus = status;
                      });
                    },
                    onRecordDurationChanged: (duration) {
                      setState(() {
                        recordDuration = duration;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
        Container(height: 100.0.h, color: Color.fromRGBO(1, 1, 1, 1)),
      ],
    );
  }
}
