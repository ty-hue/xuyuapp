import 'package:bilbili_project/pages/Create/comps/music_tab_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SelectMusicPane extends StatefulWidget {
  final Function toggleShowPane;
  SelectMusicPane({Key? key, required this.toggleShowPane}) : super(key: key);

  @override
  _SelectMusicPaneState createState() => _SelectMusicPaneState();
}

class _SelectMusicPaneState extends State<SelectMusicPane>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  @override
  void initState() {
    super.initState();
    _tabController = TabController(vsync: this, length: 4);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 搜索框
        GestureDetector(
          onTap: () {
            print('点击了搜索框');
          },
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: Color.fromRGBO(241, 241, 243, 1),
              borderRadius: BorderRadius.all(Radius.circular(10.r)),
            ),
            child: Row(
              spacing: 8.w,
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Icon(
                  Icons.search,
                  color: Color.fromRGBO(137, 137, 139, 1),
                  size: 24.sp,
                ),
                Text(
                  '搜索歌名',
                  style: TextStyle(
                    color: Color.fromRGBO(137, 137, 139, 1),
                    fontSize: 14.sp,
                    letterSpacing: 2.sp,
                  ),
                ),
              ],
            ),
          ),
        ),
        // TabBar 和 导入音频按钮
        Container(
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: Color.fromRGBO(228, 228, 228, 1),
                width: 1.w,
              ),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: TabBar(
                  controller: _tabController,
                  indicatorColor: Colors.black, // 选中下划线颜色
                  labelColor: Colors.black, // 选中项文字的颜色
                  unselectedLabelColor: Color.fromRGBO(
                    124,
                    124,
                    124,
                    1,
                  ), // 未选中文本的颜色
                  dividerColor: Colors.transparent, // 分割线颜色
                  // 选中文本的字体样式
                  labelStyle: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                  ),
                  // 未选择文本的字体样式
                  unselectedLabelStyle: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                  ),
                  tabs: [
                    Tab(text: '推荐'),
                    Tab(text: '热门'),
                    Tab(text: '收藏'),
                    Tab(text: '用过'),
                  ],
                ),
              ),
              SizedBox(width: 30.w),
              // 导入音频按钮
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    // 切换显示选择音乐面板还是上传音乐面板
                    widget.toggleShowPane();
                  },
                  borderRadius: BorderRadius.all(Radius.circular(10.r)),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 8.h,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(10.r)),
                    ),
                    child: Row(
                      spacing: 8.w,
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        // 播放音乐图标
                        Icon(
                          Icons.upload_file,
                          color: Color.fromRGBO(43, 42, 47, 1),
                          size: 20.sp,
                        ),
                        Text(
                          '导入音频',
                          style: TextStyle(
                            color: Color.fromRGBO(43, 42, 47, 1),
                            fontSize: 13.sp,
                            letterSpacing: 2.sp,
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
        // TabBarView (内容区域)
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              MusicTabView(),
              MusicTabView(),
              MusicTabView(),
              MusicTabView(),
            ],
          ),
        ),
      ],
    );
  }
}
