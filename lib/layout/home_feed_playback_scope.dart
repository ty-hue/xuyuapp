import 'package:flutter/material.dart';

/// 由 [ShellPage] 注入：仅当底部栏选中首页分支且当前路由仍是 `/`（未被全屏页覆盖）时为 true。
/// [TabbarViewVideoList] 再与纵向 PageView 的当前条组合，驱动 [CustomVideoPlayer.isActive]。
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
