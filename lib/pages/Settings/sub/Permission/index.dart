import 'package:bilbili_project/components/static_app_bar.dart';
import 'package:bilbili_project/components/with_statusBar_color.dart';
import 'package:bilbili_project/pages/Settings/comps/group_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class PermissionPage extends StatefulWidget {
  PermissionPage({Key? key}) : super(key: key);

  @override
  State<PermissionPage> createState() => _PermissionState();
}

class _PermissionState extends State<PermissionPage> {
  @override
  Widget build(BuildContext context) {
    return WithStatusbarColorView(
      statusBarColor: Color.fromRGBO(22, 24, 36, 1),
      child: Scaffold(
        appBar: StaticAppBar(
          title: '权限设置',
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
                    spacing: 8.h,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          GroupItemView(
                            isNeedIcon: false,
                            icon: Icons.view_list,
                            backgroundColor: Color.fromRGBO(29, 31, 43, 1),
                            isFirst: true,
                            itemName: '通讯录权限',
                            attachedWidget: Text(
                              '去设置',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 13.sp,
                              ),
                            ),
                            cb: () {},
                          ),

                          GroupItemView(
                            isNeedIcon: false,
                            icon: Icons.view_list,
                            backgroundColor: Color.fromRGBO(29, 31, 43, 1),
                            itemName: '相册权限',
                            attachedWidget: Text(
                              '去设置',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 13.sp,
                              ),
                            ),
                            cb: () {},
                          ),
                          GroupItemView(
                            isNeedIcon: false,
                            icon: Icons.view_list,
                            backgroundColor: Color.fromRGBO(29, 31, 43, 1),
                            itemName: '相机权限',
                            attachedWidget: Text(
                              '去设置',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 13.sp,
                              ),
                            ),
                            cb: () {},
                          ),
                          GroupItemView(
                            isNeedIcon: false,
                            icon: Icons.view_list,
                            backgroundColor: Color.fromRGBO(29, 31, 43, 1),
                            itemName: '麦克风权限',
                            attachedWidget: Text(
                              '去设置',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 13.sp,
                              ),
                            ),
                            cb: () {},
                          ),
                          GroupItemView(
                            isNeedIcon: false,
                            icon: Icons.view_list,
                            backgroundColor: Color.fromRGBO(29, 31, 43, 1),
                            itemName: '其他权限',
                            needUnderline: false,
                            attachedWidget: Text(
                              '去设置',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 13.sp,
                              ),
                            ),
                            cb: () {},
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
