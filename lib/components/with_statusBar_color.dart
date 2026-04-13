import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class WithStatusbarColorView extends StatelessWidget {
  final Color statusBarColor; // 状态栏颜色
  final Widget child;
  final Brightness statusBarIconBrightness;
  final Brightness statusBarBrightness;
  const WithStatusbarColorView({
    Key? key,
    required this.statusBarColor,
    required this.child,
    this.statusBarIconBrightness = Brightness.light, // 改变安卓状态栏图标颜色
    this.statusBarBrightness = Brightness.dark, // 改变ios状态栏文字颜色
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: statusBarColor, // Android
        statusBarIconBrightness: statusBarIconBrightness, // Android 图标白色
        statusBarBrightness: statusBarBrightness, // iOS 白字
      ),
      child: SafeArea(top: false, bottom: true, child: child),
    );
  }
}
