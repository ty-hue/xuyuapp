import 'package:bilbili_project/components/custom_input.dart';
import 'package:bilbili_project/components/phone_input.dart';
import 'package:bilbili_project/components/static_app_bar.dart';
import 'package:bilbili_project/components/with_statusBar_color.dart';
import 'package:bilbili_project/pages/Settings/sub/AccountSafe/sub/RecoverAccount/comps/agree_sheet.dart';
import 'package:bilbili_project/pages/Settings/sub/AccountSafe/sub/RecoverAccount/comps/question_find_account_sheet.dart';
import 'package:bilbili_project/utils/ToastUtils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class RecoverAccountPage extends StatefulWidget {
  RecoverAccountPage({Key? key}) : super(key: key);

  @override
  State<RecoverAccountPage> createState() => _RecoverAccountState();
}

class _RecoverAccountState extends State<RecoverAccountPage> {
  String prefix = '+86';
  String phoneNumber = '';
  int selectedMethod = -1;
  bool isRead = false;
  bool get isAllowSubmit {
    if (selectedMethod == -1) {
      return false;
    }
    return true;
  }

  Widget _buildMethodItem({
    required String title,
    String subTitle = '',
    required Widget formChild,
    required int value,
    VoidCallback? onSubTitleTap,
  }) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedMethod = value;
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 16.h),
        decoration: BoxDecoration(
          color: Color.fromRGBO(29, 31, 42, 1),
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Radio(
                      value: value,
                      groupValue: selectedMethod,
                      onChanged: (value) {
                        setState(() {
                          selectedMethod = value as int;
                        });
                      },
                    ),
                    Text(
                      title,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: onSubTitleTap ?? () {},
                  child: Text(
                    subTitle,
                    style: TextStyle(
                      color: Color.fromRGBO(124, 176, 227, 1),
                      fontSize: 12.sp,
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: EdgeInsets.only(left: 40.w),
              child: selectedMethod == value ? formChild : Container(),
            ),
          ],
        ),
      ),
    );
  }

  void _openQuestionFindAccountSheet() async {
    await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
      ),
      builder: (BuildContext context) {
        return QuestionFindAccountSheet();
      },
    );
  }

  void _openAgreeSheet() async {
    await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
      ),
      builder: (BuildContext context) {
        return AgreeSheet(
          onAgree: () {
            setState(() {
              isRead = true;
              _submit();
              Navigator.pop(context);
            });
          },
        );
      },
    );
  }

  void _submit() {
    ToastUtils.showToast(context, msg: '未知错误');
  }

  @override
  Widget build(BuildContext context) {
    return WithStatusbarColorView(
      statusBarColor: Colors.white,
      child: Scaffold(
        appBar: StaticAppBar(
          titleColor: Colors.white,
          title: '确认账号',
          titleFontWeight: FontWeight.bold,
          backgroundColor: Color.fromRGBO(22, 24, 36, 1),
          statusBarHeight: MediaQuery.of(context).padding.top,
        ),
        body: Container(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 32.h),
          decoration: BoxDecoration(color: Color.fromRGBO(22, 24, 36, 1)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '通过以下任意方式，确认要找回的账号',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 13.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 24.h),
                  _buildMethodItem(
                    value: 0,
                    title: '通过绑定的手机号',
                    formChild: PhoneInputView(
                      outBoxDecoration: BoxDecoration(
                        color: Colors.transparent,
                        // 底部边框
                        border: Border(
                          bottom: BorderSide(
                            color: Color.fromRGBO(38, 40, 51, 1),
                            width: 1.w,
                          ),
                        ),
                      ),
                      dividerLine: Container(
                        width: 1.w,
                        height: 20.h,
                        color: Color.fromRGBO(
                          103,
                          104,
                          111,
                          1,
                        ).withOpacity(0.5),
                      ),
                      filled: false,
                      textStyle: TextStyle(
                        color: Color.fromRGBO(103, 104, 111, 1),
                        fontSize: 16.sp,
                      ),
                      hintStyle: TextStyle(
                        color: Color.fromRGBO(103, 104, 111, 1),
                        fontSize: 16.sp,
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 6.w,
                        vertical: 16.h,
                      ),
                      prefixColor: Color.fromRGBO(103, 104, 111, 1),
                      prefixFontSize: 16.sp,
                      prefix: prefix,
                      prefixPadding: EdgeInsets.symmetric(horizontal: 0),
                      onPhonePrefixChanged: (String value) {
                        setState(() {
                          prefix = value;
                        });
                      },
                      onPhoneNumberChanged: (String value) {
                        setState(() {
                          phoneNumber = value;
                        });
                      },
                    ),
                  ),
                  SizedBox(height: 24.h),
                  _buildMethodItem(
                    value: 1,
                    title: '通过絮语号',
                    subTitle: '如何获取絮语号？',
                    onSubTitleTap: _openQuestionFindAccountSheet,
                    formChild: Container(
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        // 底部边框
                        border: Border(
                          bottom: BorderSide(
                            color: Color.fromRGBO(38, 40, 51, 1),
                            width: 1.w,
                          ),
                        ),
                      ),
                      child: CustomInputView(
                        hintText: '请输入絮语号',
                        filled: false,
                        textStyle: TextStyle(
                          color: Color.fromRGBO(103, 104, 111, 1),
                          fontSize: 16.sp,
                        ),
                        hintStyle: TextStyle(
                          color: Color.fromRGBO(103, 104, 111, 1),
                          fontSize: 16.sp,
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 6.w,
                          vertical: 16.h,
                        ),

                        onChanged: (value) {
                          setState(() {});
                        },
                      ),
                    ),
                  ),
                ],
              ),
              Column(
                spacing: 6.h,
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    height: 56.h,
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        disabledBackgroundColor: Color.fromRGBO(
                          254,
                          43,
                          84,
                          1,
                        ).withOpacity(0.2),

                        backgroundColor: Color.fromRGBO(254, 43, 84, 1),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                      ),
                      onPressed: !isAllowSubmit
                          ? null
                          : () {
                              !isRead ? _openAgreeSheet() : _submit();
                            },
                      child: Text(
                        '下一步',
                        style: TextStyle(
                          color: !isAllowSubmit
                              ? Colors.white.withOpacity(0.8)
                              : Colors.white,
                          fontSize: 18.sp,
                        ),
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Checkbox(
                        activeColor: Color.fromRGBO(249, 45, 87, 1),
                        shape: CircleBorder(),
                        value: isRead,
                        onChanged: (value) {
                          setState(() {
                            isRead = value as bool;
                          });
                        },
                      ),
                      Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: '已阅读并同意',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.8),
                                fontSize: 12.sp,
                              ),
                            ),
                            TextSpan(
                              text: ' 用户协议 ',
                              style: TextStyle(
                                color: Color.fromRGBO(124, 176, 227, 1),
                                fontSize: 12.sp,
                              ),
                            ),
                            TextSpan(
                              text: '和',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.8),
                                fontSize: 12.sp,
                              ),
                            ),
                            TextSpan(
                              text: ' 隐私政策 ',
                              style: TextStyle(
                                color: Color.fromRGBO(124, 176, 227, 1),
                                fontSize: 12.sp,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
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
