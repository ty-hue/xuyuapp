import 'package:bilbili_project/layout/home_feed_playback_scope.dart';
import 'package:bilbili_project/pages/Home/comps/video_list_item.dart';
import 'package:bilbili_project/pages/Home/data/home_feed_mock.dart';
import 'package:flutter/material.dart';

class TabbarViewVideoList extends StatefulWidget {
  TabbarViewVideoList({
    Key? key,
    List<HomeFeedItem>? feed,
    this.tabVisible = true,
    required this.clearPlaybackNotifier,
  })  : feed = feed ?? kHomeMockFeed,
        super(key: key);

  /// 推荐 / 关注等 Tab 可传不同列表；默认 `kHomeMockFeed`。
  final List<HomeFeedItem> feed;
  final bool tabVisible;

  /// 与 [HomePage] 共享：清屏播放时同步为 true。
  final ValueNotifier<bool> clearPlaybackNotifier;

  @override
  _TabbarViewVideoListState createState() => _TabbarViewVideoListState();
}

class _TabbarViewVideoListState extends State<TabbarViewVideoList>
    with AutomaticKeepAliveClientMixin {
  int _currentPage = 0;

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final homeVisible = HomeFeedPlaybackScope.playbackAllowed(context);
    final items = widget.feed;
    return ValueListenableBuilder<bool>(
      valueListenable: widget.clearPlaybackNotifier,
      builder: (context, clear, _) {
        return PageView.builder(
          scrollDirection: Axis.vertical,
          physics:
              clear ? const NeverScrollableScrollPhysics() : null,
          itemCount: items.length,
          onPageChanged: (index) {
            setState(() => _currentPage = index);
          },
          itemBuilder: (context, index) {
            final item = items[index];
            return VideoListItem(
              key: ValueKey<String>(item.id),
              item: item,
              isActive:
                  homeVisible && widget.tabVisible && index == _currentPage,
              clearPlaybackNotifier: widget.clearPlaybackNotifier,
            );
          },
        );
      },
    );
  }
}