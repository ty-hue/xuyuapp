import 'dart:async';
import 'dart:math' as math;

import 'package:bilbili_project/store/create/create_shoot_notifier.dart';
import 'package:bilbili_project/store/create/create_shoot_state.dart';
import 'package:bilbili_project/utils/ToastUtils.dart';
import 'package:bilbili_project/viewmodels/Create/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

/// 右侧工具栏：状态来自 [createShootProvider]（含翻转摄像头）；打开 Sheet 依赖外部回调。
class ToolBar extends ConsumerStatefulWidget {
  const ToolBar({
    super.key,
    required this.openCountDownSheet,
    required this.openSettingSheet,
    required this.onBeautyTap,
    required this.onFilterTap,
  });

  final VoidCallback openCountDownSheet;
  final VoidCallback openSettingSheet;
  final VoidCallback onBeautyTap;
  final VoidCallback onFilterTap;

  @override
  ConsumerState<ToolBar> createState() => _ToolBarState();
}

class _ToolBarState extends ConsumerState<ToolBar> {
  static const Duration _kFlipIconAnimDuration = Duration(milliseconds: 320);
  /// 折叠时滚动区可视高度（整项行数）。
  static const int _kCollapsedSlotCount = 4;
  /// 点击「更多」后滚动区可视高度（半项露底，提示可滚动）。
  static const double _kExpandedVisibleSlots = 4.5;

  int _flipAnimGeneration = 0;
  double _flipTurnEnd = 0;
  late Tween<double> _flipRotationTween;
  bool _flipIconAnimating = false;
  Timer? _flipRestartTimer;

  /// 滚动区内「更多」展开后可视区为 [_kExpandedVisibleSlots] 项高并可滚动；
  /// 仅当滚动项多于 [_kCollapsedSlotCount] 时出现按钮。
  bool _scrollToolsExpanded = false;

  final ScrollController _scrollToolController = ScrollController();

  @override
  void initState() {
    super.initState();
    final front = ref.read(createShootProvider).useFrontCamera;
    _flipTurnEnd = front ? 0.0 : 0.5;
    _flipRotationTween = Tween<double>(begin: _flipTurnEnd, end: _flipTurnEnd);
  }

  @override
  void dispose() {
    _flipRestartTimer?.cancel();
    _scrollToolController.dispose();
    super.dispose();
  }

  void _resetScrollToolListToTop() {
    if (_scrollToolController.hasClients) {
      _scrollToolController.jumpTo(0);
    }
  }

  /// 须与 [_scrollToolItems] 中 `add` 条件保持一致。
  int _scrollToolItemCount(CreateShootState s) {
    int n = 0;
    if (s.cameraSelectedIndex == 1 && s.recordStatus == RecordStatus.normal) {
      n++;
    }
    if (s.cameraSelectedIndex != 2 && s.recordStatus == RecordStatus.normal) {
      n++;
    }
    if (s.recordStatus == RecordStatus.normal) {
      n += 4;
    }
    return n;
  }

  @override
  void didUpdateWidget(covariant ToolBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    final s = ref.read(createShootProvider);
    if (_scrollToolItemCount(s) <= _kCollapsedSlotCount && _scrollToolsExpanded) {
      _scrollToolsExpanded = false;
      _resetScrollToolListToTop();
    }
  }

  void _onFlipTap() {
    if (_flipIconAnimating) return;
    _flipIconAnimating = true;
    _flipRestartTimer?.cancel();

    final begin = _flipTurnEnd;
    _flipTurnEnd += 0.5;
    _flipRotationTween = Tween<double>(begin: begin, end: _flipTurnEnd);
    _flipAnimGeneration++;
    setState(() {});

    _flipRestartTimer = Timer(_kFlipIconAnimDuration, () {
      _flipRestartTimer = null;
      if (!mounted) return;
      _flipIconAnimating = false;
      ref.read(createShootProvider.notifier).toggleUseFrontCamera();
    });
  }

