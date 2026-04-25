import 'package:bilbili_project/components/with_statusBar_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:go_router/go_router.dart';

/// 消息列表中的「互动消息」入口页：综合互动 / 新关注我的。
class InteractiveMessagesPage extends StatefulWidget {
  const InteractiveMessagesPage({super.key});

  @override
  State<InteractiveMessagesPage> createState() => _InteractiveMessagesPageState();
}

enum _BodyTab { allInteractions, newFollowers }

class _InteractiveMessagesPageState extends State<InteractiveMessagesPage> {
  static const Color _cPrimary = Color(0xFFFF2D55);
  static const Color _cDivider = Color(0xFFEEEEEE);
  static const Color _cMeta = Color(0xFF999999);
  static const Color _cBody = Color(0xFF333333);
  static const Color _cTagBg = Color(0xFFF2F2F2);
  static const Color _cCloseFriend = Color(0xFFE8E0FF);

  _BodyTab _tab = _BodyTab.allInteractions;

  /// 「互动消息」下拉面板的当前筛选项（演示）
  String _messageFilterId = 'all_msg';

  /// 筛选面板打开时为 true，用于三角箭头朝上动画。
  bool _filterMenuOpen = false;

  final List<_FeedItem> _feedItems = const [
    _FeedItem(
      userName: '海阔天空',
      avatarUrl:
          'https://q8.itc.cn/q_70/images03/20250114/d9d8d1106f454c2b83ea395927bfc020.jpeg',
      badge: _UserBadge.fan,
      overlay: _AvatarOverlay.reply,
      content: '回复: 说得对，我也觉得这块实现可以更简单一点。',
      dateText: '4月12日',
      thumbUrl:
          'https://q2.itc.cn/q_70/images03/20250623/337b5e62a9444bcda5d4b1aee5cddf54.jpeg',
      showInlineActions: true,
    ),
    _FeedItem(
      userName: 'CF 张琦 (通行证)',
      avatarUrl:
          'https://q6.itc.cn/q_70/images03/20250306/355fba6a5cb049f5b98c2ed9f03cc5e1.jpeg',
      badge: _UserBadge.mutual,
      overlay: _AvatarOverlay.like,
      content: '赞了你的评论: 周末一起去爬山吗？',
      dateText: '2025年12月24日',
      thumbUrl:
          'https://wx4.sinaimg.cn/mw690/70e1e519ly1i9xgh6g04ej20sg0sggsj.jpg',
    ),
    _FeedItem(
      userName: '小红薯',
      avatarUrl:
          'https://q2.itc.cn/q_70/images03/20250623/337b5e62a9444bcda5d4b1aee5cddf54.jpeg',
      badge: _UserBadge.closeFriend,
      overlay: _AvatarOverlay.mention,
      content: '提到了你: @llg 看下这个视频',
      dateText: '4月8日',
      thumbUrl:
          'https://ww3.sinaimg.cn/mw690/6c79248dly1iba2jh0rpzj20wr0wb42e.jpg',
    ),
    _FeedItem(
      userName: '视频创作者',
      avatarUrl:
          'https://wx4.sinaimg.cn/mw690/70e1e519ly1i9xgh6g04ej20sg0sggsj.jpg',
      overlay: _AvatarOverlay.like,
      content: '赞了你分享的视频',
      dateText: '2025年11月2日',
      thumbUrl:
          'https://q8.itc.cn/q_70/images03/20250114/d9d8d1106f454c2b83ea395927bfc020.jpeg',
    ),
  ];

  final List<_NewFollowerItem> _followers = const [
    _NewFollowerItem(
      userName: 'CF 张琦 (通行证)',
      avatarUrl:
          'https://q6.itc.cn/q_70/images03/20250306/355fba6a5cb049f5b98c2ed9f03cc5e1.jpeg',
      mutual: true,
      timeLine: '周三 关注了你',
      initialAction: _FollowerAction.sayHello,
    ),
    _NewFollowerItem(
      userName: '昵称示例A',
      avatarUrl:
          'https://q8.itc.cn/q_70/images03/20250114/d9d8d1106f454c2b83ea395927bfc020.jpeg',
      mutual: false,
      timeLine: '2025年11月2日 关注了你',
      initialAction: _FollowerAction.followBack,
    ),
    _NewFollowerItem(
      userName: '昵称示例B',
      avatarUrl:
          'https://q2.itc.cn/q_70/images03/20250623/337b5e62a9444bcda5d4b1aee5cddf54.jpeg',
      mutual: false,
      timeLine: '周一 关注了你',
      initialAction: _FollowerAction.following,
    ),
  ];

