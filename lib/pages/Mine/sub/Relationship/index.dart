import 'package:bilbili_project/pages/Mine/sub/Relationship/comps/tab-view-comp.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class RelationshipPage extends StatefulWidget {
  RelationshipPage({Key? key}) : super(key: key);

  @override
  State<RelationshipPage> createState() => _RelationshipPageState();
}

class _RelationshipPageState extends State<RelationshipPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  @override
  void initState() {
    super.initState();
    _tabController = TabController(vsync: this, length: 4);
  }

  Widget _buildTabBarWidget() {
    return Container(
      decoration: BoxDecoration(
        color: const Color.fromRGBO(22, 24, 35, 1), // 关键：吸顶后需要背景色来遮挡下方内容
        border: Border.all(width: 0, color: Color.fromRGBO(22, 22, 22, 1)),
      ),
      child: TabBar(
        padding: EdgeInsets.symmetric(horizontal: 20.w), // ✅ 关键
        controller: _tabController,
        indicatorColor: Colors.white,
        indicatorWeight: 3.h,
        indicatorSize: TabBarIndicatorSize.label,
        labelPadding: EdgeInsets.symmetric(horizontal: 8.w), // ✅ 控制宽度
        dividerHeight: 0,
        dividerColor: Colors.white.withOpacity(0.2),
        tabs: [
          Tab(text: '互关'),
          Tab(text: '关注'),
          Tab(text: '粉丝'),
          Tab(text: '朋友'),
        ],
        labelStyle: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold),
        unselectedLabelStyle: TextStyle(
          fontSize: 14.sp,
          fontWeight: FontWeight.bold,
        ),
        labelColor: Colors.white,
        unselectedLabelColor: Colors.grey,
      ),
    );
  }

  // 自定义navbar
  PreferredSizeWidget _buildNavBar(double statusBarHeight) {
    final double appBarTotalHeight = statusBarHeight + 46.h;
    return PreferredSize(
      preferredSize: Size.fromHeight(appBarTotalHeight),
      child: Container(
        decoration: BoxDecoration(
          color: Color.fromRGBO(22, 24, 35, 1),
          // 底部边框
          border: Border(
            bottom: BorderSide(width: 1, color: Colors.white.withOpacity(0.2)),
          ),
        ),
        margin: EdgeInsets.only(top: statusBarHeight + 6.h),
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        height: 40.h,
        child: Row(
          children: [
            GestureDetector(
              child: Icon(
                Icons.arrow_back_ios_new,
                color: Colors.white,
                size: 24.sp,
              ),
              onTap: () {
                context.pop();
              },
            ),
            Expanded(flex: 1, child: _buildTabBarWidget()),
            GestureDetector(
              child: Icon(Icons.settings, color: Colors.white, size: 24.sp),
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Color.fromRGBO(22, 24, 35, 1), // Android
        statusBarIconBrightness: Brightness.light, // Android 图标白色
        statusBarBrightness: Brightness.dark, // iOS 白字
      ),
      child: SafeArea(
        top: false,
        child: Scaffold(
          extendBodyBehindAppBar: true,
          appBar: _buildNavBar(MediaQuery.of(context).padding.top),
          body: Container(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 46.h + 20.h,
              left: 16.w,
              right: 16.w,
            ),
            color: Color.fromRGBO(22, 24, 35, 1),
            child: TabBarView(
              controller: _tabController,
              children: [
                TabViewComp(),
                TabViewComp(),
                TabViewComp(),
                TabViewComp(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
