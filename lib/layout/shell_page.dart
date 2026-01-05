import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ShellPage extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const ShellPage({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: BottomNavigationBar(
        // 1. 移除水波纹效果
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color.fromARGB(255, 27, 25, 25),
        showUnselectedLabels: true,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.grey,
        currentIndex: navigationShell.currentIndex,
        selectedFontSize: 15,
        unselectedFontSize: 15,
        onTap: (index) {
          navigationShell.goBranch(
            index,
            initialLocation: index == navigationShell.currentIndex,
          );
        },
        items: [
          const BottomNavigationBarItem(icon: SizedBox.shrink(), label: '首页'),
          const BottomNavigationBarItem(icon: SizedBox.shrink(), label: '朋友'),
          // 2. 自定义中间的“发布”项
          BottomNavigationBarItem(
            // 使用一个 Container 来创建一个圆形背景的“+”号图标
            icon: Container(
              padding: EdgeInsets.symmetric(vertical: 4, horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: Icon(
                Icons.add,
                color: Colors.white, // “+”号颜色
                size: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            // 设置一个空的 label，这样文字就不会显示
            label: '',
          ),
          const BottomNavigationBarItem(icon: SizedBox.shrink(), label: '消息'),
          const BottomNavigationBarItem(icon: SizedBox.shrink(), label: '我的'),
        ],
      ),
    );
  }
}
