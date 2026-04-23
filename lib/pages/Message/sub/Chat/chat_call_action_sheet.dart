import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 聊天顶栏摄像头：视频通话 / 语音通话 / 取消（底部 Action Sheet）。
Future<void> showChatCallActionSheet(BuildContext context) {
  final bottomInset = MediaQuery.paddingOf(context).bottom;

  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withValues(alpha: 0.45),
    isScrollControlled: true,
    builder: (ctx) {
      return Padding(
        padding: EdgeInsets.only(bottom: bottomInset),
        child: ClipRRect(
          borderRadius: BorderRadius.vertical(top: Radius.circular(14.r)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ColoredBox(
                color: Colors.white,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _CallSheetRow(
                      icon: Icons.videocam_outlined,
                      label: '视频通话',
                      onTap: () {
                        Navigator.of(ctx).pop();
                        ScaffoldMessenger.maybeOf(context)?.showSnackBar(
                          const SnackBar(content: Text('视频通话（演示）')),
                        );
                      },
                    ),
                    Divider(height: 1.h, thickness: 1, color: const Color(0xFFE5E5EA)),
                    _CallSheetRow(
                      icon: Icons.call_outlined,
                      label: '语音通话',
                      onTap: () {
                        Navigator.of(ctx).pop();
                        ScaffoldMessenger.maybeOf(context)?.showSnackBar(
                          const SnackBar(content: Text('语音通话（演示）')),
                        );
                      },
                    ),
                  ],
                ),
              ),
              Container(height: 8.h, width: double.infinity, color: const Color(0xFFF2F2F7)),
              Material(
                color: Colors.white,
                child: InkWell(
                  onTap: () => Navigator.of(ctx).pop(),
                  child: SizedBox(
                    width: double.infinity,
                    height: 52.h,
                    child: Center(
                      child: Text(
                        '取消',
                        style: TextStyle(fontSize: 17.sp, fontWeight: FontWeight.w400, color: Colors.black87),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

class _CallSheetRow extends StatelessWidget {
  const _CallSheetRow({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          width: double.infinity,
          height: 52.h,
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 24.r, color: Colors.black87),
                SizedBox(width: 10.w),
                Text(
                  label,
                  style: TextStyle(fontSize: 17.sp, fontWeight: FontWeight.w400, color: Colors.black87),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
