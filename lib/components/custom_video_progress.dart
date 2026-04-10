import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoProgressSlider extends StatefulWidget {
  final VideoPlayerController controller;
  final double defaultHeight;
  final double defaultThumbSize;
  final Color progressColor;
  final Color thumbColor;
  final Color trackColor;
  final double scale;

  const VideoProgressSlider({
    super.key,
    required this.controller,
    this.defaultHeight = 4.0,
    this.defaultThumbSize = 12.0,
    this.scale = 2,
    this.progressColor = const Color(0xFFFE2C55),
    this.thumbColor = Colors.white,
    this.trackColor = const Color(0x66FFFFFF),
  });

  @override
  State<VideoProgressSlider> createState() => _VideoProgressSliderState();
}

class _VideoProgressSliderState extends State<VideoProgressSlider> {
  double _dragValue = 0.0;
  bool _isDragging = false;
  double _thumbSize = 12.0;
  final double _activeThumbSize = 16.0;
  double _currentHeight = 4.0;

  @override
  void initState() {
    super.initState();
    _currentHeight = widget.defaultHeight;
    widget.controller.addListener(_updateProgress);
  }

  void _updateProgress() {
    if (!_isDragging && mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: Container(
        height: 24.0,
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return _buildProgressBar(context, constraints.maxWidth);
          },
        ),
      ),
    );
  }

  Widget _buildProgressBar(BuildContext context, double containerWidth) {
    final duration = widget.controller.value.duration;
    final position = _isDragging ? duration * _dragValue : widget.controller.value.position;
    final progress = duration.inMilliseconds > 0 ? position.inMilliseconds / duration.inMilliseconds : 0.0;

    return Container(
      color: Colors.amber,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (details) => _handleTap(details.globalPosition, containerWidth),
        onHorizontalDragStart: (_) => _startDrag(),
        onHorizontalDragUpdate: (details) => _updateDrag(details.globalPosition, containerWidth),
        onHorizontalDragEnd: (_) => _endDrag(),
        child: Stack(
          alignment: AlignmentDirectional.centerStart,
          children: [
            // 背景轨道
            AnimatedContainer(
              duration: const Duration(milliseconds: 100),
              height: _currentHeight,
              width: containerWidth,
              decoration: BoxDecoration(
                color: widget.trackColor,
                borderRadius: BorderRadius.circular(2.0),
              ),
            ),
            // 已播放进度
            AnimatedContainer(
              duration: const Duration(milliseconds: 0),
              height: _currentHeight,
              width: progress * containerWidth,
              decoration: BoxDecoration(
                color: widget.progressColor,
                borderRadius: BorderRadius.circular(2.0),
              ),
            ),
            // 拖拽圆点
            // if (_isDragging)
            Positioned(
              left: progress * containerWidth - _thumbSize / 2,
              top: (24 - _thumbSize) / 2,
              child: Container(
                width: _thumbSize,
                height: _thumbSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: widget.thumbColor,
                  border: Border.all(color: widget.progressColor, width: 2.0),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 4.0, offset: const Offset(0, 2)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _startDrag() {
    setState(() {
      _isDragging = true;
      _thumbSize = _activeThumbSize;
      _currentHeight = widget.defaultHeight * widget.scale;
      _dragValue = widget.controller.value.position.inMilliseconds / widget.controller.value.duration.inMilliseconds;
    });
  }

  void _endDrag() {
    widget.controller.seekTo(widget.controller.value.duration * _dragValue);
    setState(() {
      _isDragging = false;
      _thumbSize = widget.defaultThumbSize;
      _currentHeight = widget.defaultHeight;
    });
  }

  void _handleTap(Offset globalPosition, double containerWidth) {
    final box = context.findRenderObject() as RenderBox;
    final tapPos = box.globalToLocal(globalPosition);
    final newValue = (tapPos.dx / containerWidth).clamp(0.0, 1.0);
    widget.controller.seekTo(widget.controller.value.duration * newValue);
  }

  void _updateDrag(Offset globalPosition, double containerWidth) {
    final box = context.findRenderObject() as RenderBox;
    final dragPos = box.globalToLocal(globalPosition);
    final newValue = (dragPos.dx / containerWidth).clamp(0.0, 1.0);
    setState(() => _dragValue = newValue);
  }
}

