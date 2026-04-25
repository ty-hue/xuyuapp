import 'package:bilbili_project/pages/Create/comps/camera_view.dart';
import 'package:bilbili_project/pages/Create/comps/countdown_sheet_sekeleton.dart';
import 'package:bilbili_project/pages/Create/comps/inspiration_view.dart';
import 'package:bilbili_project/pages/Create/comps/setting_sheet_sekeleton.dart';
import 'package:bilbili_project/pages/Create/comps/auto_center_scroll_tabbar.dart';
import 'package:bilbili_project/pages/Create/comps/text_view.dart';
import 'package:bilbili_project/routes/app_router.dart';
import 'package:bilbili_project/pages/Create/sub/ReleasePreparation/release_preparation_args.dart';
import 'package:bilbili_project/routes/create_routes/release_preparation_route.dart';
import 'package:bilbili_project/store/create/create_shoot_notifier.dart';
import 'package:bilbili_project/store/create/create_shoot_state.dart';
import 'package:bilbili_project/utils/SheetUtils.dart';
import 'package:bilbili_project/utils/create_sheet_precache.dart';
import 'package:bilbili_project/viewmodels/Create/index.dart';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:volume_button_override/volume_button_override.dart';

class CreatePage extends ConsumerStatefulWidget {
  final String? fromUrl;
  const CreatePage({super.key, this.fromUrl});

  @override
  ConsumerState<CreatePage> createState() => _CreatePageState();
}

class _CreatePageState extends ConsumerState<CreatePage> {
  final GlobalKey<CameraViewState> cameraKey = GlobalKey();
  final VolumeButtonController _controller = VolumeButtonController();

