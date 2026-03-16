import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CountdownShow extends StatefulWidget {
  final int countdown;
  // 记时完成后回调
  final VoidCallback onCountdownFinished;
  CountdownShow({Key? key, required this.countdown, required this.onCountdownFinished}) : super(key: key);

  @override
  _CountdownShowState createState() => _CountdownShowState();
}

class _CountdownShowState extends State<CountdownShow> {
  Timer? timer;
  late int _countdown;
    final AudioPlayer _player = AudioPlayer();
    Future<void> _playSound() async {
  await _player.play(AssetSource('sounds/count_down.mp3'));
}
  @override
  void initState() {
    super.initState();
    _countdown = widget.countdown;
    // 倒计时
    timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_countdown <= 0) {
        timer.cancel();
        // 倒计时完成后回调
        widget.onCountdownFinished();
        return;
      }
      setState(() {
        _countdown--;
      });
      // 播放倒计时音效
      _playSound();
    });

  }
  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    timer?.cancel();
    // 释放音效资源
    _player.dispose();
  }
@override
Widget build(BuildContext context) {
  return Center(
    child: AnimatedSwitcher(
      duration: Duration(milliseconds: 300),

      transitionBuilder: (child, animation) {
        return ScaleTransition(
          scale: CurvedAnimation(
            parent: animation,
            curve: Curves.elasticOut,
          ),
          child: child,
        );
      },

      // 关键：不渲染旧child
      layoutBuilder: (currentChild, previousChildren) {
        return currentChild ?? SizedBox();
      },

      child: Text(
        _countdown.toString(),
        key: ValueKey(_countdown),
        style: TextStyle(
          color: Colors.white,
          fontSize: 90.0.sp,
          fontWeight: FontWeight.bold,
          decoration: TextDecoration.none,
        ),
      ),
    ),
  );
}
}