  /// 顶栏总高度（须与 [_buildAppBar] 外层 [SizedBox.height] 一致，供下拉锚点使用）。
  double get _appBarTotalHeight => 53.h;

  /// 仅在已处于「互动消息」内容时调用：展开筛选面板。
  void _showInteractiveFilterPanel() {
    final topInset = MediaQuery.paddingOf(context).top;
    final headerBottom = topInset + _appBarTotalHeight;

    setState(() => _filterMenuOpen = true);

    showGeneralDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: Colors.black.withValues(alpha: 0.45),
      transitionDuration: const Duration(milliseconds: 420),
      pageBuilder: (dialogContext, animation, secondaryAnimation) {
        return _AnimatedFilterDropdown(
          animation: animation,
          headerBottom: headerBottom,
          messageFilterId: _messageFilterId,
          primary: _cPrimary,
          onSelect: (id) {
            setState(() => _messageFilterId = id);
            Navigator.of(dialogContext).pop();
          },
          onDismissBarrier: () => Navigator.of(dialogContext).pop(),
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return child;
      },
    ).then((_) {
      if (mounted) setState(() => _filterMenuOpen = false);
    });
  }

  void _onInteractiveTitleTap() {
    if (_tab == _BodyTab.newFollowers) {
      setState(() => _tab = _BodyTab.allInteractions);
      return;
    }
    _showInteractiveFilterPanel();
  }

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.paddingOf(context).top;
    return WithStatusbarColorView(
      statusBarColor: Colors.white,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Column(
          children: [
            SizedBox(height: top),
            _buildAppBar(context),
            Expanded(
              child: SlidableAutoCloseBehavior(
                child: _tab == _BodyTab.allInteractions ? _buildFeedList() : _buildNewFollowersList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    /// 与右侧占位同宽，使中间 Tab 组在屏幕水平方向居中。
    final double sideSlotWidth = 88.w;

    return SizedBox(
      height: _appBarTotalHeight,
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: _cDivider, width: 1)),
        ),
        child: Padding(
          padding: EdgeInsets.fromLTRB(4.w, 8.h, 4.w, 7.h),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: sideSlotWidth,
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Padding(
                    padding: EdgeInsets.only(left: 2.w),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () => context.pop(),
                          child: Icon(Icons.arrow_back_ios_new, size: 24.sp, color: Colors.black),
                        ),
                        SizedBox(width: 6.w),
                        Container(
                          width: 18.r,
                          height: 18.r,
                          alignment: Alignment.center,
                          decoration: const BoxDecoration(color: _cPrimary, shape: BoxShape.circle),
                          child: Text(
                            '1',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w600,
                              height: 1,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Align(
                  alignment: Alignment.topCenter,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: _onInteractiveTitleTap,
                        child: _HeaderTabColumn(
                          active: _tab == _BodyTab.allInteractions,
                          underlineWidth: 22.w,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '互动消息',
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: _tab == _BodyTab.allInteractions ? FontWeight.w700 : FontWeight.w400,
                                  color: Colors.black,
                                ),
                              ),
                              AnimatedRotation(
                                turns: _filterMenuOpen && _tab == _BodyTab.allInteractions ? 0.5 : 0,
                                duration: const Duration(milliseconds: 400),
                                curve: Curves.easeOutCubic,
                                child: Icon(Icons.arrow_drop_down, size: 22.sp, color: Colors.black87),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(width: 24.w),
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () => setState(() => _tab = _BodyTab.newFollowers),
                        child: _HeaderTabColumn(
                          active: _tab == _BodyTab.newFollowers,
                          underlineWidth: 22.w,
                          child: Text(
                            '新关注我的',
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: _tab == _BodyTab.newFollowers ? FontWeight.w700 : FontWeight.w400,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(width: sideSlotWidth),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeedList() {
    return ListView.separated(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.only(bottom: 24.h),
      itemCount: _feedItems.length,
      separatorBuilder: (context, index) => const Divider(height: 1, thickness: 1, color: _cDivider),
      itemBuilder: (context, index) {
        final item = _feedItems[index];
        return Slidable(
          key: ValueKey('interactive_feed_${item.userName}_$index'),
          groupTag: 'interactive_messages_feed',
          closeOnScroll: true,
          endActionPane: ActionPane(
            motion: const DrawerMotion(),
            extentRatio: 0.36,
            children: [
              CustomSlidableAction(
                flex: 1,
                backgroundColor: const Color(0xFF555555),
                foregroundColor: Colors.white,
                onPressed: (_) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('不再通知（演示）')),
                  );
                },
                child: Center(
                  child: Text(
                    '不再通知',
                    style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500, color: Colors.white),
                  ),
                ),
              ),
              CustomSlidableAction(
                flex: 1,
                backgroundColor: const Color(0xFFFF3B30),
                foregroundColor: Colors.white,
                onPressed: (_) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('删除（演示）')),
                  );
                },
                child: Center(
                  child: Text(
                    '删除',
                    style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
          child: _FeedListTile(
            item: item,
            cMeta: _cMeta,
            cBody: _cBody,
            cTagBg: _cTagBg,
            cCloseFriend: _cCloseFriend,
            onTap: () {},
          ),
        );
      },
    );
  }

  Widget _buildNewFollowersList() {
    return ListView.separated(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.only(bottom: 24.h),
      itemCount: _followers.length,
      separatorBuilder: (context, index) => const Divider(height: 1, thickness: 1, color: _cDivider),
      itemBuilder: (context, index) {
        final item = _followers[index];
        return Slidable(
          key: ValueKey('interactive_follow_${item.userName}_$index'),
          groupTag: 'interactive_messages_followers',
          closeOnScroll: true,
          endActionPane: ActionPane(
            motion: const DrawerMotion(),
            extentRatio: 0.36,
            children: [
              CustomSlidableAction(
                flex: 1,
                backgroundColor: const Color(0xFFFF9500),
                foregroundColor: Colors.white,
                onPressed: (_) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('移除粉丝（演示）')),
                  );
                },
                child: Center(
                  child: Text(
                    '移除粉丝',
                    style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600, color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              CustomSlidableAction(
                flex: 1,
                backgroundColor: const Color(0xFFFF3B30),
                foregroundColor: Colors.white,
                onPressed: (_) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('删除（演示）')),
                  );
                },
                child: Center(
                  child: Text(
                    '删除',
                    style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
          child: _NewFollowerTile(item: item, cPrimary: _cPrimary, cTagBg: _cTagBg),
        );
      },
    );
  }
}

/// 下拉面板：全宽、自上而下一行行展开高度。
class _AnimatedFilterDropdown extends StatelessWidget {
  const _AnimatedFilterDropdown({
    required this.animation,
    required this.headerBottom,
    required this.messageFilterId,
    required this.primary,
    required this.onSelect,
    required this.onDismissBarrier,
  });

  final Animation<double> animation;
  final double headerBottom;
  final String messageFilterId;
  final Color primary;
  final void Function(String id) onSelect;
  final VoidCallback onDismissBarrier;

  static double _rowHeightFactor(double animationValue, int index) {
    const stagger = 0.09;
    final start = (index * stagger).clamp(0.0, 0.82);
    final end = (0.34 + index * stagger).clamp(0.26, 1.0);
    final v = animationValue;
    if (v <= start) return 0;
    if (v >= end) return 1;
    return Curves.easeOutCubic.transform((v - start) / (end - start));
  }

  @override
  Widget build(BuildContext context) {
    final rows = <Widget>[
      _FilterPanelRow(
        id: 'all_msg',
        label: '全部消息',
        leading: Icon(Icons.bolt_outlined, size: 22.sp, color: const Color(0xFF888888)),
        selectedId: messageFilterId,
        primary: primary,
        onTap: onSelect,
      ),
      _FilterPanelRow(
        id: 'likes',
        label: '赞与收藏',
        leading: Icon(Icons.favorite_border, size: 22.sp, color: const Color(0xFF888888)),
        selectedId: messageFilterId,
        primary: primary,
        onTap: onSelect,
      ),
      _FilterPanelRow(
        id: 'mentions',
        label: '提及',
        leading: Icon(Icons.alternate_email, size: 22.sp, color: const Color(0xFF888888)),
        selectedId: messageFilterId,
        primary: primary,
        onTap: onSelect,
      ),
      _FilterPanelRow(
        id: 'comments_in',
        label: '收到的评论',
        leading: Icon(Icons.sms_outlined, size: 22.sp, color: const Color(0xFF888888)),
        selectedId: messageFilterId,
        primary: primary,
        onTap: onSelect,
      ),
      _FilterPanelRow(
        id: 'comments_out',
        label: '发出的评论',
        leading: Icon(Icons.chat_bubble_outline, size: 22.sp, color: const Color(0xFF888888)),
        selectedId: messageFilterId,
        primary: primary,
        onTap: onSelect,
      ),
      _FilterPanelRow(
        id: 'danmaku',
        label: '收到的弹幕',
        leading: Container(
          width: 22.r,
          height: 22.r,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFF888888)),
            borderRadius: BorderRadius.circular(4.r),
          ),
          child: Text('弹', style: TextStyle(fontSize: 11.sp, color: const Color(0xFF888888), fontWeight: FontWeight.w600)),
        ),
        selectedId: messageFilterId,
        primary: primary,
        onTap: onSelect,
      ),
    ];

    return Material(
      type: MaterialType.transparency,
      child: Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onDismissBarrier,
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            top: headerBottom,
            child: Material(
              color: Colors.white,
              elevation: 2,
              shadowColor: Colors.black12,
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(12.r)),
              clipBehavior: Clip.antiAlias,
              child: AnimatedBuilder(
                animation: animation,
                builder: (context, _) {
                  final v = animation.value;
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      for (int i = 0; i < rows.length; i++)
                        ClipRect(
                          child: Align(
                            alignment: Alignment.topCenter,
                            heightFactor: _rowHeightFactor(v, i).clamp(0.0, 1.0),
                            child: rows[i],
                          ),
                        ),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 顶栏单个 Tab：标题 + 短下划线；与左侧返回行 [CrossAxisAlignment.start] 对齐，保证与标题垂直对齐。
class _HeaderTabColumn extends StatelessWidget {
  const _HeaderTabColumn({
    required this.active,
    required this.child,
    required this.underlineWidth,
  });

  final bool active;
  final Widget child;
  final double underlineWidth;

  @override
  Widget build(BuildContext context) {
    return IntrinsicWidth(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Center(child: child),
          SizedBox(height: 4.h),
          SizedBox(
            height: 3.h,
            child: Center(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOutCubic,
                width: active ? underlineWidth : 0,
                height: 3.h,
                decoration: BoxDecoration(
                  color: active ? Colors.black : Colors.transparent,
                  borderRadius: BorderRadius.circular(1.5.r),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterPanelRow extends StatelessWidget {
  const _FilterPanelRow({
    required this.id,
    required this.label,
    required this.leading,
    required this.selectedId,
    required this.primary,
    required this.onTap,
  });

  final String id;
  final String label;
  final Widget leading;
  final String selectedId;
  final Color primary;
  final void Function(String id) onTap;

  @override
  Widget build(BuildContext context) {
    final selected = selectedId == id;
    return Material(
      color: Colors.white,
      child: InkWell(
        onTap: () => onTap(id),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
          child: Row(
            children: [
              SizedBox(width: 24.w, child: Center(child: leading)),
              SizedBox(width: 12.w),
              Expanded(
                child: Text(label, style: TextStyle(fontSize: 15.sp, color: Colors.black, fontWeight: FontWeight.w400)),
              ),
              if (selected) Icon(Icons.check, color: primary, size: 22.sp),
            ],
          ),
        ),
      ),
    );
  }
}

enum _UserBadge { none, fan, mutual, closeFriend }

enum _AvatarOverlay { none, reply, like, mention }

class _FeedItem {
  const _FeedItem({
    required this.userName,
    required this.avatarUrl,
    required this.content,
    required this.dateText,
    required this.thumbUrl,
    this.badge = _UserBadge.none,
    this.overlay = _AvatarOverlay.none,
    this.showInlineActions = false,
  });

  final String userName;
  final String avatarUrl;
  final String content;
  final String dateText;
  final String thumbUrl;
  final _UserBadge badge;
  final _AvatarOverlay overlay;
  final bool showInlineActions;
}

class _FeedListTile extends StatelessWidget {
  const _FeedListTile({
    required this.item,
    required this.cMeta,
    required this.cBody,
    required this.cTagBg,
    required this.cCloseFriend,
    required this.onTap,
  });

  final _FeedItem item;
  final Color cMeta;
  final Color cBody;
  final Color cTagBg;
  final Color cCloseFriend;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 12.h),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _AvatarWithOverlay(url: item.avatarUrl, overlay: item.overlay, size: 48.r),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            item.userName,
                            style: TextStyle(
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w700,
                              color: Colors.black,
                              height: 1.2,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (item.badge != _UserBadge.none) ...[
                          SizedBox(width: 6.w),
                          _Badge(badge: item.badge, cTagBg: cTagBg, cCloseFriend: cCloseFriend),
                        ],
                      ],
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      item.content,
                      style: TextStyle(fontSize: 14.sp, color: cBody, height: 1.35),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 6.h),
                    Text(item.dateText, style: TextStyle(fontSize: 12.sp, color: cMeta)),
                    if (item.showInlineActions) ...[
                      SizedBox(height: 10.h),
                      Wrap(
                        spacing: 16.w,
                        runSpacing: 8.h,
                        children: [
                          _InlineAction(icon: Icons.chat_bubble_outline, label: '回复评论'),
                          _InlineAction(icon: Icons.favorite_border, label: '赞'),
                          _InlineAction(icon: Icons.north_east, label: '发作品'),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              SizedBox(width: 10.w),
              ClipRRect(
                borderRadius: BorderRadius.circular(6.r),
                child: Image.network(
                  item.thumbUrl,
                  width: 52.w,
                  height: 72.h,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: 52.w,
                    height: 72.h,
                    color: const Color(0xFFF5F5F5),
                    child: Icon(Icons.image_not_supported_outlined, size: 22.sp, color: cMeta),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.badge, required this.cTagBg, required this.cCloseFriend});

  final _UserBadge badge;
  final Color cTagBg;
  final Color cCloseFriend;

  @override
  Widget build(BuildContext context) {
    late String t;
    late Color bg;
    late Color fg;
    switch (badge) {
      case _UserBadge.none:
        return const SizedBox.shrink();
      case _UserBadge.fan:
        t = '粉丝';
        bg = cTagBg;
        fg = const Color(0xFF666666);
        break;
      case _UserBadge.mutual:
        t = '互相关注';
        bg = cTagBg;
        fg = const Color(0xFF666666);
        break;
      case _UserBadge.closeFriend:
        t = '密友';
        bg = cCloseFriend;
        fg = const Color(0xFF6B5BCE);
        break;
    }
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(4.r)),
      child: Text(t, style: TextStyle(fontSize: 10.sp, color: fg, fontWeight: FontWeight.w500)),
    );
  }
}

class _AvatarWithOverlay extends StatelessWidget {
  const _AvatarWithOverlay({required this.url, required this.overlay, required this.size});

  final String url;
  final _AvatarOverlay overlay;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: CircleAvatar(
              radius: size / 2,
              backgroundColor: const Color(0xFFF0F0F0),
              backgroundImage: NetworkImage(url),
            ),
          ),
          if (overlay != _AvatarOverlay.none)
            Positioned(
              right: -2,
              bottom: -2,
              child: _OverlayDisc(overlay: overlay),
            ),
        ],
      ),
    );
  }
}

class _OverlayDisc extends StatelessWidget {
  const _OverlayDisc({required this.overlay});

  final _AvatarOverlay overlay;

  @override
  Widget build(BuildContext context) {
    const d = 20.0;
    Widget child;
    switch (overlay) {
      case _AvatarOverlay.reply:
        child = Icon(Icons.chat_bubble, size: 11.sp, color: Colors.white);
        return Container(
          width: d.r,
          height: d.r,
          alignment: Alignment.center,
          decoration: const BoxDecoration(color: Color(0xFF4A90E2), shape: BoxShape.circle),
          child: child,
        );
      case _AvatarOverlay.like:
        return Container(
          width: d.r,
          height: d.r,
          alignment: Alignment.center,
          decoration: const BoxDecoration(color: Color(0xFFFF2D55), shape: BoxShape.circle),
          child: Icon(Icons.favorite, size: 11.sp, color: Colors.white),
        );
      case _AvatarOverlay.mention:
        return Container(
          width: d.r,
          height: d.r,
          alignment: Alignment.center,
          decoration: const BoxDecoration(color: Color(0xFFFFC107), shape: BoxShape.circle),
          child: Text('@', style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w800, color: Colors.white, height: 1)),
        );
      case _AvatarOverlay.none:
        return const SizedBox.shrink();
    }
  }
}

class _InlineAction extends StatelessWidget {
  const _InlineAction({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$label（演示）')));
      },
      borderRadius: BorderRadius.circular(20.r),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 4.h, horizontal: 2.w),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 15.sp, color: const Color(0xFF666666)),
            SizedBox(width: 4.w),
            Text(label, style: TextStyle(fontSize: 12.sp, color: const Color(0xFF666666))),
          ],
        ),
      ),
    );
  }
}

enum _FollowerAction { sayHello, followBack, follow, following }

class _NewFollowerItem {
  const _NewFollowerItem({
    required this.userName,
    required this.avatarUrl,
    required this.timeLine,
    required this.initialAction,
    this.mutual = false,
  });

  final String userName;
  final String avatarUrl;
  final String timeLine;
  final bool mutual;
  final _FollowerAction initialAction;
}

class _NewFollowerTile extends StatefulWidget {
  const _NewFollowerTile({required this.item, required this.cPrimary, required this.cTagBg});

  final _NewFollowerItem item;
  final Color cPrimary;
  final Color cTagBg;

  @override
  State<_NewFollowerTile> createState() => _NewFollowerTileState();
}

class _NewFollowerTileState extends State<_NewFollowerTile> {
  late _FollowerAction _action;

  @override
  void initState() {
    super.initState();
    _action = widget.item.initialAction;
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    return Material(
      color: Colors.white,
      child: InkWell(
        onTap: () {},
        child: Padding(
          padding: EdgeInsets.fromLTRB(16.w, 12.h, 8.w, 12.h),
          child: Row(
            children: [
              CircleAvatar(
                radius: 26.r,
                backgroundColor: const Color(0xFFF0F0F0),
                backgroundImage: NetworkImage(item.avatarUrl),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            item.userName,
                            style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w700, color: Colors.black),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (item.mutual) ...[
                          SizedBox(width: 6.w),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                            decoration: BoxDecoration(
                              color: widget.cTagBg,
                              borderRadius: BorderRadius.circular(4.r),
                            ),
                            child: Text(
                              '互相关注',
                              style: TextStyle(fontSize: 10.sp, color: const Color(0xFF666666)),
                            ),
                          ),
                        ],
                      ],
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      item.timeLine,
                      style: TextStyle(fontSize: 13.sp, color: const Color(0xFF888888)),
                    ),
                  ],
                ),
              ),
              _buildActionButton(),
              Icon(Icons.chevron_right, size: 22.sp, color: const Color(0xFFCCCCCC)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton() {
    switch (_action) {
      case _FollowerAction.sayHello:
        return Padding(
          padding: EdgeInsets.only(right: 4.w),
          child: TextButton(
            style: TextButton.styleFrom(
              backgroundColor: const Color(0xFFF2F2F2),
              foregroundColor: Colors.black,
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
            ),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('打招呼（演示）')));
            },
            child: Text('👋 打招呼', style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w500)),
          ),
        );
      case _FollowerAction.followBack:
      case _FollowerAction.follow:
        return Padding(
          padding: EdgeInsets.only(right: 4.w),
          child: TextButton(
            style: TextButton.styleFrom(
              backgroundColor: widget.cPrimary,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
            ),
            onPressed: () {
              setState(() {
                _action = _FollowerAction.following;
              });
            },
            child: Text(
              _action == _FollowerAction.followBack ? '回关' : '关注',
              style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600),
            ),
          ),
        );
      case _FollowerAction.following:
        return Padding(
          padding: EdgeInsets.only(right: 4.w),
          child: TextButton(
            style: TextButton.styleFrom(
              backgroundColor: const Color(0xFFF2F2F2),
              foregroundColor: Colors.black,
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
            ),
            onPressed: () {},
            child: Text('已关注', style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w500)),
          ),
        );
    }
  }
}
