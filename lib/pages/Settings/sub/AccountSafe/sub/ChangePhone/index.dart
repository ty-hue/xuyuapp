import 'package:bilbili_project/components/appBar_back_icon_btn.dart';
import 'package:bilbili_project/components/static_app_bar.dart';
import 'package:bilbili_project/components/with_statusBar_color.dart';
import 'package:bilbili_project/routes/app_router.dart';
import 'package:bilbili_project/routes/settings_routes/change_phone_second_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class ChangePhonePage extends StatefulWidget {
  ChangePhonePage({Key? key}) : super(key: key);

  @override
  _ChangePhoneState createState() => _ChangePhoneState();
}

class _ChangePhoneState extends State<ChangePhonePage> {
  @override
  Widget build(BuildContext context) {
    return WithStatusbarColorView(
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.dark,
      statusBarColor: Colors.white,
      child: Scaffold(
        appBar: StaticAppBar(
          titleColor: Colors.black,
          title: '手机号绑定',
          titleFontWeight: FontWeight.bold,
          backgroundColor: Colors.white,
          statusBarHeight: MediaQuery.of(context).padding.top,
          leadingChild: BackIconBtn(
            color: Colors.black,
            size: 30.0,
            
          ),
        ),
        body: Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          alignment: Alignment.center,
          color: Colors.white,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    '已绑定手机号',
                    style: TextStyle(color: Colors.black, fontSize: 16.sp),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 20.h),
                  Text(
                    '155******66',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 60.h),
                  SizedBox(
                    height: 50.h,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        backgroundColor: Color.fromRGBO(254, 43, 84, 1),
                      ),
                      onPressed: () {
                        // 跳转修改手机号页
                        ChangePhoneSecondRoute().push(context);
                      },
                      child: Text(
                        '更换绑定手机号',
                        style: TextStyle(color: Colors.white, fontSize: 16.sp),
                      ),
                    ),
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
