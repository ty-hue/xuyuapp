import 'package:bilbili_project/pages/Create/comps/camera_view.dart';
import 'package:bilbili_project/pages/Create/comps/countdown_sheet_sekeleton.dart';
import 'package:bilbili_project/pages/Create/comps/inspiration_view.dart';
import 'package:bilbili_project/pages/Create/comps/setting_sheet_sekeleton.dart';
import 'package:bilbili_project/pages/Create/comps/auto_center_scroll_tabbar.dart';
import 'package:bilbili_project/pages/Create/comps/text_view.dart';
import 'package:bilbili_project/utils/SheetUtils.dart';
import 'package:bilbili_project/utils/create_sheet_precache.dart';
import 'package:bilbili_project/viewmodels/Create/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:volume_button_override/volume_button_override.dart';

class CreatePage extends StatefulWidget {
  final String? fromUrl;
  CreatePage({Key? key, this.fromUrl}) : super(key: key);

  @override
  State<CreatePage> createState() => _CreatePageState();
}

class _CreatePageState extends State<CreatePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      scheduleCreateSheetImagePrecache(context);
    });
  }

  bool isExpandToolsBar = false; // 是否展开工具栏
  FlashStatus flashStatus = FlashStatus.off; // 闪光灯状态 默认关闭
  RecordDuration recordDuration = RecordDuration.s15; // 拍摄时长 默认短 (分段拍模式专用)
  bool speedMode = false; // 快慢速
  MicrophoneStatus microphoneStatus = MicrophoneStatus.off; // 麦克风状态 默认关闭
  GifStatus gifStatus = GifStatus.off; // 动图状态 默认关闭
  SettingSheetType settingSheetType = SettingSheetType(
    maxRecordDuration: '15',
    aspectRatio: '9:16',
    useVolumeKeys: false,
    grid: false,
  ); // settings sheet参数
  void onChangeSettingSheetParams(SettingSheetType type) {
    setState(() {
      // 必须新建实例：设置 Sheet 会就地改 params 再回调，若直接 settingSheetType = type
      // 则引用不变，CameraView.didUpdateWidget 无法发现 aspectRatio 变化，原生不会按新比例重启相机。
      settingSheetType = SettingSheetType(
        maxRecordDuration: type.maxRecordDuration,
        aspectRatio: type.aspectRatio,
        useVolumeKeys: type.useVolumeKeys,
        grid: type.grid,
      );
      recordDuration = RecordDuration.values.firstWhere(
        (element) => element.seconds.toString() == type.maxRecordDuration,
      );
      // 处理音量键
      if (settingSheetType.useVolumeKeys) {
        _startListening();
      } else {
        stopListening();
      }
    });
  }

  CountDownType countdownType = CountDownType(countdownDuration: '3秒');

  List<String> speedOptions = ['极慢', '慢', '标准', '快', '极快']; // 快慢速选项

  int speedSelectedIndex = 2; // 快慢速默认标准

  // 快慢速改变
  void onSpeedSelectedIndexChanged(int index) {
    setState(() {
      speedSelectedIndex = index;
    });
  }

  // 打开设置sheet
  void openSettingSheet() {
    SheetUtils(
      SettingSheetSekeleton(
        settingSheetType: settingSheetType,
        onSettingChanged: onChangeSettingSheetParams,
      ),
    ).openAsyncSheet(context: context);
  }

  // 打开倒计时sheet
  void onCountDownChanged(CountDownType type) {
    setState(() {
      countdownType = type;
    });
  }

  // 是否开始倒计时
  bool isStartCountDown = false;
  final GlobalKey<CameraViewState> cameraKey = GlobalKey();

  // 修改是否开始倒计时
  void onIsStartCountDownChanged(bool isStart) {
    setState(() {
      isStartCountDown = isStart;
    });
    cameraKey.currentState?.changeUI(RecordStatus.recording);
  }

  // 倒计时结束后
  void onCountdownFinished() {
    setState(() {
      isStartCountDown = false;
    });
    // 倒计时结束后，开始录制
    if (cameraSelectedIndex == 0) {
      cameraKey.currentState?.takePhoto();
      return;
    } else {
      cameraKey.currentState?.startRecording();
    }
  }

  void openCountDownSheet() {
    SheetUtils(
      CountDownSheetSekeleton(
        countDownType: countdownType,
        onCountDownChanged: onCountDownChanged,
        onIsStartCountDownChanged: onIsStartCountDownChanged,
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
      settingSheetType.maxRecordDuration = duration.seconds.toString();
    });
  }

  // outSelectedIndex 改变
  void onOutSelectedIndexChanged(int index) {
    setState(() {
      outSelectedIndex = index;
    });
  }

  List<String> cameraOptions = ['照片', '视频'];
  int cameraSelectedIndex = 0;
  void onInSelectedIndexChanged(int index) {
    setState(() {
      cameraSelectedIndex = index;
    });
  }

  // 控制底部AutoCenterScrollTabBar显示隐藏
  RecordStatus recordStatus = RecordStatus.normal;

  /// 预览区是否已展示成片（照片路径就绪 / 视频可播放），为 false 时「下一步」禁用。
  bool _previewReadyForNext = false;

  void onPreviewReadyForNext(bool ready) {
    setState(() {
      _previewReadyForNext = ready;
    });
  }

  // 录制状态改变
  void onRecordStatusChanged(RecordStatus status) {
    setState(() {
      recordStatus = status;
      _previewReadyForNext = false;
    });
  }

  Widget get bottomUI {
    switch (recordStatus) {
      case RecordStatus.normal:
        return AutoCenterScrollTabBar(
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
        );
      case RecordStatus.recording:
        return Container();
      case RecordStatus.end:
        return SizedBox(
          width: MediaQuery.of(context).size.width * 0.8,
          height: 50.0.h,
          child: ElevatedButton(
            onPressed: _previewReadyForNext ? () {} : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              disabledBackgroundColor: const Color.fromRGBO(55, 55, 55, 0.72),
              disabledForegroundColor: const Color.fromRGBO(255, 255, 255, 0.38),
            ),
            child: Text(
              '下一步',
              style: TextStyle(
                fontSize: 16.0.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
    }
  }

  // 创建音量键控制器
  final VolumeButtonController _controller = VolumeButtonController();
  // 开始监听音量键
  Future<void> _startListening() async {
    final upAction = ButtonAction(
      id: ButtonActionId.volumeUp,
      onAction: () {
        // 要做的事情
        if (cameraSelectedIndex == 0) {
          cameraKey.currentState?.takePhoto();
          stopListening();
          setState(() {
            settingSheetType.useVolumeKeys = false;
          });
        } else {
          if (cameraKey.currentState?.recordStatus == RecordStatus.normal) {
            cameraKey.currentState?.startRecording();
          } else {
            cameraKey.currentState?.stopRecording();
            stopListening();
            setState(() {
              settingSheetType.useVolumeKeys = false;
            });
          }
        }
      },
    );

    final downAction = ButtonAction(
      id: ButtonActionId.volumeDown,
      onAction: () {
        if (cameraSelectedIndex == 0) {
          cameraKey.currentState?.takePhoto();
          stopListening();
        } else {
          if (cameraKey.currentState?.recordStatus == RecordStatus.normal) {
            cameraKey.currentState?.startRecording();
          } else {
            cameraKey.currentState?.stopRecording();
            stopListening();
          }
        }
      },
    );

    try {
      await _controller.startListening(
        volumeUpAction: upAction,
        volumeDownAction: downAction,
      );
    } catch (_) {}
  }

  // 移除音量键监听
  Future<void> stopListening() async {
    try {
      await _controller.stopListening();
    } catch (_) {
      print('移除音量键监听失败');
    }
  }

  @override
  void dispose() {
    super.dispose();
    // 释放音量键控制器
    stopListening();
  }

  

  @override
  Widget build(BuildContext context) {
    final double topVal = MediaQuery.of(context).padding.top + 10.h;

    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final totalH = constraints.maxHeight;
        final bottomH = 100.0.h;
        final previewRegionH = (totalH - bottomH).clamp(0.0, double.infinity);
        final ar = settingSheetType.aspectRatio;
        // 宽始终满屏；高由比例算出；上下黑边各为 (预览区总高 - contentH) / 2（过高则 ClipRect 居中裁切）。
        final wh = ar == '3:4' ? 3 / 4 : 9 / 16; // width / height
        final contentH = w > 0 ? w / wh : 0.0;
        final bottomBar = SizedBox(
          height: bottomH,
          child: Container(
            padding: EdgeInsets.only(top: 10.0.h),
            color: const Color.fromRGBO(1, 1, 1, 1),
            child: Align(alignment: Alignment.topCenter, child: bottomUI),
          ),
        );

        Widget cameraPreviewSlot() {
          final cameraTab = CameraView(
            key: cameraKey,
            onRecordStatusChanged: onRecordStatusChanged,
            onPreviewReadyForNext: onPreviewReadyForNext,
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
            speedOptions: speedOptions,
            speedSelectedIndex: speedSelectedIndex,
            onSpeedSelectedIndexChanged: onSpeedSelectedIndexChanged,
            countdown: int.parse(
              countdownType.countdownDuration.replaceAll('秒', ''),
            ),
            isStartCountDown: isStartCountDown,
            onIsStartCountDownChanged: onIsStartCountDownChanged,
            onCountdownFinished: onCountdownFinished,
            settingSheetType: settingSheetType,
            previewSlotWidth: w,
            previewSlotHeight: previewRegionH,
            previewContentHeight: contentH,
          );
          return ColoredBox(
            color: Colors.black,
            child: SizedBox(
              width: w,
              height: previewRegionH,
              child: ClipRect(child: cameraTab),
            ),
          );
        }

        final column = Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (outSelectedIndex == 1)
              Expanded(child: cameraPreviewSlot())
            else
              Expanded(
                child: outSelectedIndex == 0 ? TextView() : InspirationView(),
              ),
            bottomBar,
          ],
        );

        // if (outSelectedIndex == 1) {
        //   final safeTop = MediaQuery.of(context).padding.top;
        //   return Stack(
        //     clipBehavior: Clip.none,
        //     children: [
        //       column,
        //       Positioned(
        //         left: 12.w,
        //         top: safeTop + 6.h,
        //         child: GestureDetector(
        //           behavior: HitTestBehavior.opaque,
        //           onTap: () {
        //             if (context.canPop()) context.pop();
        //           },
        //           child: Padding(
        //             padding: EdgeInsets.all(8.w),
        //             child: Icon(Icons.close, color: Colors.white, size: 33.sp),
        //           ),
        //         ),
        //       ),
        //     ],
        //   );
        // }

        return column;
      },
    );
  }
}
