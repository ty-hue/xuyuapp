import 'package:bilbili_project/components/static_app_bar.dart';
import 'package:bilbili_project/components/with_statusBar_color.dart';
import 'package:bilbili_project/routes/app_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AllFunctionPage extends StatefulWidget {
  AllFunctionPage({Key? key}) : super(key: key);

  @override
  _AllFunctionPageState createState() => _AllFunctionPageState();
}

class _AllFunctionPageState extends State<AllFunctionPage> {
  Widget _buildItem({
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        spacing: 4.h,
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white, size: 24.sp),
          Text(
            title,
            style: TextStyle(color: Colors.white, fontSize: 13.sp),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WithStatusbarColorView(
      statusBarColor: Color.fromRGBO(22, 22, 22, 1),
      child: Scaffold(
        appBar: StaticAppBar(
          statusBarHeight: MediaQuery.of(context).padding.top,
          backgroundColor: Color.fromRGBO(22, 22, 22, 1),
          title: '我的功能',
          titleFontWeight: FontWeight.bold,
        ),
        body: Container(
          padding: EdgeInsets.all(16.w),
          color: Color.fromRGBO(22, 22, 22, 1),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: 24.h,
                children: [
                  Text(
                    '主页展示',
                    style: TextStyle(
                      color: Color.fromRGBO(119, 119, 119, 1),
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.left,
                  ),
                  Row(
                    spacing: 30.w,
                    children: [
                      _buildItem(
                        title: '观看历史',
                        icon: Icons.history,
                        onTap: () {
                          WatchHistoryPageRoute().push(context);
                        },
                      ),
                      _buildItem(
                        title: '数据分析',
                        icon: Icons.analytics,
                        onTap: () {
                          DataAnalysisPageRoute().push(context);
                        },
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 40.h),
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: 24.h,
                children: [
                  Text(
                    '更多功能',
                    style: TextStyle(
                      color: Color.fromRGBO(119, 119, 119, 1),
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.left,
                  ),
                  Row(
                    spacing: 30.w,
                    children: [
                      _buildItem(
                        title: '常访问的人',
                        icon: Icons.people,
                        onTap: () {
                          WatchHistoryPageRoute().push(context);
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
    );
  }
}
