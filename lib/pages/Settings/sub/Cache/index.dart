import 'dart:async';

import 'package:bilbili_project/components/appBar_back_icon_btn.dart';
import 'package:bilbili_project/components/static_app_bar.dart';
import 'package:bilbili_project/components/with_statusBar_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

String _formatBytes(int bytes) {
  if (bytes <= 0) return '0KB';
  final kb = bytes / 1024;
  if (kb < 1024) return '${kb.toStringAsFixed(1)}KB';
  final mb = kb / 1024;
  if (mb < 1024) return '${mb.toStringAsFixed(1)}MB';
  final gb = mb / 1024;
  return '${gb.toStringAsFixed(1)}GB';
}

/// 清理缓存：进入后先「扫描计算」，完成后展示用量与分项；清理前二次确认。
class CachePage extends StatefulWidget {
  const CachePage({super.key});

  @override
  State<CachePage> createState() => _CachePageState();
}

class _CachePageState extends State<CachePage> {
  static const Color _pageBg = Color(0xFFF5F5F5);
  static const Color _textPrimary = Color(0xFF161823);

  bool _scanning = true;
  double _scanProgress = 0;
  Timer? _scanTimer;
  late _CacheSummary _summary;

  @override
  void initState() {
    super.initState();
    _summary = _CacheSummary.demo();
    _startScanAnimation();
  }

  void _startScanAnimation() {
    _scanTimer?.cancel();
    setState(() {
      _scanning = true;
      _scanProgress = 0;
    });
    const totalMs = 2400;
    const tick = 50;
    var elapsed = 0;
    _scanTimer = Timer.periodic(const Duration(milliseconds: tick), (t) {
      elapsed += tick;
      if (!mounted) return;
      if (elapsed >= totalMs) {
        t.cancel();
        setState(() {
          _scanning = false;
          _scanProgress = 1;
        });
        return;
      }
      setState(() {
        _scanProgress = (elapsed / totalMs).clamp(0.0, 1.0);
      });
    });
  }

  @override
  void dispose() {
    _scanTimer?.cancel();
    super.dispose();
  }

  int get _percentLabel => (_scanProgress * 100).floor().clamp(0, 99);

  void _onClearCacheTap() {
    final release = _formatBytes(_summary.cacheBytes);
    showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => _ClearCacheConfirmDialog(
        releaseText: release,
        onCancel: () => Navigator.of(ctx).pop(),
        onConfirm: () {
          Navigator.of(ctx).pop();
          setState(() {
            _summary = _summary.afterClearCache();
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '已清理絮语缓存',
                style: TextStyle(fontSize: 14.sp),
              ),
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.paddingOf(context).top;
    return WithStatusbarColorView(
      statusBarColor: Colors.white,
      child: Scaffold(
        backgroundColor: _pageBg,
        appBar: StaticAppBar(
          statusBarHeight: topPad,
          backgroundColor: Colors.white,
          title: '清理缓存',
          titleColor: _textPrimary,
          titleFontWeight: FontWeight.w600,
          leadingChild: BackIconBtn(
            color: _textPrimary,
            icon: Icons.arrow_back_ios_new,
            size: 18,
          ),
        ),
        body: ListView(
          padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 24.h),
          children: [
            _StorageSummaryCard(
              scanning: _scanning,
              scanProgress: _scanProgress,
              scanPercentLabel: _percentLabel,
              summary: _summary,
            ),
            SizedBox(height: 12.h),
            if (_scanning)
              const _BottomLoadingCard()
            else
              _CacheDetailCard(
                summary: _summary,
                onClearCache: _onClearCacheTap,
              ),
          ],
        ),
      ),
    );
  }
}

class _CacheSummary {
  const _CacheSummary({
    required this.appTotalBytes,
    required this.deviceAppPercent,
    required this.barAppFraction,
    required this.barDeviceUsedFraction,
    required this.barFreeFraction,
    required this.cacheBytes,
    required this.offlineBytes,
    required this.draftCount,
    required this.draftBytes,
    required this.chatBytes,
    required this.essentialBytes,
  });

  final int appTotalBytes;
  final int deviceAppPercent;
  final double barAppFraction;
  final double barDeviceUsedFraction;
  final double barFreeFraction;
  final int cacheBytes;
  final int offlineBytes;
  final int draftCount;
  final int draftBytes;
  final int chatBytes;
  final int essentialBytes;

  factory _CacheSummary.demo() {
    return _CacheSummary(
      appTotalBytes: (2.3 * 1024 * 1024 * 1024).round(),
      deviceAppPercent: 4,
      barAppFraction: 0.04,
      barDeviceUsedFraction: 0.52,
      barFreeFraction: 0.44,
      cacheBytes: (612.0 * 1024 * 1024).round(),
      offlineBytes: 0,
      draftCount: 0,
      draftBytes: 0,
      chatBytes: (11.1 * 1024 * 1024).round(),
      essentialBytes: (1.7 * 1024 * 1024 * 1024).round(),
    );
  }

  _CacheSummary afterClearCache() {
    final cleared = cacheBytes;
    return _CacheSummary(
      appTotalBytes: (appTotalBytes - cleared).clamp(0, 1 << 40),
      deviceAppPercent: deviceAppPercent,
      barAppFraction: barAppFraction,
      barDeviceUsedFraction: barDeviceUsedFraction,
      barFreeFraction: barFreeFraction,
      cacheBytes: 0,
      offlineBytes: offlineBytes,
      draftCount: draftCount,
      draftBytes: draftBytes,
      chatBytes: chatBytes,
      essentialBytes: essentialBytes,
    );
  }
}

/// 顶部横向「设备存储」条：红 = App，蓝 = 设备已用，灰 = 可用。
/// 用 [LinearGradient] 硬色阶绘制，避免 Row/Expanded 在窄约束下高度为 0 或浅灰条在白底上「看不见」。
class _DeviceStorageStrip extends StatelessWidget {
  const _DeviceStorageStrip({
    required this.scanT,
    required this.appFraction,
    required this.deviceUsedFraction,
    required this.red,
    required this.blue,
    required this.freeGray,
  });

  /// 0~1：扫描中随进度展开；完成后为 1。
  final double scanT;
  final double appFraction;
  final double deviceUsedFraction;
  final Color red;
  final Color blue;
  final Color freeGray;

  @override
  Widget build(BuildContext context) {
    final t = scanT.clamp(0.0, 1.0);
    final p1 = (appFraction * t).clamp(0.0, 1.0);
    final p2 = (p1 + deviceUsedFraction * t).clamp(0.0, 1.0);
    final safeP2 = p2 <= p1 ? (p1 + 1e-6).clamp(0.0, 1.0) : p2;

    final track = const Color(0xFFECECEC);

    if (t < 1e-5) {
      return DecoratedBox(
        decoration: BoxDecoration(
          color: track,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: const Color(0xFFD8D8D8)),
        ),
      );
    }

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: const Color(0xFFD8D8D8)),
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            red,
            red,
            blue,
            blue,
            freeGray,
            freeGray,
          ],
          stops: [
            0,
            p1,
            p1,
            safeP2,
            safeP2,
            1,
          ],
        ),
      ),
    );
  }
}

