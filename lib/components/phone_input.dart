import 'package:bilbili_project/components/custom_input.dart';
import 'package:bilbili_project/routes/app_router.dart';
import 'package:bilbili_project/routes/login_routes/choose_phone_prefix_route.dart';
import 'package:bilbili_project/viewmodels/EditProfile/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class PhoneInputView extends StatefulWidget {
  final ValueChanged<String> onPhonePrefixChanged;
  final ValueChanged<String> onPhoneNumberChanged;
  final BoxDecoration? outBoxDecoration;
  final Color cursorColor; // 光标颜色
  final double cursorWidth; // 光标宽度
  final double cursorRadius; // 光标圆角
  final TextStyle textStyle; // 输入文字样式
  final bool obscureText; // 是否隐藏文本
  final bool filled; // 是否填充背景颜色
  final Color fillColor; // 背景颜色
  final String hintText; // 提示文字
  final InputBorder? border; // 边框样式
  final TextStyle? hintStyle; // 提示文字样式
  final EdgeInsetsGeometry? contentPadding; // 内容内边距
  final BoxConstraints? constraints; // 尾部清空按钮大小限制
  final TextInputType keyboardType; // 键盘类型
  final Color? prefixColor; // 前缀文字颜色
  final double? prefixFontSize; // 前缀文字大小
  // 分割线
  final Widget? dividerLine; // 分割线颜色
  final String prefix;
  final EdgeInsetsGeometry? prefixPadding; // 前缀内边距
  PhoneInputView({
    Key? key,
    required this.onPhonePrefixChanged,
    this.prefix = '+86',
    required this.onPhoneNumberChanged,
    this.outBoxDecoration,
    this.cursorColor = const Color.fromRGBO(209, 176, 40, 1), // 光标颜色
    this.cursorWidth = 2, // 光标宽度
    this.cursorRadius = 2, // 光标圆角
    this.textStyle = const TextStyle(
      fontSize: 18.0, // 设置输入文字的大小
      color: Colors.black, // 设置输入文字的颜色
    ), // 输入文字样式
    this.obscureText = false, // 是否隐藏文本
    this.filled = true, // 是否填充背景颜色
    this.fillColor = const Color.fromRGBO(248, 248, 248, 1), // 背景颜色
    this.hintText = '请输入手机号', // 提示文字
    this.border, // 边框样式
    this.hintStyle, // 提示文字样式
    this.contentPadding, // 内容内边距
    this.constraints, // 尾部清空按钮大小限制
    this.keyboardType = TextInputType.phone, // 键盘类型
    this.prefixColor, // 前缀文字颜色
    this.prefixFontSize, // 前缀文字大小
    this.dividerLine, // 分割线
    this.prefixPadding, // 前缀内边距
  }) : super(key: key);

  @override
  State<PhoneInputView> createState() => _PhoneInputViewState();
}

class _PhoneInputViewState extends State<PhoneInputView> {
  @override
  Widget build(BuildContext context) {
    return Container(
      // padding: EdgeInsets.symmetric(vertical: 14.h),
      decoration:
          widget.outBoxDecoration ??
          BoxDecoration(
            color: Color.fromRGBO(248, 248, 248, 1),
            borderRadius: BorderRadius.circular(12.r),
          ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () async {
              AreaItem prefix = await ChoosePhonePrefixRoute().push(context);
              if (prefix.phonePrefix.isNotEmpty) {
                // 通知父组件
                widget.onPhonePrefixChanged(prefix.phonePrefix);
              }
            },
            child: Padding(
              padding:
                  widget.prefixPadding ??
                  EdgeInsets.symmetric(horizontal: 10.w),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    widget.prefix,
                    style: TextStyle(
                      color: widget.prefixColor ?? Colors.black,
                      fontSize: widget.prefixFontSize ?? 20.sp,
                    ),
                  ),
                  // 向下的三角形图标
                  Icon(
                    Icons.arrow_drop_down,
                    color: widget.prefixColor ?? Colors.black,
                    size: 30.sp,
                  ),
                ],
              ),
            ),
          ),
          widget.dividerLine ??
              Container(width: 1.w, height: 20.h, color: Colors.grey),
          Expanded(
            child: CustomInputView(
              cursorColor: widget.cursorColor, // 光标颜色
              cursorWidth: widget.cursorWidth, // 光标宽度
              cursorRadius: widget.cursorRadius, // 光标圆角
              textStyle: widget.textStyle, // 输入文字样式
              obscureText: widget.obscureText, // 是否隐藏文本
              filled: widget.filled, // 是否填充背景颜色
              fillColor: widget.fillColor, // 背景颜色
              hintText: widget.hintText, // 提示文字
              border: widget.border, // 边框样式
              hintStyle: widget.hintStyle, // 提示文字样式
              contentPadding: widget.contentPadding, // 内容内边距
              constraints: widget.constraints, // 尾部清空按钮大小限制
              keyboardType: TextInputType.phone,
              onChanged: (value) {
                widget.onPhoneNumberChanged(value);
              },
            ),
          ),
        ],
      ),
    );
  }
}
