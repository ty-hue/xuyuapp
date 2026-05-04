import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:bilbili_project/components/tiktok_video_gesture.dart';
import 'package:bilbili_project/pages/Home/comps/feed_video_progress_utils.dart';
import 'package:bilbili_project/pages/Home/comps/landscape_feed_video_page.dart';
import 'package:bilbili_project/pages/Home/comps/video_long_press_sheet_skeleton.dart';
import 'package:bilbili_project/routes/app_router.dart';
import 'package:bilbili_project/utils/SheetUtils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_player/video_player.dart';
import 'dart:math' as math;

class CustomVideoPlayer extends StatefulWidget {
  final String url;

  /// 是否为当前可见页（如纵向 PageView 里的一条）；为 false 时暂停，为 true 时播放。
  final bool isActive;

  /// 双击视频区域时的回调（如点赞）；爱心动效由内部处理。
  final VoidCallback? onDoubleTapLike;

  /// 与 [videoHeightHint] 同时存在且宽大于高时，首帧前即可按横屏样式占位（可选）。
  final int? videoWidthHint;
  final int? videoHeightHint;

  /// 传入后在横屏全屏页展示标题、作者、互动等（与抖音横屏条一致）。
  final LandscapeFeedSocialMeta? landscapeMeta;

  /// 进度条展开时「当前/总时长」文案样式，在默认 `18.sp` 基础上合并；不传则与原先 Feed 一致。
  final TextStyle? progressTimeLabelStyle;

  /// 进度条触摸区相对底部 [Stack] 再向下偏移（正值向下，内部用 `Positioned(bottom: -value)`）。
  /// 默认 `0` 不改变布局；需要更贴底时可传 `6.h` 等，由调用方按需传入。
  final double progressBarBottomOffset;

  /// 仅「长按清屏播放」时使用；隐藏首页顶栏 Tab + 搜索。
  final ValueNotifier<bool>? clearPlaybackChromeNotifier;

  /// 拖拽进度条或清屏模式下拖进度时使用；隐藏本条右侧 / 底部互动层，
  /// **不**隐藏首页顶栏（与 [clearPlaybackChromeNotifier] 区分）。
  final ValueNotifier<bool>? feedScrubbingOverlayNotifier;

  const CustomVideoPlayer({
    Key? key,
    required this.url,
    this.isActive = true,
    this.onDoubleTapLike,
    this.videoWidthHint,
    this.videoHeightHint,
    this.landscapeMeta,
    this.progressTimeLabelStyle,
    this.progressBarBottomOffset = 0,
    this.clearPlaybackChromeNotifier,
    this.feedScrubbingOverlayNotifier,
  }) : super(key: key);

  @override
  State<CustomVideoPlayer> createState() => _CustomVideoPlayerState();
}

class _CustomVideoPlayerState extends State<CustomVideoPlayer> {
  static const int _kUiPositionTickMs = 250;

  late VideoPlayerController _controller;

  bool _landscapeFullscreenPushInFlight = false;

  /// 触摸：手指在扩大热区内按下未抬起。
  bool _touchingProgressZone = false;

  /// 桌面/Web：指针悬停在扩大热区内。
  bool _mouseInsideProgressZone = false;

  /// 本次按住进度条前视频是否在播；seek 后原生层常会暂停，需按需 `play()` 恢复。
  bool _wasPlayingWhenScrubStarted = false;

  /// 用户在本条视频上最近一次「点按」选择的是暂停时为 true。
  /// 用于区分：因切 Tab / 去「我的」等导致的 `isActive=false`（仅 pause），回到前台时不应擅自 `play()`。
  bool _userExplicitlyPaused = false;

  bool _uiPlayingTracked = false;
  bool _uiInitializedTracked = false;
  int _uiPositionTickTracked = -1;

  /// 清屏播放：除进度条外隐藏视频内 Chrome。
  bool _clearPlaybackChrome = false;

  /// 清屏底栏拖拽进度中。
  bool _clearBarScrubbing = false;

  double _appliedPlaybackSpeed = 1.0;

