import 'dart:async';

import 'dart:math' show max;

import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:bilbili_project/components/expandable_text.dart';
import 'package:bilbili_project/pages/Home/comps/feed_video_progress_utils.dart';
import 'package:bilbili_project/utils/NumberUtils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:video_player/video_player.dart';

/// 横屏全屏页顶部 / 底部展示用的作品与互动数据（与 Feed 条一致）。
class LandscapeFeedSocialMeta {
  const LandscapeFeedSocialMeta({
    required this.title,
    required this.author,
    required this.initialLikeCount,
    required this.commentCount,
    required this.initialCollectCount,
    this.avatarAssetPath = 'lib/assets/avatar.webp',
  });

  final String title;
  final String author;
  final int initialLikeCount;
  final int commentCount;
  final int initialCollectCount;
  final String avatarAssetPath;

  static LandscapeFeedSocialMeta fallback() => const LandscapeFeedSocialMeta(
        title: '视频',
        author: '@用户',
        initialLikeCount: 0,
        commentCount: 0,
        initialCollectCount: 0,
      );
}

/// 退出横屏全屏时带回竖屏 [CustomVideoPlayer]，用于恢复进度与播放状态。
class LandscapeFeedVideoExit {
  const LandscapeFeedVideoExit({
    required this.position,
    required this.wasPlaying,
    required this.playbackSpeed,
    required this.volume,
  });

  final Duration position;
  final bool wasPlaying;
  final double playbackSpeed;
  final double volume;
}

/// 首页横屏视频「全屏观看」：复用 Feed 同一个控制器 + 抖音式横屏控件。
/// 仅通过竖屏「全屏观看」按钮进入；左上角返回回到竖屏 Feed。
class LandscapeFeedVideoPage extends StatefulWidget {
  const LandscapeFeedVideoPage({
    super.key,
    required this.controller,
    this.meta,
    this.onExitPortrait,
  });

  final VideoPlayerController controller;
  final LandscapeFeedSocialMeta? meta;

  /// 页面销毁时（含返回）把当前进度与播放状态回传给竖屏。
  final void Function(LandscapeFeedVideoExit exit)? onExitPortrait;

  @override
  State<LandscapeFeedVideoPage> createState() => _LandscapeFeedVideoPageState();
}

