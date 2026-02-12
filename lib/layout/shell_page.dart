import 'package:bilbili_project/routes/app_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class ShellPage extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const ShellPage({super.key, required this.navigationShell});
  int _branchToBottomIndex(int branchIndex) {
    if (branchIndex >= 2) {
      return branchIndex + 1; // 因为中间多了一个 +
    }
    return branchIndex;
  }

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
        currentIndex: _branchToBottomIndex(navigationShell.currentIndex),
        selectedFontSize: 15.0.sp,
        unselectedFontSize: 15.0.sp,
        onTap: (index) {
          // 中间发布按钮
          if (index == 2) {
            final s = GoRouterState.of(context);
            CreateRoute(fromUrl: s.fullPath).push(context);
            return;
          }

          // bottomIndex → branchIndex
          final branchIndex = index > 2 ? index - 1 : index;

          navigationShell.goBranch(
            branchIndex,
            initialLocation: branchIndex == navigationShell.currentIndex,
          );
        },
        items: [
          const BottomNavigationBarItem(icon: SizedBox.shrink(), label: '首页'),
          const BottomNavigationBarItem(icon: SizedBox.shrink(), label: '朋友'),
          // 2. 自定义中间的“发布”项
          BottomNavigationBarItem(
            // 使用一个 Container 来创建一个圆形背景的“+”号图标
            icon: Container(
              padding: EdgeInsets.symmetric(
                vertical: 4.0.h,
                horizontal: 12.0.w,
              ),
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(8.0.r),
                border: Border.all(color: Colors.white, width: 2.0.w),
              ),
              child: Icon(
                Icons.add,
                color: Colors.white, // “+”号颜色
                size: 20.r,
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
