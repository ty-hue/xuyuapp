import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

class FillCodePage extends StatefulWidget {
  FillCodePage({Key? key}) : super(key: key);

  @override
  State<FillCodePage> createState() => _FillCodePageState();
}

class _FillCodePageState extends State<FillCodePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios),
          onPressed: () {
            context.pop();
          },
        ),
      ),
      body: Container(
        width: double.infinity,
        padding: EdgeInsets.only(top: 20, left: 30, right: 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '输入验证码',
              style: TextStyle(fontSize: 28, color: Colors.black),
              textAlign: TextAlign.left,
            ),
            SizedBox(height: 10),
            Text(
              '验证码已发送至 +8615573010566',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            SizedBox(height: 36),
            PinCodeTextField(
              autoFocus: true,
              appContext: context, // 必须提供 context
              length: 4, // 验证码的长度
              obscureText: false, // 是否隐藏文本
              animationType: AnimationType.fade, // 输入时的动画类型
              pinTheme: PinTheme(
                borderWidth: 1,
                selectedBorderWidth: 1,
                shape: PinCodeFieldShape.underline, // 输入框的形状，也可以是 underline
                fieldWidth: 70,
                activeColor: const Color.fromARGB(255, 158, 90, 104), // 激活时的边框颜色
                inactiveColor: Colors.black, // 未激活时的边框颜色
                selectedColor: const Color.fromARGB(255, 132, 121, 228), // 选中时的边框颜色
                activeFillColor: Colors.transparent, // 激活时的填充颜色
                inactiveFillColor: Colors.transparent, // 未激活时的填充颜色
                selectedFillColor: Colors.transparent, // 选中时的填充颜色
              ),
              animationDuration: const Duration(milliseconds:  300),
              backgroundColor: Colors.transparent,
              enableActiveFill: true,
              textStyle: TextStyle(fontSize: 26, color: Colors.black),
              onCompleted: (v) {
                // 输入完成后的回调
                print("Completed: $v");
              },
              onChanged: (value) {
                // 文本变化时的回调
                print(value);
              },
              beforeTextPaste: (text) {
                // 在粘贴之前的回调，可以用来阻止粘贴
                print("Allowing to paste $text");
                return true; // 返回 true 允许粘贴
              },
            ),
            SizedBox(height: 10),
           Text(
            '54s后重新获取',
            style: TextStyle(fontSize: 16, color: Colors.grey),
           ),
          ],
        ),
      ),
    );
  }
}
