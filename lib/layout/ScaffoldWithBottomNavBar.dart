import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ScaffoldWithBottomNavBar extends StatefulWidget {
  final Widget child;
  ScaffoldWithBottomNavBar({Key? key, required this.child}) : super(key: key);
  @override
  State<ScaffoldWithBottomNavBar> createState() =>
      _ScaffoldWithBottomNavBarState();
}

class _ScaffoldWithBottomNavBarState extends State<ScaffoldWithBottomNavBar> {
  int _currentIndex = 0;
  void _onItemTapped(int index, BuildContext context) {
    setState(() {
      _currentIndex = index;
    });
    // 处理导航到不同页面的逻辑
    if (index == 0) {
      context.go('/'); // 假设你有一个首页路由
    } else if (index == 1) {
      context.go('/friend'); // 假设你有一个好友列表路由
    } else if (index == 2) {
      // 点击中间项时不做任何操作，因为它是“+”号按钮
    } else if (index == 3) {
      context.go('/message'); // 假设你有一个消息列表路由
    } else if (index == 4) {
      context.go('/mine'); // 假设你有一个用户个人信息路由
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.child,
      // 使用 Stack 来堆叠 BottomNavigationBar 和凸起的按钮
      bottomNavigationBar:
          // 1. 底部的导航栏背景
          BottomNavigationBar(
            // 注意：items 的数量必须是奇数，这样中间项才能被“+”号完美覆盖
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.home), label: '首页'),
              BottomNavigationBarItem(icon: Icon(Icons.people), label: '朋友'),
              // 中间项是一个占位符，它的 icon 和 label 会被我们的自定义按钮覆盖
              BottomNavigationBarItem(icon: SizedBox(), label: ''),
              BottomNavigationBarItem(icon: Icon(Icons.message), label: '消息'),
              BottomNavigationBarItem(icon: Icon(Icons.person), label: '我的'),
            ],
            currentIndex: _currentIndex,
            onTap: (index) => _onItemTapped(index, context),
            type: BottomNavigationBarType.fixed, // 对于超过3个item，建议使用 fixed
            selectedItemColor: Colors.blue,
            unselectedItemColor: Colors.grey,
          ),
      // 2. 凸起的“+”号按钮
      // 使用 Scaffold 自带的 FAB
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.go('/create'),
        child: const Icon(Icons.add),
      ),
      // 将 FAB 定位在 BottomNavigationBar 的中心
      floatingActionButtonLocation: FloatingActionButtonLocation.miniCenterDocked,
    );
  }
}
