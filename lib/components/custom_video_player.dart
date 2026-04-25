import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:bilbili_project/components/tiktok_video_gesture.dart';
import 'package:bilbili_project/pages/Home/comps/feed_video_progress_utils.dart';
import 'package:bilbili_project/pages/Home/comps/landscape_feed_video_page.dart';
import 'package:bilbili_project/pages/Home/comps/video_long_press_sheet_skeleton.dart';
import 'package:bilbili_project/utils/SheetUtils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_player/video_player.dart';

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

  /// 进度条展开时「当前/总时长」文案样式，在默认 `12.sp` 基础上合并；不传则与原先 Feed 一致。
  final TextStyle? progressTimeLabelStyle;

  /// 进度条触摸区相对底部 [Stack] 再向下偏移（正值向下，内部用 `Positioned(bottom: -value)`）。
  /// 默认 `0` 不改变布局；需要更贴底时可传 `6.h` 等，由调用方按需传入。
  final double progressBarBottomOffset;

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
  }) : super(key: key);

  @override
  State<CustomVideoPlayer> createState() => _CustomVideoPlayerState();
}

class _CustomVideoPlayerState extends State<CustomVideoPlayer>
    with WidgetsBindingObserver {
  late VideoPlayerController _controller;

  /// 用于检测「竖屏 → 横屏」后自动进全屏；全屏返回后会重置。
  Orientation? _autoFsOrientationBaseline;

  bool _landscapeFullscreenPushInFlight = false;

  /// 触摸：手指在扩大热区内按下未抬起。
  bool _touchingProgressZone = false;

  /// 桌面/Web：指针悬停在扩大热区内。
  bool _mouseInsideProgressZone = false;

  /// 本次按住进度条前视频是否在播；seek 后原生层常会暂停，需按需 `play()` 恢复。
  bool _wasPlayingWhenScrubStarted = false;

  bool get _progressBarExpanded =>
      _touchingProgressZone || _mouseInsideProgressZone;

  double get _barHeight => _progressBarExpanded ? 8.h : 4.h;

  double get _thumbRadius => _progressBarExpanded ? 8.w : 4.w;

  /// 底部可触摸区域高度（含进度条上方空白）；展开时加高以容纳时间文案。
  double get _progressTouchZoneHeight => _progressBarExpanded ? 68.h : 48.h;

  /// 首帧布局后再 play，否则刚初始化时纹理未挂上，`play()` 容易无声失败（冷启动进首页常见）。
  void _schedulePlayIfActive() {
    if (!mounted || !widget.isActive || !_controller.value.isInitialized) {
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !widget.isActive) return;
      _controller.play();
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _autoFsOrientationBaseline = MediaQuery.orientationOf(context);
      }
    });

    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.url))
      ..initialize().then((_) {
        if (!mounted) return;
        _controller.setLooping(true);
        _controller.addListener(() {
          setState(() {});
        });
        // 先触发一帧，让 VideoPlayer 进入树并完成布局，再调度 play。
        setState(() {});
        _schedulePlayIfActive();
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          _autoFsOrientationBaseline = MediaQuery.orientationOf(context);
          _tryEnterFullscreenFromLandscapeRotation();
        });
      });
  }

  @override
  void didUpdateWidget(covariant CustomVideoPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isActive != widget.isActive) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _autoFsOrientationBaseline = MediaQuery.orientationOf(context);
      });
    }
    if (oldWidget.isActive == widget.isActive) return;
    if (!_controller.value.isInitialized) return;
    if (widget.isActive) {
      _schedulePlayIfActive();
    } else {
      _controller.pause();
    }
    setState(() {});
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller.dispose();
    super.dispose();
  }

  @override
  void didChangeMetrics() {
    super.didChangeMetrics();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _tryEnterFullscreenFromLandscapeRotation();
    });
  }

  /// 当前条为横屏片源、且为可见页时，设备从竖屏转到横屏则自动打开全屏（系统未锁旋转时才会收到变化）。
  void _tryEnterFullscreenFromLandscapeRotation() {
    if (!widget.isActive) return;
    if (!_controller.value.isInitialized) return;
    if (!_isLandscapeVideo()) return;
    final route = ModalRoute.of(context);
    if (route == null || !route.isCurrent) return;

    final newO = MediaQuery.orientationOf(context);
    final old = _autoFsOrientationBaseline;
    _autoFsOrientationBaseline = newO;

    if (newO != Orientation.landscape) return;
    if (old != Orientation.portrait) return;

    _openLandscapeFullScreen();
  }

  void togglePlay() {
    if (!_controller.value.isInitialized) return;
    if (_controller.value.isPlaying) {
      _controller.pause();
    } else {
      _controller.play();
    }
    setState(() {});
  }

  void _openLongPressSheet() {
    SheetUtils(
      VideoLongPressSheetSkeleton(),
      deferHeavyChild: false,
    ).openAsyncSheet<void>(context: context);
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
    try {
      final v = _controller.value;
      final initialPosition = v.position;
      final initialPlaying = v.isPlaying;
      final initialSpeed = v.playbackSpeed;
      final initialVolume = v.volume;
      // 避免与全屏内第二个控制器同时出声；全屏会按 initial* 续播或保持暂停。
      await _controller.pause();
      if (!mounted) return;

      LandscapeFeedVideoExit? exitSnapshot;
      // 使用根 Navigator，全屏页盖住整个 Shell（含底部 Tab），与抖音一致。
      await Navigator.of(context, rootNavigator: true).push<void>(
        MaterialPageRoute<void>(
          builder: (ctx) => LandscapeFeedVideoPage(
            url: widget.url,
            meta: widget.landscapeMeta,
            initialPosition: initialPosition,
            initialPlaying: initialPlaying,
            initialPlaybackSpeed: initialSpeed,
            initialVolume: initialVolume,
            onExitPortrait: (exit) => exitSnapshot = exit,
          ),
        ),
      );
      if (!mounted) return;

      final exit = exitSnapshot ??
          LandscapeFeedVideoExit(
            position: initialPosition,
            wasPlaying: initialPlaying,
            playbackSpeed: initialSpeed,
            volume: initialVolume,
          );

      if (_controller.value.isInitialized) {
        final dur = _controller.value.duration;
        var p = exit.position;
        if (dur > Duration.zero && p > dur) p = dur;
        await _controller.seekTo(p);
        try {
          await _controller.setPlaybackSpeed(exit.playbackSpeed);
        } catch (_) {}
        try {
          await _controller.setVolume(exit.volume);
        } catch (_) {}
        if (exit.wasPlaying && widget.isActive) {
          await _controller.play();
        } else {
          await _controller.pause();
        }
        setState(() {});
      } else if (widget.isActive) {
        _schedulePlayIfActive();
      }

      if (mounted) {
        _autoFsOrientationBaseline = MediaQuery.orientationOf(context);
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
            if (!_controller.value.isPlaying)
              Positioned(
                left: r.left,
                top: r.top,
                width: r.width,
                height: r.height,
                child: const Center(
                  child: Icon(Icons.play_arrow, size: 80, color: Colors.white),
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
          if (!_controller.value.isPlaying)
            const Center(
              child: Icon(Icons.play_arrow, size: 80, color: Colors.white),
            ),
        ],
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
                  _isLandscapeVideo();
              final pillTop = showPill
                  ? _landscapeContainRect(box).bottom + 8.h
                  : 0.0;

              return Stack(
                fit: StackFit.expand,
                children: [
                  TikTokVideoGesture(
                    onSingleTap: togglePlay,
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
        if (_controller.value.isInitialized)
          Positioned(
            left: 0,
            right: 0,
            bottom: -widget.progressBarBottomOffset,
            child: MouseRegion(
              onEnter: (_) => setState(() => _mouseInsideProgressZone = true),
              onExit: (_) => setState(() => _mouseInsideProgressZone = false),
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
                          _seekToLocalDx(e.localPosition.dx, w);
                        },
                        onPointerMove: (e) {
                          if (!_touchingProgressZone) return;
                          _seekToLocalDx(e.localPosition.dx, w);
                        },
                        onPointerUp: (_) {
                          _touchingProgressZone = false;
                          setState(() {});
                        },
                        onPointerCancel: (_) {
                          _touchingProgressZone = false;
                          setState(() {});
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
                                  style: TextStyle(fontSize: 12.sp)
                                      .merge(widget.progressTimeLabelStyle),
                                ),
                                SizedBox(height: 6.h),
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
      ],
    );
  }
}
