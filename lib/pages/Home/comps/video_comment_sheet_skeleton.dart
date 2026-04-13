import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 评论底部 sheet 占位（半屏）。圆角由 modal [Material.shape] 裁剪。
class VideoCommentSheetSkeleton extends StatelessWidget {
  const VideoCommentSheetSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.sizeOf(context).height * 0.5;
    return Container(
      height: h,
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 24.0.w, vertical: 24.0.h),
      color: Colors.white,
    );
  }
}