class _StorageSummaryCard extends StatelessWidget {
  const _StorageSummaryCard({
    required this.scanning,
    required this.scanProgress,
    required this.scanPercentLabel,
    required this.summary,
  });

  final bool scanning;
  final double scanProgress;
  final int scanPercentLabel;
  final _CacheSummary summary;

  static const Color _red = Color(0xFFFE2C55);
  static const Color _blue = Color(0xFF4A90D9);
  /// 与色条「可用」段一致，在白底上仍可辨认。
  static const Color _barFree = Color(0xFFC9CED6);
  static const Color _textPrimary = Color(0xFF161823);
  static const Color _textSecondary = Color(0xFF73747A);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 18.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: double.infinity,
            height: 12,
            child: _DeviceStorageStrip(
              scanT: scanning ? scanProgress : 1.0,
              appFraction: summary.barAppFraction,
              deviceUsedFraction: summary.barDeviceUsedFraction,
              red: _red,
              blue: _blue,
              freeGray: _barFree,
            ),
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              _LegendDot(color: _red, label: 'App 已用空间'),
              SizedBox(width: 16.w),
              _LegendDot(color: _blue, label: '设备已用空间'),
              SizedBox(width: 16.w),
              _LegendDot(color: _barFree, label: '设备可用空间'),
            ],
          ),
          SizedBox(height: 18.h),
          Text(
            '絮语已用空间',
            style: TextStyle(
              fontSize: 13.sp,
              color: _textSecondary,
              height: 1.3,
            ),
          ),
          SizedBox(height: 6.h),
          if (scanning) ...[
            Text(
              '正在计算 $scanPercentLabel%',
              style: TextStyle(
                fontSize: 22.sp,
                fontWeight: FontWeight.w700,
                color: _textPrimary,
                height: 1.2,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              '可能需要一些时间，请稍等。',
              style: TextStyle(
                fontSize: 13.sp,
                color: _textSecondary,
                height: 1.35,
              ),
            ),
          ] else ...[
            Text(
              _formatBytes(summary.appTotalBytes),
              style: TextStyle(
                fontSize: 28.sp,
                fontWeight: FontWeight.w700,
                color: _textPrimary,
                height: 1.1,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              '占设备 ${summary.deviceAppPercent}% 存储空间',
              style: TextStyle(
                fontSize: 13.sp,
                color: _textSecondary,
                height: 1.35,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 7.w,
          height: 7.w,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        SizedBox(width: 5.w),
        Text(
          label,
          style: TextStyle(
            fontSize: 11.sp,
            color: const Color(0xFF73747A),
          ),
        ),
      ],
    );
  }
}

class _BottomLoadingCard extends StatelessWidget {
  const _BottomLoadingCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 120.h,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SizedBox(
        width: 28.w,
        height: 28.w,
        child: const CircularProgressIndicator(
          strokeWidth: 2.5,
          color: Color(0xFFFE2C55),
        ),
      ),
    );
  }
}

