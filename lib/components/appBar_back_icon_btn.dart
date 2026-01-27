import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class BackIconBtn extends StatelessWidget {
  final double size;
  final Color color;
  final IconData icon;

  const BackIconBtn({
    super.key,
    this.size = 20.0,
    this.color = Colors.white,
    this.icon = Icons.arrow_back_ios_new,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        context.pop();
      },
      child: Icon(icon, color: color, size: size.r),
    );
  }
}
