import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class VideoTabView extends StatefulWidget {
  VideoTabView({Key? key}) : super(key: key);

  @override
  _VideoTabViewState createState() => _VideoTabViewState();
}

class _VideoTabViewState extends State<VideoTabView> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 6.h),
          child: Row(
            spacing: 16.w,
            children: [
              GestureDetector(
                onTap: () {
                  print('未看完');
                },
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.w,
                    vertical: 3.h,
                  ),
                  decoration: BoxDecoration(
                    color: Color.fromRGBO(35,37,48, 1),
                    borderRadius: BorderRadius.circular(3.r),
                  ),
                  child: Text(
                    '未看完',
                    style: TextStyle(
                      color: Color.fromRGBO(141,142,147, 1),
                      fontSize: 12.sp,
                    ),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  print('已看完');
                },
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.w,
                    vertical: 3.h,
                  ),
                  decoration: BoxDecoration(
                    color: Color.fromRGBO(35,37,48, 1),
                    borderRadius: BorderRadius.circular(3.r),
                  ),
                  child: Text(
                    '已看完',
                    style: TextStyle(
                      color: Color.fromRGBO(141,142,147, 1),
                      fontSize: 12.sp,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: CustomScrollView(
            slivers: [
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => Container(
                    padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                    child: Text('视频 $index',style: TextStyle(
                      color: Colors.white,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                    ),),
                  ),
                  childCount: 20,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