class _CacheDetailCard extends StatelessWidget {
  const _CacheDetailCard({
    required this.summary,
    required this.onClearCache,
  });

  final _CacheSummary summary;
  final VoidCallback onClearCache;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _DetailRow(
            title: '缓存',
            valueText: _formatBytes(summary.cacheBytes),
            desc: '使用絮语过程中产生的临时数据，清理后不影响正常使用。',
            actionLabel: '清理',
            emphasized: true,
            enabled: summary.cacheBytes > 0,
            onTap: summary.cacheBytes > 0 ? onClearCache : null,
          ),
          const Divider(height: 1, thickness: 1, color: Color(0xFFF0F0F0)),
          _DetailRow(
            title: '离线视频',
            valueText: _formatBytes(summary.offlineBytes),
            desc: '离线模式下下载的视频，删除后若需再次观看需要重新下载。',
            actionLabel: '清理',
            emphasized: false,
            enabled: summary.offlineBytes > 0,
            onTap: null,
          ),
          const Divider(height: 1, thickness: 1, color: Color(0xFFF0F0F0)),
          _DetailRow(
            title: '草稿 (${summary.draftCount})',
            valueText: _formatBytes(summary.draftBytes),
            desc: '保存在设备上的未发布的草稿作品，删除后不可恢复。',
            actionLabel: '管理',
            emphasized: false,
            enabled: true,
            onTap: null,
          ),
          const Divider(height: 1, thickness: 1, color: Color(0xFFF0F0F0)),
          _DetailRow(
            title: '聊天记录',
            valueText: _formatBytes(summary.chatBytes),
            desc: '可以删除聊天记录中的视频、图片和文件，或删除所选聊天的全部消息。',
            actionLabel: '管理',
            emphasized: false,
            enabled: true,
            onTap: null,
          ),
          const Divider(height: 1, thickness: 1, color: Color(0xFFF0F0F0)),
          _EssentialRow(
            valueText: _formatBytes(summary.essentialBytes),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.title,
    required this.valueText,
    required this.desc,
    required this.actionLabel,
    required this.emphasized,
    required this.enabled,
    this.onTap,
  });

  final String title;
  final String valueText;
  final String desc;
  final String actionLabel;
  final bool emphasized;
  final bool enabled;
  final VoidCallback? onTap;

  static const Color _red = Color(0xFFFE2C55);
  static const Color _textPrimary = Color(0xFF161823);
  static const Color _textSecondary = Color(0xFF73747A);

  @override
  Widget build(BuildContext context) {
    final btnBg = emphasized && enabled
        ? _red
        : const Color(0xFFF2F2F2);
    final btnFg = emphasized && enabled ? Colors.white : _textSecondary;

    return Padding(
      padding: EdgeInsets.fromLTRB(14.w, 14.h, 12.w, 14.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                    color: _textPrimary,
                  ),
                ),
                SizedBox(height: 6.h),
                Text(
                  valueText,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: _textPrimary,
                  ),
                ),
                SizedBox(height: 6.h),
                Text(
                  desc,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: _textSecondary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 8.w),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: enabled ? onTap : null,
              borderRadius: BorderRadius.circular(6.r),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: btnBg,
                  borderRadius: BorderRadius.circular(6.r),
                ),
                alignment: Alignment.center,
                child: Text(
                  actionLabel,
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    color: btnFg,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EssentialRow extends StatelessWidget {
  const _EssentialRow({required this.valueText});

  final String valueText;

  static const Color _textPrimary = Color(0xFF161823);
  static const Color _textSecondary = Color(0xFF73747A);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(14.w, 14.h, 14.w, 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'App 必要文件',
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.w600,
              color: _textPrimary,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            valueText,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: _textPrimary,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            '维持絮语正常使用的必要文件，如登录数据，大小因 App 的使用情况有差异。',
            style: TextStyle(
              fontSize: 12.sp,
              color: _textSecondary,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _ClearCacheConfirmDialog extends StatelessWidget {
  const _ClearCacheConfirmDialog({
    required this.releaseText,
    required this.onCancel,
    required this.onConfirm,
  });

  final String releaseText;
  final VoidCallback onCancel;
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
      insetPadding: EdgeInsets.symmetric(horizontal: 40.w),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(22.w, 22.h, 22.w, 18.h),
            child: Text(
              '将清理絮语缓存数据，可释放 $releaseText 存储空间',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF161823),
                height: 1.45,
              ),
            ),
          ),
          const Divider(height: 1, thickness: 1, color: Color(0xFFEFEFEF)),
          IntrinsicHeight(
            child: Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: onCancel,
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                      child: Center(
                        child: Text(
                          '取消',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF161823),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Container(width: 1, color: const Color(0xFFEFEFEF)),
                Expanded(
                  child: InkWell(
                    onTap: onConfirm,
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                      child: Center(
                        child: Text(
                          '清理',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFFFE2C55),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
