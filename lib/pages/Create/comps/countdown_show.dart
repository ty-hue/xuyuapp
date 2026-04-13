import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
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
  static final AssetSource _tickSound = AssetSource('sounds/count_down.mp3');

  Timer? _timer;
  late int _countdown;
  final AudioPlayer _player = AudioPlayer();

  bool _disposed = false;
  bool _soundReady = false;
  Future<void> _playChain = Future.value();

  @override
  void initState() {
    super.initState();
    _countdown = widget.countdown;
    // 与原先一致：立刻启动周期，避免预加载较慢时数字长时间不动。
    _timer = Timer.periodic(const Duration(seconds: 1), _onTick);
    unawaited(_bootstrap());
  }

  /// 预加载音源，避免每秒 `play(AssetSource)` 重复解码/缓冲造成顿挫。
  Future<void> _bootstrap() async {
    try {
      if (_disposed || !mounted) return;

      await _player.setReleaseMode(ReleaseMode.stop);

      if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
        await _player.setPlayerMode(PlayerMode.lowLatency);
      }

      await _player.setSource(_tickSound);
      if (_disposed || !mounted) return;
      _soundReady = true;
    } catch (_) {
      _soundReady = false;
    }
  }

  void _onTick(Timer timer) {
    if (_countdown <= 0) {
      timer.cancel();
      widget.onCountdownFinished();
      return;
    }
    setState(() {
      _countdown--;
    });
    _playChain = _playChain.then((_) => _triggerTick());
  }

  /// 已缓冲的源上 stop + resume，等价于从头再播，且不会与上一次异步播放叠在一起。
  Future<void> _triggerTick() async {
    if (_disposed || !mounted) return;
    // 预加载未完成时不播，避免与 _bootstrap 里的 setSource 并发。
    if (!_soundReady) return;
    try {
      await _player.stop();
      await _player.resume();
    } catch (_) {
      if (_disposed || !mounted) return;
      try {
        await _player.play(_tickSound);
      } catch (_) {}
    }
  }

  @override
  void dispose() {
    _disposed = true;
    _timer?.cancel();
    unawaited(_player.dispose());
    super.dispose();
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
