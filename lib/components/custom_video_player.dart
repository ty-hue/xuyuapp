import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_player/video_player.dart';

class CustomVideoPlayer extends StatefulWidget {
  final String url;

  const CustomVideoPlayer({Key? key, required this.url}) : super(key: key);

  @override
  State<CustomVideoPlayer> createState() => _CustomVideoPlayerState();
}

class _CustomVideoPlayerState extends State<CustomVideoPlayer> {
  late VideoPlayerController _controller;
  bool isPlaying = false;

  @override
  void initState() {
    super.initState();

    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.url))
      ..initialize().then((_) {
        setState(() {});
        _controller.setLooping(true);
        _controller.addListener(() {
          setState(() {});
        });
      });
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
    setState(() {
      isPlaying = _controller.value.isPlaying;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_controller.value.isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }

    return GestureDetector(
      onTap: togglePlay,
      child: Stack(
        alignment: Alignment.center,
        children: [
          AspectRatio(
            aspectRatio: _controller.value.aspectRatio,
            child: VideoPlayer(_controller),
          ),

          // ▶️ 播放按钮（自定义UI）
          if (!_controller.value.isPlaying)
            Icon(Icons.play_arrow, size: 80, color: Colors.white),
          // ⏳ 进度条（自定义）
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: ProgressBar(
              progress: _controller.value.position,
              total: _controller.value.duration,

              onSeek: (duration) {
                _controller.seekTo(duration);
              },
              barHeight: 4.h, // 进度条高度
              thumbRadius: 4.w, // 滑块半径
              timeLabelLocation: TimeLabelLocation.none, // 显示时间标签
              baseBarColor: Colors.grey.withOpacity(0.3),
              progressBarColor: Colors.white,
              bufferedBarColor: Colors.white30,
              thumbColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
