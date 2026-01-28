import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class PasswordInputView extends StatefulWidget {
  final ValueChanged<String> onPasswordChanged;
  PasswordInputView({Key? key, required this.onPasswordChanged})
    : super(key: key);

  @override
  State<PasswordInputView> createState() => _PasswordInputViewState();
}

class _PasswordInputViewState extends State<PasswordInputView> {
  final TextEditingController _passwordController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      // 密码
      obscureText: true,
      controller: _passwordController,
      onFieldSubmitted: (value) {},
      validator: (value) => null,
      onChanged: (value) {
        widget.onPasswordChanged(value);
      },
      cursorColor: Color.fromRGBO(209, 176, 40, 1), // 光标颜色
      cursorWidth: 2.w, // 光标宽度
      // cursorHeight: 20.h, // 光标高度，可选，不设置默认文字高度
      cursorRadius: Radius.circular(2.r), // 光标圆角
      style: TextStyle(
        fontSize: 18.0.sp, // 设置输入文字的大小
        color: Colors.black, // 设置输入文字的颜色
        // fontWeight: FontWeight.bold, // 还可以设置粗细等
      ),
      decoration: InputDecoration(
        filled: true,
        fillColor: Color.fromRGBO(248, 248, 248, 1),
        isDense: true, //彻底解决高度问题
        hintText: '请输入密码',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12), // 圆角
          borderSide: BorderSide.none, // 去掉边框线
        ),
        hintStyle: TextStyle(color: Colors.grey, fontSize: 16.sp),
        contentPadding: EdgeInsets.only(left: 20.w, top: 14.h, bottom: 14.h),
        suffixIcon: _passwordController.text.isNotEmpty
            ? Padding(
                padding: EdgeInsets.only(right: 20.w),
                child: GestureDetector(
                  onTap: () {
                    _passwordController.clear();
                    widget.onPasswordChanged('');
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Color.fromRGBO(169,169,173, 1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.close, size: 13.0.sp, color: Colors.white),
                  ),
                ),
              )
            : null,
        suffixIconConstraints: BoxConstraints(
          minWidth: 40.0.w,
          minHeight: 40.0.h,
        ),
      ),
    );
  }
}
