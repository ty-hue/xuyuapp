import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class OpenVisitorView extends StatefulWidget {
  OpenVisitorView({Key? key}) : super(key: key);

  @override
  State<OpenVisitorView> createState() => _OpenVisitorViewState();
}

class _OpenVisitorViewState extends State<OpenVisitorView> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            '仅展示30天内已授权的访客，访客记录仅你可见',
            style: TextStyle(fontSize: 14.sp, color: Colors.grey),
            textAlign: TextAlign.center,
            softWrap: true,
          ),
          SizedBox(height: 20.h),
          Expanded(
            child: ListView.builder(
              itemCount: 3,
              itemBuilder: (context, index) {
                return Container(
                  height: 86.h,
                  alignment: Alignment.center,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(30.w),
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Color.fromRGBO(197, 198, 200, 1),
                              ),
                              width: 60.w,
                              height: 60.w,
                              child: Image.network(
                                'https://q9.itc.cn/q_70/images03/20250730/7e535ac6918d44c4a0ab740ed9aa349d.jpeg',
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          SizedBox(width: 10.w),
                          Text(
                            '张三',
                            style: TextStyle(
                              fontSize: 16.sp,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        width: 100.w,
                        height: 36.h,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color.fromRGBO(255, 102, 102, 1),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6.w),
                            ),
                          ),
                        onPressed: () {},
                        child: Text(
                          '关注',
                          style: TextStyle(fontSize: 16.sp, color: Colors.white),
                        ),
                      ),
                      )
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
