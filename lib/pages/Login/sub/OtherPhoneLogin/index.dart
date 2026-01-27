import 'package:bilbili_project/components/appBar_back_icon_btn.dart';
import 'package:bilbili_project/components/phone_input.dart';
import 'package:bilbili_project/components/static_app_bar.dart';
import 'package:bilbili_project/components/with_statusBar_color.dart';
import 'package:bilbili_project/pages/Login/comps/login_other_method.dart';
import 'package:bilbili_project/routes/login_routes/fill_code_route.dart';
import 'package:bilbili_project/routes/app_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

// ignore: must_be_immutable
class OtherPhoneLoginPage extends StatefulWidget {
  OtherPhoneLoginPage({Key? key}) : super(key: key);

  @override
  State<OtherPhoneLoginPage> createState() => _OtherPhoneLoginPageState();
}

class _OtherPhoneLoginPageState extends State<OtherPhoneLoginPage> {
  String phonePrefix = '+86';
  String phoneNumber = '';
  bool get isAllowSubmit {
    if(phoneNumber.isEmpty){
      return false;
    }
    if(phonePrefix == '+86'){
      if(phoneNumber.length != 11){
        return false;
      }
      return true;
    }else{
      if(phoneNumber.isNotEmpty){
        return true;
      }
      return false;
    }
    
  }
  bool _isChecked = false;
  Widget _buildCheckbox() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
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
            borderRadius: BorderRadius.circular(5), // 圆角大小
          ),
          // 可选：设置边框
          side: BorderSide(color: Colors.grey, width: 1.0.w),
        ),
        Text(
          '已阅读并同意"用户协议"和"隐私协议"',
          style: TextStyle(fontSize: 14.0.sp, color: Colors.grey),
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
      resizeToAvoidBottomInset: false, // ⭐ 关键 让键盘抬起不挤压页面内容
      appBar: StaticAppBar(
        backgroundColor: Colors.white,
        statusBarHeight: MediaQuery.of(context).padding.top,
        leadingChild: BackIconBtn(color: Colors.black,size: 30.0),
      ),
      body: Stack(
        children: [
          Container(
            padding: EdgeInsets.only(top: 20.0.h, left: 30.0.w, right: 30.0.w),
            alignment: Alignment.topCenter,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  spacing: 10.0.w,
                  children: [
                    Image.asset(
                      'lib/assets/app_logo.png',
                      width: 60.0.w,
                      height: 60.0.h,
                      fit: BoxFit.cover,
                    ),
                    Text('登录体验更多精彩', style: TextStyle(fontSize: 28.0.sp)),
                  ],
                ),
                SizedBox(height: 60.0.h),
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
                SizedBox(height: 28.0.h),
                SizedBox(
                  width: double.infinity,
                  height: 48.0.h,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      disabledBackgroundColor: Colors.blue.withOpacity(0.5),
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0.r),
                      ),
                      // minimumSize: Size(200, 50),
                    ),
                    onPressed: isAllowSubmit ? () {
                      FillCodeRoute().go(context);
                    } : null,
                    child: Text(
                      '获取短信验证码',
                      style: TextStyle(fontSize: 16.0.sp, color: Colors.white),
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
    ));
  }
}