  @override
  void initState() {
    super.initState();
    // 不得在 initState 同步改 provider（仍在 build 阶段，Riverpod 会断言）。
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final n = ref.read(createShootProvider.notifier);
      n.setRecordStatus(RecordStatus.normal);
      n.setPreviewReadyForNext(false);
      n.setIsStartCountDown(false);
      scheduleCreateSheetImagePrecache(context);
    });
  }

  @override
  void dispose() {
    unawaited(stopListening());
    super.dispose();
  }

  Future<void> _startListening() async {
    final upAction = ButtonAction(
      id: ButtonActionId.volumeUp,
      onAction: () {
        final shoot = ref.read(createShootProvider);
        if (shoot.cameraSelectedIndex == 0) {
          cameraKey.currentState?.takePhoto();
          unawaited(stopListening());
          ref.read(createShootProvider.notifier).clearUseVolumeKeys();
        } else {
          if (cameraKey.currentState?.recordStatus == RecordStatus.normal) {
            cameraKey.currentState?.startRecording();
          } else {
            cameraKey.currentState?.stopRecording();
            unawaited(stopListening());
            ref.read(createShootProvider.notifier).clearUseVolumeKeys();
          }
        }
      },
    );

    final downAction = ButtonAction(
      id: ButtonActionId.volumeDown,
      onAction: () {
        final shoot = ref.read(createShootProvider);
        if (shoot.cameraSelectedIndex == 0) {
          cameraKey.currentState?.takePhoto();
          unawaited(stopListening());
        } else {
          if (cameraKey.currentState?.recordStatus == RecordStatus.normal) {
            cameraKey.currentState?.startRecording();
          } else {
            cameraKey.currentState?.stopRecording();
            unawaited(stopListening());
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

  Future<void> stopListening() async {
    try {
      await _controller.stopListening();
    } catch (_) {
      debugPrint('移除音量键监听失败');
    }
  }

  void openSettingSheet() {
    final shoot = ref.read(createShootProvider);
    SheetUtils(
      SettingSheetSekeleton(
        settingSheetType: SettingSheetType(
          maxRecordDuration: shoot.settingSheetType.maxRecordDuration,
          aspectRatio: shoot.settingSheetType.aspectRatio,
          useVolumeKeys: shoot.settingSheetType.useVolumeKeys,
          grid: shoot.settingSheetType.grid,
        ),
        onSettingChanged: (type) {
          ref.read(createShootProvider.notifier).applySettingsFromSheet(type);
          if (type.useVolumeKeys) {
            unawaited(_startListening());
          } else {
            unawaited(stopListening());
          }
        },
      ),
    ).openAsyncSheet(context: context);
  }

  void openCountDownSheet() {
    final shoot = ref.read(createShootProvider);
    SheetUtils(
      CountDownSheetSekeleton(
        countDownType: CountDownType(
          countdownDuration: shoot.countdownType.countdownDuration,
        ),
        onCountDownChanged: (type) {
          ref.read(createShootProvider.notifier).setCountdownType(type);
        },
        onIsStartCountDownChanged: (isStart) {
          ref.read(createShootProvider.notifier).setIsStartCountDown(isStart);
          cameraKey.currentState?.changeUI(RecordStatus.recording);
        },
      ),
    ).openAsyncSheet(context: context);
  }

  void _onCountdownFinished() {
    ref.read(createShootProvider.notifier).onCountdownFinishedFromSheet();
    final shoot = ref.read(createShootProvider);
    if (shoot.cameraSelectedIndex == 0) {
      cameraKey.currentState?.takePhoto();
    } else {
      cameraKey.currentState?.startRecording();
    }
  }

  // 跳转到发布准备页
  Future<void> _onReleasePreparation() async {
    final args = await cameraKey.currentState?.prepareReleaseArgs() ??
        ReleasePreparationArgs.text();
    ReleasePreparationNav.setPending(args);
    if (!mounted) return;
    ReleasePreparationRoute().push(context);
  }

  Widget _bottomBar(CreateShootState shoot) {
    switch (shoot.recordStatus) {
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
          initialIndex: shoot.outSelectedIndex,
          tabs: CreateShootLabels.outerTabs,
          onChanged: (i) =>
              ref.read(createShootProvider.notifier).setOutSelectedIndex(i),
        );
      case RecordStatus.recording:
        return Container();
      case RecordStatus.end:
        return SizedBox(
          width: MediaQuery.sizeOf(context).width * 0.8,
          height: 50.0.h,
          child: ElevatedButton(
            onPressed: shoot.previewReadyForNext ? _onReleasePreparation : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              disabledBackgroundColor: const Color.fromRGBO(55, 55, 55, 0.72),
              disabledForegroundColor: const Color.fromRGBO(
                255,
                255,
                255,
                0.38,
              ),
            ),
            child: Text(
              '下一步',
              style: TextStyle(fontSize: 16.0.sp, fontWeight: FontWeight.bold),
            ),
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final shoot = ref.watch(createShootProvider);

    ref.listen(
      createShootProvider.select((s) => s.settingSheetType.useVolumeKeys),
      (prev, next) {
        if (next) {
          WidgetsBinding.instance.addPostFrameCallback(
            (_) => unawaited(_startListening()),
          );
        } else if (prev == true) {
          unawaited(stopListening());
        }
      },
    );

    final double topVal = MediaQuery.paddingOf(context).top + 10.h;

    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final totalH = constraints.maxHeight;
        final bottomH = 100.0.h;
        final previewRegionH = (totalH - bottomH).clamp(0.0, double.infinity);
        final ar = shoot.settingSheetType.aspectRatio;
        final wh = ar == '3:4' ? 3 / 4 : 9 / 16;
        final contentH = w > 0 ? w / wh : 0.0;
        final bottomBar = SizedBox(
          height: bottomH,
          child: Container(
            padding: EdgeInsets.only(top: 10.0.h),
            color: const Color.fromRGBO(1, 1, 1, 1),
            child: Align(
              alignment: Alignment.topCenter,
              child: _bottomBar(shoot),
            ),
          ),
        );

        Widget cameraPreviewSlot() {
          final cameraTab = CameraView(
            key: cameraKey,
            topVal: topVal,
            fromUrl: widget.fromUrl,
            onCountdownFinished: _onCountdownFinished,
            openCountDownSheet: openCountDownSheet,
            openSettingSheet: openSettingSheet,
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

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (shoot.outSelectedIndex == 1)
              Expanded(child: cameraPreviewSlot())
            else
              Expanded(
                child: shoot.outSelectedIndex == 0
                    ? TextView(belowSiblingHeight: bottomH)
                    : const InspirationView(),
              ),
            bottomBar,
          ],
        );
      },
    );
  }
}
