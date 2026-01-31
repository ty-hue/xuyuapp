import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class QuestionFindAccountSheetSkeleton extends StatefulWidget {
  @override
  State<QuestionFindAccountSheetSkeleton> createState() =>
      _QuestionFindAccountSheetSkeletonState();
}

class _QuestionFindAccountSheetSkeletonState extends State<QuestionFindAccountSheetSkeleton> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return  ClipRRect(
        borderRadius: BorderRadius.all(Radius.circular(16.r)),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 24.h),
          color: Colors.white,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: Icon(Icons.close, color: Colors.black),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Column(
                    children: [
                      Text(
                        '如何获取絮语号',
                        style: TextStyle(
                          fontSize: 20.sp,
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 20.h),
                      SizedBox(
                        width: MediaQuery.of(context).size.width - 40.w,
                        child: Text(
                          '无需登录絮语，在絮语内搜索账号的昵称，找到对应账号并进入个人页面，在个人主页或主页右下角[···]里，可以复制絮语号',
                          style: TextStyle(
                            fontSize: 16.sp,
                            color: Colors.black,
                          ),
                          textAlign: TextAlign.center,
                          softWrap: true,
                        ),
                      ),
                      SizedBox(height: 20.h),
                      SizedBox(
                        width: MediaQuery.of(context).size.width - 40.w,
                        height: 46.h,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.r),
                            ),
                            backgroundColor: Color.fromRGBO(232, 232, 233, 1),
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Text(
                            '我知道了',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 16.sp,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    
  }
}
