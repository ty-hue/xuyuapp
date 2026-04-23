import 'dart:math' show min;

import 'package:bilbili_project/components/with_statusBar_color.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 从聊天信息页进入「查找聊天内容」时可通过 [extra] 传入；用于演示头像与昵称。
class ChatHistorySearchPageArgs {
  const ChatHistorySearchPageArgs({
    this.peerTitle = '心似❤️朝阳☀️',
    this.peerAvatarUrl,
    this.selfTitle = '我',
    this.selfAvatarUrl,
  });

  final String peerTitle;
  final String? peerAvatarUrl;
  final String selfTitle;
  final String? selfAvatarUrl;
}

/// 单条聊天记录命中（演示数据）。
class _ChatHistoryHit {
  const _ChatHistoryHit({
    required this.id,
    required this.senderName,
    required this.senderAvatarUrl,
    required this.sentAt,
    required this.typeLabel,
    required this.previewBody,
  });

  final String id;
  final String senderName;
  final String? senderAvatarUrl;
  final DateTime sentAt;

  /// 如 `[分享视频]`
  final String typeLabel;

  /// 展示在类型标签后的正文（会与标签拼接成一行预览）。
  final String previewBody;

  String get previewLine {
    final t = typeLabel.trim();
    final b = previewBody.trim();
    if (t.isEmpty) return b;
    return '$t $b';
  }
}

/// 查找聊天记录：顶栏搜索 + 空态快速入口 + 结果列表（关键词标红）。
class ChatHistorySearchPage extends StatefulWidget {
  const ChatHistorySearchPage({
    super.key,
    required this.args,
  });

  final ChatHistorySearchPageArgs args;

  @override
  State<ChatHistorySearchPage> createState() => _ChatHistorySearchPageState();
}

class _ChatHistorySearchPageState extends State<ChatHistorySearchPage> {
  final TextEditingController _queryController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();

  static const Color _fieldFill = Color(0xFFF2F2F7);
  static const Color _hint = Color(0xFFC7C7CC);
  static const Color _sub = Color(0xFF8E8E93);
  static const Color _highlight = Color(0xFFFF3B30);

  late List<_ChatHistoryHit> _all;

  @override
  void initState() {
    super.initState();
    _all = _buildDemoHits();
    _queryController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _queryController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  List<_ChatHistoryHit> _buildDemoHits() {
    final a = widget.args;
    final peerAv = a.peerAvatarUrl;
    final selfAv = a.selfAvatarUrl;

    final now = DateTime.now();
    DateTime daysAgo(int d) => now.subtract(Duration(days: d));

    return [
      _ChatHistoryHit(
        id: '1',
        senderName: 'llg',
        senderAvatarUrl: 'https://wx4.sinaimg.cn/mw690/70e1e519ly1i9xgh6g04ej20sg0sggsj.jpg',
        sentAt: daysAgo(2),
        typeLabel: '[分享视频]',
        previewBody: '你看看这个视频有你认识的吗',
      ),
      _ChatHistoryHit(
        id: '2',
        senderName: a.peerTitle,
        senderAvatarUrl: peerAv,
        sentAt: daysAgo(4),
        typeLabel: '[分享评论]',
        previewBody: '评论区有人说你是大神哈哈',
      ),
      _ChatHistoryHit(
        id: '3',
        senderName: 'llg',
        senderAvatarUrl: 'https://wx4.sinaimg.cn/mw690/70e1e519ly1i9xgh6g04ej20sg0sggsj.jpg',
        sentAt: daysAgo(14),
        typeLabel: '[分享视频]',
        previewBody: '你好久没上线了',
      ),
      _ChatHistoryHit(
        id: '4',
        senderName: a.peerTitle,
        senderAvatarUrl: peerAv,
        sentAt: daysAgo(30),
        typeLabel: '',
        previewBody: '你这周末有空吗一起打球',
      ),
      _ChatHistoryHit(
        id: '5',
        senderName: a.selfTitle,
        senderAvatarUrl: selfAv,
        sentAt: daysAgo(1),
        typeLabel: '[图片]',
        previewBody: '你看这张拍得怎么样',
      ),
      _ChatHistoryHit(
        id: '6',
        senderName: 'llg',
        senderAvatarUrl: 'https://wx4.sinaimg.cn/mw690/70e1e519ly1i9xgh6g04ej20sg0sggsj.jpg',
        sentAt: daysAgo(45),
        typeLabel: '[链接]',
        previewBody: '给你安利一篇文章你大概率喜欢',
      ),
      _ChatHistoryHit(
        id: '7',
        senderName: a.peerTitle,
        senderAvatarUrl: peerAv,
        sentAt: daysAgo(90),
        typeLabel: '[语音]',
        previewBody: '你怎么不回我消息呀',
      ),
      _ChatHistoryHit(
        id: '8',
        senderName: a.selfTitle,
        senderAvatarUrl: selfAv,
        sentAt: daysAgo(200),
        typeLabel: '',
        previewBody: '你还记得上次说的那件事吗',
      ),
    ];
  }

  String _formatDateLine(DateTime t) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final d = DateTime(t.year, t.month, t.day);
    final diff = today.difference(d).inDays;
    if (diff >= 0 && diff < 7) {
      const names = ['星期一', '星期二', '星期三', '星期四', '星期五', '星期六', '星期日'];
      return names[t.weekday - 1];
    }
    return '${t.month}-${t.day}';
  }

  List<_ChatHistoryHit> _filtered() {
    final q = _queryController.text.trim();
    if (q.isEmpty) return [];
    bool hit(_ChatHistoryHit e) {
      final line = e.previewLine;
      return line.contains(q) || e.senderName.contains(q);
    }

    final list = _all.where(hit).toList();
    list.sort((a, b) => b.sentAt.compareTo(a.sentAt));
    return list;
  }

