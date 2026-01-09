import 'package:bilbili_project/routes/app_router.dart';
import 'package:bilbili_project/viewmodels/Mine/index.dart';
import 'package:flutter/material.dart';

class DrawerMenu extends StatefulWidget {
  final BuildContext context;
  DrawerMenu({Key? key, required this.context}) : super(key: key);

  @override
  State<DrawerMenu> createState() => _DrawerMenuState();
}

class _DrawerMenuState extends State<DrawerMenu> {
  final List<MenuItem> _topMenuItems = [
    MenuItem(title: '我的订单', icon: Icons.shopping_cart, cb: () {}),
    MenuItem(title: '我的钱包', icon: Icons.wallet, cb: () {}),
  ];
  final List<MenuItem> _centerMenuItems = [
    MenuItem(title: '我的二维码', icon: Icons.qr_code, cb: () {}),
    MenuItem(title: '观看历史', icon: Icons.history, cb: () {}),
    MenuItem(title: '离线模式', icon: Icons.offline_bolt, cb: () {}),
    MenuItem(title: '稍后再看', icon: Icons.playlist_add_check, cb: () {}),
    MenuItem(title: '絮语创作者中心', icon: Icons.article, cb: () {}),
  ];
  List<MenuItem> get _bottomMenuItems => [
    MenuItem(title: '絮语公益', icon: Icons.volunteer_activism, cb: () {}),
    MenuItem(title: '我的客服', icon: Icons.contact_support, cb: () {}),
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
        padding: EdgeInsets.symmetric(vertical: 18),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(item.icon, color: Colors.white),
            SizedBox(width: 12),
            Text(item.title, style: TextStyle(color: Colors.white)),
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
      width: 200,
      child: SafeArea(
        top: true,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildMenuGroup(_topMenuItems),
              SizedBox(height: 12),
              Divider(height: 0.5, color: Colors.grey),
              SizedBox(height: 12),
              _buildMenuGroup(_centerMenuItems),
              SizedBox(height: 12),
              Divider(height: 0.5, color: Colors.grey),
              SizedBox(height: 12),
              _buildMenuGroup(_bottomMenuItems),
            ],
          ),
        ),
      ),
    );
  }
}