  void _syncFlipTurnsToFacing() {
    final front = ref.read(createShootProvider).useFrontCamera;
    var n = (_flipTurnEnd / 0.5).round();
    final needEven = front;
    final isEven = n % 2 == 0;
    if (needEven != isEven) n += 1;
    _flipTurnEnd = n * 0.5;
    _flipRotationTween = Tween<double>(begin: _flipTurnEnd, end: _flipTurnEnd);
  }

  IconData _flashIcon(FlashStatus f) {
    switch (f) {
      case FlashStatus.off:
        return Icons.flash_off_sharp;
      case FlashStatus.on:
        return Icons.flash_on_sharp;
      case FlashStatus.auto:
        return Icons.flash_auto_sharp;
    }
  }

  IconData _recordDurationIcon(RecordDuration d) {
    switch (d) {
      case RecordDuration.s15:
        return FontAwesomeIcons.hourglassStart;
      case RecordDuration.s60:
        return FontAwesomeIcons.solidHourglassHalf;
      case RecordDuration.s180:
        return FontAwesomeIcons.hourglassEnd;
    }
  }

  IconData _speedModeIcon(bool speedMode) {
    return speedMode
        ? Icons.motion_photos_on_sharp
        : Icons.motion_photos_off_sharp;
  }

  IconData _microphoneIcon(MicrophoneStatus m) {
    return m == MicrophoneStatus.on ? Icons.mic_sharp : Icons.mic_off_sharp;
  }

  IconData _gifIcon(GifStatus g) {
    return g == GifStatus.on ? Icons.videocam_sharp : Icons.videocam_off_sharp;
  }

  double get _scrollItemH => 60.0.h;

  TextStyle get _labelStyle => TextStyle(
        color: Colors.white,
        fontSize: 13.0.sp,
        decoration: TextDecoration.none,
        fontWeight: FontWeight.w600,
      );

