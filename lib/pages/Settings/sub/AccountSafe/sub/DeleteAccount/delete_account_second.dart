import 'package:bilbili_project/components/phone_input.dart';
import 'package:bilbili_project/components/static_app_bar.dart';
import 'package:bilbili_project/components/with_statusBar_color.dart';
import 'package:bilbili_project/routes/app_router.dart';
import 'package:bilbili_project/routes/login_routes/fill_code_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class DeleteAccountSecondPage extends StatefulWidget {
  DeleteAccountSecondPage({Key? key}) : super(key: key);

  @override
  State<DeleteAccountSecondPage> createState() =>
      _DeleteAccountSecondPageState();
}

class _DeleteAccountSecondPageState extends State<DeleteAccountSecondPage> {
  @override
  Widget build(BuildContext context) {
    return WithStatusbarColorView(
      statusBarColor: Color.fromRGBO(22, 24, 36, 1),
      child: Scaffold(
        appBar: StaticAppBar(
          backgroundColor: Color.fromRGBO(22, 24, 36, 1),
          statusBarHeight: MediaQuery.of(context).padding.top,
        ),
        body: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(color: Color.fromRGBO(22, 24, 36, 1)),
          child: Container(
            height: MediaQuery.of(context).size.height * 0.5,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: MediaQuery.of(context).size.width * 0.7,
                  child: Column(
                    children: [
                      Text(
                        '账号注销安全验证',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 10.h),
                      Text(
                        '账号注销后不可恢复，为保障账号安全请进行安全验证',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.normal,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 30.h),
                      Column(
                        spacing: 10.h,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // 圆型头像
                          GestureDetector(
                            onTap: () {
                              // 跳转修改头像页
                            },
                            child: ClipOval(
                              child: Image.network(
                                'https://q1.itc.cn/q_70/images03/20250701/afddfb3d5fcf459594cfa880445c9b2c.jpeg',
                                width: 60.w,
                                height: 60.h,
                              ),
                            ),
                          ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            spacing: 4.w,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'llg',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: Column(
                    spacing: 10.h,
                    children: [
                      SizedBox(
                        height: 56.h,
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            disabledBackgroundColor: Color.fromRGBO(
                              254,
                              43,
                              84,
                              1,
                            ).withOpacity(0.2),

                            backgroundColor: Color.fromRGBO(254, 43, 84, 1),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.r),
                            ),
                          ),
                          onPressed: () {
                            FillCodeRoute().push(context);
                          },
                          child: Text(
                            '手机号验证',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18.sp,
                            ),
                          ),
                        ),
                      ),
                      Text(
                        '需本账号绑定的手机号进行验证，验证后可完成注销',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 13.sp,
                          fontWeight: FontWeight.normal,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