  void _clearQuery() {
    _queryController.clear();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.paddingOf(context).top;
    final q = _queryController.text.trim();
    final emptyQuery = q.isEmpty;
    final results = _filtered();

    return WithStatusbarColorView(
      statusBarColor: Colors.white,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildTopBar(context, top),
            Divider(height: 1.h, thickness: 1, color: const Color(0xFFE5E5EA)),
            Expanded(
              child: emptyQuery ? _buildEmptySearchHint() : _buildResultList(context, results, q),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context, double statusBarHeight) {
    final q = _queryController.text;
    final showClear = q.isNotEmpty;

    return Padding(
      padding: EdgeInsets.only(top: statusBarHeight, left: 4.w, right: 12.w),
      child: SizedBox(
        height: 44.h,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            InkWell(
              onTap: () => Navigator.of(context).maybePop(),
              borderRadius: BorderRadius.circular(22.r),
              child: Padding(
                padding: EdgeInsets.only(left: 4.w, right: 8.w),
                child: Icon(Icons.arrow_back_ios_new_rounded, size: 18.r, color: Colors.black87),
              ),
            ),
            Expanded(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: _fieldFill,
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Row(
                  children: [
                    SizedBox(width: 10.w),
                    Icon(Icons.search_rounded, size: 18.r, color: _hint),
                    SizedBox(width: 6.w),
                    Expanded(
                      child: TextField(
                        controller: _queryController,
                        focusNode: _searchFocus,
                        autofocus: true,
                        style: TextStyle(fontSize: 15.sp, color: Colors.black87),
                        decoration: InputDecoration(
                          isDense: true,
                          hintText: '搜索聊天内容',
                          hintStyle: TextStyle(fontSize: 15.sp, color: _hint),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(vertical: 10.h),
                        ),
                      ),
                    ),
                    if (showClear)
                      IconButton(
                        onPressed: _clearQuery,
                        icon: Icon(Icons.cancel_rounded, size: 20.r, color: _hint),
                        padding: EdgeInsets.zero,
                        constraints: BoxConstraints(minWidth: 36.w, minHeight: 36.w),
                      )
                    else
                      SizedBox(width: 8.w),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 未输入关键词时：提示文案置于内容区正中。
  Widget _buildEmptySearchHint() {
    return Center(
      child: Text(
        '快速搜索聊天内容',
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 13.sp, color: _sub),
      ),
    );
  }

  Widget _buildResultList(BuildContext context, List<_ChatHistoryHit> hits, String query) {
    if (hits.isEmpty) {
      return Center(
        child: Text(
          '未找到相关聊天记录',
          style: TextStyle(fontSize: 14.sp, color: _sub),
        ),
      );
    }

    final basePrev = TextStyle(fontSize: 14.sp, color: _sub, height: 1.35);
    final hlPrev = TextStyle(fontSize: 14.sp, color: _highlight, fontWeight: FontWeight.w500, height: 1.35);

    return ListView.separated(
      padding: EdgeInsets.only(bottom: MediaQuery.paddingOf(context).bottom + 12.h),
      itemCount: hits.length,
      separatorBuilder: (context, index) => Divider(height: 1.h, thickness: 1, indent: 72.w, color: const Color(0xFFE5E5EA)),
      itemBuilder: (context, i) {
        final e = hits[i];
        return Material(
          color: Colors.white,
          child: InkWell(
            onTap: () => ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('定位到消息（演示）：${e.previewLine}')),
            ),
            child: Padding(
              padding: EdgeInsets.fromLTRB(12.w, 10.h, 12.w, 10.h),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _avatar(e.senderAvatarUrl),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                e.senderName,
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Text(
                              _formatDateLine(e.sentAt),
                              style: TextStyle(fontSize: 12.sp, color: _sub),
                            ),
                          ],
                        ),
                        SizedBox(height: 4.h),
                        Text.rich(
                          TextSpan(children: _highlightSpans(e.previewLine, query, basePrev, hlPrev)),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _avatar(String? url) {
    final r = 22.r;
    if (url != null && url.isNotEmpty) {
      return ClipOval(
        child: ExtendedImage.network(
          url,
          width: r * 2,
          height: r * 2,
          fit: BoxFit.cover,
          loadStateChanged: (state) {
            if (state.extendedImageLoadState == LoadState.failed) {
              return _avatarFallback(r);
            }
            return null;
          },
        ),
      );
    }
    return _avatarFallback(r);
  }

  Widget _avatarFallback(double r) {
    return CircleAvatar(
      radius: r,
      backgroundColor: const Color(0xFFE5E5EA),
      child: Icon(Icons.person_rounded, size: r, color: Colors.white70),
    );
  }

  /// 将 [query] 在 [text] 中的命中标红（英文忽略大小写）。
  static List<InlineSpan> _highlightSpans(
    String text,
    String query,
    TextStyle base,
    TextStyle highlight,
  ) {
    final q = query.trim();
    if (q.isEmpty) {
      return [TextSpan(text: text, style: base)];
    }

    final lowerText = text.toLowerCase();
    final lowerQ = q.toLowerCase();
    final out = <InlineSpan>[];
    var start = 0;
    while (true) {
      final i = lowerText.indexOf(lowerQ, start);
      if (i < 0) {
        if (start < text.length) {
          out.add(TextSpan(text: text.substring(start), style: base));
        }
        break;
      }
      if (i > start) {
        out.add(TextSpan(text: text.substring(start, i), style: base));
      }
      final endIdx = min(i + q.length, text.length);
      out.add(TextSpan(text: text.substring(i, endIdx), style: highlight));
      start = endIdx;
    }
    return out;
  }
}
