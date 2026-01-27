import 'package:bilbili_project/routes/app_router.dart';
import 'package:bilbili_project/routes/login_routes/choose_phone_prefix_route.dart';
import 'package:bilbili_project/viewmodels/EditProfile/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class PhoneInputView extends StatefulWidget {
  final ValueChanged<String> onPhonePrefixChanged;
  final ValueChanged<String> onPhoneNumberChanged;
  final String prefix;
  PhoneInputView({
    Key? key,
    required this.onPhonePrefixChanged,
    this.prefix = '+86',
    required this.onPhoneNumberChanged,
  }) : super(key: key);

  @override
  State<PhoneInputView> createState() => _PhoneInputViewState();
}

class _PhoneInputViewState extends State<PhoneInputView> {
  final TextEditingController _phoneController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 14.h),
      decoration: BoxDecoration(
        color: Color.fromRGBO(248, 248, 248, 1),
        borderRadius: BorderRadius.circular(14.r),
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
              padding: EdgeInsets.symmetric(horizontal: 10.w),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    widget.prefix,
                    style: TextStyle(color: Colors.black, fontSize: 20.sp),
                  ),
                  // 向下的三角形图标
                  Icon(Icons.arrow_drop_down, color: Colors.black, size: 30.sp),
                ],
              ),
            ),
          ),
          Container(width: 1.w, height: 20.h, color: Colors.grey),
          Expanded(
            child: TextFormField(
              keyboardType: TextInputType.number,
              controller: _phoneController,
              onFieldSubmitted: (value) {},
              validator: (value) {
                return null;
              },
              onChanged: (value) {
                widget.onPhoneNumberChanged(value);
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
                isDense: true, //彻底解决高度问题
                hintText: '请输入手机号',
                border: InputBorder.none,
                hintStyle: TextStyle(color: Colors.grey, fontSize: 16.sp),
                contentPadding: EdgeInsets.only(left: 10.w),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
