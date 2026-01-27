import 'package:bilbili_project/components/appBar_back_icon_btn.dart';
import 'package:bilbili_project/components/static_app_bar.dart';
import 'package:bilbili_project/components/with_statusBar_color.dart';
import 'package:bilbili_project/pages/Login/comps/login_other_method.dart';
import 'package:bilbili_project/routes/login_routes/other_phone_login_route.dart';
import 'package:bilbili_project/routes/app_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class LoginPage extends StatefulWidget {
  LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _isChecked = false;
  Widget _buildCheckbox() {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // 设置勾选为圆角
            Checkbox(
              value: _isChecked,
              activeColor: Colors.blueAccent,
              checkColor: Colors.white,
              onChanged: (bool? value) {
                _isChecked = value ?? false;
                setState(() {});
              },
              // 设置形状
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5.0.r), // 圆角大小
              ),
              // 可选：设置边框
              side: BorderSide(color: Colors.grey, width: 1.0.w),
            ),
            Expanded(
              child: Text(
                '已阅读并同意《中国联通认证服务条款》及"用户协议"和“隐私政策”',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontSize: 12.0.sp),
              ),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return WithStatusbarColorView(
      statusBarBrightness: Brightness.dark,
      statusBarIconBrightness: Brightness.dark,
      statusBarColor: Colors.white,
      child: Scaffold(
        appBar: StaticAppBar(
          statusBarHeight: MediaQuery.of(context).padding.top,
          backgroundColor: Colors.white,
          leadingChild: BackIconBtn(
            icon: Icons.close,
            color: Colors.black,
            size: 30.0,
          ),
        ),
        body: Stack(
          children: [
            Container(
              padding: EdgeInsets.only(
                top: 80.0.h,
                left: 30.0.w,
                right: 30.0.w,
              ),
              alignment: Alignment.topCenter,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    'lib/assets/app_logo.png',
                    width: 80.0.w,
                    height: 80.0.h,
                    fit: BoxFit.cover,
                  ),
                  SizedBox(height: 20.0.h),
                  Text('登录体验更多精彩', style: TextStyle(fontSize: 18.0.sp)),
                  SizedBox(height: 20.0.h),
                  Text(
                    '155****0566',
                    style: TextStyle(
                      fontSize: 30.0.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 10.0.h),
                  Text(
                    '认证服务由中国联通提供',
                    style: TextStyle(color: Colors.grey, fontSize: 12.0.sp),
                  ),
                  SizedBox(height: 40.0.h),
                  SizedBox(
                    width: double.infinity,
                    height: 50.0.h,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0.r),
                        ),
                        // minimumSize: Size(200, 50),
                      ),
                      onPressed: () {},
                      child: Text(
                        '同意协议并一键登录',
                        style: TextStyle(
                          fontSize: 16.0.sp,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 20.0.h),
                  SizedBox(
                    width: double.infinity,
                    height: 50.0.h,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0.r),
                        ),
                      ),
                      onPressed: () {
                        OtherPhoneLoginRoute().push(context);
                      },
                      child: Text(
                        '其他手机号登录',
                        style: TextStyle(
                          fontSize: 16.0.sp,
                          color: const Color.fromARGB(255, 41, 37, 37),
                        ),
                      ),
                    ),
                  ),
                  _buildCheckbox(),
                ],
              ),
            ),
            LoginOtherMethod(),
          ],
        ),
      ),
    );
  }
}
