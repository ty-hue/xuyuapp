import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'comps/tab_view_comp.dart';

class ResultView extends StatefulWidget {
  final double statusBarHeight;
  ResultView({Key? key, required this.statusBarHeight}) : super(key: key);

  @override
  State<ResultView> createState() => _ResultViewState();
}

class _ResultViewState extends State<ResultView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  @override
  void initState() {
    super.initState();
    _tabController = TabController(vsync: this, length: 5);
  }

  Widget _buildTabBarWidget() {
    return Container(
      width: double.infinity,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: const Color.fromRGBO(22, 24, 35, 1), // 关键：吸顶后需要背景色来遮挡下方内容
        border: Border.all(width: 0, color: Color.fromRGBO(22, 22, 22, 1)),
      ),
      child: TabBar(
        padding: EdgeInsets.only(left: 20.w,right: 20.w), // ✅ 关键
        controller: _tabController,
        indicatorColor: const Color.fromARGB(255, 190, 173, 21),
        indicatorWeight: 3.h,
        indicatorSize: TabBarIndicatorSize.tab,
        labelPadding: EdgeInsets.symmetric(horizontal: 0.w), // ✅ 控制宽度
        dividerHeight: 1.h,
        dividerColor: Colors.white.withOpacity(0.2),
        tabs: [
          Tab(text: '喜欢'),
          Tab(text: '收藏'),
          Tab(text: '作品'),
          Tab(text: '私密'),
          Tab(text: '观看历史'),
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

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Color.fromRGBO(22, 24, 35, 1),
      padding: EdgeInsets.only(top: widget.statusBarHeight + 46.h + 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildTabBarWidget(),
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 10.h),
              color: Color.fromRGBO(22, 24, 35, 1),
              child: TabBarView(
                controller: _tabController,
                children: [
                  TabViewComp(),
                  TabViewComp(),
                  TabViewComp(),
                  TabViewComp(),
                  TabViewComp(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
