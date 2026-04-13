import 'dart:math' as math;

import 'package:flutter/material.dart';

/// 视频区手势：单击回调 + 双击在触点出现爱心动效（参考抖音交互）。
class TikTokVideoGesture extends StatefulWidget {
  const TikTokVideoGesture({
    super.key,
    required this.child,
    this.onSingleTap,
    this.onDoubleTapLike,
    this.onLongPress,
  });

  final Widget child;

  /// 单击（播放/暂停等）
  final VoidCallback? onSingleTap;

  /// 双击点赞时回调（更新点赞数等）
  final VoidCallback? onDoubleTapLike;

  /// 长按（如弹出更多操作 sheet）
  final VoidCallback? onLongPress;

  @override
  State<TikTokVideoGesture> createState() => _TikTokVideoGestureState();
}

class _TikTokVideoGestureState extends State<TikTokVideoGesture> {
  final List<_FavoriteBurst> _bursts = [];
  int _nextId = 0;

  void _removeBurst(int id) {
    if (!mounted) return;
    setState(() {
      _bursts.removeWhere((e) => e.id == id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: widget.onSingleTap,
      onLongPress: widget.onLongPress,
      onDoubleTapDown: (details) {
        setState(() {
          _bursts.add(
            _FavoriteBurst(++_nextId, details.localPosition),
          );
        });
        widget.onDoubleTapLike?.call();
      },
      child: Stack(
        clipBehavior: Clip.none,
        fit: StackFit.expand,
        children: [
          widget.child,
          ..._bursts.map(
            (b) => TikTokFavoriteAnimationIcon(
              key: ValueKey<int>(b.id),
              position: b.position,
              onAnimationComplete: () => _removeBurst(b.id),
            ),
          ),
        ],
      ),
    );
  }
}

class _FavoriteBurst {
  _FavoriteBurst(this.id, this.position);

  final int id;
  final Offset position;
}

class TikTokFavoriteAnimationIcon extends StatefulWidget {
  const TikTokFavoriteAnimationIcon({
    super.key,
    required this.position,
    required this.onAnimationComplete,
    this.size = 100,
  });

  final Offset position;
  final double size;
  final VoidCallback onAnimationComplete;

  @override
  State<TikTokFavoriteAnimationIcon> createState() =>
      _TikTokFavoriteAnimationIconState();
}

class _TikTokFavoriteAnimationIconState extends State<TikTokFavoriteAnimationIcon>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  late final double _rotate;

  static const double _appearDuration = 0.1;
  static const double _dismissDuration = 0.8;

  @override
  void initState() {
    super.initState();
    _rotate = math.pi / 10.0 * (2 * math.Random().nextDouble() - 1);
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..addListener(() => setState(() {}));

    _animationController.forward().then((_) {
      if (mounted) widget.onAnimationComplete();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  double get _value => _animationController.value;

  double get _opa {
    final v = _value;
    if (v < _appearDuration) {
      return 0.99 / _appearDuration * v;
    }
    if (v < _dismissDuration) {
      return 0.99;
    }
    final res = 0.99 - (v - _dismissDuration) / (1 - _dismissDuration);
    return res < 0 ? 0 : res;
  }

  double get _scale {
    final v = _value;
    if (v < _appearDuration) {
      return 1 + _appearDuration - v;
    }
    if (v < _dismissDuration) {
      return 1;
    }
    return (v - _dismissDuration) / (1 - _dismissDuration) + 1;
  }

  @override
  Widget build(BuildContext context) {
    final content = ShaderMask(
      blendMode: BlendMode.srcATop,
      shaderCallback: (bounds) => RadialGradient(
        center: Alignment.topLeft + const Alignment(0.66, 0.66),
        colors: const [
          Color(0xffEF6F6F),
          Color(0xffF03E3E),
        ],
      ).createShader(bounds),
      child: Icon(
        Icons.favorite,
        size: widget.size,
        color: Colors.white,
      ),
    );

    final body = Transform.rotate(
      angle: _rotate,
      child: Opacity(
        opacity: _opa,
        child: Transform.scale(
          alignment: Alignment.bottomCenter,
          scale: _scale,
          child: content,
        ),
      ),
    );

    return Positioned(
      left: widget.position.dx - widget.size / 2,
      top: widget.position.dy - widget.size / 2,
      child: body,
    );
  }
}
