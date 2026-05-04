import 'package:bilbili_project/components/with_statusBar_color.dart';
import 'package:bilbili_project/pages/Home/comps/tabbar_view_video_list.dart';
import 'package:bilbili_project/pages/Home/data/home_feed_mock.dart';
import 'package:flutter/material.dart';

/// 朋友：与首页相同的纵向视频流 UI，顶栏无 TabBar / 搜索；
/// 数据为「互相关注」作者发布内容（当前为 [kFriendMutualFollowMockFeed]，可换 API）。
class FriendPage extends StatefulWidget {
  FriendPage({Key? key}) : super(key: key);

  @override
  State<FriendPage> createState() => _FriendPageState();
}

class _FriendPageState extends State<FriendPage> {
  /// 清屏播放等与首页一致的交互（由 [TabbarViewVideoList] / [HomeFeedPlaybackScope] 协同）。
  late final ValueNotifier<bool> _clearPlaybackNotifier;

  @override
  void initState() {
    super.initState();
    _clearPlaybackNotifier = ValueNotifier<bool>(false);
  }

  @override
  void dispose() {
    _clearPlaybackNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WithStatusbarColorView(
      statusBarColor: Colors.transparent,
      child: Container(
        color: Colors.black87,
        child: TabbarViewVideoList(
          key: const PageStorageKey<String>('friend_mutual_follow_feed'),
          tabVisible: true,
          feed: kFriendMutualFollowMockFeed,
          clearPlaybackNotifier: _clearPlaybackNotifier,
        ),
      ),
    );
  }
}