  /// 参见 [kVideoFeedPlaybackSpeedSteps]，清屏面板循环倍速与该列表一致。
  static const Color _kClearChromeSurface = Color(0xE62E2E32);

  /// 与设计稿对齐：方形关闭 / 等高右侧胶囊。
  double get _clearChromeHitExtent => 42.h;

  /// 长按清屏 **或** 正在操作进度（含悬停进度区）：隐藏大图播放键、横屏「全屏观看」，
  /// 并通过 [feedScrubbingOverlayNotifier] 收起本条 overlay（顶栏不受影响）。
  bool get _immersivePlaybackTrim =>
      _clearPlaybackChrome ||
      _touchingProgressZone ||
      _mouseInsideProgressZone ||
      _clearBarScrubbing;

  bool get _progressBarExpanded =>
      _touchingProgressZone || _mouseInsideProgressZone;

  double get _barHeight => _progressBarExpanded ? 5.h : 2.5.h;

  double get _thumbRadius => _progressBarExpanded ? 5.w : 2.5.w;

  /// 底部可触摸区域高度（含进度条上方空白）；展开时加高以容纳时间文案。
  /// 条带视觉较细，触控区仍略高于条本身，避免误触困难。
  double get _progressTouchZoneHeight => _progressBarExpanded ? 92.h : 40.h;

  void _applyClearPlaybackChrome(bool value) {
    if (!mounted) return;
    final n = widget.clearPlaybackChromeNotifier;
    final needsFrame = _clearPlaybackChrome != value;
    final needsNotify = n != null && n.value != value;
    if (!needsFrame && !needsNotify) return;
    if (needsFrame) {
      setState(() => _clearPlaybackChrome = value);
    }
    if (needsNotify) {
      n.value = value;
    }
  }

  void _syncFeedScrubbingOverlayNotifier() {
    final notifier = widget.feedScrubbingOverlayNotifier;
    if (notifier == null) return;
    final immersive =
        _touchingProgressZone || _mouseInsideProgressZone || _clearBarScrubbing;
    if (notifier.value != immersive) {
      notifier.value = immersive;
    }
  }

