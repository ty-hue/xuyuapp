import 'package:bilbili_project/layout/home_feed_playback_scope.dart';
import 'package:bilbili_project/pages/Home/comps/video_list_item.dart';
import 'package:flutter/material.dart';
class TabbarViewVideoList extends StatefulWidget {
  TabbarViewVideoList({Key? key}) : super(key: key);

  @override
  _TabbarViewVideoListState createState() => _TabbarViewVideoListState();
}

class _TabbarViewVideoListState extends State<TabbarViewVideoList> {
  int _currentPage = 0;

  @override
  Widget build(BuildContext context) {
    final homeVisible = HomeFeedPlaybackScope.playbackAllowed(context);
    return PageView.builder(
      scrollDirection: Axis.vertical,
      itemCount: 2,
      onPageChanged: (index) {
        setState(() => _currentPage = index);
      },
      itemBuilder: (context, index) {
        return VideoListItem(
          key: ValueKey<int>(index),
          isActive: homeVisible && index == _currentPage,
        );
      },
    );
  }
}