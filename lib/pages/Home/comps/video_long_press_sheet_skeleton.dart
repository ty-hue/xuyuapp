import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 长按菜单关闭时通过 [Navigator.pop] 回传给播放器的选项。
enum VideoLongPressSheetResult {
  clearScreenPlayback,
}

/// 首页视频时长按 sheet 与清屏面板共用的速度档位（单一数据源）。
const List<double> kVideoFeedPlaybackSpeedSteps = <double>[
  0.75,
  1.0,
  1.25,
  1.5,
  2.0,
  3.0,
];

String _speedChipLabel(double s) {
  if ((s - s.roundToDouble()).abs() < 1e-6) {
    return '${s.round()}';
  }
  // 去掉形如 1.5000000001
  final t = (s * 100).round() / 100;
  if ((t - t.roundToDouble()).abs() < 1e-6) return '${t.round()}';
  return '$t';
}

/// 圆角由 [SheetUtils] 打开的 modal [Material.shape] 统一裁剪，此处不再套外层 [ClipRRect]。
class VideoLongPressSheetSkeleton extends StatefulWidget {
  const VideoLongPressSheetSkeleton({
    super.key,
    required this.initialPlaybackSpeed,
    required this.onPlaybackSpeedSelected,
    required this.onReportNavigate,
  });

  /// 打开 sheet 时当前倍速，用于高亮对应档位。
  final double initialPlaybackSpeed;

  /// 用户点选倍速后由播放器完成 [VideoPlayerController.setPlaybackSpeed]。
  final Future<void> Function(double speed) onPlaybackSpeedSelected;

  /// 关闭 sheet 后跳转举报页（使用调用方 [BuildContext]，避免 sheet 内 context 已卸载）。
  final VoidCallback onReportNavigate;

  @override
  State<VideoLongPressSheetSkeleton> createState() =>
      _VideoLongPressSheetSkeletonState();
}

class _VideoLongPressSheetSkeletonState
    extends State<VideoLongPressSheetSkeleton> {
  Widget _buildRowItem({
    required IconData icon,
    required String title,
    bool underline = true,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 16.0.h),
          decoration: BoxDecoration(
            border: Border(
              bottom: underline
                  ? BorderSide(
                      color: Colors.grey.withValues(alpha: 0.3),
                      width: 1.w,
                    )
                  : BorderSide.none,
            ),
          ),
          child: Row(
            spacing: 14.w,
            children: [
              Icon(
                icon,
                size: 24.sp,
                color: const Color.fromRGBO(25, 27, 38, 1),
              ),
              Expanded(
                child: Row(
                  spacing: 12.w,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16.sp,
                        color: const Color.fromRGBO(62, 63, 72, 1),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Expanded(child: trailing ?? const SizedBox.shrink()),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _onSpeedTap(double speed) async {
    await widget.onPlaybackSpeedSelected(speed);
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  void _onClearScreenTap() {
    Navigator.of(context).pop(VideoLongPressSheetResult.clearScreenPlayback);
  }

  void _onReportTap() {
    Navigator.of(context).pop();
    widget.onReportNavigate();
  }

  bool _speedMatches(double candidate) {
    return (candidate - widget.initialPlaybackSpeed).abs() < 0.02;
  }

  @override
  Widget build(BuildContext context) {
    const accent = Color.fromRGBO(251, 48, 89, 1);
    return ClipRRect(
      borderRadius: BorderRadius.all(Radius.circular(16.r)),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.0.w, vertical: 24.0.h),
        decoration: const BoxDecoration(color: Color.fromRGBO(242, 243, 244, 1)),
        child: Container(
          padding: EdgeInsets.only(left: 24.0.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(Radius.circular(16.r)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildRowItem(
                icon: Icons.speed_rounded,
                title: '倍速',
                trailing: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    spacing: 12.w,
                    children: [
                      for (final speed in kVideoFeedPlaybackSpeedSteps)
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () => _onSpeedTap(speed),
                            borderRadius: BorderRadius.circular(8.r),
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: 10.w,
                                vertical: 8.h,
                              ),
                              child: Text(
                                _speedChipLabel(speed),
                                style: TextStyle(
                                  fontSize: 15.sp,
                                  fontWeight: _speedMatches(speed)
                                      ? FontWeight.w800
                                      : FontWeight.w500,
                                  color: _speedMatches(speed)
                                      ? accent
                                      : const Color.fromRGBO(
                                          124,
                                          125,
                                          131,
                                          1,
                                        ),
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              _buildRowItem(
                icon: Icons.layers_clear_rounded,
                title: '清屏播放',
                onTap: _onClearScreenTap,
              ),
              _buildRowItem(
                icon: Icons.outlined_flag_rounded,
                title: '举报',
                underline: false,
                onTap: _onReportTap,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
