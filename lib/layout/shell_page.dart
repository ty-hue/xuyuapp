import 'package:bilbili_project/routes/app_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class ShellPage extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const ShellPage({super.key, required this.navigationShell});

  int _branchToBottomIndex(int branchIndex) {
    if (branchIndex >= 2) {
      return branchIndex + 1;
    }
    return branchIndex;
  }

  void _onBottomTap(BuildContext context, int index) {
    if (index == 2) {
      final s = GoRouterState.of(context);
      CreateRoute(fromUrl: s.fullPath).push(context);
      return;
    }
    final branchIndex = index > 2 ? index - 1 : index;
    navigationShell.goBranch(
      branchIndex,
      initialLocation: branchIndex == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomIndex = _branchToBottomIndex(navigationShell.currentIndex);
    const barBg = Color.fromARGB(255, 27, 25, 25);

    Widget textItem(int index, String title) {
      final selected = bottomIndex == index;
      return Expanded(
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => _onBottomTap(context, index),
          child: Center(
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15.0.sp,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                color: selected ? Colors.white : Colors.grey,
              ),
            ),
          ),
        ),
      );
    }

    final plusButton = Container(
      padding: EdgeInsets.symmetric(vertical: 4.0.h, horizontal: 12.0.w),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(8.0.r),
        border: Border.all(color: Colors.white, width: 2.0.w),
      ),
      child: Icon(
        Icons.add,
        color: Colors.white,
        size: 20.r,
        fontWeight: FontWeight.bold,
      ),
    );

    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: Material(
        color: barBg,
        child: SafeArea(
          child: SizedBox(
            height: 52.h + 20.h,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                textItem(0, '首页'),
                textItem(1, '朋友'),
                Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => _onBottomTap(context, 2),
                    child: Center(child: plusButton),
                  ),
                ),
                textItem(3, '消息'),
                textItem(4, '我的'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
