import 'package:bilbili_project/pages/Create/comps/camera_view.dart';
import 'package:bilbili_project/pages/Create/comps/countdown_sheet_sekeleton.dart';
import 'package:bilbili_project/pages/Create/comps/inspiration_view.dart';
import 'package:bilbili_project/pages/Create/comps/setting_sheet_sekeleton.dart';
import 'package:bilbili_project/pages/Create/comps/auto_center_scroll_tabbar.dart';
import 'package:bilbili_project/pages/Create/comps/text_view.dart';
import 'package:bilbili_project/utils/SheetUtils.dart';
import 'package:bilbili_project/viewmodels/Create/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

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

  CountDownType countdownType = CountDownType(
    countdownDuration: '3秒',
    mode: '照片',
  );
  void openSettingSheet() {
    SheetUtils(
      SettingSheetSekeleton(
        settingSheetType: settingSheetType,
        onSettingChanged: onChangeSettingSheetParams,
      ),
    ).openAsyncSheet(context: context);
  }

  void onCountDownChanged(CountDownType type) {
    setState(() {
      countdownType = type;
    });
  }

  void openCountDownSheet() {
    SheetUtils(
      CountDownSheetSekeleton(
        countDownType: countdownType,
        onCountDownChanged: onCountDownChanged,
      ),
    ).openAsyncSheet(context: context);
  }

  List<String> options = ['文字', '相机', '创作灵感'];
  int outSelectedIndex = 1;
  void onOptionSelected(int index) {
    setState(() {
      outSelectedIndex = index;
    });
  }

  // 动图
  void onGifStatusChanged(GifStatus status) {
    setState(() {
      gifStatus = status;
    });
  }

  // 麦克风
  void onMicrophoneStatusChanged(MicrophoneStatus status) {
    setState(() {
      microphoneStatus = status;
    });
  }

  // 速度
  void onSpeedModeChanged(bool mode) {
    setState(() {
      speedMode = mode;
    });
  }

  // 闪光灯
  void onFlashStatusChanged(FlashStatus status) {
    setState(() {
      flashStatus = status;
    });
  }

  // 时长
  void onRecordDurationChanged(RecordDuration duration) {
    setState(() {
      recordDuration = duration;
    });
  }

  // outSelectedIndex 改变
  void onOutSelectedIndexChanged(int index) {
    setState(() {
      outSelectedIndex = index;
    });
  }
  List<String> cameraOptions = ['分段拍', '照片', '视频'];
  int cameraSelectedIndex = 0;
  void onInSelectedIndexChanged(int index) {
    setState(() {
      cameraSelectedIndex = index;
    });
  }
  @override
  Widget build(BuildContext context) {
    final double topVal = MediaQuery.of(context).padding.top + 10.h;
    return Column(
      children: [
        Expanded(
          child: outSelectedIndex == 0
              ? TextView()
              : outSelectedIndex == 1
              ? CameraView(
                  topVal: topVal,
                  fromUrl: widget.fromUrl,
                  gifStatus: gifStatus,
                  onGifStatusChanged: onGifStatusChanged,
                  microphoneStatus: microphoneStatus,
                  onMicrophoneStatusChanged: onMicrophoneStatusChanged,
                  openCountDownSheet: openCountDownSheet,
                  openSettingSheet: openSettingSheet,
                  speedMode: speedMode,
                  onSpeedModeChanged: onSpeedModeChanged,
                  flashStatus: flashStatus,
                  onFlashStatusChanged: onFlashStatusChanged,
                  recordDuration: recordDuration,
                  onRecordDurationChanged: onRecordDurationChanged,
                  cameraSelectedIndex: cameraSelectedIndex,
                  onInSelectedIndexChanged: onInSelectedIndexChanged,
                  cameraOptions: cameraOptions,
                )
              : InspirationView(),
        ),
        Container(
          height: 100.0.h,
          color: Color.fromRGBO(1, 1, 1, 1),
          child: Align(
            alignment: Alignment.topCenter,
            child: AutoCenterScrollTabBar(
              itemSpacing: 16.0.w,
              highlightHeight: 50.0.h,
              highlightColor: Colors.transparent,
              itemPadding: EdgeInsets.symmetric(horizontal: 6.0.w),
              activeStyle: TextStyle(
                fontSize: 14.0.sp,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                decoration: TextDecoration.none,
              ),
              inactiveStyle: TextStyle(
                fontSize: 14.0.sp,
                color: Colors.grey,
                decoration: TextDecoration.none,
              ),
              initialIndex: outSelectedIndex,
              tabs: options,
              onChanged: onOutSelectedIndexChanged,
            ),
          ),
        ),
      ],
    );
  }
}