class _LandscapeFeedVideoPageState extends State<LandscapeFeedVideoPage>
    with TickerProviderStateMixin {
  late final VideoPlayerController _controller;

  late final AnimationController _speedPanelAnim;
  late final Animation<Offset> _speedPanelSlide;

  /// 锁屏：先淡出音量钮，再将锁钮移到竖直居中（0=未锁布局，1=已锁布局）。
  late final AnimationController _lockHudAnim;

  LandscapeFeedSocialMeta get _m =>
      widget.meta ?? LandscapeFeedSocialMeta.fallback();

  bool _followed = false;
  bool _liked = false;
  late int _likeCount;
  bool _collected = false;
  late int _collectCount;

  bool _touchingProgressZone = false;
  bool _mouseInsideProgressZone = false;
  bool _wasPlayingWhenScrubStarted = false;

  bool _brightnessPanel = false;
  /// 1 = 最亮（无压暗），0 = 最暗。
  double _brightnessLevel = 1;

  bool _volumePanel = false;
  double _volumeLevel = 1;

  bool _speedPanel = false;

  bool _gestureLocked = false;
  double _playbackSpeed = 1;

  /// 清屏：仅保留画面（从竖屏「播放中」进全屏时初始为 true）。
  bool _chromeHidden = false;

  /// HUD 可见且正在播放时，无操作 2s 后自动清屏。
  Timer? _idleChromeTimer;

  /// 与 [_onControllerTick] 配合，仅在 [isPlaying] 变化时重置空闲计时。
  bool _idlePlayingTracked = false;

  static const List<double> _speedOptions = [3.0, 2.0, 1.5, 1.25, 1.0, 0.75];

  static const Duration _kChromeIdleHideDuration = Duration(seconds: 2);

  /// 与 [_circleHudButton] 圆形底一致，柱形调节器同宽同色。
  static const Color _kHudCircleSurface = Color.fromRGBO(0, 0, 0, 0.48);

  /// [_lockHudAnim] 前半段用于音量淡出，此后锁钮下移到屏竖直中心。
  static const double _kLockHudFadeOutEnd = 0.38;
  static const Duration _kLockHudAnimDuration = Duration(milliseconds: 720);

  static String _speedLabel(double s) {
    if ((s - 3.0).abs() < 0.001) return '3x';
    if ((s - 2.0).abs() < 0.001) return '2x';
    if ((s - 1.5).abs() < 0.001) return '1.5x';
    if ((s - 1.25).abs() < 0.001) return '1.25x';
    if ((s - 1.0).abs() < 0.001) return '1x';
    if ((s - 0.75).abs() < 0.001) return '0.75x';
    return '${s}x';
  }

  bool get _overlayOpen =>
      _brightnessPanel || _volumePanel || _speedPanel;

  bool get _progressBarExpanded =>
      _touchingProgressZone || _mouseInsideProgressZone;

  double get _barHeight => _progressBarExpanded ? 8.h : 4.h;

  double get _thumbRadius => _progressBarExpanded ? 8.w : 4.w;

  /// 横屏底栏：轨道贴顶，区高度过大会在轨道与下方互动行之间留大片空白，故略小于竖屏 Feed。
  double get _progressTouchZoneHeight => _progressBarExpanded ? 44.h : 28.h;

  /// 横屏下刘海 / 系统栏在左右之间切换时，[MediaQuery.padding] 的 left/right 会互换。
  /// 用两侧 inset 的较大值作为统一左右边距，避免 180° 旋转后 HUD 横向「跳动」。
  static double _landscapeHudSideGutter(MediaQueryData mq) {
    final v = mq.viewPadding;
    return max(v.left, v.right);
  }

  void _dismissOverlays() {
    if (!_overlayOpen) return;
    setState(() {
      _brightnessPanel = false;
      _volumePanel = false;
    });
    if (_speedPanel) _closeSpeedPanel();
    _bumpChromeIdleTimer();
  }

  void _cancelIdleChromeTimer() {
    _idleChromeTimer?.cancel();
    _idleChromeTimer = null;
  }

  /// 有操作时重置：仅在「正在播 + HUD 可见 + 无浮层 + 未锁手势」时启动 2s 自动清屏。
  void _bumpChromeIdleTimer() {
    _cancelIdleChromeTimer();
    if (!_controller.value.isInitialized) return;
    if (!_controller.value.isPlaying ||
        _chromeHidden ||
        _overlayOpen ||
        _gestureLocked ||
        _touchingProgressZone ||
        _mouseInsideProgressZone) {
      return;
    }
    _idleChromeTimer = Timer(_kChromeIdleHideDuration, () {
      if (!mounted) return;
      if (!_controller.value.isInitialized) return;
      if (!_controller.value.isPlaying ||
          _chromeHidden ||
          _overlayOpen ||
          _gestureLocked ||
          _touchingProgressZone ||
          _mouseInsideProgressZone) {
        return;
      }
      setState(() => _chromeHidden = true);
      _idleChromeTimer = null;
    });
  }

  void _onControllerTick() {
    if (!mounted) return;
    final playing = _controller.value.isPlaying;
    if (playing != _idlePlayingTracked) {
      _idlePlayingTracked = playing;
      if (playing) {
        _bumpChromeIdleTimer();
      } else {
        _cancelIdleChromeTimer();
      }
    }
    setState(() {});
  }

  void _openSpeedPanel() {
    _cancelIdleChromeTimer();
    setState(() {
      _speedPanel = true;
      _brightnessPanel = false;
      _volumePanel = false;
    });
    _speedPanelAnim.forward(from: 0);
  }

  void _closeSpeedPanel() {
    if (!_speedPanel) return;
    _cancelIdleChromeTimer();
    _speedPanelAnim.reverse().then((_) {
      if (!mounted) return;
      setState(() => _speedPanel = false);
      _bumpChromeIdleTimer();
    });
  }

  /// 打开亮度 / 音量等互斥浮层时，立刻收起倍速条（不打滑出动画）。
  void _resetSpeedPanelAnim() {
    _speedPanelAnim.stop();
    _speedPanelAnim.reset();
  }

  @override
  void initState() {
    super.initState();
    _speedPanelAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    );
    _speedPanelSlide = Tween<Offset>(
      begin: const Offset(1, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _speedPanelAnim,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    ));
    _lockHudAnim = AnimationController(
      vsync: this,
      duration: _kLockHudAnimDuration,
    )..addListener(() {
        if (mounted) setState(() {});
      });
    _likeCount = _m.initialLikeCount;
    _collectCount = _m.initialCollectCount;
    _controller = widget.controller;
    _playbackSpeed =
        _controller.value.playbackSpeed > 0 ? _controller.value.playbackSpeed : 1;
    _volumeLevel = _controller.value.volume.clamp(0.0, 1.0);
    // 进入全屏时若正在播放，默认直接沉浸清屏；暂停则展示 HUD。
    _chromeHidden = _controller.value.isPlaying;
    _idlePlayingTracked = _controller.value.isPlaying;
    // 全屏页只由用户点「全屏观看」进入：强制横屏（不受系统旋转锁影响）。
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _controller.addListener(_onControllerTick);
  }

  @override
  void dispose() {
    _cancelIdleChromeTimer();
    _controller.removeListener(_onControllerTick);
    widget.onExitPortrait?.call(
      LandscapeFeedVideoExit(
        position: _controller.value.isInitialized
            ? _controller.value.position
            : Duration.zero,
        wasPlaying: _controller.value.isInitialized &&
            _controller.value.isPlaying,
        playbackSpeed: _playbackSpeed,
        volume: _volumeLevel,
      ),
    );
    _speedPanelAnim.dispose();
    _lockHudAnim.dispose();
    // 主界面按竖屏设计：退出后只许竖屏，避免横持设备时整页随系统旋转、布局错位。
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  void _exitToPortraitByBackButton() {
    Navigator.of(context).pop();
  }

  Future<void> _applyVolume(double v) async {
    _volumeLevel = v.clamp(0.0, 1.0);
    try {
      await _controller.setVolume(_volumeLevel);
    } catch (_) {}
    if (mounted) {
      setState(() {});
      _bumpChromeIdleTimer();
    }
  }

  void _togglePlay() {
    if (!_controller.value.isInitialized || _gestureLocked || _overlayOpen) {
      return;
    }
    if (_controller.value.isPlaying) {
      _controller.pause();
    } else {
      _controller.play();
    }
    setState(() {});
    if (_controller.value.isPlaying) {
      _bumpChromeIdleTimer();
    } else {
      _cancelIdleChromeTimer();
    }
  }

  /// 清屏时点击 → 显示 HUD；已显示 HUD 时点击画面 → 切换播放 / 暂停。
  void _onVideoTap() {
    if (_overlayOpen) return;
    if (_gestureLocked) {
      // 锁屏时禁止点画面切播放；清屏下第一次点画面仅唤出 HUD（含右侧锁按钮以便解锁）。
      if (_chromeHidden) {
        setState(() => _chromeHidden = false);
        _bumpChromeIdleTimer();
      }
      return;
    }
    if (_chromeHidden) {
      setState(() => _chromeHidden = false);
      _bumpChromeIdleTimer();
      return;
    }
    _togglePlay();
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

  Future<void> _setSpeed(double s) async {
    _playbackSpeed = s;
    try {
      await _controller.setPlaybackSpeed(s);
    } catch (_) {}
    if (mounted) setState(() {});
  }

  /// 圆形半透明底，避免图标与画面撞色。
  Widget _circleHudButton({
    required Widget icon,
    required VoidCallback onPressed,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        customBorder: const CircleBorder(),
        child: Container(
          width: 48.r,
          height: 48.r,
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: _kHudCircleSurface,
          ),
          child: icon,
        ),
      ),
    );
  }

  /// 竖向胶囊：宽度与 [_circleHudButton] 一致，底色与圆形 HUD 相同。
  Widget _verticalCapsule({
    required double level,
    required ValueChanged<double> onLevelChanged,
    required IconData centerIcon,
    double dragSensitivity = 220,
  }) {
    final w = 70.r;
    final h = 220.h;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onVerticalDragStart: (_) => _bumpChromeIdleTimer(),
      onVerticalDragUpdate: (d) {
        onLevelChanged(
          (level - d.delta.dy / dragSensitivity).clamp(0.0, 1.0),
        );
      },
      onVerticalDragEnd: (_) => _bumpChromeIdleTimer(),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(w / 2),
        child: SizedBox(
          width: w,
          height: h,
          child: Stack(
            fit: StackFit.expand,
            alignment: Alignment.center,
            children: [
              const ColoredBox(color: _kHudCircleSurface),
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  width: w,
                  height: (h * level).clamp(0.0, h),
                  color: Colors.white.withValues(alpha: 0.28),
                ),
              ),
              Icon(centerIcon, color: Colors.white, size: 12.sp),
            ],
          ),
        ),
      ),
    );
  }

  /// 倍速条：极深底，顶满物理右缘与上下（盖住右侧黑边 / 安全区内边）。
  /// 须作为 [Positioned]（带 width、top、bottom）的子使用。
  Widget _speedSidePanel() {
    const accentRed = Color(0xFFFF2D55);
    const panelBg = Color(0xFA000000);

    return MediaQuery.removePadding(
      context: context,
      removeRight: true,
      removeTop: true,
      removeBottom: true,
      child: ColoredBox(
        color: panelBg,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final items = _speedOptions.map((s) {
              final selected = (_playbackSpeed - s).abs() < 0.001;
              final label = _speedLabel(s);
              return InkWell(
                onTap: () {
                  _setSpeed(s);
                  _closeSpeedPanel();
                },
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 18.h, horizontal: 10.w),
                  child: Center(
                    child: Text(
                      label,
                      style: TextStyle(
                        color: selected ? accentRed : Colors.white,
                        fontSize: 8.sp,
                        fontWeight:
                            selected ? FontWeight.w700 : FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              );
            }).toList();
            return NotificationListener<ScrollNotification>(
              onNotification: (n) {
                if (n is ScrollStartNotification ||
                    n is ScrollUpdateNotification) {
                  _bumpChromeIdleTimer();
                }
                return false;
              },
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: items,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _topBar() {
    final titleStyle = TextStyle(
      color: Colors.white,
      fontSize: 8.sp,
      fontWeight: FontWeight.w600,
      shadows: const [Shadow(color: Colors.black54, blurRadius: 4)],
    );
    return Padding(
      padding: EdgeInsets.fromLTRB(0, 0.h, 0.w, 0.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              IconButton(
                padding: EdgeInsets.zero,
                // constraints: BoxConstraints.tightFor(width: 40.w, height: 40.h),
                icon: Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 14.sp),
                onPressed: _exitToPortraitByBackButton,
              ),
              SizedBox(width: 2.w),
              Expanded(
                child: ExpandableText(text: _m.title, style: titleStyle),
              ),
            ],
          ),
          Padding(
            padding: EdgeInsets.only(left: 30.w),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 1.w),
                  ),
                  child: CircleAvatar(
                    radius: 20.r,
                    backgroundImage: AssetImage(_m.avatarAssetPath),
                  ),
                ),
                SizedBox(width: 4.w),
                Flexible(
                  fit: FlexFit.loose,
                  child: Text(
                    _m.author,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 6.sp,
                      fontWeight: FontWeight.w600,
                      shadows: const [
                        Shadow(color: Colors.black54, blurRadius: 4),
                      ],
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
                if (!_followed) ...[
                  SizedBox(width: 4.w),
                  GestureDetector(
                    onTap: () {
                      setState(() => _followed = true);
                      _bumpChromeIdleTimer();
                    },
                    child: Container(
                      padding: EdgeInsets.all(2.r),
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color.fromRGBO(251, 48, 89, 1),
                      ),
                      child: Icon(Icons.add, color: Colors.white, size: 10.sp),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 常态：仅左侧太阳按钮（圆形底）。
  Widget _buildBrightnessEntry() {
    return _circleHudButton(
      icon: Icon(Icons.wb_sunny_outlined, color: Colors.white, size: 10.sp),
      onPressed: () {
        _cancelIdleChromeTimer();
        _resetSpeedPanelAnim();
        setState(() {
          _brightnessPanel = true;
          _volumePanel = false;
          _speedPanel = false;
        });
      },
    );
  }

  void _onGestureLockTap() {
    if (_lockHudAnim.isAnimating) return;
    if (_gestureLocked) {
      setState(() => _gestureLocked = false);
      _bumpChromeIdleTimer();
      _lockHudAnim.reverse();
    } else {
      setState(() {
        _gestureLocked = true;
        _volumePanel = false;
      });
      _cancelIdleChromeTimer();
      _lockHudAnim.forward(from: 0);
    }
  }

  /// 右侧锁 + 音量：锁屏时先淡出音量钮，再将锁钮动画下移到竖直居中。
  Widget _buildVolumeLockColumn() {
    final lockSize = 70.r;
    final gap = 20.h;
    final volSize = 70.r;

    return LayoutBuilder(
      builder: (context, c) {
        final h = c.maxHeight;
        final colH = lockSize + gap + volSize;
        final initialLockTop = (h - colH) / 2;
        final targetLockTop = (h - lockSize) / 2;

        final t = Curves.easeInOut
            .transform(_lockHudAnim.value.clamp(0.0, 1.0));

        final split = _kLockHudFadeOutEnd;
        final double volOpacity;
        final double lockTop;
        if (t <= split) {
          volOpacity = 1 - t / split;
          lockTop = initialLockTop;
        } else {
          volOpacity = 0;
          final u = (t - split) / (1 - split);
          lockTop = initialLockTop + (targetLockTop - initialLockTop) * u;
        }

        final showClosedLock = t > split;

        return Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              top: lockTop,
              left: 0,
              right: 0,
              height: lockSize,
              child: Center(
                child: _circleHudButton(
                  icon: Icon(
                    showClosedLock ? Icons.lock : Icons.lock_open_rounded,
                    color: Colors.white,
                    size: 10.sp,
                  ),
                  onPressed: _onGestureLockTap,
                ),
              ),
            ),
            Positioned(
              top: lockTop + lockSize + gap,
              left: 0,
              right: 0,
              height: volSize,
              child: IgnorePointer(
                ignoring: volOpacity < 0.01,
                child: Opacity(
                  opacity: volOpacity.clamp(0.0, 1.0),
                  child: Center(
                    child: _circleHudButton(
                      icon: Icon(
                        _volumeLevel <= 0.01
                            ? Icons.volume_off_rounded
                            : Icons.volume_up_rounded,
                        color: Colors.white,
                        size: 10.sp,
                      ),
                      onPressed: () {
                        if (_gestureLocked) return;
                        _cancelIdleChromeTimer();
                        _resetSpeedPanelAnim();
                        setState(() {
                          _volumePanel = true;
                          _brightnessPanel = false;
                          _speedPanel = false;
                        });
                      },
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _bottomBar(double landscapeSideGutter) {
    if (!_controller.value.isInitialized) return const SizedBox.shrink();

    // 系统底边 + 真机横屏时 bottom 常全为 0（导航条在左右侧）时的最小下沿间隙。
    final mq = MediaQuery.of(context);
    final systemBottom = max(mq.viewPadding.bottom, mq.padding.bottom);
    final minVisualBottom = 26.h;
    final bottomInset = max(systemBottom, minVisualBottom);

    return Padding(
      padding: EdgeInsets.fromLTRB(
        landscapeSideGutter + 16.w,
        0,
        landscapeSideGutter + 16.w,
        2.h + bottomInset,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: FeedVideoProgressTimeLabel(
              position: _controller.value.position,
              total: _controller.value.duration,
              textAlign: TextAlign.start,
              style: TextStyle(fontSize: 6.sp),
            ),
          ),
          // 与竖屏 Feed 一致：时间紧挨轨道；可拖动区仍用 Stack 在轨道下方留足高度，不把轨道挤离文案。
          SizedBox(height: 2.h),
          MouseRegion(
            onEnter: (_) {
              _cancelIdleChromeTimer();
              setState(() => _mouseInsideProgressZone = true);
            },
            onExit: (_) {
              setState(() => _mouseInsideProgressZone = false);
              _bumpChromeIdleTimer();
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
                    child: Stack(
                      clipBehavior: Clip.none,
                      alignment: Alignment.topCenter,
                      children: [
                        Positioned.fill(
                          child: Listener(
                            behavior: HitTestBehavior.opaque,
                            onPointerDown: (e) {
                              _cancelIdleChromeTimer();
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
                              _bumpChromeIdleTimer();
                            },
                            onPointerCancel: (_) {
                              _touchingProgressZone = false;
                              setState(() {});
                              _bumpChromeIdleTimer();
                            },
                          ),
                        ),
                        // 原先用 bottomCenter 把轨道沉在 48/68h 区底部，和上方时间离得过远；改到顶部紧贴时间行。
                        IgnorePointer(
                          child: ProgressBar(
                            progress: _controller.value.position,
                            total: _controller.value.duration,
                            barHeight: _barHeight,
                            thumbRadius: _thumbRadius,
                            timeLabelLocation: TimeLabelLocation.none,
                            baseBarColor: Colors.grey.withValues(alpha: 0.35),
                            progressBarColor: Colors.white,
                            bufferedBarColor: Colors.white30,
                            thumbColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
          SizedBox(height: 4.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _bottomStat(
                icon: FontAwesomeIcons.solidHeart,
                count: _likeCount,
                label: '点赞',
                color: _liked ? const Color(0xFFFF2D55) : Colors.white,
                onTap: () {
                  setState(() {
                    if (_liked) {
                      _liked = false;
                      if (_likeCount > 0) _likeCount--;
                    } else {
                      _liked = true;
                      _likeCount++;
                    }
                  });
                  _bumpChromeIdleTimer();
                },
              ),
              SizedBox(width: 20.w),
              _bottomStat(
                icon: FontAwesomeIcons.solidStar,
                count: _collectCount,
                label: '收藏',
                color: _collected ? const Color(0xFFFFC94A) : Colors.white,
                onTap: () {
                  setState(() {
                    if (_collected) {
                      _collected = false;
                      if (_collectCount > 0) _collectCount--;
                    } else {
                      _collected = true;
                      _collectCount++;
                    }
                  });
                  _bumpChromeIdleTimer();
                },
              ),
              const Spacer(),
              Padding(
                padding: EdgeInsets.only(bottom: 2.h, right: 4.w),
                child: TextButton(
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  onPressed: () {
                    if (_speedPanel) {
                      _closeSpeedPanel();
                    } else {
                      _openSpeedPanel();
                    }
                  },
                  child: Text(
                    '倍速',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 7.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _bottomStat({
    required IconData icon,
    required int count,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 10.sp),
          SizedBox(width: 2.w),
          Text(
            count <= 0 ? label : NumberUtils.formatLikeCount(count),
            style: TextStyle(
              color: Colors.white,
              fontSize: 6.sp,
              shadows: const [Shadow(color: Colors.black54, blurRadius: 4)],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dim = (1 - _brightnessLevel) * 0.58;
    final mq = MediaQuery.of(context);
    final sideGutter = _landscapeHudSideGutter(mq);

    final body = !_controller.value.isInitialized
        ? const Center(
            child: CircularProgressIndicator(color: Colors.white54),
          )
        : Stack(
            fit: StackFit.expand,
            children: [
              Positioned.fill(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: _overlayOpen ? null : _onVideoTap,
                  child: ColoredBox(
                    color: Colors.black,
                    child: Center(
                      child: AspectRatio(
                        aspectRatio: _controller.value.aspectRatio,
                        child: VideoPlayer(_controller),
                      ),
                    ),
                  ),
                ),
              ),
              Positioned.fill(
                child: IgnorePointer(
                  ignoring: true,
                  child: ColoredBox(
                    color: Colors.black.withValues(alpha: dim),
                  ),
                ),
              ),
              if (_overlayOpen)
                Positioned.fill(
                  child: GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: _dismissOverlays,
                    child: const ColoredBox(color: Colors.transparent),
                  ),
                ),
              if (!_overlayOpen && !_chromeHidden) ...[
                if (!_gestureLocked) ...[
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withValues(alpha: 0.65),
                            Colors.transparent,
                          ],
                        ),
                      ),
                      child: SafeArea(
                        bottom: false,
                        left: false,
                        right: false,
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: sideGutter + 4.w),
                          child: _topBar(),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 0,
                    top: 0,
                    bottom: 0,
                    width: 100.w,
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.only(
                          left: max(0.0, sideGutter - 10.w),
                        ),
                        child: _buildBrightnessEntry(),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            Colors.black.withValues(alpha: 0.72),
                            Colors.transparent,
                          ],
                        ),
                      ),
                      // 底部内边距在 [_bottomBar] 内用 viewPadding 计算，避免仅依赖 padding 在真机为 0。
                      child: _bottomBar(sideGutter),
                    ),
                  ),
                ],
                // 锁屏时仍保留右侧锁 + 音量，便于同一 70.r 按钮上切换关锁图标并解锁。
                Positioned(
                  right: 0,
                  top: 0,
                  bottom: 0,
                  width: 100.w,
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.only(
                        right: max(0.0, sideGutter - 10.w),
                      ),
                      child: _buildVolumeLockColumn(),
                    ),
                  ),
                ),
              ],
              if (_brightnessPanel)
                Positioned(
                  left: 0,
                  top: 0,
                  bottom: 0,
                  width: 100.w,
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.only(
                        left: max(0.0, sideGutter - 10.w),
                      ),
                      child: _verticalCapsule(
                        level: _brightnessLevel,
                        centerIcon: Icons.wb_sunny_outlined,
                        onLevelChanged: (v) {
                          setState(() => _brightnessLevel = v);
                          _bumpChromeIdleTimer();
                        },
                      ),
                    ),
                  ),
                ),
              if (_volumePanel)
                Positioned(
                  right: 0,
                  top: 0,
                  bottom: 0,
                  width: 100.w,
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.only(
                        right: max(0.0, sideGutter - 10.w),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // 与 [_buildVolumeLockColumn] 中锁按钮占位一致，使柱条与音量图标同列对齐。
                          SizedBox(width: 70.r, height: 70.r),
                          SizedBox(height: 20.h),
                          _verticalCapsule(
                            level: _volumeLevel,
                            centerIcon: _volumeLevel <= 0.01
                                ? Icons.volume_off_rounded
                                : Icons.volume_up_rounded,
                            onLevelChanged: (v) {
                              setState(() => _volumeLevel = v);
                              _applyVolume(v);
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              if (_speedPanel)
                Positioned(
                  right: 0,
                  top: 0,
                  bottom: 0,
                  width: 0.24.sw,
                  child: SlideTransition(
                    position: _speedPanelSlide,
                    child: _speedSidePanel(),
                  ),
                ),
              if (!_controller.value.isPlaying &&
                  !_gestureLocked &&
                  !_overlayOpen &&
                  !_chromeHidden)
                IgnorePointer(
                  child: Center(
                    child: Icon(
                      Icons.play_arrow_rounded,
                      size: 88,
                      color: Colors.white.withValues(alpha: 0.82),
                    ),
                  ),
                ),
            ],
          );

    return PopScope(
      canPop: !_overlayOpen && !_chromeHidden,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (_overlayOpen) {
          _dismissOverlays();
          return;
        }
        if (_chromeHidden) {
          setState(() => _chromeHidden = false);
          _bumpChromeIdleTimer();
        }
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: body,
      ),
    );
  }
}
