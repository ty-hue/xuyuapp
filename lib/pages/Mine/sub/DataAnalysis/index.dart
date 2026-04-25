import 'package:bilbili_project/components/static_app_bar.dart';
import 'package:bilbili_project/components/with_statusBar_color.dart';
import 'package:bilbili_project/pages/Mine/sub/DataAnalysis/comps/daily_line_chart_card.dart';
import 'package:bilbili_project/pages/Mine/sub/DataAnalysis/data_analysis_demo_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class DataAnalysisPage extends StatefulWidget {
  const DataAnalysisPage({super.key});

  @override
  State<DataAnalysisPage> createState() => _DataAnalysisPageState();
}

class _DataAnalysisPageState extends State<DataAnalysisPage> {
  static const _bg = Color.fromRGBO(29, 31, 43, 1);
  static const _muted = Color(0xFF8B92A8);

  late DateTime _month;

  @override
  void initState() {
    super.initState();
    final n = DateTime.now();
    _month = DateTime(n.year, n.month);
  }

  bool get _canGoNext {
    final now = DateTime.now();
    final cur = DateTime(now.year, now.month);
    return DateTime(_month.year, _month.month).isBefore(cur);
  }

  void _prevMonth() {
    setState(() {
      _month = DateTime(_month.year, _month.month - 1);
    });
  }

  void _nextMonth() {
    if (!_canGoNext) return;
    setState(() {
      _month = DateTime(_month.year, _month.month + 1);
    });
  }

  String _monthTitle() => '${_month.year}年${_month.month}月';

  @override
  Widget build(BuildContext context) {
    final days = DataAnalysisDemoData.daysInMonth(_month.year, _month.month);
    final visits = DataAnalysisDemoData.homepageVisits(_month.year, _month.month);
    final views = DataAnalysisDemoData.workViews(_month.year, _month.month);
    final followers = DataAnalysisDemoData.followerNetChange(_month.year, _month.month);

    final visitSum = DataAnalysisDemoData.sumY(visits).round();
    final viewSum = DataAnalysisDemoData.sumY(views).round();
    final followerNet = DataAnalysisDemoData.sumY(followers).round();

    return WithStatusbarColorView(
      statusBarColor: _bg,
      child: Scaffold(
        backgroundColor: _bg,
        appBar: StaticAppBar(
          statusBarHeight: MediaQuery.of(context).padding.top,
          backgroundColor: _bg,
          title: '数据分析',
        ),
        body: CustomScrollView(
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 4.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '按月查看趋势，轻触折线查看每日数值',
                      style: TextStyle(
                        color: _muted,
                        fontSize: 13.sp,
                        height: 1.4,
                      ),
                    ),
                    SizedBox(height: 16.h),
                    _MonthSwitcher(
                      title: _monthTitle(),
                      canGoNext: _canGoNext,
                      onPrev: _prevMonth,
                      onNext: _nextMonth,
                    ),
                    SizedBox(height: 8.h),
                    _KpiRow(
                      visitSum: visitSum,
                      viewSum: viewSum,
                      followerNet: followerNet,
                    ),
                    SizedBox(height: 8.h),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 28.h),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  DailyLineChartCard(
                    title: '主页访问量',
                    subtitle: '每日访问你主页的人数（演示数据）',
                    spots: visits,
                    daysInMonth: days,
                    accent: const Color(0xFF58A6FF),
                    valueUnit: ' 人',
                    summaryLabel: '本月累计',
                    summaryValue: '$visitSum 人',
                  ),
                  DailyLineChartCard(
                    title: '作品浏览量',
                    subtitle: '每日作品被浏览次数（演示数据）',
                    spots: views,
                    daysInMonth: days,
                    accent: const Color(0xFFC084FC),
                    valueUnit: ' 次',
                    summaryLabel: '本月累计',
                    summaryValue: _formatCount(viewSum),
                  ),
                  DailyLineChartCard(
                    title: '粉丝净变化',
                    subtitle: '每日新增与取关相抵后的净值，虚线为增减平衡线',
                    spots: followers,
                    daysInMonth: days,
                    accent: const Color(0xFF34D399),
                    valueUnit: ' 人',
                    showZeroReference: true,
                    summaryLabel: '本月合计',
                    summaryValue:
                        '${followerNet >= 0 ? '+' : ''}$followerNet 人',
                  ),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _formatCount(int n) {
    if (n >= 10000) return '${(n / 10000).toStringAsFixed(1)} 万';
    return '$n 次';
  }
}

class _MonthSwitcher extends StatelessWidget {
  const _MonthSwitcher({
    required this.title,
    required this.canGoNext,
    required this.onPrev,
    required this.onNext,
  });

  final String title;
  final bool canGoNext;
  final VoidCallback onPrev;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: const Color(0xFF252836),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: const Color(0xFF34384A)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: onPrev,
            icon: Icon(Icons.chevron_left_rounded, size: 28.sp),
            color: Colors.white,
            style: IconButton.styleFrom(
              backgroundColor: Colors.transparent,
              padding: EdgeInsets.all(4.w),
            ),
          ),
          Text(
            title,
            style: TextStyle(
              color: Colors.white,
              fontSize: 17.sp,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
          IconButton(
            onPressed: canGoNext ? onNext : null,
            icon: Icon(Icons.chevron_right_rounded, size: 28.sp),
            color: canGoNext ? Colors.white : const Color(0xFF4A5068),
            style: IconButton.styleFrom(
              backgroundColor: Colors.transparent,
              padding: EdgeInsets.all(4.w),
            ),
          ),
        ],
      ),
    );
  }
}

class _KpiRow extends StatelessWidget {
  const _KpiRow({
    required this.visitSum,
    required this.viewSum,
    required this.followerNet,
  });

  final int visitSum;
  final int viewSum;
  final int followerNet;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _KpiTile(
            label: '主页访问',
            value: '$visitSum',
            unit: '人',
            icon: Icons.person_outline_rounded,
            tint: const Color(0xFF58A6FF),
          ),
        ),
        SizedBox(width: 10.w),
        Expanded(
          child: _KpiTile(
            label: '作品浏览',
            value: viewSum >= 10000
                ? '${(viewSum / 10000).toStringAsFixed(1)}'
                : '$viewSum',
            unit: viewSum >= 10000 ? '万次' : '次',
            icon: Icons.play_circle_outline_rounded,
            tint: const Color(0xFFC084FC),
          ),
        ),
        SizedBox(width: 10.w),
        Expanded(
          child: _KpiTile(
            label: '粉丝净值',
            value: followerNet >= 0 ? '+$followerNet' : '$followerNet',
            unit: '人',
            icon: followerNet >= 0
                ? Icons.trending_up_rounded
                : Icons.trending_down_rounded,
            tint: followerNet >= 0
                ? const Color(0xFF34D399)
                : const Color(0xFFF87171),
          ),
        ),
      ],
    );
  }
}

class _KpiTile extends StatelessWidget {
  const _KpiTile({
    required this.label,
    required this.value,
    required this.unit,
    required this.icon,
    required this.tint,
  });

  final String label;
  final String value;
  final String unit;
  final IconData icon;
  final Color tint;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: const Color(0xFF252836),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: const Color(0xFF34384A)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16.sp, color: tint),
              SizedBox(width: 4.w),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: const Color(0xFF8B92A8),
                    fontSize: 11.sp,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 6.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Flexible(
                child: Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              if (unit.isNotEmpty) ...[
                SizedBox(width: 2.w),
                Text(
                  unit,
                  style: TextStyle(
                    color: const Color(0xFF8B92A8),
                    fontSize: 11.sp,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
