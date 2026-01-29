import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AgreeSheet extends StatefulWidget {
  final Function()? onAgree;
  const AgreeSheet({super.key, this.onAgree});

  @override
  State<AgreeSheet> createState() => _AgreeSheetState();
}

class _AgreeSheetState extends State<AgreeSheet> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ClipRRect(
        borderRadius: BorderRadius.all(Radius.circular(16.r)),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 24.h),
          color: Colors.white,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Column(
                    children: [
                      Text(
                        '用户协议及隐私政策',
                        style: TextStyle(
                          fontSize: 18.sp,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(height: 20.h),
                      SizedBox(
                        width: MediaQuery.of(context).size.width - 40.w,
                        child: Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: '请阅读并同意',
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  color: Colors.black,
                                ),
                              ),
                              TextSpan(
                                text: '用户协议',
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  color: Color.fromRGBO(124, 176, 227, 1),
                                ),
                              ),
                              TextSpan(
                                text: ' 和 ',
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  color: Colors.black,
                                ),
                              ),
                              TextSpan(
                                text: '隐私政策',
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  color: Color.fromRGBO(124, 176, 227, 1)
                                ),
                              ),
                            ],
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
                            backgroundColor: Color.fromRGBO(254, 43, 84, 1)
                          ),
                          onPressed: () {
                            // 直接进行下一步
                            widget.onAgree?.call();
                          },
                          child: Text(
                            '同意下一步',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16.sp,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 20.h),
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Text(
                          '不同意',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 16.sp,
                          ),
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
