import 'package:bilbili_project/routes/app_router.dart';
import 'package:bilbili_project/viewmodels/Mine/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 侧栏菜单内容（不含 [Drawer] 壳），供 Shell 抖音式推页使用。
class DrawerMenuPanel extends StatelessWidget {
  final BuildContext navigatorContext;
  final VoidCallback? onBeforeItemTap;

  const DrawerMenuPanel({
    super.key,
    required this.navigatorContext,
    this.onBeforeItemTap,
  });

  Widget _buildMenuItem(MenuItem item) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        onBeforeItemTap?.call();
        item.cb();
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 18.0.h),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(item.icon, color: Colors.white),
            SizedBox(width: 12.0.w),
            Text(
              item.title,
              style: TextStyle(
                color: Colors.white,
                fontSize: 14.0.sp,
                decoration: TextDecoration.none,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuGroup(List<MenuItem> items) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: items.map((item) => _buildMenuItem(item)).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ctx = navigatorContext;
    final centerMenuItems = <MenuItem>[
      MenuItem(
        title: '观看历史',
        icon: Icons.history,
        cb: () => WatchHistoryPageRoute().push(ctx),
      ),
      MenuItem(
        title: '账号数据分析',
        icon: Icons.analytics,
        cb: () => DataAnalysisPageRoute().push(ctx),
      ),
    ];
    final bottomMenuItems = <MenuItem>[
      MenuItem(
        title: '设置',
        icon: Icons.settings,
        cb: () => SettingsPageRoute().push(ctx),
      ),
    ];

    return ColoredBox(
      color: const Color.fromRGBO(22, 22, 22, 1),
      child: SafeArea(
        top: true,
        bottom: true,
        left: false,
        right: true,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildMenuGroup(centerMenuItems),
              SizedBox(height: 12.0.h),
              Divider(height: 0.5.h, color: Colors.grey),
              SizedBox(height: 12.0.h),
              _buildMenuGroup(bottomMenuItems),
            ],
          ),
        ),
      ),
    );
  }
}
