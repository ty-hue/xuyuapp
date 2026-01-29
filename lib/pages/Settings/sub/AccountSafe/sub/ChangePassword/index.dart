import 'package:bilbili_project/components/appBar_back_icon_btn.dart';
import 'package:bilbili_project/components/custom_input.dart';
import 'package:bilbili_project/components/static_app_bar.dart';
import 'package:bilbili_project/components/with_statusBar_color.dart';
import 'package:bilbili_project/routes/app_router.dart';
import 'package:bilbili_project/routes/login_routes/fill_code_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ChangePasswordPage extends StatefulWidget {
  ChangePasswordPage({Key? key}) : super(key: key);

  @override
  _ChangePasswordState createState() => _ChangePasswordState();
}

class _ChangePasswordState extends State<ChangePasswordPage> {
  // 校验密码
  bool _validatePwd() {
    // 密码需要8-20位，至少包含字母、数字、符号的任意两种
    return pwd.isNotEmpty && pwd.length < 8 ||
        pwd.length > 20 ||
        !RegExp(r'[A-Za-z]').hasMatch(pwd) ||
        !RegExp(r'[0-9]').hasMatch(pwd) ||
        !RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(pwd);
  }

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String pwd = '';
  bool isShowError = false;
  @override
  Widget build(BuildContext context) {
    return WithStatusbarColorView(
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.dark,
      statusBarColor: Colors.white,
      child: Scaffold(
        appBar: StaticAppBar(
          titleColor: Colors.black,
          title: '手机号绑定',
          titleFontWeight: FontWeight.bold,
          backgroundColor: Colors.white,
          statusBarHeight: MediaQuery.of(context).padding.top,
          leadingChild: BackIconBtn(color: Colors.black, size: 30.0),
        ),
        body: Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
          color: Colors.white,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    '请输入新登录密码',
                    style: TextStyle(
                      color: Colors.black.withOpacity(0.8),
                      fontSize: 24.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 10.h),
                  Text(
                    '密码需要8-20位，至少包含字母、数字、符号的任意两种',
                    style: TextStyle(color: Colors.grey, fontSize: 14.sp),
                  ),
                  SizedBox(height: 20.h),
                  // 输入框
                  Form(
                    key: _formKey,
                    child: CustomInputView(
                      hintText: '请输入密码',
                      obscureText: true,
                      keyboardType: TextInputType.visiblePassword,
                      onChanged: (value) {
                        setState(() {
                          isShowError = false;
                          pwd = value;
                        });
                      },
                    ),
                  ),
                  SizedBox(height: 6.h),
                  isShowError
                      ? Padding(
                          padding: EdgeInsets.only(
                            left: 20.w,
                            top: 6.h,
                            bottom: 6.h,
                          ),
                          child: Text(
                            '密码需要8-20位，至少包含字母、数字、符号的任意两种',
                            style: TextStyle(
                              color: Colors.red,
                              fontSize: 12.sp,
                            ),
                          ),
                        )
                      : SizedBox(),
                  Padding(
                    padding: EdgeInsets.only(left: 20.w),
                    child: Text(
                      '通过短信验证可以使用新密码',
                      style: TextStyle(color: Colors.grey, fontSize: 12.sp),
                    ),
                  ),
                  SizedBox(height: 20.h),
                  SizedBox(
                    height: 50.h,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        disabledBackgroundColor: Color.fromRGBO(
                          254,
                          183,
                          197,
                          1,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        backgroundColor: Color.fromRGBO(254, 43, 84, 1),
                      ),
                      onPressed: pwd.isNotEmpty && pwd.length >= 8
                          ? () {
                              if (!_validatePwd()) {
                                FillCodeRoute().push(context);
                              } else {
                                setState(() {
                                  isShowError = true;
                                });
                              }
                            }
                          : null,
                      child: Text(
                        '获取短信验证码',
                        style: TextStyle(color: Colors.white, fontSize: 16.sp),
                      ),
                    ),
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
