import 'dart:math' as math;

import 'package:bilbili_project/pages/Home/comps/video_comment_models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

/// 主楼直连回复：默认展示条数；首次「展开更多」+ [kExpandAddFirst]；之后每次 + [kExpandAddAfter]；无收起。
const int kInitialVisibleRootReplies = 2;
const int kExpandAddFirst = 3;
const int kExpandAddAfter = 10;

/// 评论半屏 bottom sheet。布局与楼中楼结构参考常见短视频产品；数据用 [VideoCommentNode] / [buildVideoCommentForest] 与接口对齐。
class VideoCommentSheetSkeleton extends StatefulWidget {
  const VideoCommentSheetSkeleton({
    super.key,
    this.totalCount,
    this.comments,
    this.onReply,
    this.hintText = '善语结善缘，恶言伤人心',
  });

  /// 为 null 时用 [comments] 的条数或骨架演示值。
  final int? totalCount;
  final List<VideoCommentNode>? comments;
  final void Function(VideoCommentNode target)? onReply;
  final String hintText;

  @override
  State<VideoCommentSheetSkeleton> createState() =>
      _VideoCommentSheetSkeletonState();
}

class _VideoCommentSheetSkeletonState extends State<VideoCommentSheetSkeleton> {
  final TextEditingController _inputController = TextEditingController();
  final FocusNode _inputFocus = FocusNode();

  /// 为 true 时占满 [MediaQuery] 的屏幕总高度，为 false 时半屏
  bool _isFullHeight = false;

  static const String _a =
      'https://q6.itc.cn/q_70/images03/20250306/355fba5a5cb049f5b98c2ed9f03cc5e1.jpeg';
  static const String _b =
      'https://q2.itc.cn/q_70/images03/20250623/337b5e62a9444bcda5d4b1aee5cddf54.jpeg';
  static const String _c =
      'https://gimg2.baidu.com/image_search/src=http%3A%2F%2Fci.xiaohongshu.com%2F0f978950-9630-58ff-e79a-3ac8f7dfbfcc%3FimageView2%2F2%2Fw%2F1080%2Fformat%2Fjpg&refer=http%3A%2F%2Fci.xiaohongshu.com&app=2002&size=f9999,10000&q=a80&n=0&g=0n&fmt=auto?sec=1778439524&t=3a4b5e1b129df6428ba6c91242e46436';

  /// 含多层楼中楼：主评 → 作者回复 → 再回复（带 A ▶ B）以及另起一条子回复。
  static final List<VideoCommentNode> _kDemoTree = [
    VideoCommentNode(
      id: '101',
      user: VideoCommentUser(
        id: 'u1',
        nickname: '数字浪潮',
        avatarUrl: _a,
        isVideoAuthor: false,
      ),
      content: '你订阅了 GitHub Copilot 后，写代码还用手敲吗？求真实体验',
      timeAgo: '1小时前',
      location: '广东',
      likeCount: 4917,
      replies: [
        VideoCommentNode(
          id: '102',
          parentId: '101',
          user: VideoCommentUser(
            id: 'u2',
            nickname: '教你宇宙级AI编程',
            avatarUrl: _b,
            isVideoAuthor: true,
          ),
          content: 'github copilot 已经不允许新的小破站 up 用教育认证白嫖了，只能买 10 刀一个月',
          timeAgo: '4-9',
          location: '浙江',
          likeCount: 12,
          replies: [
            VideoCommentNode(
              id: '105',
              parentId: '102',
              user: const VideoCommentUser(
                id: 'u4',
                nickname: '看看脑电波',
                avatarUrl: _c,
              ),
              replyToUser: const VideoCommentUser(
                id: 'u3',
                nickname: '李嘉图',
                avatarUrl: null,
              ),
              content: '纯小白，claude 不是单独的 ide 吗？和 cursor 比哪个强？',
              timeAgo: '4-9',
              location: '安徽',
              likeCount: 0,
            ),
          ],
        ),
        VideoCommentNode(
          id: '103',
          parentId: '101',
          user: const VideoCommentUser(
            id: 'u5',
            nickname: 'iior',
            avatarUrl: null,
            isVideoAuthor: false,
          ),
          replyToUser: const VideoCommentUser(
            id: 'u4',
            nickname: '看看脑电波',
            avatarUrl: null,
          ),
          content: '同问，现在还在用教育版白嫖吗？',
          timeAgo: '4-9',
          location: '上海',
          likeCount: 1,
        ),
        for (int i = 0; i < 18; i++)
          VideoCommentNode(
            id: 'stub_101_${110 + i}',
            parentId: '101',
            user: VideoCommentUser(
              id: 'u_${110 + i}',
              nickname: '楼友${i + 1}',
              avatarUrl: i.isEven ? _a : _b,
            ),
            content: '接楼讨论第 ${i + 1} 条（展开：首次多 3 条，之后每次多 10 条）',
            timeAgo: '4-9',
            likeCount: 3 + i,
          ),
      ],
    ),
    VideoCommentNode(
      id: '201',
      user: VideoCommentUser(id: 'u6', nickname: '摸鱼中', avatarUrl: _a),
      content: '前排占座',
      timeAgo: '昨天 18:20',
      location: '北京',
      likeCount: 0,
    ),
  ];

