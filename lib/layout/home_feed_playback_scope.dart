import 'package:flutter/material.dart';

/// 由 [ShellPage] 注入：选中首页 (`/`) 或朋友 (`/friend`) 等分支且顶层路由仍为该分支根路径时，
/// 纵向视频才可播。[TabbarViewVideoList] 与 PageView 当前条驱动 [CustomVideoPlayer.isActive]。
class HomeFeedPlaybackScope extends InheritedWidget {
  const HomeFeedPlaybackScope({
    super.key,
    required this.allowPlayback,
    required super.child,
  });

  final bool allowPlayback;

  static bool playbackAllowed(BuildContext context) {
    final scope =
        context.dependOnInheritedWidgetOfExactType<HomeFeedPlaybackScope>();
    return scope?.allowPlayback ?? false;
  }

  @override
  bool updateShouldNotify(HomeFeedPlaybackScope oldWidget) {
    return oldWidget.allowPlayback != allowPlayback;
  }
}
