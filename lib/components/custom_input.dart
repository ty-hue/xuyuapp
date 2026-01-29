import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomInputView extends StatefulWidget {
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
  final ValueChanged<String> onChanged;
  CustomInputView({
    Key? key,
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
    this.hintText = '请输入内容', // 提示文字
    this.border, // 边框样式
    this.hintStyle, // 提示文字样式
    this.contentPadding, // 内容内边距
    this.constraints, // 尾部清空按钮大小限制
    this.keyboardType = TextInputType.text, // 键盘类型
    required this.onChanged,
  }) : super(key: key);

  @override
  State<CustomInputView> createState() => _PasswordInputViewState();
}

class _PasswordInputViewState extends State<CustomInputView> {
  final TextEditingController _inputController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      keyboardType: widget.keyboardType,
      obscureText: widget.obscureText,
      controller: _inputController,
      onFieldSubmitted: (value) {},
      validator: (value) => null,
      onChanged: (value) {
        widget.onChanged(value);
      },
      cursorColor: widget.cursorColor, // 光标颜色
      cursorWidth: widget.cursorWidth.w, // 光标宽度
      // cursorHeight: 20.h, // 光标高度，可选，不设置默认文字高度
      cursorRadius: Radius.circular(widget.cursorRadius.r), // 光标圆角
      style: widget.textStyle,
      decoration: InputDecoration(
        filled: widget.filled,
        fillColor: widget.fillColor,
        isDense: true, //彻底解决高度问题
        hintText: widget.hintText,
        border:
            widget.border ??
            OutlineInputBorder(
              borderRadius: BorderRadius.circular(12), // 圆角
              borderSide: BorderSide.none, // 去掉边框线
            ),
        hintStyle:
            widget.hintStyle ?? TextStyle(color: Colors.grey, fontSize: 16.sp),
        contentPadding:
            widget.contentPadding ??
            EdgeInsets.only(left: 20.w, top: 14.h, bottom: 14.h),
        suffixIcon: _inputController.text.isNotEmpty
            ? Padding(
                padding: EdgeInsets.only(right: 20.w),
                child: GestureDetector(
                  onTap: () {
                    _inputController.clear();
                    widget.onChanged('');
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Color.fromRGBO(169, 169, 173, 1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.close,
                      size: 13.0.sp,
                      color: Colors.white,
                    ),
                  ),
                ),
              )
            : null,
        suffixIconConstraints:
            widget.constraints ??
            BoxConstraints(minWidth: 40.0.w, minHeight: 40.0.h),
      ),
    );
  }
}
