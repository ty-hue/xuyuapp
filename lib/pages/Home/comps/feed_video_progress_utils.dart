import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

/// 与 `audio_video_progress_bar` 无标签、全宽轨道时的比例一致。
Duration feedVideoDurationFromLocalDx(
  double dx,
  double width,
  double barHeight,
  Duration total,
) {
  if (width <= 0 || total.inMilliseconds <= 0) {
    return Duration.zero;
  }
  final cap = barHeight / 2;
  final barStart = cap;
  final barEnd = width - cap;
  final barW = barEnd - barStart;
  if (barW <= 0) return Duration.zero;
  final pos = (dx - barStart).clamp(0.0, barW);
  final t = pos / barW;
  final ms = (t * total.inMilliseconds).round().clamp(
        0,
        total.inMilliseconds,
      );
  return Duration(milliseconds: ms);
}

/// 总时长 ≥1 小时时用 `H:MM:SS`，否则 `MM:SS`。
String feedVideoFormatClock(Duration d, {required bool useHours}) {
  var x = d;
  if (x.isNegative) x = Duration.zero;
  if (!useHours) {
    final secs = x.inSeconds;
    final m = (secs ~/ 60).toString().padLeft(2, '0');
    final s = (secs % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }
  final h = x.inHours;
  final m = x.inMinutes.remainder(60).toString().padLeft(2, '0');
  final s = x.inSeconds.remainder(60).toString().padLeft(2, '0');
  return '$h:$m:$s';
}

String feedVideoProgressTimeLabelText(Duration pos, Duration total) {
  var p = pos;
  if (total > Duration.zero && p > total) p = total;
  final useHours = total.inHours >= 1;
  final a = feedVideoFormatClock(p, useHours: useHours);
  final b = feedVideoFormatClock(total, useHours: useHours);
  return '$a/$b';
}

/// 进度条上方「当前/总时长」文案（与 [feedVideoProgressTimeLabelText] 一致）。
///
/// 通过 [style] 与 [defaultStyle] 合并即可单独调字号等，不影响其他页面。
class FeedVideoProgressTimeLabel extends StatelessWidget {
  const FeedVideoProgressTimeLabel({
    super.key,
    required this.position,
    required this.total,
    this.textAlign = TextAlign.center,
    this.style,
  });

  final Duration position;
  final Duration total;
  final TextAlign textAlign;

  /// 合并到 [defaultStyle] 之上，例如 `TextStyle(fontSize: 9.sp)`。
  final TextStyle? style;

  /// 字重、阴影等默认；字号默认 12（逻辑像素），通常由 [style] 传入 `.sp` 覆盖。
  static TextStyle defaultStyle() => const TextStyle(
        color: Colors.white,
        fontSize: 12,
        fontWeight: FontWeight.w500,
        height: 1.0,
        shadows: [
          Shadow(
            color: Colors.black54,
            blurRadius: 6,
            offset: Offset(0, 1),
          ),
        ],
      );

  @override
  Widget build(BuildContext context) {
    return Text(
      feedVideoProgressTimeLabelText(position, total),
      textAlign: textAlign,
      style: defaultStyle().merge(style),
    );
  }
}

/// 进度条区域水平拖动手势一旦按下即被判定为胜出，避免外层 PageView 抢手势。
final class FeedVideoProgressZoneHorizontalDragRecognizer
    extends HorizontalDragGestureRecognizer {
  @override
  void addAllowedPointer(PointerDownEvent event) {
    super.addAllowedPointer(event);
    resolve(GestureDisposition.accepted);
  }

  @override
  String get debugDescription => 'FeedVideoProgressZoneHorizontalDragRecognizer';
}
