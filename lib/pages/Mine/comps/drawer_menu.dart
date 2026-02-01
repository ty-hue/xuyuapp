import 'package:bilbili_project/routes/app_router.dart';
import 'package:bilbili_project/viewmodels/Mine/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class DrawerMenu extends StatefulWidget {
  final BuildContext context;
  DrawerMenu({Key? key, required this.context}) : super(key: key);

  @override
  State<DrawerMenu> createState() => _DrawerMenuState();
}

class _DrawerMenuState extends State<DrawerMenu> {
  late List<MenuItem> _centerMenuItems = [];
  @override
  initState() {
    super.initState();
    _centerMenuItems = [
      MenuItem(
        title: '观看历史',
        icon: Icons.history,
        cb: () {
          WatchHistoryPageRoute().push(widget.context);
        },
      ),
      MenuItem(
        title: '账号数据分析',
        icon: Icons.analytics,
        cb: () {
          DataAnalysisPageRoute().push(widget.context);
        },
      ),
    ];
  }

  List<MenuItem> get _bottomMenuItems => [
    MenuItem(
      title: '设置',
      icon: Icons.settings,
      cb: () {
        SettingsPageRoute().push(widget.context);
      },
    ),
  ];
  Widget _buildMenuItem(MenuItem item) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque, //  padding区域也可以点击
      onTap: () {
        // 调用回调函数
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
              style: TextStyle(color: Colors.white, fontSize: 14.0.sp),
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
    return Drawer(
      backgroundColor: Color.fromRGBO(22, 22, 22, 1),
      width: 200.0.w,
      child: SafeArea(
        top: true,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildMenuGroup(_centerMenuItems),
              SizedBox(height: 12.0.h),
              Divider(height: 0.5.h, color: Colors.grey),
              SizedBox(height: 12.0.h),
              _buildMenuGroup(_bottomMenuItems),
            ],
          ),
        ),
      ),
    );
  }
}