  void _schedulePlayIfActive() {
    if (!mounted || !widget.isActive || !_controller.value.isInitialized) {
      return;
    }
    if (_userExplicitlyPaused) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !widget.isActive) return;
      if (_userExplicitlyPaused) return;
      if (!_controller.value.isPlaying) _controller.play();
    });
  }

  void _onControllerValueChanged() {
    if (!mounted) return;
    final v = _controller.value;
    final init = v.isInitialized;
    final playing = v.isPlaying;
    final positionTick = init ? (v.position.inMilliseconds ~/ _kUiPositionTickMs) : -1;
    final shouldRefreshByPosition = positionTick != _uiPositionTickTracked &&
        (playing ||
            _progressBarExpanded ||
            _clearPlaybackChrome ||
            _clearBarScrubbing ||
            _touchingProgressZone ||
            _mouseInsideProgressZone);
    if (_uiInitializedTracked == init &&
        _uiPlayingTracked == playing &&
        !shouldRefreshByPosition) {
      return;
    }
    _uiInitializedTracked = init;
    _uiPlayingTracked = playing;
    _uiPositionTickTracked = positionTick;
    setState(() {});
  }

  @override
  void initState() {
    super.initState();

    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.url))
      ..initialize().then((_) async {
        if (!mounted) return;
        _controller.setLooping(true);
        try {
          _appliedPlaybackSpeed = _controller.value.playbackSpeed;
        } catch (_) {
          _appliedPlaybackSpeed = 1.0;
        }
        _controller.addListener(_onControllerValueChanged);
        setState(() {});
        _schedulePlayIfActive();
      });
  }

  @override
  void didUpdateWidget(covariant CustomVideoPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isActive == widget.isActive) return;
    if (!_controller.value.isInitialized) return;
    if (widget.isActive) {
      if (!_userExplicitlyPaused) {
        _schedulePlayIfActive();
      }
    } else {
      _controller.pause();
      if (_clearPlaybackChrome) {
        _applyClearPlaybackChrome(false);
      }
      _touchingProgressZone = false;
      _mouseInsideProgressZone = false;
      _clearBarScrubbing = false;
      _syncFeedScrubbingOverlayNotifier();
    }
    setState(() {});
  }

  @override
  void dispose() {
    widget.feedScrubbingOverlayNotifier?.value = false;
    _controller.removeListener(_onControllerValueChanged);
    _controller.dispose();
    super.dispose();
  }

  void _handleVideoTap() {
    togglePlay();
  }

  void togglePlay() {
    if (!_controller.value.isInitialized) return;
    if (_controller.value.isPlaying) {
      _controller.pause();
      _userExplicitlyPaused = true;
    } else {
      _controller.play();
      _userExplicitlyPaused = false;
    }
    setState(() {});
  }

  Future<void> _openLongPressSheet() async {
    final result = await SheetUtils(
      VideoLongPressSheetSkeleton(
        initialPlaybackSpeed: _appliedPlaybackSpeed,
        onPlaybackSpeedSelected: _applyPlaybackSpeed,
        onReportNavigate: () {
          ReportPageRoute().push(context);
        },
      ),
      deferHeavyChild: false,
    ).openAsyncSheet<VideoLongPressSheetResult>(context: context);
    if (!mounted) return;
    if (result == VideoLongPressSheetResult.clearScreenPlayback) {
      _applyClearPlaybackChrome(true);
    }
  }

  /// 横屏片源：宽 > 高；优先解码后的 `size`，否则用接口下发的 hint。
  bool _isLandscapeVideo() {
    if (_controller.value.isInitialized) {
      final sz = _controller.value.size;
      if (sz.width > 0 && sz.height > 0) {
        return sz.width > sz.height;
      }
      final ar = _controller.value.aspectRatio;
      if (ar > 1.0) return true;
      if (ar > 0 && ar < 1.0) return false;
    }
    final w = widget.videoWidthHint, h = widget.videoHeightHint;
    if (w != null && h != null && w > 0 && h > 0) {
      return w > h;
    }
    return false;
  }

  Rect _landscapeContainRect(Size box) {
    final sz = _controller.value.size;
    var ar = sz.width > 0 && sz.height > 0
        ? sz.width / sz.height
        : _controller.value.aspectRatio;
    if (ar <= 0) ar = 16 / 9;
    var vw = box.width;
    var vh = vw / ar;
    if (vh > box.height) {
      vh = box.height;
      vw = vh * ar;
    }
    final left = (box.width - vw) / 2;
    final top = (box.height - vh) / 2;
    return Rect.fromLTWH(left, top, vw, vh);
  }

  Future<void> _openLandscapeFullScreen() async {
    if (!_controller.value.isInitialized) return;
    if (_landscapeFullscreenPushInFlight) return;
    _landscapeFullscreenPushInFlight = true;

    bool initialPlaying = false;

    try {
      initialPlaying = _controller.value.isPlaying;
      if (!mounted) return;

      // 使用根 Navigator，全屏页盖住整个 Shell（含底部 Tab），与抖音一致。
      await Navigator.of(context, rootNavigator: true).push<void>(
        MaterialPageRoute<void>(
          builder: (ctx) => LandscapeFeedVideoPage(
            controller: _controller,
            meta: widget.landscapeMeta,
          ),
        ),
      );
      if (!mounted) return;

      // 复用同一控制器：返回竖屏时按需恢复播放状态。
      if (_controller.value.isInitialized) {
        if (!widget.isActive) {
          await _controller.pause();
        } else if (initialPlaying && !_controller.value.isPlaying) {
          await _controller.play();
        }
        if (mounted) setState(() {});
      }
    } finally {
      _landscapeFullscreenPushInFlight = false;
    }
  }

  Widget _fullScreenWatchChip() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _openLandscapeFullScreen,
        borderRadius: BorderRadius.circular(24.r),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 9.h),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.48),
            borderRadius: BorderRadius.circular(24.r),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.screen_rotation_rounded,
                color: Colors.white,
                size: 18.sp,
              ),
              SizedBox(width: 8.w),
              Text(
                '全屏观看',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVideoBody(Size box) {
    if (!_controller.value.isInitialized) {
      return const ColoredBox(
        color: Color(0xFF141414),
        child: Center(child: CircularProgressIndicator(color: Colors.white38)),
      );
    }

    final landscape = _isLandscapeVideo();

    if (landscape) {
      final r = _landscapeContainRect(box);
      return ColoredBox(
        color: const Color(0xFF262626),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Positioned(
              left: r.left,
              top: r.top,
              width: r.width,
              height: r.height,
              child: VideoPlayer(_controller),
            ),
            if (!_immersivePlaybackTrim && !_controller.value.isPlaying)
              Positioned(
                left: r.left,
                top: r.top,
                width: r.width,
                height: r.height,
                child: const Center(
                  child: Icon(
                    Icons.play_arrow_rounded,
                    size: 80,
                    color: Colors.white,
                  ),
                ),
              ),
          ],
        ),
      );
    }

    final sz = _controller.value.size;
    var ar = _controller.value.aspectRatio;
    if (ar <= 0 && sz.width > 0 && sz.height > 0) {
      ar = sz.width / sz.height;
    }
    if (ar <= 0) ar = 9 / 16;
    final vw = sz.width > 0 ? sz.width : ar * 720;
    final vh = sz.height > 0 ? sz.height : 720.0;
    return ColoredBox(
      color: Colors.black,
      child: Stack(
        fit: StackFit.expand,
        children: [
          FittedBox(
            fit: BoxFit.cover,
            clipBehavior: Clip.hardEdge,
            child: SizedBox(
              width: vw,
              height: vh,
              child: VideoPlayer(_controller),
            ),
          ),
          if (!_immersivePlaybackTrim && !_controller.value.isPlaying)
            const Center(
              child: Icon(
                Icons.play_arrow_rounded,
                size: 80,
                color: Colors.white,
              ),
            ),
        ],
      ),
    );
  }

  String _formatSpeedLabel(double s) {
    if ((s - s.roundToDouble()).abs() < 1e-6) {
      return '${s.round()}x';
    }
    return '${s}x';
  }

  Future<void> _applyPlaybackSpeed(double speed) async {
    if (!_controller.value.isInitialized) return;
    try {
      await _controller.setPlaybackSpeed(speed);
    } catch (_) {}
    if (!mounted) return;
    try {
      _appliedPlaybackSpeed = _controller.value.playbackSpeed;
    } catch (_) {
      _appliedPlaybackSpeed = speed;
    }
    setState(() {});
  }

  Future<void> _cycleClearModeSpeed() async {
    final list = kVideoFeedPlaybackSpeedSteps;
    final i = list.indexWhere((e) => (e - _appliedPlaybackSpeed).abs() < 0.001);
    final idx = i < 0 ? 0 : i;
    final next = list[(idx + 1) % list.length];
    await _applyPlaybackSpeed(next);
  }

  void _seekClearBarToDx(double dx, double width) {
    final d = feedVideoDurationFromLocalDx(
      dx,
      width,
      3.h,
      _controller.value.duration,
    );
    _controller.seekTo(d).then((_) {
      if (!mounted) return;
      if (_wasPlayingWhenScrubStarted && !_controller.value.isPlaying) {
        _controller.play();
      }
      setState(() {});
    });
  }

  Widget _clearChromeCloseSquare() {
    final r = BorderRadius.circular(10.r);
    return SizedBox(
      width: _clearChromeHitExtent,
      height: _clearChromeHitExtent,
      child: Material(
        color: _kClearChromeSurface,
        borderRadius: r,
        child: InkWell(
          onTap: () => _applyClearPlaybackChrome(false),
          borderRadius: r,
          child: Icon(
            Icons.close_rounded,
            color: Colors.white,
            size: 21.sp,
          ),
        ),
      ),
    );
  }

  Widget _clearChromePlaySpeedPill(bool playingNow) {
    final r = BorderRadius.circular(10.r);
    return SizedBox(
      height: _clearChromeHitExtent,
      child: Material(
        color: _kClearChromeSurface,
        borderRadius: r,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            InkWell(
              borderRadius: BorderRadius.horizontal(left: Radius.circular(10.r)),
              onTap: togglePlay,
              child: SizedBox(
                height: _clearChromeHitExtent,
                width: 44.w,
                child: Icon(
                  playingNow ? Icons.pause_rounded : Icons.play_arrow_rounded,
                  color: Colors.white,
                  size: 24.sp,
                ),
              ),
            ),
            SizedBox(
              height: 16.h,
              child: VerticalDivider(
                width: 1.w,
                thickness: 1,
                color: Colors.white.withValues(alpha: 0.28),
              ),
            ),
            InkWell(
              borderRadius:
                  BorderRadius.horizontal(right: Radius.circular(10.r)),
              onTap: () {
                _cycleClearModeSpeed();
              },
              child: Padding(
                padding: EdgeInsets.only(left: 8.w, right: 14.w),
                child: Center(
                  child: Text(
                    _formatSpeedLabel(_appliedPlaybackSpeed),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13.5.sp,
                      fontWeight: FontWeight.w600,
                      height: 1.0,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClearModeThinProgressInner(double trackWidth) {
    final dur = _controller.value.duration;
    final pos = _controller.value.position;
    final totalMs = dur.inMilliseconds;
    final t =
        totalMs > 0 ? (pos.inMilliseconds / totalMs).clamp(0.0, 1.0) : 0.0;

    final h = 2.5.h;
    return ClipRRect(
      borderRadius: BorderRadius.circular(1.5.r),
      child: SizedBox(
        height: h,
        width: trackWidth,
        child: Stack(
          fit: StackFit.expand,
          children: [
            ColoredBox(
              color: Colors.white.withValues(alpha: 0.22),
            ),
            FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: t,
              heightFactor: 1,
              child: const ColoredBox(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClearModeBottomChrome(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    final playingNow = _controller.value.isPlaying;
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0x00000000),
            Color(0x66000000),
          ],
        ),
      ),
      child: Padding(
        padding: EdgeInsets.only(
          left: 12.w,
          right: 12.w,
          top: 10.h,
          bottom: bottomInset + 10.h,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _clearChromeCloseSquare(),
            SizedBox(width: 10.w),
            Expanded(
              child: SizedBox(
                height: math.max(_clearChromeHitExtent, 40.h),
                child: LayoutBuilder(
                  builder: (context, c) {
                    final trackW = c.maxWidth;
                    return Listener(
                      behavior: HitTestBehavior.opaque,
                      onPointerDown: (e) {
                        _wasPlayingWhenScrubStarted =
                            _controller.value.isPlaying;
                        _clearBarScrubbing = true;
                        setState(() {});
                        _syncFeedScrubbingOverlayNotifier();
                        _seekClearBarToDx(e.localPosition.dx, trackW);
                      },
                      onPointerMove: (e) {
                        if (!_clearBarScrubbing) return;
                        _seekClearBarToDx(e.localPosition.dx, trackW);
                      },
                      onPointerUp: (_) {
                        _clearBarScrubbing = false;
                        setState(() {});
                        _syncFeedScrubbingOverlayNotifier();
                      },
                      onPointerCancel: (_) {
                        _clearBarScrubbing = false;
                        setState(() {});
                        _syncFeedScrubbingOverlayNotifier();
                      },
                      child: Align(
                        alignment: Alignment.center,
                        child: _buildClearModeThinProgressInner(trackW),
                      ),
                    );
                  },
                ),
              ),
            ),
            SizedBox(width: 10.w),
            _clearChromePlaySpeedPill(playingNow),
          ],
        ),
      ),
    );
  }

  void _seekToLocalDx(double dx, double width) {
    final d = feedVideoDurationFromLocalDx(
      dx,
      width,
      _barHeight,
      _controller.value.duration,
    );
    _controller.seekTo(d).then((_) {
      if (!mounted) return;
      if (_wasPlayingWhenScrubStarted && !_controller.value.isPlaying) {
        _controller.play();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      clipBehavior: Clip.none,
      children: [
        Positioned.fill(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final box = Size(constraints.maxWidth, constraints.maxHeight);
              final showPill = _controller.value.isInitialized &&
                  _isLandscapeVideo() &&
                  !_immersivePlaybackTrim;
              final pillTop = showPill
                  ? _landscapeContainRect(box).bottom + 8.h
                  : 0.0;

              return Stack(
                fit: StackFit.expand,
                children: [
                  TikTokVideoGesture(
                    onSingleTap: _handleVideoTap,
                    onDoubleTapLike: widget.onDoubleTapLike,
                    onLongPress: _openLongPressSheet,
                    child: SizedBox.expand(child: _buildVideoBody(box)),
                  ),
                  if (showPill)
                    Positioned(
                      left: 0,
                      right: 0,
                      top: pillTop,
                      child: Center(child: _fullScreenWatchChip()),
                    ),
                ],
              );
            },
          ),
        ),
        if (_controller.value.isInitialized && !_clearPlaybackChrome)
          Positioned(
            left: 0,
            right: 0,
            bottom: -widget.progressBarBottomOffset,
            child: MouseRegion(
              onEnter: (_) {
                setState(() => _mouseInsideProgressZone = true);
                _syncFeedScrubbingOverlayNotifier();
              },
              onExit: (_) {
                setState(() => _mouseInsideProgressZone = false);
                _syncFeedScrubbingOverlayNotifier();
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOutCubic,
                height: _progressTouchZoneHeight,
                width: double.infinity,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final w = constraints.maxWidth;
                    return RawGestureDetector(
                      behavior: HitTestBehavior.opaque,
                      gestures: <Type, GestureRecognizerFactory>{
                        FeedVideoProgressZoneHorizontalDragRecognizer:
                            GestureRecognizerFactoryWithHandlers<
                              FeedVideoProgressZoneHorizontalDragRecognizer
                            >(FeedVideoProgressZoneHorizontalDragRecognizer.new, (
                              FeedVideoProgressZoneHorizontalDragRecognizer instance,
                            ) {
                              instance
                                ..onStart = (_) {}
                                ..onUpdate = (_) {}
                                ..onEnd = (_) {}
                                ..onCancel = () {};
                            }),
                      },
                      child: Listener(
                        behavior: HitTestBehavior.opaque,
                        onPointerDown: (e) {
                          _wasPlayingWhenScrubStarted =
                              _controller.value.isPlaying;
                          _touchingProgressZone = true;
                          setState(() {});
                          _syncFeedScrubbingOverlayNotifier();
                          _seekToLocalDx(e.localPosition.dx, w);
                        },
                        onPointerMove: (e) {
                          if (!_touchingProgressZone) return;
                          _seekToLocalDx(e.localPosition.dx, w);
                        },
                        onPointerUp: (_) {
                          _touchingProgressZone = false;
                          setState(() {});
                          _syncFeedScrubbingOverlayNotifier();
                        },
                        onPointerCancel: (_) {
                          _touchingProgressZone = false;
                          setState(() {});
                          _syncFeedScrubbingOverlayNotifier();
                        },
                        child: Align(
                          alignment: Alignment.bottomCenter,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              if (_progressBarExpanded) ...[
                                FeedVideoProgressTimeLabel(
                                  position: _controller.value.position,
                                  total: _controller.value.duration,
                                  style: TextStyle(fontSize: 18.sp)
                                      .merge(widget.progressTimeLabelStyle),
                                ),
                                SizedBox(height: 20.h),
                              ],
                              IgnorePointer(
                                child: ProgressBar(
                                  progress: _controller.value.position,
                                  total: _controller.value.duration,
                                  barHeight: _barHeight,
                                  thumbRadius: _thumbRadius,
                                  timeLabelLocation: TimeLabelLocation.none,
                                  baseBarColor: Colors.grey.withValues(
                                    alpha: 0.3,
                                  ),
                                  progressBarColor: Colors.white,
                                  bufferedBarColor: Colors.white30,
                                  thumbColor: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        if (_controller.value.isInitialized && _clearPlaybackChrome)
          Positioned(
            left: 0,
            right: 0,
            bottom: -widget.progressBarBottomOffset,
            child: _buildClearModeBottomChrome(context),
          ),
      ],
    );
  }
}
