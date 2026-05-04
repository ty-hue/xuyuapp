import 'package:bilbili_project/components/with_statusBar_color.dart';
import 'package:bilbili_project/pages/Home/comps/tabbar_view_video_list.dart';
import 'package:bilbili_project/routes/app_router.dart';
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
  int _currentTabIndex = 0;

  /// 任一视频处于「清屏播放」时为 true：隐藏顶部 TabBar / 搜索与底部壳无关。
  late final ValueNotifier<bool> _clearPlaybackNotifier;

  @override
  void initState() {
    super.initState();
    _clearPlaybackNotifier = ValueNotifier<bool>(false);
    _tabController = TabController(vsync: this, length: 2);
    _tabController.addListener(_handleTabChange);
  }

  void _handleTabChange() {
    if (!_tabController.indexIsChanging && _currentTabIndex != _tabController.index) {
      setState(() => _currentTabIndex = _tabController.index);
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    _clearPlaybackNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WithStatusbarColorView(
      statusBarColor: Colors.transparent,
      child: Container(
        color: Colors.black87,
        child: ValueListenableBuilder<bool>(
          valueListenable: _clearPlaybackNotifier,
          builder: (context, hideTopChrome, _) {
            return Stack(
              children: [
                Positioned.fill(
                  child: TabBarView(
                    controller: _tabController,
                    physics: hideTopChrome
                        ? const NeverScrollableScrollPhysics()
                        : null,
                    children: [
                      TabbarViewVideoList(
                        key: const PageStorageKey<String>('home_feed_tab_follow'),
                        tabVisible: _currentTabIndex == 0,
                        clearPlaybackNotifier: _clearPlaybackNotifier,
                      ),
                      TabbarViewVideoList(
                        key:
                            const PageStorageKey<String>('home_feed_tab_recommend'),
                        tabVisible: _currentTabIndex == 1,
                        clearPlaybackNotifier: _clearPlaybackNotifier,
                      ),
                    ],
                  ),
                ),
                if (!hideTopChrome)
                  Positioned(
                    top: MediaQuery.paddingOf(context).top,
                    left: 0,
                    right: 0,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(width: 60.w, height: 60.h),
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal:
                                  MediaQuery.sizeOf(context).width * 0.14,
                            ),
                            child: TabBar(
                              controller: _tabController,
                              indicatorWeight: 1.h,
                              indicatorColor: Colors.white,
                              labelColor: Colors.white,
                              indicatorSize: TabBarIndicatorSize.label,
                              unselectedLabelColor: const Color.fromRGBO(
                                187,
                                188,
                                191,
                                1,
                              ),
                              dividerColor: Colors.transparent,
                              labelStyle: TextStyle(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.bold,
                              ),
                              unselectedLabelStyle: TextStyle(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.bold,
                              ),
                              tabs: const [
                                Tab(text: '关注'),
                                Tab(text: '推荐'),
                              ],
                            ),
                          ),
                        ),
                        GestureDetector(
                          behavior: HitTestBehavior.translucent,
                          onTap: () {
                            GlobalSearchRoute().push(context);
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
            );
          },
        ),
      ),
    );
  }
}
