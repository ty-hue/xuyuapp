import 'package:bilbili_project/pages/Login/comps/login_other_method.dart';
import 'package:bilbili_project/pages/Login/sub/OtherPhoneLogin/params/params.dart';
import 'package:bilbili_project/routes/login_routes/choose_phone_prefix_route.dart';
import 'package:bilbili_project/routes/login_routes/fill_code_route.dart';
import 'package:bilbili_project/routes/app_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

// ignore: must_be_immutable
class OtherPhoneLoginPage extends StatefulWidget {
  final OtherPhoneLoginParams extra;
  OtherPhoneLoginPage({Key? key, required this.extra}) : super(key: key);
 

  @override
  State<OtherPhoneLoginPage> createState() => _OtherPhoneLoginPageState();
}

class _OtherPhoneLoginPageState extends State<OtherPhoneLoginPage> {
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
        Text('已阅读并同意"用户协议"和"隐私协议"', style: TextStyle(fontSize: 14.0.sp, color: Colors.grey)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios),
          onPressed: () {
            LoginRoute().go(context);
          },
        ),
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
                  child: Stack(
                    children: [
                      TextFormField(
                        validator: (value) {
                          return null;
                        },
                        style: TextStyle(
                          fontSize: 20.0.sp, // 设置输入文字的大小
                          color: Colors.black87, // 设置输入文字的颜色
                          // fontWeight: FontWeight.bold, // 还可以设置粗细等
                        ),
                        decoration: InputDecoration(
                          // 2. 设置提示文字的样式
                          hintStyle: TextStyle(
                            fontSize: 18.0.sp, // 设置提示文字的大小
                            color: Colors.grey[500], // 设置提示文字的颜色
                          ),
                          contentPadding: EdgeInsets.only(left: 100.0.w), // 内容内边距
                          hintText: "请输入手机号",
                          fillColor: Colors.transparent,
                          filled: true,
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.blue),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 0,
                        bottom: 0,
                        left: 0,
                        child: GestureDetector(
                          onTap: () {
                            // 处理点击事件
                            ChoosePhonePrefixRoute().go(context);
                          },
                          child: Container(
                            alignment: Alignment.center,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  widget.extra.code,
                                  style: TextStyle(
                                    fontSize: 24.0.sp,
                                    color: Colors.black,
                                  ),
                                ),
                                Icon(
                                  FontAwesomeIcons.angleDown,
                                  size: 20.r,
                                  color: Colors.black,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 28.0.h),
                SizedBox(
                  width: double.infinity,
                  height: 48.0.h,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0.r),
                      ),
                      // minimumSize: Size(200, 50),
                    ),
                    onPressed: () {
                      FillCodeRoute().go(context);
                    },
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
    );
  }
}