  /// 固定区：翻转、闪光灯、设置（逻辑与原先一致）。
  Widget _buildFixedToolColumn(CreateShootState s, CreateShootNotifier n) {
    return SizedBox(
      width: 64.0.w,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!s.isStartCountDown)
            GestureDetector(
              onTap: _onFlipTap,
              child: SizedBox(
                height: 50.h,
                child: Column(
                  spacing: 2.0.h,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TweenAnimationBuilder<double>(
                      key: ValueKey<int>(_flipAnimGeneration),
                      duration: _kFlipIconAnimDuration,
                      curve: Curves.easeInOutCubic,
                      tween: _flipRotationTween,
                      builder: (context, double turns, child) {
                        return Transform.rotate(
                          angle: turns * 2 * math.pi,
                          child: child,
                        );
                      },
                      child: Icon(
                        // ignore: deprecated_member_use
                        FontAwesomeIcons.refresh,
                        color: Colors.white,
                        size: 22.0.sp,
                      ),
                    ),
                    Text('翻转', style: _labelStyle),
                  ],
                ),
              ),
            ),
          if (s.recordStatus == RecordStatus.normal)
            GestureDetector(
              onTap: () {
                switch (s.flashStatus) {
                  case FlashStatus.off:
                    n.setFlashStatus(FlashStatus.on);
                    break;
                  case FlashStatus.on:
                    n.setFlashStatus(FlashStatus.auto);
                    break;
                  case FlashStatus.auto:
                    n.setFlashStatus(FlashStatus.off);
                    break;
                }
              },
              child: SizedBox(
                height: _scrollItemH,
                child: Column(
                  spacing: 2.0.h,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(_flashIcon(s.flashStatus),
                        color: Colors.white, size: 22.0.sp),
                    Text('闪光灯', style: _labelStyle),
                  ],
                ),
              ),
            ),
          if (s.recordStatus == RecordStatus.normal)
            GestureDetector(
              onTap: widget.openSettingSheet,
              child: SizedBox(
                height: _scrollItemH,
                child: Column(
                  spacing: 2.0.h,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.settings_sharp, color: Colors.white, size: 22.0.sp),
                    Text('设置', style: _labelStyle),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMicrophoneItem(CreateShootState s, CreateShootNotifier n) {
    return GestureDetector(
      onTap: () {
        n.setMicrophoneStatus(
          s.microphoneStatus == MicrophoneStatus.off
              ? MicrophoneStatus.on
              : MicrophoneStatus.off,
        );
      },
      child: SizedBox(
        height: _scrollItemH,
        child: Column(
          spacing: 2.0.h,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _microphoneIcon(s.microphoneStatus),
              color: s.microphoneStatus == MicrophoneStatus.off
                  ? Colors.red
                  : Colors.white,
              size: 22.0.sp,
            ),
            Text('麦克风', style: _labelStyle),
          ],
        ),
      ),
    );
  }

  Widget _buildDurationOrGifSwitcher(CreateShootState s, CreateShootNotifier n) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: s.cameraSelectedIndex == 1
          ? GestureDetector(
              key: const ValueKey(1),
              onTap: () {
                switch (s.recordDuration) {
                  case RecordDuration.s15:
                    n.setRecordDuration(RecordDuration.s60);
                    ToastUtils.showToastReplace(context, msg: '最大拍摄时长60秒');
                    break;
                  case RecordDuration.s60:
                    n.setRecordDuration(RecordDuration.s180);
                    ToastUtils.showToastReplace(context, msg: '最大拍摄时长3分钟');
                    break;
                  case RecordDuration.s180:
                    n.setRecordDuration(RecordDuration.s15);
                    ToastUtils.showToastReplace(context, msg: '最大拍摄时长15秒');
                    break;
                }
              },
              child: SizedBox(
                height: _scrollItemH,
                child: Column(
                  spacing: 2.0.h,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(_recordDurationIcon(s.recordDuration),
                        color: Colors.white, size: 22.0.sp),
                    Text('时长', style: _labelStyle),
                  ],
                ),
              ),
            )
          : GestureDetector(
              key: const ValueKey(2),
              onTap: () {
                n.setGifStatus(
                  s.gifStatus == GifStatus.off ? GifStatus.on : GifStatus.off,
                );
              },
              child: SizedBox(
                height: _scrollItemH,
                child: Column(
                  spacing: 2.0.h,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(_gifIcon(s.gifStatus),
                        color: Colors.white, size: 22.0.sp),
                    Text('动图', style: _labelStyle),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildCountdownItem() {
    return GestureDetector(
      onTap: widget.openCountDownSheet,
      child: SizedBox(
        height: _scrollItemH,
        child: Column(
          spacing: 2.0.h,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.timer_sharp, color: Colors.white, size: 22.0.sp),
            Text('倒计时', style: _labelStyle),
          ],
        ),
      ),
    );
  }

  Widget _buildBeautyItem() {
    return GestureDetector(
      onTap: widget.onBeautyTap,
      child: SizedBox(
        height: _scrollItemH,
        child: Column(
          spacing: 2.0.h,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.face_retouching_natural_sharp,
                color: Colors.white, size: 22.0.sp),
            Text('美颜', style: _labelStyle),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterItem() {
    return GestureDetector(
      onTap: widget.onFilterTap,
      child: SizedBox(
        height: _scrollItemH,
        child: Column(
          spacing: 2.0.h,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.movie_filter_sharp, color: Colors.white, size: 22.0.sp),
            Text('滤镜', style: _labelStyle),
          ],
        ),
      ),
    );
  }

  Widget _buildSpeedItem(CreateShootState s, CreateShootNotifier n) {
    return GestureDetector(
      onTap: () => n.setSpeedMode(!s.speedMode),
      child: SizedBox(
        height: _scrollItemH,
        child: Column(
          spacing: 2.0.h,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(_speedModeIcon(s.speedMode), color: Colors.white, size: 22.0.sp),
            Text('快慢速', style: _labelStyle),
          ],
        ),
      ),
    );
  }

  /// 滚动区条目（麦克风、时长/动图、倒计时、美颜、滤镜、快慢速），顺序与原先单列一致。
  List<Widget> _scrollToolItems(CreateShootState s, CreateShootNotifier n) {
    final list = <Widget>[];
    if (s.cameraSelectedIndex == 1 && s.recordStatus == RecordStatus.normal) {
      list.add(_buildMicrophoneItem(s, n));
    }
    if (s.cameraSelectedIndex != 2 && s.recordStatus == RecordStatus.normal) {
      list.add(_buildDurationOrGifSwitcher(s, n));
    }
    if (s.recordStatus == RecordStatus.normal) {
      list.add(_buildCountdownItem());
      list.add(_buildBeautyItem());
      list.add(_buildFilterItem());
      list.add(_buildSpeedItem(s, n));
    }
    return list;
  }

  /// 固定工具栏与滚动工具栏之间的横线分隔。
  Widget _buildToolbarDivider() {
    return Padding(
      padding: EdgeInsets.only(top: 6.0.h, bottom: 8.0.h),
      child: SizedBox(
        width: 64.0.w,
        child: Align(
          alignment: Alignment.center,
          child: Container(
            width: 44.0.w,
            height: 1,
            color: Colors.white.withValues(alpha: 0.28),
          ),
        ),
      ),
    );
  }

  Widget _buildMoreToggle(bool expanded) {
    return GestureDetector(
      onTap: () {
        if (_scrollToolsExpanded) {
          _resetScrollToolListToTop();
        }
        setState(() => _scrollToolsExpanded = !_scrollToolsExpanded);
      },
      child: SizedBox(
        width: 64.0.w,
        height: _scrollItemH,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              alignment: Alignment.center,
              height: 30.0.h,
              width: 30.0.w,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15.0.r),
                color: Colors.white.withValues(alpha: 0.2),
              ),
              child: Icon(
                expanded ? FontAwesomeIcons.angleUp : FontAwesomeIcons.angleDown,
                color: Colors.white,
                size: 18.0.sp,
              ),
            ),
            Text(expanded ? '收起' : '更多', style: _labelStyle),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final shoot = ref.watch(createShootProvider);
    final notifier = ref.read(createShootProvider.notifier);

    ref.listen(
      createShootProvider.select((s) => s.useFrontCamera),
      (prev, next) {
        if (prev == next) return;
        if (_flipIconAnimating) return;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          setState(_syncFlipTurnsToFacing);
        });
      },
    );
    final scrollItems = _scrollToolItems(shoot, notifier);
    final needMore =
        scrollItems.length > _kCollapsedSlotCount &&
            shoot.recordStatus == RecordStatus.normal;

    final collapsedH = scrollItems.isEmpty
        ? 0.0
        : math.min(_kCollapsedSlotCount, scrollItems.length) * _scrollItemH;

    final expandedViewportH = _kExpandedVisibleSlots * _scrollItemH;

    final scrollAreaH = !needMore
        ? scrollItems.length * _scrollItemH
        : (_scrollToolsExpanded ? expandedViewportH : collapsedH);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildFixedToolColumn(shoot, notifier),
        if (scrollItems.isNotEmpty) _buildToolbarDivider(),
        if (scrollItems.isNotEmpty)
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOutCubic,
            width: 64.0.w,
            height: scrollAreaH,
            clipBehavior: Clip.hardEdge,
            decoration: const BoxDecoration(),
            child: ListView(
              controller: _scrollToolController,
              padding: EdgeInsets.zero,
              physics: needMore && _scrollToolsExpanded
                  ? const AlwaysScrollableScrollPhysics()
                  : const NeverScrollableScrollPhysics(),
              children: scrollItems,
            ),
          ),
        if (needMore) _buildMoreToggle(_scrollToolsExpanded),
      ],
    );
  }
}
