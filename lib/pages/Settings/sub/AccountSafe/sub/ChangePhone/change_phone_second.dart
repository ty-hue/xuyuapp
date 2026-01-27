import 'package:bilbili_project/components/appBar_back_icon_btn.dart';
import 'package:bilbili_project/components/phone_input.dart';
import 'package:bilbili_project/components/static_app_bar.dart';
import 'package:bilbili_project/components/with_statusBar_color.dart';
import 'package:bilbili_project/routes/app_router.dart';
import 'package:bilbili_project/routes/login_routes/fill_code_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class ChangePhoneSecondPage extends StatefulWidget {
  ChangePhoneSecondPage({Key? key}) : super(key: key);

  @override
  _ChangePhoneSecondState createState() => _ChangePhoneSecondState();
}

class _ChangePhoneSecondState extends State<ChangePhoneSecondPage> {
  bool get isAllowSubmit {
    if (phoneNumber.isEmpty) {
      return false;
    }
    if (phonePrefix == '+86') {
      if (phoneNumber.length != 11) {
        return false;
      }
      return true;
    } else {
      if (phoneNumber.isNotEmpty) {
        return true;
      }
      return false;
    }
  }

  String phonePrefix = '+86';
  String phoneNumber = '';
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
                    '请输入新手机号',
                    style: TextStyle(
                      color: Colors.black.withOpacity(0.8),
                      fontSize: 24.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 10.h),
                  Text(
                    '换绑新手机号之后，可以用新的手机号及当前密码登录',
                    style: TextStyle(color: Colors.grey, fontSize: 14.sp),
                  ),
                  SizedBox(height: 20.h),
                  Form(
                    child: PhoneInputView(
                      onPhoneNumberChanged: (number) {
                        setState(() {
                          phoneNumber = number;
                        });
                      },
                      prefix: phonePrefix,
                      onPhonePrefixChanged: (prefix) {
                        setState(() {
                          phonePrefix = prefix;
                        });
                      },
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
                      onPressed: isAllowSubmit
                          ? () {
                              FillCodeRoute().push(context);
                            }
                          : null,
                      child: Text(
                        '验证并绑定手机号',
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
