import 'package:bilbili_project/components/default_dialog_skeleton.dart';
import 'package:bilbili_project/components/static_app_bar.dart';
import 'package:bilbili_project/components/with_statusBar_color.dart';
import 'package:bilbili_project/pages/Mine/sub/WatchHistory/comps/users_tab_view.dart';
import 'package:bilbili_project/pages/Mine/sub/WatchHistory/comps/video_tab_view.dart';
import 'package:bilbili_project/routes/app_router.dart';
import 'package:bilbili_project/routes/watch_history_routes/history_search_route.dart';
import 'package:bilbili_project/utils/DialogUtils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class WatchHistoryPage extends StatefulWidget {
  WatchHistoryPage({Key? key}) : super(key: key);

  @override
  _WatchHistoryPageState createState() => _WatchHistoryPageState();
}

class _WatchHistoryPageState extends State<WatchHistoryPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  @override
  void initState() {
    super.initState();
    _tabController = TabController(vsync: this, length: 2, initialIndex: 0);
  }

  @override
  Widget build(BuildContext context) {
    return WithStatusbarColorView(
      statusBarColor: Color.fromRGBO(29, 31, 43, 1),
      child: Scaffold(
        appBar: StaticAppBar(
          statusBarHeight: MediaQuery.of(context).padding.top,
          backgroundColor: Color.fromRGBO(29, 31, 43, 1),
          title: '观看历史',
          titleFontWeight: FontWeight.bold,
          actionSpacing: 20.w,
          actions: [
            GestureDetector(
              onTap: () {
                HistorySearchRoute().push(context);
              },
              child: Icon(
                FontAwesomeIcons.search,
                color: Colors.white,
                size: 20.sp,
              ),
            ),
            GestureDetector(
              onTap: () {
                // 弹出dialog
                DialogUtils(
                  DefaultDialgSkeleton(
                    rightBtnText: "清除",
                    onRightBtnTap: () {
                      Navigator.pop(context);
                    },
                    child: Container(
                      width: 250.w,
                      alignment: Alignment.center,
                      padding: EdgeInsets.symmetric(
                        horizontal: 10.w,
                        vertical: 20.h,
                      ),
                      child: Text(
                        '历史记录清除后无法恢复，是否清除全部记录',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color.fromRGBO(34, 35, 46, 1),
                          fontSize: 14.sp,
                        ),
                      ),
                    ),
                  ),
                ).showCustomDialog(context);
              },
              child: Icon(
                FontAwesomeIcons.trashAlt,
                color: Colors.white,
                size: 20.sp,
              ),
            ),
          ],
        ),
        body: Container(
          color: Color.fromRGBO(29, 31, 43, 1),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TabBar(
                padding: EdgeInsets.only(left: 20.w, right: 20.w), // ✅ 关键
                controller: _tabController,
                indicatorColor: const Color.fromARGB(255, 190, 173, 21),
                indicatorWeight: 3.h,
                indicatorSize: TabBarIndicatorSize.tab,
                labelPadding: EdgeInsets.symmetric(horizontal: 0.w), // ✅ 控制宽度
                dividerHeight: 1.h,
                dividerColor: Colors.white.withOpacity(0.2),
                tabs: [
                  Tab(text: '用户'),
                  Tab(text: '视频'),
                ],
                labelStyle: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                ),
                unselectedLabelStyle: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                ),
                labelColor: Colors.white,
                unselectedLabelColor: Colors.grey,
              ),
              Expanded(
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 10.h),
                  child: TabBarView(
                    controller: _tabController,
                    children: [UsersTabView(), VideoTabView()],
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
