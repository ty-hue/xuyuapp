import 'package:bilbili_project/utils/ToastUtils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class CloseVisitorView extends StatelessWidget {
  final Future<void> Function(bool isShow) onTap;
  const CloseVisitorView({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
        alignment: Alignment.center,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(70.r),
                  child: Image.network(
                    'https://q9.itc.cn/q_70/images03/20250730/7e535ac6918d44c4a0ab740ed9aa349d.jpeg',
                    width: 140.w,
                    height: 140.h,
                  ),
                ),
                Positioned(
                  child: Container(
                    width: 50.w,
                    height: 50.h,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color.fromRGBO(255, 140, 0, 1),
                    ),
                    alignment: Alignment.center,
                    child: AnimatedRotation(
                      turns: 0.04,
                      duration: Duration(seconds: 1),
                      child: Icon(
                        Icons.person,
                        color: Colors.white,
                        size: 30.sp,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 1.h,
                  right: -40.w,
                  child: Container(
                    width: 80.w,
                    height: 80.h,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color.fromRGBO(245, 67, 160, 1),
                      border: Border.all(
                        color: Color.fromRGBO(22, 24, 35, 1),
                        width: 10.w,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: AnimatedRotation(
                      turns: -0.04,
                      duration: Duration(seconds: 1),
                      child: Icon(Icons.pets, color: Colors.white, size: 40.sp),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20.h),
            Text(
              '授权查看访客',
              style: TextStyle(
                fontSize: 18.sp,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20.h),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  spacing: 10.w,
                  children: [
                    Container(
                      width: 6.w,
                      height: 6.w,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color.fromRGBO(197, 198, 200, 1),
                      ),
                    ),
                    Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: '访客记录中仅展示同样已授权的用户',
                            style: TextStyle(
                              fontSize: 16.sp,
                              color: Color.fromRGBO(197, 198, 200, 1),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 14.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  spacing: 10.w,
                  children: [
                    Container(
                      width: 6.w,
                      height: 6.w,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color.fromRGBO(197, 198, 200, 1),
                      ),
                    ),
                    Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: '访客记录中仅展示同样已授权的用户',
                            style: TextStyle(
                              fontSize: 16.sp,
                              color: Color.fromRGBO(197, 198, 200, 1),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 14.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  spacing: 10.w,
                  children: [
                    Container(
                      width: 6.w,
                      height: 6.w,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color.fromRGBO(197, 198, 200, 1),
                      ),
                    ),
                    Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: '访客记录中仅展示同样已授权的用户',
                            style: TextStyle(
                              fontSize: 16.sp,
                              color: Color.fromRGBO(197, 198, 200, 1),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 50.h),
            Container(
              width: 280.w,
              height: 44.h,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color.fromRGBO(254, 44, 85, 1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                ),
                onPressed: () async{
                 await onTap(true);
                },
                child: Text(
                  '开启访客',
                  style: TextStyle(fontSize: 16.sp, color: Colors.white),
                ),
              ),
            ),
            SizedBox(height: 20.h),
            Container(
              width: 280.w,
              height: 44.h,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color.fromRGBO(56, 58, 68, 1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                ),
                onPressed: () async{
                  // 返回到mine页，并提示一个消息
                  context.pop();
                  ToastUtils.showToast(context, msg: '你将不会再接收到相关通知');
                },
                child: Text(
                  '保持关闭',
                  style: TextStyle(fontSize: 16.sp, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      );
  }
}