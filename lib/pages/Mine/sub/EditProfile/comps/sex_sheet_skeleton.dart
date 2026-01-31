import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SexSheetSkeleton extends StatefulWidget {
  SexSheetSkeleton({Key? key}) : super(key: key);

  @override
  State<SexSheetSkeleton> createState() => _SexSheetSkeletonState();
}

class _SexSheetSkeletonState extends State<SexSheetSkeleton> {
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.all(Radius.circular(16.r)),
      child: Container(
        padding: EdgeInsets.only(bottom: 20.h),
        color: Colors.transparent,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16.r),
              child: Container(
                color: Color.fromRGBO(198, 199, 199, 1),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ListTile(
                      title: Center(
                        child: Text(
                          '男',
                          style: TextStyle(
                            fontSize: 18.sp,
                            color: Colors.blueAccent,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      onTap: () {
                        // setState(() => _selectedGender = '男');
                        Navigator.pop(context, true);
                      },
                    ),
                    Divider(
                      height: 1.h,
                      color: Color.fromRGBO(177, 177, 177, 1),
                    ),
                    ListTile(
                      title: Center(
                        child: Text(
                          '女',
                          style: TextStyle(
                            fontSize: 18.sp,
                            color: Colors.blueAccent,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      onTap: () {
                        // setState(() => _selectedGender = '女');
                        Navigator.pop(context, false);
                      },
                    ),
                    Divider(
                      height: 1.h,
                      color: Color.fromRGBO(177, 177, 177, 1),
                    ),
                    ListTile(
                      title: Center(
                        child: Text(
                          '不展示',
                          style: TextStyle(
                            fontSize: 18.sp,
                            color: Colors.blueAccent,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      onTap: () {
                        // setState(() => _selectedGender = '暂不选择');
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16.h),
            Container(
              height: 60.h,
              child: TextButton(
                style: TextButton.styleFrom(
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                ),
                onPressed: () {
                  // setState(() => _selectedGender = '暂不选择');
                  Navigator.pop(context);
                },
                child: Text(
                  '取消',
                  style: TextStyle(
                    fontSize: 20.sp,
                    color: Colors.blueAccent,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
