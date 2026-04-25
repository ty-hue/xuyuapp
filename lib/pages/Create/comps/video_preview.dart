import 'dart:async';
import 'dart:io';

import 'package:bilbili_project/components/loading.dart';
import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:video_player/video_player.dart';

/// 相册 [videoData]、本地文件 [videoFilePath]、网络地址 [networkVideoUrl] 三选一（非空者至多一个）。
/// [videoFilePath] 为 null 或空：表示 native 路径尚未就绪，仅在本组件内显示 loading（用于录制结束立刻进预览页）。
/// [onPlaybackReady]：首帧可播放时回调一次，供父级启用「下一步」等。
/// [onVideoPlayerBound]：解码完成并持有 [VideoPlayerController] 时回调；dispose 前回调 `null`。
///
/// 成片预览不使用 Chewie：在 [Positioned.fill] 等强约束下 Chewie 易出现
/// `RenderConstraintsTransformBox` 巨量溢出与缺少 Material 祖先报错。
class VideoPreview extends StatefulWidget {
  final AssetEntity? videoData;
  final String? videoFilePath;
  /// 与本地源互斥；用于创作灵感等网络样片预览。
  final String? networkVideoUrl;
  final VoidCallback? onPlaybackReady;
  final ValueChanged<VideoPlayerController?>? onVideoPlayerBound;

  VideoPreview({
    super.key,
    this.videoData,
    this.videoFilePath,
    this.networkVideoUrl,
    this.onPlaybackReady,
    this.onVideoPlayerBound,
  })  : assert(
          videoData == null || videoFilePath == null,
          'videoData 与 videoFilePath 勿同时传入',
        ),
        assert(
          (networkVideoUrl == null || networkVideoUrl.isEmpty) ||
              (videoData == null &&
                  (videoFilePath == null || videoFilePath.isEmpty)),
          'networkVideoUrl 与本地相册/文件勿同时传入',
        );

  @override
  State<VideoPreview> createState() => _VideoPreviewState();
}

class _VideoPreviewState extends State<VideoPreview> {
  VideoPlayerController? _controller;
  bool _isControllerInitialized = false;
  bool _initStarted = false;
  bool _playbackReadyNotified = false;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  @override
  void didUpdateWidget(covariant VideoPreview oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.videoData == widget.videoData &&
        oldWidget.videoFilePath == widget.videoFilePath &&
        oldWidget.networkVideoUrl == widget.networkVideoUrl) {
      return;
    }
    widget.onVideoPlayerBound?.call(null);
    _controller?.dispose();
    _controller = null;
    _isControllerInitialized = false;
    _initStarted = false;
    _playbackReadyNotified = false;
    _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    if (_initStarted) return;

    final net = widget.networkVideoUrl;
    if (net != null && net.isNotEmpty) {
      _initStarted = true;
      try {
        final controller = VideoPlayerController.networkUrl(Uri.parse(net));
        await controller.initialize();
        if (!mounted) {
          await controller.dispose();
          return;
        }
        controller.setLooping(true);
        unawaited(controller.play());

        setState(() {
          _controller = controller;
          _isControllerInitialized = true;
        });
        widget.onVideoPlayerBound?.call(controller);
        _notifyPlaybackReadyOnce();
      } catch (_) {
        if (mounted) setState(() {});
      }
      return;
    }

    File? file;
    if (widget.videoData != null) {
      _initStarted = true;
      file = await widget.videoData!.file;
    } else {
      final p = widget.videoFilePath;
      if (p == null || p.isEmpty) {
        return;
      }
      _initStarted = true;
      final f = File(p);
      if (await f.exists()) file = f;
    }

    if (file == null || !await file.exists()) {
      if (mounted) setState(() {});
      return;
    }

    try {
      final controller = VideoPlayerController.file(file);
      await controller.initialize();
      if (!mounted) {
        await controller.dispose();
        return;
      }
      controller.setLooping(false);
      unawaited(controller.play());

      setState(() {
        _controller = controller;
        _isControllerInitialized = true;
      });
      widget.onVideoPlayerBound?.call(controller);
      _notifyPlaybackReadyOnce();
    } catch (_) {
      if (mounted) setState(() {});
    }
  }

  void _notifyPlaybackReadyOnce() {
    if (_playbackReadyNotified || !mounted) return;
    _playbackReadyNotified = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) widget.onPlaybackReady?.call();
    });
  }

  void _togglePlay() {
    final c = _controller;
    if (c == null || !c.value.isInitialized) return;
    if (c.value.isPlaying) {
      c.pause();
    } else {
      c.play();
    }
  }

  @override
  void dispose() {
    widget.onVideoPlayerBound?.call(null);
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isControllerInitialized) {
      return const ColoredBox(
        color: Colors.black,
        child: Center(
          child: FetchLoadingView(),
        ),
      );
    }
    final c = _controller;
    if (c == null || !c.value.isInitialized) {
      return const ColoredBox(
        color: Colors.black,
        child: Center(
          child: FetchLoadingView(),
        ),
      );
    }

    final sz = c.value.size;
    final ar = (sz.width > 0 && sz.height > 0)
        ? sz.width / sz.height
        : c.value.aspectRatio;
    final safeAr = (ar.isFinite && ar > 0) ? ar : (16 / 9);

    return Material(
      color: Colors.black,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final maxW = constraints.maxWidth;
          final maxH = constraints.maxHeight;
          if (!maxW.isFinite ||
              !maxH.isFinite ||
              maxW <= 0 ||
              maxH <= 0) {
            return Center(
              child: AspectRatio(
                aspectRatio: safeAr,
                child: VideoPlayer(c),
              ),
            );
          }

          var w = maxW;
          var h = w / safeAr;
          if (h > maxH) {
            h = maxH;
            w = h * safeAr;
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: ListenableBuilder(
                  listenable: c,
                  builder: (context, _) {
                    return Center(
                      child: SizedBox(
                        width: w,
                        height: h,
                        child: ClipRect(
                          child: GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: _togglePlay,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                FittedBox(
                                  fit: BoxFit.contain,
                                  child: SizedBox(
                                    width: sz.width > 0 ? sz.width : w,
                                    height: sz.height > 0 ? sz.height : h,
                                    child: VideoPlayer(c),
                                  ),
                                ),
                                if (!c.value.isPlaying)
                                  DecoratedBox(
                                    decoration: BoxDecoration(
                                      color: Colors.black.withValues(alpha: 0.35),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Padding(
                                      padding: EdgeInsets.all(12),
                                      child: Icon(
                                        Icons.play_arrow_rounded,
                                        color: Colors.white,
                                        size: 48,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              Material(
                color: Colors.black,
                child: SafeArea(
                  top: false,
                  minimum: EdgeInsets.zero,
                  child: VideoProgressIndicator(
                    c,
                    allowScrubbing: true,
                    padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                    colors: const VideoProgressColors(
                      playedColor: Color.fromRGBO(255, 250, 254, 1),
                      bufferedColor: Color(0x44FFFFFF),
                      backgroundColor: Color(0x22FFFFFF),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
