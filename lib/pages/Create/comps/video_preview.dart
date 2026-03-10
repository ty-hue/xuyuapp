import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';

class VideoPreview extends StatefulWidget {
  final AssetEntity videoData;

  const VideoPreview({Key? key, required this.videoData}) : super(key: key);

  @override
  _VideoPreviewState createState() => _VideoPreviewState();
}

class _VideoPreviewState extends State<VideoPreview> {
  late VideoPlayerController _controller;
  late ChewieController _chewieController;
  bool _isControllerInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // 使用传递过来的 videoData 初始化播放器
    final videoData = widget.videoData;
    _initializePlayer(videoData);
  }

  // 初始化视频播放器
  Future<void> _initializePlayer(AssetEntity videoFile) async {
    final file = await videoFile.file;
    if (file != null) {
      _controller = VideoPlayerController.file(file);

      // 初始化视频控制器并设置 Chewie 控制器
      await _controller.initialize();

      _chewieController = ChewieController(
        videoPlayerController: _controller,
        autoPlay: true,
        looping: false,
        showOptions: false, // 显示视频选项（旋转、全屏等）
        aspectRatio: _controller.value.aspectRatio,
        showControls: true, // 显示播放控制器（播放、暂停、进度条等）
        allowFullScreen: false, // 允许全屏播放
        allowMuting: false, // 允许静音播放
        allowPlaybackSpeedChanging: false, // 允许调整播放速度
        allowedScreenSleep: false, // 允许屏幕休眠
        materialProgressColors: ChewieProgressColors(
          playedColor: Color.fromRGBO(255,250,254, 1),
          handleColor: Colors.white,
          backgroundColor: Colors.white.withOpacity(0.2),
          bufferedColor: Colors.transparent,
        ),
        placeholder: const Center(child: CircularProgressIndicator()),
        
      );

      // 控制器初始化完成后更新状态
      setState(() {
        _isControllerInitialized = true;
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _chewieController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isControllerInitialized) {
      // 控制器初始化前显示加载指示器
      return const Center(child: CircularProgressIndicator());
    }

    // 控制器初始化后再渲染视频播放器
    return Chewie(controller: _chewieController);
  }
}
