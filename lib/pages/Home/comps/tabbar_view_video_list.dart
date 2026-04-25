import 'package:bilbili_project/layout/home_feed_playback_scope.dart';
import 'package:bilbili_project/pages/Home/comps/video_list_item.dart';
import 'package:bilbili_project/pages/Home/data/home_feed_mock.dart';
import 'package:flutter/material.dart';

class TabbarViewVideoList extends StatefulWidget {
  TabbarViewVideoList({Key? key, List<HomeFeedItem>? feed})
      : feed = feed ?? kHomeMockFeed,
        super(key: key);

  /// 推荐 / 关注等 Tab 可传不同列表；默认 `kHomeMockFeed`。
  final List<HomeFeedItem> feed;

  @override
  _TabbarViewVideoListState createState() => _TabbarViewVideoListState();
}

class _TabbarViewVideoListState extends State<TabbarViewVideoList> {
  int _currentPage = 0;

  @override
  Widget build(BuildContext context) {
    final homeVisible = HomeFeedPlaybackScope.playbackAllowed(context);
    final items = widget.feed;
    return PageView.builder(
      scrollDirection: Axis.vertical,
      itemCount: items.length,
      onPageChanged: (index) {
        setState(() => _currentPage = index);
      },
      itemBuilder: (context, index) {
        final item = items[index];
        return VideoListItem(
          key: ValueKey<String>(item.id),
          item: item,
          isActive: homeVisible && index == _currentPage,
        );
      },
    );
  }
}