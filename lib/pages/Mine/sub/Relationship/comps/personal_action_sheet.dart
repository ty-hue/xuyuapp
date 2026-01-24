import 'package:bilbili_project/routes/app_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class PersonalActionSheet extends StatefulWidget {
  final bool initialValue;
  final Future<void> Function() openDontSeeSheet;
  final Future<void> Function() openBlockSheet;

  const PersonalActionSheet({required this.initialValue, required this.openDontSeeSheet, required this.openBlockSheet});

  @override
  State<PersonalActionSheet> createState() => _PersonalActionSheetState();
}

class _PersonalActionSheetState extends State<PersonalActionSheet> {
  late bool _value;

  @override
  void initState() {
    super.initState();
    _value = widget.initialValue;
  }

  Widget _buildSingleActionBtn({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 30.h, horizontal: 12.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10.r),
        ),

        child: Column(
          spacing: 8.h,
          children: [
            // 发私信
            Icon(icon, color: Color.fromRGBO(80, 82, 90, 1), size: 24.sp),
            Text(
              text,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.bold,
                color: Color.fromRGBO(22, 24, 35, 1),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionItem({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 18.w),
      height: 50.h,
      decoration: BoxDecoration(color: Colors.white),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            text,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.bold,
              color: Color.fromRGBO(22, 24, 35, 1),
            ),
          ),
          GestureDetector(
            onTap: onTap,
            child: Icon(
              icon,
              color: Color.fromRGBO(80, 81, 89, 1),
              size: 24.sp,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.all(Radius.circular(16.r)),
      child: Container(
        height: 380.h,
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
        color: Color.fromRGBO(243, 243, 244, 1),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  child: Column(
                    spacing: 4.h,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '海阔天空',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Row(
                        spacing: 4.w,
                        children: [
                          Text(
                            '抖音号：60080893467',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 14.sp,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                          // 复制图标按钮
                          GestureDetector(
                            onTap: () {
                              // 复制抖音号到剪贴板
                            },
                            child: Icon(
                              Icons.copy,
                              color: Colors.grey,
                              size: 16.sp,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Icon(Icons.close, color: Colors.black),
                ),
              ],
            ),
            SizedBox(height: 20.h),
            Row(
              spacing: 12.w,
              children: [
                Expanded(
                  child: _buildSingleActionBtn(
                    icon: FontAwesomeIcons.paperPlane,
                    text: '发私信',
                    onTap: () {
                      print('发私信');
                    },
                  ),
                ),
                Expanded(
                  child: _buildSingleActionBtn(
                    icon: FontAwesomeIcons.flag,
                    text: '举报',
                    onTap: () {
                      ReportPageRoute().push(context);
                    },
                  ),
                ),
                Expanded(
                  child: _buildSingleActionBtn(
                    icon: FontAwesomeIcons.userLock,
                    text: '拉黑',
                    onTap: () {
                      Navigator.pop(context);
                      widget.openBlockSheet();
                    },
                  ),
                ),
              ],
            ),
            SizedBox(height: 20.h),
            ClipRRect(
              borderRadius: BorderRadius.circular(10.r),
              child: Container(
                child: Column(
                  children: [
                    _buildActionItem(
                      icon: FontAwesomeIcons.plus,
                      text: '不让他（她）看',
                      onTap: () {
                        Navigator.pop(context);
                        widget.openDontSeeSheet();
                      },
                    ),
                    _buildActionItem(
                      icon: FontAwesomeIcons.minus,
                      text: '移除粉丝',
                      onTap: () {
                        print('移除粉丝');
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
