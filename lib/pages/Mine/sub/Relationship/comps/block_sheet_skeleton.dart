import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class BlockSheetSkeleton extends StatefulWidget {
  final bool value;

  const BlockSheetSkeleton({required this.value});

  @override
  State<BlockSheetSkeleton> createState() => _BlockSheetState();
}

class _BlockSheetState extends State<BlockSheetSkeleton> {
  late bool value;

  @override
  void initState() {
    super.initState();
    value = widget.value;
  }


  Widget _buildActionItem({
    required String text,
    required VoidCallback onTap,
    required Color color,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 18.w),
        height: 64.h,
        decoration: BoxDecoration(color: Colors.white),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              text,
              style: TextStyle(fontSize: 18.sp, color: color),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.all(Radius.circular(16.r)),
      child: Container(
        height: 300.h,
        color: Color.fromRGBO(243, 243, 244, 1),
        child: Column(
          children: [
            Container(
              color: Colors.white,
              height: 60.h,
              alignment: Alignment.center,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '拉黑后，对方将无法搜索到你，也不能再给你发私信。',
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.normal,
                      color: Color.fromRGBO(80, 82, 90, 1),
                    ),
                  ),
                ],
              ),
            ),
            Divider(height: 1.h, color: Color.fromRGBO(224, 224, 224, 1)),
            ClipRRect(
              borderRadius: BorderRadius.circular(10.r),
              child: Container(
                child: Column(
                  children: [
                    _buildActionItem(
                      text: '确认拉黑',
                      color: Color.fromRGBO(254, 102, 87, 1),
                      onTap: () {
                        Navigator.pop(context, true);
                        print('确认拉黑');
                      },
                    ),
                    Divider(
                      height: 1.h,
                      color: Color.fromRGBO(224, 224, 224, 1),
                    ),
                    _buildActionItem(
                      text: '不让他看作品',
                      color: Color.fromRGBO(22, 24, 35, 1),
                      onTap: () {
                        Navigator.pop(context, false);
                        print('不让他看作品');
                      },
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 10.h),
            Expanded(
              child: _buildActionItem(
                color: Color.fromRGBO(22, 24, 35, 1),
                text: '取消',
                onTap: () {
                  Navigator.pop(context);
                  print('取消');
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
