import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class LoginOtherMethod extends StatefulWidget {
  LoginOtherMethod({Key? key}) : super(key: key);

  @override
  State<LoginOtherMethod> createState() => _LoginOtherMethodState();
}

class _LoginOtherMethodState extends State<LoginOtherMethod> {
  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 100.0.h,
      left: 0,
      right: 0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        spacing: 38.0.w,
        children: [
          // -- 微信图标 ---
          GestureDetector(
            onTap: () {
              // 处理点击事件
            },
            child: Icon(
              FontAwesomeIcons.weixin, // 使用微信图标
              size: 30.r,
              color: const Color.fromARGB(255, 27, 233, 8), // 设置为微信的绿色
            ),
          ),
          GestureDetector(
            onTap: () {
              // 处理点击事件
            },
            child: Icon(
              FontAwesomeIcons.apple, // 使用微信图标
              size: 30.r,
              color: Colors.black, // 设置为微信的绿色
            ),
          ),
          GestureDetector(
            onTap: () {
              // 处理点击事件
            },
            child: Icon(
              FontAwesomeIcons.qq, // 使用微信图标
              size: 30.r,
              color: Colors.blueAccent, // 设置为微信的绿色
            ),
          ),
          GestureDetector(
            onTap: () {
              // 处理点击事件
            },
            child: Icon(
              FontAwesomeIcons.github, // 使用微信图标
              size: 30.r,
              color: Colors.black87, // 设置为微信的绿色
            ),
          ),
        ],
      ),
    );
  }
}
