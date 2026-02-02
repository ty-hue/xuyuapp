import 'package:bilbili_project/components/static_app_bar.dart';
import 'package:bilbili_project/components/with_statusBar_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AboutPage extends StatefulWidget {
  AboutPage({Key? key}) : super(key: key);

  @override
  _AboutPageState createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  Widget _buildItem({
    required String title,
    String? subTitle,
    Widget? tailChild,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: onTap,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            spacing: subTitle == null ? 0 : 4.h,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(color: Colors.white, fontSize: 16.sp),
              ),
              if (subTitle != null)
                Text(
                  subTitle,
                  style: TextStyle(color: Colors.grey, fontSize: 13.sp),
                ),
            ],
          ),
          tailChild ??
              Icon(
                Icons.arrow_forward_ios,
                color: Color.fromRGBO(137, 139, 148, 1),
                size: 20.sp,
              ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WithStatusbarColorView(
      statusBarColor: Color.fromRGBO(29, 31, 43, 1),
      child: Scaffold(
        appBar: StaticAppBar(
          statusBarHeight: MediaQuery.of(context).padding.top,
          backgroundColor: Color.fromRGBO(29, 31, 43, 1),
        ),
        body: Container(
          color: Color.fromRGBO(29, 31, 43, 1),
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
          child: Column(
            spacing: 30.h,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Column(
                spacing: 10.h,
                mainAxisSize: MainAxisSize.min,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10.r),
                    child: Image.asset(
                      'lib/assets/app_logo.png',
                      width: 70.w,
                      height: 70.h,
                    ),
                  ),
                  Text(
                    '絮语',
                    style: TextStyle(color: Colors.white, fontSize: 18.sp),
                  ),
                  Text(
                    'Version 1.0.0',
                    style: TextStyle(color: Colors.grey, fontSize: 13.sp),
                  ),
                ],
              ),
              Column(
                spacing: 30.h,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildItem(
                    title: '版本更新',
                    onTap: () {
                      // 处理点击事件
                      print('版本更新');
                    },
                  ),
                  _buildItem(
                    title: '访问絮语官网',
                    subTitle: 'https://www.xuyushe.com',
                    onTap: () {
                      // 处理点击事件
                      print('访问絮语官网');
                    },
                  ),
                  _buildItem(
                    title: '絮语官方邮箱',
                    subTitle: 'service@xuyushe.com',
                    tailChild: Text(
                      '点击复制',
                      style: TextStyle(color: Colors.grey, fontSize: 14.sp),
                    ),
                    onTap: () {
                      // 处理点击事件
                      print('复制邮箱');
                    },
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
