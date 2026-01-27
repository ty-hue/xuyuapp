import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AppBarTextBtn extends StatelessWidget {
  final String text;
  final Function()? onTap;
  final double fontSize;
  final Color color;
  final Color activeColor;
  final bool? isActive;
  const AppBarTextBtn({
    Key? key,
    this.text = '',
    this.onTap,
    this.fontSize = 16.0,
    this.color =  Colors.white,
    this.activeColor = const Color.fromARGB(255, 212, 38, 47),
    this.isActive,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        alignment: Alignment.center,
        child: Text(
          text,
          style: TextStyle(
            color: isActive == true ? activeColor : color,
            fontSize: fontSize.sp,
          ),
        ),
      ),
    );
  }
}
