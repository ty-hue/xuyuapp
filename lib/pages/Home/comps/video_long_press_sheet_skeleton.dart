import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 圆角由 [SheetUtils] 打开的 modal [Material.shape] 统一裁剪，此处不再套 [ClipRRect]。
class VideoLongPressSheetSkeleton extends StatelessWidget {
  const VideoLongPressSheetSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.sizeOf(context).height * 0.5;
    return Container(
      height: h,
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 24.0.w, vertical: 24.0.h),
      color: const Color.fromRGBO(9, 12, 11, 1),
    );
  }
}
