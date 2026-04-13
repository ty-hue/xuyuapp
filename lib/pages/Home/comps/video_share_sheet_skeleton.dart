import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 分享底部 sheet 占位（屏高 20%）。圆角由 modal [Material.shape] 裁剪。
class VideoShareSheetSkeleton extends StatelessWidget {
  const VideoShareSheetSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.sizeOf(context).height * 0.2;
    return Container(
      height: h,
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 24.0.w, vertical: 24.0.h),
      color: const Color.fromRGBO(9, 12, 11, 1),
    );
  }
}
