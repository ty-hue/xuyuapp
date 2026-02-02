import 'package:bilbili_project/components/static_app_bar.dart';
import 'package:bilbili_project/components/with_statusBar_color.dart';
import 'package:bilbili_project/routes/app_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SwitchAccountPage extends StatefulWidget {
  SwitchAccountPage({Key? key}) : super(key: key);

  @override
  _SwitchAccountPageState createState() => _SwitchAccountPageState();
}

class _SwitchAccountPageState extends State<SwitchAccountPage> {
  @override
  Widget build(BuildContext context) {
    return WithStatusbarColorView(
      statusBarColor: Color.fromRGBO(29, 31, 43, 1),
      child: Scaffold(
        appBar: StaticAppBar(
          statusBarHeight: MediaQuery.of(context).padding.top,
          backgroundColor: Color.fromRGBO(29, 31, 43, 1),
          title: '切换账号',
        ),
        body: Container(
          padding: EdgeInsets.all(20.w),
          color: Color.fromRGBO(29, 31, 43, 1),
          child: Column(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  GestureDetector(
                    onTap: () {},
                    child: Material(
                      color: Colors.transparent, // 设置背景色为透明

                      child: InkWell(
                        splashColor: Color.fromRGBO(40, 42, 52, 1), // 点击时的水波纹颜色
                        highlightColor: Color.fromRGBO(
                          40,
                          42,
                          52,
                          1,
                        ), // 点击时的背景高亮颜色
                        onTap: () {},
                        child: Padding(
                          padding: EdgeInsets.all(12.w),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Row(
                                spacing: 14.w,
                                children: [
                                  // 头像
                                  ClipOval(
                                    child: Image.network(
                                      'https://img2.baidu.com/it/u=1474861633,2919292018&fm=253&fmt=auto&app=138&f=JPEG?w=500&h=500',
                                      width: 50.w,
                                      height: 50.w,
                                    ),
                                  ),
                                  Column(
                                    spacing: 4.h,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'llg',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 16.sp,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        '25 粉丝',
                                        style: TextStyle(
                                          color: Color.fromRGBO(
                                            107,
                                            109,
                                            121,
                                            1,
                                          ),
                                          fontSize: 12.sp,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              Container(
                                width: 20.w,
                                height: 20.w,
                                decoration: BoxDecoration(
                                  color: Color.fromRGBO(248, 49, 79, 1),
                                  borderRadius: BorderRadius.circular(10.w),
                                ),
                                child: Icon(
                                  Icons.check,
                                  color: Colors.white,
                                  size: 16.sp,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Material(
                color: Colors.transparent, // 设置背景色为透明
                child: InkWell(
                  splashColor: Color.fromRGBO(40, 42, 52, 1), // 点击时的水波纹颜色
                  highlightColor: Color.fromRGBO(40, 42, 52, 1), // 点击时的背景高亮颜色
                  onTap: () {
                    LoginRoute().push(context);
                  },
                  child: Padding(
                    padding: EdgeInsets.all(12.w),
                    child: Row(
                      spacing: 14.w,
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          width: 50.w,
                          height: 50.w,
                          decoration: BoxDecoration(
                            color: Color.fromRGBO(56, 58, 68, 1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.add,
                            color: Color.fromRGBO(124, 125, 131, 1),
                            size: 30.sp,
                          ),
                        ),
                        Text(
                          '添加或注册新账号',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
