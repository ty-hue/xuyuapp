import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// [SheetUtils.openAsyncSheet] 的返回值：用户点选或划掉关闭时为 `null`。
enum WorkPreviewSheetResult {
  discardWithoutSave,
  saveDraft,
}

/// 成片预览页点返回后弹出的底部操作区（不保存返回 / 存草稿）。
/// 与 [SelectSheetSkeleton] 一致：灰底外框 + 白底圆角内列表。
class WorkPreviewSheetSkeleton extends StatelessWidget {
  const WorkPreviewSheetSkeleton({super.key});

  Widget _buildRow({
    required BuildContext context,
    required IconData icon,
    required String title,
    required Color titleColor,
    required WorkPreviewSheetResult result,
    bool showBottomBorder = true,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => Navigator.pop(context, result),
        splashColor: Color.fromRGBO(207, 72, 53, 0.2),
        highlightColor: Color.fromRGBO(207, 72, 53, 0.1),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 18.h),
          decoration: BoxDecoration(
            border: Border(
              bottom: showBottomBorder
                  ? BorderSide(color: Colors.grey.withValues(alpha: 0.2), width: 1.w)
                  : BorderSide.none,
            ),
          ),
          child: Row(
            spacing: 8.w,
            children: [
              Icon(icon, size: 22.sp, color: titleColor),
              Text(
                title,
                style: TextStyle(
                  color: titleColor,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.all(Radius.circular(16.r)),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 24.h),
        color: const Color.fromRGBO(243, 243, 245, 1),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              '操作',
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
            SizedBox(height: 8.h),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8.r),
              ),
              clipBehavior: Clip.antiAlias,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildRow(
                    context: context,
                    icon: Icons.arrow_back_ios,
                    title: '不保存返回',
                    titleColor: const Color.fromRGBO(207, 72, 53, 1),
                    result: WorkPreviewSheetResult.discardWithoutSave,
                  ),
                  _buildRow(
                    context: context,
                    icon: Icons.save_outlined,
                    title: '存草稿',
                    titleColor: const Color.fromRGBO(31, 30, 37, 1),
                    result: WorkPreviewSheetResult.saveDraft,
                    showBottomBorder: false,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
