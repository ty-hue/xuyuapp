import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:bilbili_project/components/tiktok_video_gesture.dart';
import 'package:bilbili_project/pages/Home/comps/video_long_press_sheet_skeleton.dart';
import 'package:bilbili_project/utils/SheetUtils.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_player/video_player.dart';

class CustomVideoPlayer extends StatefulWidget {
  final String url;

  /// 是否为当前可见页（如纵向 PageView 里的一条）；为 false 时暂停，为 true 时播放。
  final bool isActive;

  /// 双击视频区域时的回调（如点赞）；爱心动效由内部处理。
  final VoidCallback? onDoubleTapLike;

  const CustomVideoPlayer({
    Key? key,
    required this.url,
    this.isActive = true,
    this.onDoubleTapLike,
  }) : super(key: key);

  @override
  State<CustomVideoPlayer> createState() => _CustomVideoPlayerState();
}

class _CustomVideoPlayerState extends State<CustomVideoPlayer> {
  late VideoPlayerController _controller;

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
      });
  }

  @override
  void didUpdateWidget(covariant CustomVideoPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
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
    _controller.dispose();
    super.dispose();
  }

  void togglePlay() {
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

  /// 与 `audio_video_progress_bar` 无标签、全宽轨道时的比例一致。
  Duration _durationFromLocalDx(double dx, double width, double barHeight) {
    final total = _controller.value.duration;
    if (width <= 0 || total.inMilliseconds <= 0) {
      return Duration.zero;
    }
    final cap = barHeight / 2;
    final barStart = cap;
    final barEnd = width - cap;
    final barW = barEnd - barStart;
    if (barW <= 0) return Duration.zero;
    final pos = (dx - barStart).clamp(0.0, barW);
    final t = pos / barW;
    final ms = (t * total.inMilliseconds).round().clamp(
      0,
      total.inMilliseconds,
    );
    return Duration(milliseconds: ms);
  }

  void _seekToLocalDx(double dx, double width) {
    final d = _durationFromLocalDx(dx, width, _barHeight);
    _controller.seekTo(d).then((_) {
      if (!mounted) return;
      if (_wasPlayingWhenScrubStarted && !_controller.value.isPlaying) {
        _controller.play();
      }
    });
  }

  /// 总时长 ≥1 小时时用 `H:MM:SS`，否则 `MM:SS`（与两侧一致，便于对齐阅读）。
  static String _formatClock(Duration d, {required bool useHours}) {
    var x = d;
    if (x.isNegative) x = Duration.zero;
    if (!useHours) {
      final secs = x.inSeconds;
      final m = (secs ~/ 60).toString().padLeft(2, '0');
      final s = (secs % 60).toString().padLeft(2, '0');
      return '$m:$s';
    }
    final h = x.inHours;
    final m = x.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = x.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  String _progressTimeLabelText() {
    var pos = _controller.value.position;
    final total = _controller.value.duration;
    if (total > Duration.zero && pos > total) pos = total;
    final useHours = total.inHours >= 1;
    final a = _formatClock(pos, useHours: useHours);
    final b = _formatClock(total, useHours: useHours);
    return '$a/$b';
  }

  @override
  Widget build(BuildContext context) {
    if (!_controller.value.isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }

    return TikTokVideoGesture(
      onSingleTap: togglePlay,
      onDoubleTapLike: widget.onDoubleTapLike,
      onLongPress: _openLongPressSheet,
      child: SizedBox.expand(
        child: Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                AspectRatio(
                  aspectRatio: _controller.value.aspectRatio,
                  child: VideoPlayer(_controller),
                ),
                if (!_controller.value.isPlaying)
                  const Icon(Icons.play_arrow, size: 80, color: Colors.white),
              ],
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
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
                      // 进度区水平拖动手势在竞技场中立即胜出，避免外层 TabBarView/PageView 左滑切 Tab。
                      return RawGestureDetector(
                        behavior: HitTestBehavior.opaque,
                        gestures: <Type, GestureRecognizerFactory>{
                          _ProgressZoneHorizontalDragRecognizer:
                              GestureRecognizerFactoryWithHandlers<
                                _ProgressZoneHorizontalDragRecognizer
                              >(_ProgressZoneHorizontalDragRecognizer.new, (
                                _ProgressZoneHorizontalDragRecognizer instance,
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
                                  Text(
                                    _progressTimeLabelText(),
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12.sp,
                                      fontWeight: FontWeight.w500,
                                      height: 1.0,
                                      shadows: const [
                                        Shadow(
                                          color: Colors.black54,
                                          blurRadius: 6,
                                          offset: Offset(0, 1),
                                        ),
                                      ],
                                    ),
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
        ),
      ),
    );
  }
}

/// 与 `audio_video_progress_bar` 包相同思路：水平拖动手势一旦按下即被判定为胜出，
/// 从而不会把左/右滑交给外层的 TabBar、PageView 等。
final class _ProgressZoneHorizontalDragRecognizer
    extends HorizontalDragGestureRecognizer {
  @override
  void addAllowedPointer(PointerDownEvent event) {
    super.addAllowedPointer(event);
    resolve(GestureDisposition.accepted);
  }

  @override
  String get debugDescription => '_ProgressZoneHorizontalDragRecognizer';
}
