import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class TabViewComp extends StatefulWidget {
  TabViewComp({Key? key}) : super(key: key);

  @override
  _TabViewCompState createState() => _TabViewCompState();
}

class _TabViewCompState extends State<TabViewComp> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 10.w),
      child: CustomScrollView(
        slivers: [
          SliverGrid(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 10.h,
              crossAxisSpacing: 10.w,
              childAspectRatio: 0.8,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) => Container(
                color: Colors.white,
                child: Center(
                  child: Text(
                    '观看历史$index',
                    style: TextStyle(color: Colors.black, fontSize: 20.sp),
                  ),
                ),
              ),
              childCount: 100,
            ),
          ),
        ],
      ),
    );
  }
}
