import 'package:flutter/material.dart';

/// 由 [ShellPage] 注入，「我的」页通过 [of] 打开抖音式侧滑菜单（推动整壳含底栏）。
class MineSideMenuScope extends InheritedWidget {
  const MineSideMenuScope({
    super.key,
    required this.open,
    required this.close,
    required super.child,
  });

  final VoidCallback open;
  final VoidCallback close;

  static MineSideMenuScope? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<MineSideMenuScope>();
  }

  static MineSideMenuScope of(BuildContext context) {
    final scope = maybeOf(context);
    assert(scope != null, 'MineSideMenuScope 未找到，请确认在 ShellPage 下');
    return scope!;
  }

  @override
  bool updateShouldNotify(MineSideMenuScope oldWidget) {
    return open != oldWidget.open || close != oldWidget.close;
  }
}
