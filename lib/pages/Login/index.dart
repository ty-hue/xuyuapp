import 'package:bilbili_project/components/Login/login_other_method.dart';
import 'package:bilbili_project/routes/shell_route.dart';
import 'package:flutter/material.dart';
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
              side: BorderSide(color: Colors.grey, width: 1),
            ),
            Text('已阅读并同意《中国联通认证服务条款》', style: TextStyle(color: Colors.grey)),
          ],
        ),
        Text('及"用户协议"和“隐私政策”', style: TextStyle(color: Colors.grey)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.close),
          onPressed: () {
            context.pop();
          },
        ),
      ),
      body: Stack(
        children: [
          Container(
            padding: EdgeInsets.only(top: 80, left: 30, right: 30),
            alignment: Alignment.topCenter,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  'lib/assets/app_logo.png',
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                ),
                SizedBox(height: 20),
                Text('登录体验更多精彩', style: TextStyle(fontSize: 18)),
                SizedBox(height: 20),
                Text(
                  '155****0566',
                  style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                Text('认证服务由中国联通提供', style: TextStyle(color: Colors.grey)),
                SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      // minimumSize: Size(200, 50),
                    ),
                    onPressed: () {},
                    child: Text(
                      '同意协议并一键登录',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                ),
                SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () {
                      OtherPhoneLoginRoute().go(context);
                    },
                    child: Text(
                      '其他手机号登录',
                      style: TextStyle(
                        fontSize: 16,
                        color: const Color.fromARGB(255, 41, 37, 37),
                      ),
                    ),
                  ),
                ),
                _buildCheckbox(),
              ],
            ),
          ),
          LoginOtherMethod()
        ],
      ),
    );
  }
}
