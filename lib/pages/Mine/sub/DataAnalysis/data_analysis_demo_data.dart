import 'dart:math';

import 'package:fl_chart/fl_chart.dart';

/// 演示用日维度数据。接入后端后改为接口返回的 `List<DailyStat>` 再转成 [FlSpot]。
class DataAnalysisDemoData {
  DataAnalysisDemoData._();

  static int daysInMonth(int year, int month) =>
      DateTime(year, month + 1, 0).day;

  static List<FlSpot> homepageVisits(int year, int month) {
    final days = daysInMonth(year, month);
    final r = Random(year * 10000 + month * 100 + 11);
    return List.generate(
      days,
      (i) => FlSpot(i.toDouble(), (8 + r.nextDouble() * 42).roundToDouble()),
    );
  }

  static List<FlSpot> workViews(int year, int month) {
    final days = daysInMonth(year, month);
    final r = Random(year * 10000 + month * 100 + 22);
    return List.generate(
      days,
      (i) => FlSpot(i.toDouble(), (120 + r.nextDouble() * 880).roundToDouble()),
    );
  }

  /// 每日净增粉丝（可为负）。
  static List<FlSpot> followerNetChange(int year, int month) {
    final days = daysInMonth(year, month);
    final r = Random(year * 10000 + month * 100 + 33);
    return List.generate(days, (i) {
      final v = (r.nextDouble() * 24 - 8).roundToDouble();
      return FlSpot(i.toDouble(), v);
    });
  }

  static double sumY(List<FlSpot> spots) =>
      spots.fold<double>(0, (a, s) => a + s.y);
}
