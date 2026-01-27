import 'package:bilbili_project/components/appBar_back_icon_btn.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class StaticAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final Color backgroundColor;
  final double titleFontSize;
  final double height;
  final List<Widget> actions;
  final double actionSpacing;
  final double statusBarHeight;
  final Widget leadingChild;
  final FontWeight titleFontWeight;
  final Color titleColor;
  const StaticAppBar({
    Key? key,
    this.title = '',
    this.backgroundColor = const Color.fromRGBO(11, 11, 11, 1),
    this.titleFontSize = 16.0,
    this.height = 56.0,
    this.actions = const [],
    this.actionSpacing = 4.0,
    this.leadingChild = const BackIconBtn(),
    this.statusBarHeight = 0.0,
    this.titleFontWeight = FontWeight.normal,
    this.titleColor = Colors.white,
    
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height.h + statusBarHeight.h,
      padding: EdgeInsets.only(left: 16.w, right: 16.w, top: statusBarHeight.h),
      decoration: BoxDecoration(color: backgroundColor),
      child: Stack(
        children: [
          SizedBox(
            height: height.h,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                 mainAxisSize: MainAxisSize.min,
                 crossAxisAlignment: CrossAxisAlignment.center,
                 children: [
                   leadingChild,
                 ],
                ),
                Row(
                  spacing: actionSpacing.w,
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: actions,
                ),
              ],
            ),
          ),
          title.isNotEmpty
              ? Positioned(
                  left: 0,
                  right: 0,
                  top: 0,
                  bottom: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          color: titleColor,
                          fontSize: titleFontSize.sp,
                          fontWeight: titleFontWeight,
                        ),
                      ),
                    ],
                  ),
                )
              : Container(),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(height.h);
}