  @override
  void dispose() {
    _inputController.dispose();
    _inputFocus.dispose();
    super.dispose();
  }

  int get _countDisplay {
    if (widget.totalCount != null) return widget.totalCount!;
    final c = widget.comments;
    if (c == null) return 69;
    return c.fold<int>(0, (s, n) => s + 1 + _subCount(n));
  }

  int _subCount(VideoCommentNode n) {
    return n.replies.fold<int>(0, (s, c) => s + 1 + _subCount(c));
  }

  @override
  Widget build(BuildContext context) {
    final screenH = MediaQuery.sizeOf(context).height;
    final h = _isFullHeight ? screenH : screenH * 0.5;
    final list = widget.comments ?? _kDemoTree;
    final viewInset = MediaQuery.viewInsetsOf(context).bottom;

    return Material(
      color: Colors.white,
      child: SizedBox(
        height: h,
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _HeaderBar(
              title: '$_countDisplay条评论',
              isMaximized: _isFullHeight,
              onClose: () => Navigator.of(context).maybePop(),
              onToggleSize: () => setState(() {
                _isFullHeight = !_isFullHeight;
              }),
            ),
            Divider(
              height: 1,
              thickness: 0.5,
              color: Colors.black.withValues(alpha: 0.06),
            ),
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.fromLTRB(12.w, 8.h, 12.w, 8.h),
                itemCount: list.length,
                itemBuilder: (context, i) {
                  return Padding(
                    padding: EdgeInsets.only(bottom: 16.h),
                    child: _RootCommentThread(
                      node: list[i],
                      onReply: (n) {
                        widget.onReply?.call(n);
                        if (widget.onReply == null) {
                          debugPrint('回复: ${n.user.nickname}');
                        }
                        setState(() {
                          _inputController.text = '回复 @${n.user.nickname} ';
                        });
                        _inputFocus.requestFocus();
                      },
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: EdgeInsets.only(
                left: 12.w,
                right: 12.w,
                top: 8.h,
                bottom: 8.h + viewInset,
              ),
              child: _BottomInputRow(
                controller: _inputController,
                focusNode: _inputFocus,
                hintText: widget.hintText,
                onImageTap: () => debugPrint('选图'),
                onAtTap: () => debugPrint('@'),
                onEmojiTap: () => debugPrint('表情'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeaderBar extends StatelessWidget {
  const _HeaderBar({
    required this.title,
    required this.onClose,
    required this.isMaximized,
    required this.onToggleSize,
  });

  final String title;
  final VoidCallback onClose;
  final bool isMaximized;
  final VoidCallback onToggleSize;

  @override
  Widget build(BuildContext context) {
    final actionColor = const Color(0xFF666666);
    return SizedBox(
      height: 44.h,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1A1A1A),
            ),
          ),
          // 最右侧：放大/缩小 在 关闭 的左侧
          Positioned(
            right: 4.w,
            top: 0,
            bottom: 0,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  onPressed: onToggleSize,
                  padding: EdgeInsets.all(8.r),
                  tooltip: isMaximized ? '半屏' : '全屏',
                  icon: Icon(
                    isMaximized ? Icons.close_fullscreen : Icons.open_in_full,
                    size: 20.sp,
                    color: actionColor,
                  ),
                ),
                IconButton(
                  onPressed: onClose,
                  padding: EdgeInsets.all(8.r),
                  icon: Icon(
                    Icons.close,
                    size: 22.sp,
                    color: actionColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// 主楼 + 可分页的直连子回复 + 子楼全量递归（子楼不再分页，与产品常见行为一致；若需子层分页可再扩展）。
class _RootCommentThread extends StatefulWidget {
  const _RootCommentThread({required this.node, required this.onReply});

  final VideoCommentNode node;
  final void Function(VideoCommentNode n) onReply;

  @override
  State<_RootCommentThread> createState() => _RootCommentThreadState();
}

class _RootCommentThreadState extends State<_RootCommentThread> {
  late int _visible;
  var _usedFirstExpandRule = false;

  @override
  void initState() {
    super.initState();
    final n = widget.node.replies.length;
    _visible = n == 0 ? 0 : math.min(kInitialVisibleRootReplies, n);
  }

  void _expand() {
    final total = widget.node.replies.length;
    if (_visible >= total) return;
    setState(() {
      if (!_usedFirstExpandRule) {
        _visible = math.min(_visible + kExpandAddFirst, total);
        _usedFirstExpandRule = true;
      } else {
        _visible = math.min(_visible + kExpandAddAfter, total);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final n = widget.node;
    final replies = n.replies;
    final canExpand = _visible < replies.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _OneCommentRow(node: n, depth: 0, onReply: () => widget.onReply(n)),
        for (int i = 0; i < _visible; i++)
          _NestedCommentBlock(
            node: replies[i],
            depth: 1,
            onReply: widget.onReply,
          ),
        if (canExpand)
          _ThreadExpandButton(onTap: _expand, indentForDepth1: true),
      ],
    );
  }
}

class _NestedCommentBlock extends StatelessWidget {
  const _NestedCommentBlock({
    required this.node,
    required this.depth,
    required this.onReply,
  });

  final VideoCommentNode node;
  final int depth;
  final void Function(VideoCommentNode node) onReply;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _OneCommentRow(node: node, depth: depth, onReply: () => onReply(node)),
        for (final c in node.replies)
          _NestedCommentBlock(node: c, depth: depth + 1, onReply: onReply),
      ],
    );
  }
}

class _ThreadExpandButton extends StatelessWidget {
  const _ThreadExpandButton({
    required this.onTap,
    this.indentForDepth1 = false,
  });

  final VoidCallback onTap;
  final bool indentForDepth1;

  @override
  Widget build(BuildContext context) {
    final nameColor = const Color(0xFF6B6B6B);
    // 与 depth==1 子评正文左缘对齐：leftPad + 小头像直径 + 间距
    final left = indentForDepth1 ? 8.w + 10.w + 13.r * 2 + 8.w : 0.0;
    return Padding(
      padding: EdgeInsets.only(left: left, top: 2.h, bottom: 2.h),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(4.r),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '展开更多',
              style: TextStyle(
                fontSize: 12.5.sp,
                color: nameColor,
                fontWeight: FontWeight.w500,
              ),
            ),
            Icon(Icons.expand_more, size: 16.sp, color: nameColor),
          ],
        ),
      ),
    );
  }
}

class _OneCommentRow extends StatelessWidget {
  const _OneCommentRow({
    required this.node,
    required this.depth,
    required this.onReply,
  });

  final VideoCommentNode node;
  final int depth;
  final VoidCallback onReply;

  static const int _kMaxVisualDepth = 4;

  @override
  Widget build(BuildContext context) {
    final capDepth = math.min(depth, _kMaxVisualDepth);
    final leftPad = capDepth == 0 ? 0.0 : 8.w + capDepth * 10.w;
    final nameColor = const Color(0xFF7A7A7A);
    final metaColor = const Color(0xFFB3B3B3);
    final avR = depth == 0 ? 18.r : 13.r;

    return Padding(
      padding: EdgeInsets.only(left: leftPad, bottom: 10.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Avatar(
            url: node.user.avatarUrl,
            radius: avR,
            label: node.user.nickname.isNotEmpty ? node.user.nickname[0] : '?',
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (node.replyToUser == null)
                  _NameLineOnly(
                    name: node.user.nickname,
                    isAuthor: node.user.isVideoAuthor,
                    nameColor: nameColor,
                  )
                else
                  _ReplyNameLine(
                    replier: node.user,
                    at: node.replyToUser!,
                    nameColor: nameColor,
                  ),
                SizedBox(height: 3.h),
                Text(
                  node.content,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: const Color(0xFF1A1A1A),
                    height: 1.35,
                  ),
                ),
                SizedBox(height: 6.h),
                // 先「占满行」的 Expanded 里放 时间+回复(左贴)；最右侧为点赞区（勿对时间用 flex:1+Spacer，会分掉空白）
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Flexible(
                            flex: 0,
                            fit: FlexFit.loose,
                            child: Text(
                              _metaText(node),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 11.5.sp,
                                color: metaColor,
                                height: 1.2,
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: onReply,
                            child: Padding(
                              padding: EdgeInsets.only(left: 8.w),
                              child: Text(
                                '回复',
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: nameColor,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    _LikeDislikeRow(likeCount: node.likeCount),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _metaText(VideoCommentNode n) {
    // 不展示地点，只保留时间（接口仍可保留 [VideoCommentNode.location] 后续他用）
    return n.timeAgo;
  }
}

class _LikeDislikeRow extends StatelessWidget {
  const _LikeDislikeRow({required this.likeCount});

  final int likeCount;

  @override
  Widget build(BuildContext context) {
    const cHeart = Color(0xFF8A8A8A);
    const cCrack = Color(0xFFB0B0B0);
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(Icons.favorite_border, size: 16.5.sp, color: cHeart),
        SizedBox(width: 3.w),
        Text(
          _formatCount(likeCount),
          style: TextStyle(
            fontSize: 12.5.sp,
            color: cHeart,
            fontWeight: FontWeight.w500,
            height: 1,
          ),
        ),
        // 点赞区与「不感兴趣」碎心之间预留更大间隙
        SizedBox(width: 12.w),
        Icon(Icons.heart_broken, size: 15.5.sp, color: cCrack),
      ],
    );
  }

  String _formatCount(int n) {
    if (n < 10000) return n.toString();
    final d = n / 10000;
    return '${d.toStringAsFixed(d == d.truncate() ? 0 : 1)}万';
  }
}

class _NameLineOnly extends StatelessWidget {
  const _NameLineOnly({
    required this.name,
    required this.isAuthor,
    required this.nameColor,
  });

  final String name;
  final bool isAuthor;
  final Color nameColor;

  @override
  Widget build(BuildContext context) {
    if (name.isEmpty) return const SizedBox.shrink();
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          child: Text(
            name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12.5.sp,
              color: nameColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        if (isAuthor) ...[SizedBox(width: 5.w), _AuthorTag()],
      ],
    );
  }
}

class _ReplyNameLine extends StatelessWidget {
  const _ReplyNameLine({
    required this.replier,
    required this.at,
    required this.nameColor,
  });

  final VideoCommentUser replier;
  final VideoCommentUser at;
  final Color nameColor;

  @override
  Widget build(BuildContext context) {
    final t = TextStyle(
      fontSize: 12.5.sp,
      color: nameColor,
      fontWeight: FontWeight.w500,
    );
    return Text.rich(
      TextSpan(
        style: t,
        children: [
          TextSpan(text: replier.nickname),
          if (replier.isVideoAuthor)
            WidgetSpan(
              alignment: PlaceholderAlignment.middle,
              child: Padding(
                padding: EdgeInsets.only(left: 4.w, right: 2.w),
                child: _AuthorTag(),
              ),
            ),
          TextSpan(
            text: ' ▶ ${at.nickname}',
            style: t.copyWith(color: nameColor.withValues(alpha: 0.9)),
          ),
        ],
      ),
    );
  }
}

class _AuthorTag extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.5.h),
      decoration: BoxDecoration(
        color: const Color(0xFFFF2E4D).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(2.r),
        border: Border.all(
          color: const Color(0xFFFF2E4D).withValues(alpha: 0.5),
        ),
      ),
      child: Text(
        '作者',
        style: TextStyle(
          fontSize: 9.sp,
          color: const Color(0xFFFF2E4D),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({this.url, required this.radius, required this.label});
  final String? url;
  final double radius;
  final String label;

  @override
  Widget build(BuildContext context) {
    if (url != null && (url!.startsWith('http'))) {
      return CircleAvatar(
        radius: radius,
        backgroundColor: const Color(0xFFE6E6E6),
        backgroundImage: NetworkImage(url!),
      );
    }
    return CircleAvatar(
      radius: radius,
      backgroundColor: const Color(0xFFCCCCCC),
      child: Text(
        label,
        style: TextStyle(
          color: const Color(0xFF666666),
          fontSize: (radius * 0.8).sp,
        ),
      ),
    );
  }
}

class _BottomInputRow extends StatelessWidget {
  const _BottomInputRow({
    required this.controller,
    required this.focusNode,
    required this.hintText,
    required this.onImageTap,
    required this.onAtTap,
    required this.onEmojiTap,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final String hintText;
  final VoidCallback onImageTap;
  final VoidCallback onAtTap;
  final VoidCallback onEmojiTap;

  @override
  Widget build(BuildContext context) {
    final line = const Color(0xFFE5E5E5);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: TextField(
            controller: controller,
            focusNode: focusNode,
            minLines: 1,
            maxLines: 3,
            textInputAction: TextInputAction.send,
            textAlignVertical: TextAlignVertical.center,
            style: TextStyle(fontSize: 14.sp, color: const Color(0xFF333333)),
            decoration: InputDecoration(
              isDense: true,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 14.w,
                vertical: 10.h,
              ),
              hintText: hintText,
              hintStyle: TextStyle(
                fontSize: 13.5.sp,
                color: const Color(0xFFB8B8B8),
              ),
              filled: true,
              fillColor: const Color(0xFFF5F5F5),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(22.r),
                borderSide: BorderSide(color: line),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(22.r),
                borderSide: BorderSide(color: line.withValues(alpha: 0.0)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(22.r),
                borderSide: BorderSide(color: line, width: 0.5),
              ),
            ),
          ),
        ),
        SizedBox(width: 8.w),
        IconButton(
          onPressed: onImageTap,
          icon: Icon(
            FontAwesomeIcons.image,
            size: 20.sp,
            color: const Color(0xFF4A4A4A),
          ),
        ),
        IconButton(
          onPressed: onAtTap,
          icon: FaIcon(
            FontAwesomeIcons.at,
            size: 20.sp,
            color: const Color(0xFF4A4A4A),
          ),
        ),
        IconButton(
          onPressed: onEmojiTap,
          icon: Icon(
            FontAwesomeIcons.faceSmile,
            size: 20.sp,
            color: const Color(0xFF4A4A4A),
          ),
        ),
      ],
    );
  }
}
