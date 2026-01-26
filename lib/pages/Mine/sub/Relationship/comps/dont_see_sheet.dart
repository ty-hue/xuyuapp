import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class DontSeeSheet extends StatefulWidget {
  final bool initialValue;

  const DontSeeSheet({required this.initialValue});

  @override
  State<DontSeeSheet> createState() => _DontSeeSheetState();
}

class _DontSeeSheetState extends State<DontSeeSheet> {
  late bool _dontSee;

  @override
  void initState() {
    super.initState();
    _dontSee = widget.initialValue;
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

  Widget _buildActionItem({required String text, required VoidCallback onTap}) {
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
          Switch(
            value: _dontSee,
            onChanged: (value) {
              setState(() {
                _dontSee = value;
              });
            },
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
        height: 340.h,
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
        color: Color.fromRGBO(243, 243, 244, 1),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 头像
                SizedBox(
                  width: 80.0.w,
                  height: 80.0.h,
                  child: CircleAvatar(
                    backgroundImage: NetworkImage(
                      'https://q8.itc.cn/q_70/images03/20250114/d9d8d1106f454c2b83ea395927bfc020.jpeg',
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20.h),
            Column(
              mainAxisSize: MainAxisSize.min,
              spacing: 6.h,
              children: [
                Text(
                  '海阔天空',
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                    color: Color.fromRGBO(22, 24, 35, 1),
                  ),
                ),
                Text(
                  '开启后，他将看不到我发布的内容',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.normal,
                    color: Color.fromRGBO(80, 82, 90, 1),
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
                      text: '不让他看',
                      onTap: () {
                        print('不让他（她）看');
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
