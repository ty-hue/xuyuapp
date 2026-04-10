import 'dart:io';

import 'package:bilbili_project/components/loading.dart';
import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';

/// 相册 [videoData] 或本地文件 [videoFilePath]（二选一）。
/// [videoFilePath] 为 null 或空：表示 native 路径尚未就绪，仅在本组件内显示 loading（用于录制结束立刻进预览页）。
/// [onPlaybackReady]：首帧可播放 UI（Chewie）就绪时回调一次，供父级启用「下一步」等。
class VideoPreview extends StatefulWidget {
  final AssetEntity? videoData;
  final String? videoFilePath;
  final VoidCallback? onPlaybackReady;

  const VideoPreview({
    Key? key,
    this.videoData,
    this.videoFilePath,
    this.onPlaybackReady,
  })  : assert(
          videoData == null || videoFilePath == null,
          'videoData 与 videoFilePath 勿同时传入',
        ),
        super(key: key);

  @override
  _VideoPreviewState createState() => _VideoPreviewState();
}

class _VideoPreviewState extends State<VideoPreview> {
  VideoPlayerController? _controller;
  ChewieController? _chewieController;
  bool _isControllerInitialized = false;
  bool _initStarted = false;
  bool _playbackReadyNotified = false;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    if (_initStarted) return;

    File? file;
    if (widget.videoData != null) {
      _initStarted = true;
      file = await widget.videoData!.file;
    } else {
      final p = widget.videoFilePath;
      if (p == null || p.isEmpty) {
        // 录制刚结束、路径未到：仅展示 loading，等父级 setState 路径后 [Key] 变化会新建 State 再解码
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

      final chewie = ChewieController(
        videoPlayerController: controller,
        autoPlay: true,
        looping: false,
        showOptions: false,
        aspectRatio: controller.value.aspectRatio,
        showControls: true,
        allowFullScreen: false,
        allowMuting: false,
        allowPlaybackSpeedChanging: false,
        allowedScreenSleep: false,
        materialProgressColors: ChewieProgressColors(
          playedColor: const Color.fromRGBO(255, 250, 254, 1),
          handleColor: Colors.white,
          backgroundColor: Colors.white.withValues(alpha: 0.2),
          bufferedColor: Colors.transparent,
        ),
        placeholder: const Center(child: FetchLoadingView()),
      );

      if (!mounted) {
        chewie.dispose();
        await controller.dispose();
        return;
      }

      setState(() {
        _controller = controller;
        _chewieController = chewie;
        _isControllerInitialized = true;
      });
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

  @override
  void dispose() {
    _chewieController?.dispose();
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
    final c = _chewieController;
    if (c == null) {
      return const ColoredBox(
        color: Colors.black,
        child: Center(
          child: FetchLoadingView(),
        ),
      );
    }
    return Chewie(controller: c);
  }
}
