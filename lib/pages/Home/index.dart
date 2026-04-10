import 'package:bilbili_project/components/with_statusBar_color.dart';
import 'package:bilbili_project/pages/Home/comps/tabbar_view_video_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class HomePage extends StatefulWidget {
  HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  @override
  void initState() {
    super.initState();
    _tabController = TabController(vsync: this, length: 2);
  }

  @override
  Widget build(BuildContext context) {
    return WithStatusbarColorView(
      statusBarColor: Colors.transparent,
      child: Container(
        color: Colors.black87,
        child: Stack(
          children: [
            // Tabview区域
            Positioned.fill(
              child: TabBarView(
                controller: _tabController,
                children: [
                  TabbarViewVideoList(),
                  TabbarViewVideoList(),
                ],
              ),
            ),
            Positioned(
              top: MediaQuery.of(context).padding.top,
              left: 0,
              right: 0,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(width: 60.w, height: 60.h),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: MediaQuery.of(context).size.width * 0.14,
                      ),
                      child: TabBar(
                        controller: _tabController,
                        indicatorWeight: 1.h,
                        indicatorColor: Colors.white, // 选中下划线颜色
                        labelColor: Colors.white, // 选中项文字的颜色
                        unselectedLabelColor: Color.fromRGBO(
                          187,
                          188,
                          191,
                          1,
                        ), // 未选中文本的颜色
                        dividerColor: Colors.transparent, // 分割线颜色
                        // 选中文本的字体样式
                        labelStyle: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                        ),
                        // 未选择文本的字体样式
                        unselectedLabelStyle: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                        ),
                        tabs: [
                          Tab(text: '关注'),
                          Tab(text: '推荐'),
                        ],
                      ),
                    ),
                  ),
                  GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: () {
                      print('搜索');
                    },
                    child: Container(
                      width: 60.w,
                      height: 60.h,
                      alignment: Alignment.center,
                      child: Icon(
                        FontAwesomeIcons.search,
                        color: Colors.white,
                        size: 22.sp,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
