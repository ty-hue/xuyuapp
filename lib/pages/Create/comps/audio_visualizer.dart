import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AudioVisualizer extends StatefulWidget {
  final int numberOfBars; // 柱子的数量
  final double minHeight; // 最小高度
  final double maxHeight; // 最大高度
  final Duration duration; // 动画的持续时间

  AudioVisualizer({
    Key? key,
    this.numberOfBars = 3,
    this.minHeight = 0.2,
    this.maxHeight = 1.0,
    this.duration = const Duration(seconds: 2),
  }) : super(key: key);

  @override
  _AudioVisualizerState createState() => _AudioVisualizerState();
}

class _AudioVisualizerState extends State<AudioVisualizer> with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();

    // 创建动画控制器
    _controllers = List.generate(widget.numberOfBars, (index) {
      return AnimationController(
        duration: widget.duration * (index + 1), // 设置不同的动画周期
        vsync: this,
      )..repeat(reverse: true); // 每个柱子的动画都反向重复
    });

    // 创建柱子动画
    _animations = List.generate(widget.numberOfBars, (index) {
      return Tween<double>(
        begin: widget.minHeight,
        end: widget.maxHeight,
      ).animate(
        CurvedAnimation(parent: _controllers[index], curve: Curves.easeInOut),
      );
    });
  }

  @override
  void dispose() {
    // 释放控制器
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: List.generate(widget.numberOfBars, (index) {
        return AnimatedBuilder(
          animation: _animations[index],
          builder: (context, child) {
            return Container(
              width: 3.0.w,
              height: 18.h * _animations[index].value, // 动态调整高度
              margin: EdgeInsets.symmetric(horizontal: 1.0.w),
              color: Color.fromRGBO(254,44,85, 1),
            );
          },
        );
      }),
    );
  }
}