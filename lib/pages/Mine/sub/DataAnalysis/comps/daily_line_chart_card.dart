import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 单月按「日」为横轴的折线图卡片（x 为 0..days-1，对应 1 日..末日）。
class DailyLineChartCard extends StatelessWidget {
  const DailyLineChartCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.spots,
    required this.daysInMonth,
    required this.accent,
    required this.valueUnit,
    this.showZeroReference = false,
    this.summaryLabel,
    this.summaryValue,
  });

  final String title;
  final String subtitle;
  final List<FlSpot> spots;
  final int daysInMonth;
  final Color accent;
  final String valueUnit;
  final bool showZeroReference;
  final String? summaryLabel;
  final String? summaryValue;

  static const _axisLabel = Color(0xFF8B92A8);
  static const _grid = Color(0xFF34384A);

  @override
  Widget build(BuildContext context) {
    if (spots.isEmpty || daysInMonth < 1) {
      return const SizedBox.shrink();
    }

    final maxX = (daysInMonth - 1).toDouble();
    double minY = spots.map((e) => e.y).reduce((a, b) => a < b ? a : b);
    double maxY = spots.map((e) => e.y).reduce((a, b) => a > b ? a : b);
    if (showZeroReference) {
      minY = minY < 0 ? minY : 0;
      maxY = maxY > 0 ? maxY : 0;
    }
    final padY = (maxY - minY).abs() < 1e-6 ? 4.0 : (maxY - minY) * 0.12;
    minY -= padY;
    maxY += padY;
    if (minY == maxY) {
      minY -= 1;
      maxY += 1;
    }

    final lineSpots = spots.length > daysInMonth
        ? spots.sublist(0, daysInMonth)
        : spots;

    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.fromLTRB(18.w, 16.h, 14.w, 12.h),
      decoration: BoxDecoration(
        color: const Color(0xFF252836),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: const Color(0xFF34384A)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.22),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 4.w,
                height: 36.h,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4.r),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [accent, accent.withValues(alpha: 0.35)],
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.2,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: _axisLabel,
                        fontSize: 12.sp,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              if (summaryLabel != null && summaryValue != null)
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1D1F2B),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        summaryLabel!,
                        style: TextStyle(
                          color: _axisLabel,
                          fontSize: 10.sp,
                        ),
                      ),
                      Text(
                        summaryValue!,
                        style: TextStyle(
                          color: accent,
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          SizedBox(height: 8.h),
          SizedBox(
            height: 210.h,
            child: LineChart(
              LineChartData(
                clipData: const FlClipData.all(),
                minX: 0,
                maxX: maxX,
                minY: minY,
                maxY: maxY,
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: true,
                  horizontalInterval: _niceInterval(minY, maxY),
                  verticalInterval: _bottomLabelInterval(daysInMonth),
                  getDrawingHorizontalLine: (_) => FlLine(
                    color: _grid.withValues(alpha: 0.45),
                    strokeWidth: 1,
                  ),
                  getDrawingVerticalLine: (_) => FlLine(
                    color: _grid.withValues(alpha: 0.25),
                    strokeWidth: 1,
                  ),
                ),
                borderData: FlBorderData(show: false),
                extraLinesData: showZeroReference
                    ? ExtraLinesData(
                        horizontalLines: [
                          HorizontalLine(
                            y: 0,
                            color: _axisLabel.withValues(alpha: 0.55),
                            strokeWidth: 1,
                            dashArray: [4, 4],
                          ),
                        ],
                      )
                    : const ExtraLinesData(),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 36.w,
                      interval: _niceInterval(minY, maxY),
                      getTitlesWidget: (v, meta) {
                        if (v < meta.min || v > meta.max) {
                          return const SizedBox.shrink();
                        }
                        return SideTitleWidget(
                          meta: meta,
                          child: Text(
                            _formatYTick(v),
                            style: TextStyle(
                              color: _axisLabel,
                              fontSize: 10.sp,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 26.h,
                      interval: _bottomLabelInterval(daysInMonth),
                      getTitlesWidget: (v, meta) {
                        final day = v.round() + 1;
                        if (day < 1 || day > daysInMonth) {
                          return const SizedBox.shrink();
                        }
                        if ((v - v.round()).abs() > 0.01) {
                          return const SizedBox.shrink();
                        }
                        return SideTitleWidget(
                          meta: meta,
                          child: Text(
                            '$day',
                            style: TextStyle(
                              color: _axisLabel,
                              fontSize: 10.sp,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                lineTouchData: LineTouchData(
                  handleBuiltInTouches: true,
                  touchTooltipData: LineTouchTooltipData(
                    fitInsideHorizontally: true,
                    fitInsideVertically: true,
                    maxContentWidth: 160,
                    tooltipPadding:
                        EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                    tooltipBorderRadius: BorderRadius.circular(10.r),
                    getTooltipColor: (_) =>
                        const Color(0xFF1D1F2B).withValues(alpha: 0.95),
                    getTooltipItems: (touched) {
                      return touched.map((barSpot) {
                        final day = barSpot.x.round() + 1;
                        final y = barSpot.y;
                        final yStr = y == y.roundToDouble()
                            ? y.toInt().toString()
                            : y.toStringAsFixed(1);
                        return LineTooltipItem(
                          '$day日\n$yStr$valueUnit',
                          TextStyle(
                            color: Colors.white,
                            fontSize: 12.sp,
                            height: 1.35,
                            fontWeight: FontWeight.w500,
                          ),
                        );
                      }).toList();
                    },
                  ),
                ),
                lineBarsData: [
                  LineChartBarData(
                    spots: lineSpots,
                    isCurved: true,
                    curveSmoothness: 0.28,
                    preventCurveOverShooting: true,
                    color: accent,
                    barWidth: 2.6,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: !showZeroReference,
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          accent.withValues(alpha: 0.32),
                          accent.withValues(alpha: 0.02),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  static double _niceInterval(double minY, double maxY) {
    final r = maxY - minY;
    if (r <= 0) return 1;
    final rough = r / 4;
    final exp = (math.log(rough) / math.log(10)).floor();
    final frac = rough / math.pow(10.0, exp);
    double nice;
    if (frac <= 1) {
      nice = 1;
    } else if (frac <= 2) {
      nice = 2;
    } else if (frac <= 5) {
      nice = 5;
    } else {
      nice = 10;
    }
    return nice * math.pow(10.0, exp);
  }

  static double _bottomLabelInterval(int days) {
    if (days <= 10) return 1;
    if (days <= 16) return 2;
    if (days <= 24) return 3;
    return 4;
  }

  static String _formatYTick(double v) {
    final a = v.abs();
    if (a >= 1000) return '${(v / 1000).toStringAsFixed(1)}k';
    if (v == v.roundToDouble()) return v.toInt().toString();
    return v.toStringAsFixed(1);
  }
}
