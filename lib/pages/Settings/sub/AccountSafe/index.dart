import 'package:bilbili_project/components/static_app_bar.dart';
import 'package:bilbili_project/components/with_statusBar_color.dart';
import 'package:bilbili_project/pages/Settings/comps/group_item.dart';
import 'package:bilbili_project/pages/Settings/comps/group_title.dart';
import 'package:bilbili_project/routes/app_router.dart';
import 'package:bilbili_project/routes/settings_routes/change_password_route.dart';
import 'package:bilbili_project/routes/settings_routes/change_phone_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AccountSafePage extends StatefulWidget {
  AccountSafePage({Key? key}) : super(key: key);

  @override
  State<AccountSafePage> createState() => _AccountSafeState();
}

class _AccountSafeState extends State<AccountSafePage> {
  @override
  Widget build(BuildContext context) {
    return WithStatusbarColorView(
      statusBarColor: Color.fromRGBO(22, 24, 36, 1),
      child: Scaffold(
        appBar: StaticAppBar(
         
          title: '账号与安全',
          titleFontWeight: FontWeight.bold,
          backgroundColor: Color.fromRGBO(22, 24, 36, 1),
          statusBarHeight: MediaQuery.of(context).padding.top,
        ),
        body: Container(
          color: Color.fromRGBO(22, 24, 36, 1),
          height: double.infinity,
          child: SingleChildScrollView(
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.only(
                left: 16.w,
                right: 16.w,
                top: 16.h,
                bottom: 60.h,
              ),
              color: Color.fromRGBO(22, 24, 36, 1),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    spacing: 8.h,
                    children: [
                      // 圆型头像
                      GestureDetector(
                        onTap: () {
                          // 跳转修改头像页
                        },
                        child: ClipOval(
                          child: Image.network(
                            'https://q1.itc.cn/q_70/images03/20250701/afddfb3d5fcf459594cfa880445c9b2c.jpeg',
                            width: 46.w,
                            height: 46.h,
                          ),
                        ),
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        spacing: 4.w,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'llg',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        spacing: 4.w,
                        children: [
                          Text(
                            '抖音号：sdk19991212',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12.sp,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              // 跳转修改抖音号页
                            },
                            // 复制
                            child: Icon(
                              Icons.copy,
                              color: Colors.white,
                              size: 12.sp,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 20.h),
                  Column(
                    spacing: 8.h,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      GroupTitleView(title: '账号绑定'),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          GroupItemView(
                            icon: Icons.phone_android,
                            backgroundColor: Color.fromRGBO(29, 31, 43, 1),
                            isFirst: true,
                            itemName: '手机号绑定',
                            attachedWidget: Text(
                              '155*******66',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 14.sp,
                              ),
                            ),
                            cb: () {
                              ChangePhoneRoute().push(context);
                            },
                          ),
                          GroupItemView(
                            needUnderline: false,
                            backgroundColor: Color.fromRGBO(29, 31, 43, 1),
                            itemName: '絮语密码',
                            attachedWidget: Text(
                              '未设置',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 14.sp,
                              ),
                            ),
                            icon: Icons.lock,
                            cb: () {
                              ChangePasswordRoute().push(context);
                            },
                          ),
                        ],
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12.w),
                        child: Text(
                          '绑定的信息可用于登录或身份安全验证，完善信息有助于保护账号安全',
                          style: TextStyle(color: Colors.grey, fontSize: 13.sp),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20.h),
                  Column(
                    spacing: 8.h,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      GroupTitleView(title: '找回与注销'),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          GroupItemView(
                            backgroundColor: Color.fromRGBO(29, 31, 43, 1),
                            isFirst: true,
                            itemName: '找回账号',
                            icon: Icons.find_in_page,
                            cb: () {
                              // 跳转手机号绑定页
                            },
                          ),
                          GroupItemView(
                            backgroundColor: Color.fromRGBO(29, 31, 43, 1),
                            itemName: '注销账号',
                            icon: Icons.exit_to_app,
                            cb: () {
                              // 跳转手机号绑定页
                            },
                          ),
                          GroupItemView(
                            needUnderline: false,
                            backgroundColor: Color.fromRGBO(29, 31, 43, 1),
                            itemName: '抖音安全中心',
                            icon: Icons.security,
                            cb: () {
                              // 跳转手机号绑定页
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
