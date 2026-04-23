import 'dart:math';

import 'package:bilbili_project/components/with_statusBar_color.dart';
import 'package:bilbili_project/pages/Message/sub/Chat/chat_call_action_sheet.dart';
import 'package:bilbili_project/pages/Message/sub/Chat/chat_data_source.dart';
import 'package:bilbili_project/pages/Message/sub/Chat/chat_emoji_panel_data.dart';
import 'package:bilbili_project/pages/Message/sub/Chat/chat_info_page.dart';
import 'package:bilbili_project/pages/Message/sub/Chat/chat_models.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

/// 私信 / 聊天页（UI 参考微信；数据经 [ChatRemoteDataSource] 对接接口）
class ChatPage extends StatefulWidget {
  ChatPage({
    super.key,
    this.conversationId = 'demo_conv',
    this.peerTitle = '心似❤️朝阳☀️',
    this.peerAvatarUrl,
    this.selfAvatarUrl,
    this.notificationBadgeCount = 5,
    ChatRemoteDataSource? remote,
  }) : remote = remote ?? MockChatRemoteDataSource();

  /// 会话 id，发起拉取 / 发送时带给后端
  final String conversationId;

  /// 顶部标题展示名
  final String peerTitle;

  /// 对方头像 URL；为空则用占位图
  final String? peerAvatarUrl;

  /// 己方头像 URL；为空则用占位色块
  final String? selfAvatarUrl;

  /// 返回按钮旁红点数字（演示）
  final int notificationBadgeCount;

  final ChatRemoteDataSource remote;

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _inputController = TextEditingController();
  final FocusNode _inputFocusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();
  final PageController _plusMenuPageController = PageController();

  List<ChatListItem> _items = [];
  bool _loading = true;

  /// 「+」展开的功能面板（不含相册缩略图预览条）
  bool _plusPanelOpen = false;
  int _plusMenuPageIndex = 0;

  /// 表情面板：与「+」面板互斥
  bool _emojiPanelOpen = false;

  /// 0：默认 emoji 网格；1：收藏（静态/GIF）
  int _emojiCategoryTab = 0;

  List<String> _recentEmojis = ['😘'];

  static const Color _chatBg = Color(0xFFEDEDED);
  static const Color _selfBubbleBlue = Color(0xFF1296DB);

  /// 前 5 个固定；其后从池子中随机抽一批，保证横滑内容足够多
  static const List<QuickReactionItem> _quickReactionsHead = [
    QuickReactionItem(emoji: '👋', label: '打招呼'),
    QuickReactionItem(emoji: '🫶', label: '比心'),
    QuickReactionItem(emoji: '👍', label: '赞'),
    QuickReactionItem(emoji: '😭', label: '捂脸'),
    QuickReactionItem(emoji: '🌹', label: '玫瑰'),
  ];

  static const List<QuickReactionItem> _quickReactionPool = [
    QuickReactionItem(emoji: '🔥', label: '火热'),
    QuickReactionItem(emoji: '✨', label: '棒'),
    QuickReactionItem(emoji: '😂', label: '笑哭'),
    QuickReactionItem(emoji: '🥰', label: '爱你'),
    QuickReactionItem(emoji: '🤝', label: '合作愉快'),
    QuickReactionItem(emoji: '💪', label: '加油'),
    QuickReactionItem(emoji: '☕', label: '喝咖啡'),
    QuickReactionItem(emoji: '🎉', label: '庆祝'),
    QuickReactionItem(emoji: '🙏', label: '拜托'),
    QuickReactionItem(emoji: '👏', label: '鼓掌'),
    QuickReactionItem(emoji: '🤣', label: '太好笑'),
    QuickReactionItem(emoji: '😘', label: '么么'),
    QuickReactionItem(emoji: '🎁', label: '礼物'),
    QuickReactionItem(emoji: '🍀', label: '好运'),
    QuickReactionItem(emoji: '⭐', label: '五星'),
    QuickReactionItem(emoji: '💯', label: '满分'),
    QuickReactionItem(emoji: '🫡', label: '收到'),
    QuickReactionItem(emoji: '🧋', label: '奶茶'),
    QuickReactionItem(emoji: '🍜', label: '约饭'),
    QuickReactionItem(emoji: '🏃', label: '在路上'),
    QuickReactionItem(emoji: '😴', label: '困了'),
    QuickReactionItem(emoji: '🤔', label: '想想'),
    QuickReactionItem(emoji: '❤️', label: '心心'),
    QuickReactionItem(emoji: '🐶', label: '摸摸头'),
    QuickReactionItem(emoji: '🌙', label: '晚安'),
  ];

  late final List<QuickReactionItem> _quickReactions;
  final Random _quickRand = Random();

  @override
  void initState() {
    super.initState();
    final tail = List<QuickReactionItem>.from(_quickReactionPool)..shuffle(_quickRand);
    _quickReactions = [..._quickReactionsHead, ...tail];
    _inputFocusNode.addListener(_onInputFocusChanged);
    _loadMessages();
  }

  void _onInputFocusChanged() {
    if (_inputFocusNode.hasFocus && (_plusPanelOpen || _emojiPanelOpen)) {
      setState(() {
        _plusPanelOpen = false;
        _emojiPanelOpen = false;
      });
    }
  }

  void _toggleEmojiPanel() {
    setState(() {
      _emojiPanelOpen = !_emojiPanelOpen;
      if (_emojiPanelOpen) {
        _plusPanelOpen = false;
        _inputFocusNode.unfocus();
      }
    });
    if (_emojiPanelOpen) {
      _scrollToBottom();
    }
  }

  void _togglePlusPanel() {
    setState(() {
      _plusPanelOpen = !_plusPanelOpen;
      if (_plusPanelOpen) {
        _emojiPanelOpen = false;
        _inputFocusNode.unfocus();
      }
    });
    if (_plusPanelOpen) {
      _scrollToBottom();
    }
  }

  void _insertIntoInput(String insertion) {
    final t = _inputController.text;
    final sel = _inputController.selection;
    final start = sel.isValid ? sel.start : t.length;
    final end = sel.isValid ? sel.end : t.length;
    final nt = t.replaceRange(start, end, insertion);
    final newOffset = start + insertion.length;
    _inputController.value = TextEditingValue(
      text: nt,
      selection: TextSelection.collapsed(offset: newOffset),
    );
    setState(() {});
  }

  void _pickEmojiChar(String emoji) {
    final t = _inputController.text;
    final sel = _inputController.selection;
    final start = sel.isValid ? sel.start : t.length;
    final end = sel.isValid ? sel.end : t.length;
    final nt = t.replaceRange(start, end, emoji);
    _inputController.value = TextEditingValue(
      text: nt,
      selection: TextSelection.collapsed(offset: start + emoji.length),
    );
    setState(() {
      _recentEmojis = [
        emoji,
        ..._recentEmojis.where((e) => e != emoji),
      ].take(8).toList();
    });
  }

  Future<void> _sendCollectedStickerDirect(CollectedSticker s) async {
    await widget.remote.sendCollectedSticker(
      conversationId: widget.conversationId,
      stickerId: s.id,
      thumbnailUrl: s.thumbnailUrl,
      isGif: s.isGif,
    );
    if (!mounted) return;
    setState(() {
      _items = [
        ..._items,
        ChatListItem(
          id: 'local_${DateTime.now().millisecondsSinceEpoch}',
          kind: ChatItemKind.sticker,
          isSelf: true,
          stickerThumbUrl: s.thumbnailUrl,
          stickerIsGif: s.isGif,
        ),
      ];
    });
    _scrollToBottom();
  }

  void _emojiPanelBackspace() {
    final t = _inputController.text;
    final sel = _inputController.selection;
    if (sel.isValid && sel.start != sel.end) {
      _insertIntoInput('');
      return;
    }
    if (t.isEmpty) return;
    final list = t.characters.toList();
    if (list.isEmpty) return;
    list.removeLast();
    final newText = list.join();
    _inputController.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );
    setState(() {});
  }

  void _emojiPanelSend() => _onSendText();

  bool get _hasInputForSend => _inputController.text.trim().isNotEmpty;

  Future<void> _loadMessages() async {
    setState(() => _loading = true);
    try {
      final list = await widget.remote.fetchMessages(
        conversationId: widget.conversationId,
      );
      if (!mounted) return;
      setState(() {
        _items = list;
        _loading = false;
      });
      _scrollToBottom();
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    });
  }

  Future<void> _onSendText() async {
    final text = _inputController.text.trim();
    if (text.isEmpty) return;

    await widget.remote.sendText(
      conversationId: widget.conversationId,
      text: text,
    );
    if (!mounted) return;

    setState(() {
      _items = [
        ..._items,
        ChatListItem(
          id: 'local_${DateTime.now().millisecondsSinceEpoch}',
          kind: ChatItemKind.text,
          isSelf: true,
          text: text,
        ),
      ];
      _inputController.clear();
    });
    _scrollToBottom();
  }

  Future<void> _onQuickReactionTap(QuickReactionItem item) async {
    final emoji = item.emoji;
    await widget.remote.sendText(
      conversationId: widget.conversationId,
      text: emoji,
    );
    if (!mounted) return;
    setState(() {
      _items = [
        ..._items,
        ChatListItem(
          id: 'local_${DateTime.now().millisecondsSinceEpoch}',
          kind: ChatItemKind.text,
          isSelf: true,
          text: emoji,
        ),
      ];
    });
    _scrollToBottom();
  }

  @override
  void dispose() {
    _inputFocusNode.removeListener(_onInputFocusChanged);
    _inputFocusNode.dispose();
    _plusMenuPageController.dispose();
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final statusBar = MediaQuery.paddingOf(context).top;

    return WithStatusbarColorView(
      statusBarColor: Colors.white,
      child: Scaffold(
        backgroundColor: _chatBg,
        resizeToAvoidBottomInset: true,
        appBar: _ChatAppBar(
          statusBarHeight: statusBar,
          badgeCount: widget.notificationBadgeCount,
          peerTitle: widget.peerTitle,
          peerAvatarUrl: widget.peerAvatarUrl,
          onVideoCamPressed: () => showChatCallActionSheet(context),
          onMorePressed: () {
            context.push(
              '/chat_info',
              extra: ChatInfoPageArgs(
                peerTitle: widget.peerTitle,
                peerAvatarUrl: widget.peerAvatarUrl,
              ),
            );
          },
        ),
        body: Stack(
          clipBehavior: Clip.none,
          children: [
            Column(
              children: [
                Expanded(
                  child: _loading
                      ? const Center(child: CircularProgressIndicator())
                      : ListView.builder(
                          controller: _scrollController,
                          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                          itemCount: _items.length,
                          itemBuilder: (context, index) {
                            return _buildItem(_items[index]);
                          },
                        ),
                ),
                _buildInputPanel(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItem(ChatListItem item) {
    switch (item.kind) {
      case ChatItemKind.timeDivider:
        return Padding(
          padding: EdgeInsets.symmetric(vertical: 12.h),
          child: Center(
            child: Text(
              item.timeLabel ?? '',
              style: TextStyle(
                fontSize: 12.sp,
                color: const Color(0xFF888888),
              ),
            ),
          ),
        );
      case ChatItemKind.systemNotice:
        return Padding(
          padding: EdgeInsets.symmetric(vertical: 10.h),
          child: Center(
            child: Text(
              item.systemText ?? '',
              style: TextStyle(
                fontSize: 12.sp,
                color: const Color(0xFF888888),
              ),
            ),
          ),
        );
      case ChatItemKind.text:
        return _TextBubbleRow(
          isSelf: item.isSelf ?? false,
          text: item.text ?? '',
          peerAvatarUrl: widget.peerAvatarUrl,
          selfAvatarUrl: widget.selfAvatarUrl,
          selfBubbleColor: _selfBubbleBlue,
        );
      case ChatItemKind.video:
        return _VideoBubbleRow(
          isSelf: item.isSelf ?? false,
          thumbUrl: item.videoThumbUrl,
          tag: item.videoTag,
          peerAvatarUrl: widget.peerAvatarUrl,
          selfAvatarUrl: widget.selfAvatarUrl,
        );
      case ChatItemKind.sticker:
        return _StickerBubbleRow(
          isSelf: item.isSelf ?? false,
          thumbUrl: item.stickerThumbUrl,
          isGif: item.stickerIsGif ?? false,
          peerAvatarUrl: widget.peerAvatarUrl,
          selfAvatarUrl: widget.selfAvatarUrl,
        );
    }
  }

  Widget _buildInputPanel() {
    return Material(
      color: const Color(0xFFF7F7F7),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(vertical: 6.h),
              child: SizedBox(
                height: 40.h,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.symmetric(horizontal: 12.w),
                  itemCount: _quickReactions.length,
                  separatorBuilder: (context, _) => SizedBox(width: 8.w),
                  itemBuilder: (context, index) {
                    final q = _quickReactions[index];
                    return _QuickChip(
                      emoji: q.emoji,
                      label: q.label,
                      onTap: () => _onQuickReactionTap(q),
                    );
                  },
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(12.w, 0, 12.w, 0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(child: _buildTextInputBar()),
                  SizedBox(width: 6.w),
                  _RoundIconButton(
                    icon: _emojiPanelOpen ? Icons.emoji_emotions : Icons.emoji_emotions_outlined,
                    iconColor: _emojiPanelOpen ? _selfBubbleBlue : null,
                    onTap: _toggleEmojiPanel,
                  ),
                  SizedBox(width: 14.w),
                  _RoundIconButton(
                    icon: _plusPanelOpen ? Icons.cancel : Icons.add_circle_outline,
                    onTap: _togglePlusPanel,
                  ),
                ],
              ),
            ),
            if (_emojiPanelOpen) _buildEmojiPanel(),
            if (_plusPanelOpen) _buildPlusFeaturePanel(),
            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }

  Widget _buildTextInputBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6.r),
      ),
      child: TextField(
        focusNode: _inputFocusNode,
        controller: _inputController,
        minLines: 1,
        maxLines: 4,
        textInputAction: TextInputAction.send,
        onChanged: (_) => setState(() {}),
        onSubmitted: (_) => _onSendText(),
        style: TextStyle(fontSize: 15.sp),
        decoration: InputDecoration(
          isDense: true,
          hintText: '发送消息',
          hintStyle: TextStyle(
            color: const Color(0xFFC0C0C0),
            fontSize: 15.sp,
          ),
          contentPadding: EdgeInsets.symmetric(
            horizontal: 12.w,
            vertical: 9.h,
          ),
          border: InputBorder.none,
        ),
      ),
    );
  }

  /// 表情面板：仅「表情」与「收藏」两个 Tab，无搜索、无爱心后的扩展图标。
  Widget _buildEmojiPanel() {
    final panelH = (MediaQuery.sizeOf(context).height * 0.38).clamp(280.0, 410.0);
    final canSend = _hasInputForSend;

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFEBEBEB),
        border: Border(top: BorderSide(color: Colors.black.withValues(alpha: 0.06))),
      ),
      child: SizedBox(
        height: panelH,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(12.w, 10.h, 12.w, 8.h),
                  child: Row(
                    children: [
                      _EmojiTabChip(
                        icon: Icons.emoji_emotions_outlined,
                        selected: _emojiCategoryTab == 0,
                        onTap: () => setState(() => _emojiCategoryTab = 0),
                      ),
                      SizedBox(width: 14.w),
                      _EmojiTabChip(
                        icon: Icons.favorite,
                        selected: _emojiCategoryTab == 1,
                        onTap: () => setState(() => _emojiCategoryTab = 1),
                      ),
                    ],
                  ),
                ),
                Divider(height: 1.h, thickness: 1, color: const Color(0xFFD8D8D8)),
                Expanded(
                  child: _emojiCategoryTab == 0 ? _buildEmojiCharPickerPage() : _buildCollectedStickerPage(),
                ),
              ],
            ),
            if (_emojiCategoryTab == 0)
              Positioned(
                right: 12.w,
                bottom: 40.h,
                child: _EmojiFloatingActions(
                  onBackspace: _emojiPanelBackspace,
                  onSend: canSend ? _emojiPanelSend : null,
                  actionsActive: canSend,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmojiCharPickerPage() {
    return Padding(
      padding: EdgeInsets.fromLTRB(12.w, 8.h, 12.w, 4.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_recentEmojis.isNotEmpty) ...[
            Text(
              '最近使用',
              style: TextStyle(fontSize: 12.sp, color: const Color(0xFF888888)),
            ),
            SizedBox(height: 8.h),
            SizedBox(
              height: 42.h,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _recentEmojis.length,
                separatorBuilder: (context, _) => SizedBox(width: 10.w),
                itemBuilder: (context, i) {
                  final e = _recentEmojis[i];
                  return InkWell(
                    onTap: () => _pickEmojiChar(e),
                    borderRadius: BorderRadius.circular(8.r),
                    child: Center(
                      child: Text(e, style: TextStyle(fontSize: 30.sp)),
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 12.h),
          ],
          Text(
            '全部表情',
            style: TextStyle(fontSize: 12.sp, color: const Color(0xFF888888)),
          ),
          SizedBox(height: 8.h),
          Expanded(
            child: GridView.builder(
              padding: EdgeInsets.only(bottom: 52.h),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 8,
                mainAxisSpacing: 6.h,
                crossAxisSpacing: 2.w,
                childAspectRatio: 1,
              ),
              itemCount: kEmojiGridChars.length,
              itemBuilder: (context, i) {
                final e = kEmojiGridChars[i];
                return InkWell(
                  onTap: () => _pickEmojiChar(e),
                  child: Center(child: Text(e, style: TextStyle(fontSize: 22.sp))),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCollectedStickerPage() {
    return Padding(
      padding: EdgeInsets.fromLTRB(12.w, 10.h, 12.w, 8.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '收藏的表情',
            style: TextStyle(fontSize: 12.sp, color: const Color(0xFF888888)),
          ),
          SizedBox(height: 10.h),
          Expanded(
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                mainAxisSpacing: 10.h,
                crossAxisSpacing: 10.w,
                childAspectRatio: 1,
              ),
              itemCount: mockCollectedStickers.length,
              itemBuilder: (context, i) {
                final s = mockCollectedStickers[i];
                return _CollectedStickerTile(
                  sticker: s,
                  onTap: () => _sendCollectedStickerDirect(s),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  /// 底部「+」展开面板：**不包含**相册缩略图预览条，仅功能宫格。
  Widget _buildPlusFeaturePanel() {
    const page1 = <_PlusMenuAction>[
      _PlusMenuAction(Icons.photo_library_outlined, '相册'),
      _PlusMenuAction(Icons.camera_alt_outlined, '拍摄'),
      _PlusMenuAction(Icons.videocam_outlined, '视频通话'),
      _PlusMenuAction(Icons.groups_outlined, '一起看'),
      _PlusMenuAction(Icons.card_giftcard_outlined, '红包'),
      _PlusMenuAction(Icons.location_on_outlined, '位置'),
      _PlusMenuAction(Icons.currency_exchange_rounded, '转账'),
      _PlusMenuAction(Icons.contact_page_outlined, '个人名片'),
    ];
    const page2 = <_PlusMenuAction>[
      _PlusMenuAction(Icons.mic_none_rounded, '语音输入'),
      _PlusMenuAction(Icons.folder_open_outlined, '文件'),
      _PlusMenuAction(Icons.music_note_outlined, '音乐'),
      _PlusMenuAction(Icons.favorite_border, '收藏'),
      _PlusMenuAction(Icons.schedule_outlined, '日程'),
      _PlusMenuAction(Icons.apps_outlined, '小程序'),
      _PlusMenuAction(Icons.share_outlined, '分享'),
      _PlusMenuAction(Icons.more_horiz, '更多'),
    ];

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFEBEBEB),
        border: Border(top: BorderSide(color: Colors.black.withValues(alpha: 0.06))),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 236.h,
            child: PageView(
              controller: _plusMenuPageController,
              onPageChanged: (i) => setState(() => _plusMenuPageIndex = i),
              children: [
                _PlusFeatureGrid(actions: page1),
                _PlusFeatureGrid(actions: page2),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.only(bottom: 10.h, top: 2.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(2, (i) {
                final active = i == _plusMenuPageIndex;
                return Container(
                  margin: EdgeInsets.symmetric(horizontal: 4.w),
                  width: active ? 8.w : 6.w,
                  height: 6.h,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(3.r),
                    color: active ? const Color(0xFF8E8E8E) : const Color(0xFFC8C8C8),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

class _PlusMenuAction {
  const _PlusMenuAction(this.icon, this.label);
  final IconData icon;
  final String label;
}

class _PlusFeatureGrid extends StatelessWidget {
  const _PlusFeatureGrid({required this.actions});

  final List<_PlusMenuAction> actions;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(12.w, 14.h, 12.w, 8.h),
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          mainAxisSpacing: 14.h,
          crossAxisSpacing: 10.w,
          mainAxisExtent: 94.h,
        ),
        itemCount: actions.length,
        itemBuilder: (context, index) {
          final a = actions[index];
          return Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {},
              borderRadius: BorderRadius.circular(12.r),
              child: Column(
                children: [
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Icon(a.icon, size: 28.r, color: const Color(0xFF404040)),
                    ),
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    a.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 12.sp, color: const Color(0xFF666666)),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ChatAppBar extends StatelessWidget implements PreferredSizeWidget {
  const _ChatAppBar({
    required this.statusBarHeight,
    required this.badgeCount,
    required this.peerTitle,
    this.peerAvatarUrl,
    this.onVideoCamPressed,
    this.onMorePressed,
  });

  final double statusBarHeight;
  final int badgeCount;
  final String peerTitle;
  final String? peerAvatarUrl;
  final VoidCallback? onVideoCamPressed;
  final VoidCallback? onMorePressed;

  @override
  Size get preferredSize => Size.fromHeight(56.h + statusBarHeight);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: statusBarHeight),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Color(0xFFE5E5E5)),
        ),
      ),
      child: SizedBox(
        height: 56.h,
        child: Row(
          children: [
            Padding(
              padding: EdgeInsets.only(left: 4.w),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  InkWell(
                    onTap: () => context.pop(),
                    borderRadius: BorderRadius.circular(24.r),
                    child: Padding(
                      padding: EdgeInsets.all(8.r),
                      child: Icon(
                        Icons.arrow_back_ios_new_rounded,
                        size: 18.r,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  if (badgeCount > 0)
                    Positioned(
                      left: 20.w,
                      top: 4.h,
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 1.h),
                        decoration: BoxDecoration(
                          color: Colors.redAccent,
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        constraints: BoxConstraints(minWidth: 16.w),
                        child: Text(
                          '$badgeCount',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Row(
                children: [
                  _Avatar(url: peerAvatarUrl, radius: 16.r),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      peerTitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  padding: EdgeInsets.all(8.r),
                  constraints: BoxConstraints(minWidth: 40.w, minHeight: 40.h),
                  icon: Icon(Icons.videocam_outlined, color: Colors.black87, size: 22.r),
                  onPressed: onVideoCamPressed,
                ),
                IconButton(
                  padding: EdgeInsets.all(8.r),
                  constraints: BoxConstraints(minWidth: 40.w, minHeight: 40.h),
                  icon: Icon(Icons.more_horiz_rounded, color: Colors.black87, size: 22.r),
                  onPressed: onMorePressed,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({this.url, required this.radius});

  final String? url;
  final double radius;

  @override
  Widget build(BuildContext context) {
    if (url != null && url!.isNotEmpty) {
      return ClipOval(
        child: ExtendedImage.network(
          url!,
          width: radius * 2,
          height: radius * 2,
          fit: BoxFit.cover,
          loadStateChanged: (state) {
            if (state.extendedImageLoadState == LoadState.failed) {
              return _placeholder();
            }
            return null;
          },
        ),
      );
    }
    return _placeholder();
  }

  Widget _placeholder() {
    return CircleAvatar(
      radius: radius,
      backgroundColor: const Color(0xFFE0E0E0),
      child: Icon(Icons.person, size: radius, color: Colors.white70),
    );
  }
}

class _TextBubbleRow extends StatelessWidget {
  const _TextBubbleRow({
    required this.isSelf,
    required this.text,
    this.peerAvatarUrl,
    this.selfAvatarUrl,
    required this.selfBubbleColor,
  });

  final bool isSelf;
  final String text;
  final String? peerAvatarUrl;
  final String? selfAvatarUrl;
  final Color selfBubbleColor;

  @override
  Widget build(BuildContext context) {
    final bubble = Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 9.h),
      constraints: BoxConstraints(maxWidth: 0.68.sw),
      decoration: BoxDecoration(
        color: isSelf ? selfBubbleColor : Colors.white,
        borderRadius: BorderRadius.circular(6.r),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 16.sp,
          color: isSelf ? Colors.white : Colors.black87,
          height: 1.35,
        ),
      ),
    );

    if (isSelf) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 6.h),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            bubble,
            SizedBox(width: 8.w),
            _Avatar(url: selfAvatarUrl, radius: 18.r),
          ],
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Avatar(url: peerAvatarUrl, radius: 18.r),
          SizedBox(width: 8.w),
          bubble,
        ],
      ),
    );
  }
}

class _VideoBubbleRow extends StatelessWidget {
  const _VideoBubbleRow({
    required this.isSelf,
    this.thumbUrl,
    this.tag,
    this.peerAvatarUrl,
    this.selfAvatarUrl,
  });

  final bool isSelf;
  final String? thumbUrl;
  final String? tag;
  final String? peerAvatarUrl;
  final String? selfAvatarUrl;

  static const double _cardW = 200;
  static const double _cardH = 118;

  @override
  Widget build(BuildContext context) {
    final card = ClipRRect(
      borderRadius: BorderRadius.circular(8.r),
      child: SizedBox(
        width: _cardW.w,
        height: _cardH.h,
        child: Stack(
          fit: StackFit.expand,
          children: [
            _buildThumb(),
            Container(
              color: Colors.black.withValues(alpha: 0.12),
              child: Center(
                child: Icon(
                  Icons.play_circle_fill_rounded,
                  color: Colors.white.withValues(alpha: 0.95),
                  size: 44.r,
                ),
              ),
            ),
            if (tag != null && tag!.isNotEmpty)
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 4.h),
                  color: Colors.black45,
                  child: Text(
                    tag!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: Colors.white, fontSize: 11.sp),
                  ),
                ),
              ),
          ],
        ),
      ),
    );

    if (isSelf) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 6.h),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            card,
            SizedBox(width: 8.w),
            _Avatar(url: selfAvatarUrl, radius: 18.r),
          ],
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Avatar(url: peerAvatarUrl, radius: 18.r),
          SizedBox(width: 8.w),
          card,
        ],
      ),
    );
  }

  Widget _buildThumb() {
    if (thumbUrl != null && thumbUrl!.isNotEmpty) {
      return ExtendedImage.network(
        thumbUrl!,
        fit: BoxFit.cover,
        loadStateChanged: (state) {
          if (state.extendedImageLoadState == LoadState.failed) {
            return _gradientFallback();
          }
          return null;
        },
      );
    }
    return _gradientFallback();
  }

  Widget _gradientFallback() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFFF9A56),
            Color(0xFFFF6B6B),
            Color(0xFF7C4DFF),
          ],
        ),
      ),
      child: Center(
        child: Text(
          '预览',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.9),
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _StickerBubbleRow extends StatelessWidget {
  const _StickerBubbleRow({
    required this.isSelf,
    this.thumbUrl,
    required this.isGif,
    this.peerAvatarUrl,
    this.selfAvatarUrl,
  });

  final bool isSelf;
  final String? thumbUrl;
  final bool isGif;
  final String? peerAvatarUrl;
  final String? selfAvatarUrl;

  static const double _side = 126;

  @override
  Widget build(BuildContext context) {
    final card = ClipRRect(
      borderRadius: BorderRadius.circular(8.r),
      child: SizedBox(
        width: _side.w,
        height: _side.w,
        child: Stack(
          fit: StackFit.expand,
          children: [
            _buildThumb(),
            if (isGif)
              Positioned(
                right: 5.w,
                bottom: 5.h,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                  child: Text(
                    'GIF',
                    style: TextStyle(color: Colors.white, fontSize: 10.sp, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
          ],
        ),
      ),
    );

    if (isSelf) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 6.h),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            card,
            SizedBox(width: 8.w),
            _Avatar(url: selfAvatarUrl, radius: 18.r),
          ],
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Avatar(url: peerAvatarUrl, radius: 18.r),
          SizedBox(width: 8.w),
          card,
        ],
      ),
    );
  }

  Widget _buildThumb() {
    if (thumbUrl != null && thumbUrl!.isNotEmpty) {
      return ExtendedImage.network(
        thumbUrl!,
        fit: BoxFit.cover,
        loadStateChanged: (state) {
          if (state.extendedImageLoadState == LoadState.failed) {
            return ColoredBox(
              color: const Color(0xFFE8E8E8),
              child: Icon(Icons.broken_image_outlined, size: 36.r, color: Colors.grey),
            );
          }
          return null;
        },
      );
    }
    return ColoredBox(
      color: const Color(0xFFE8E8E8),
      child: Icon(Icons.image_outlined, size: 36.r, color: Colors.grey),
    );
  }
}

/// 表情面板右下角悬浮：退格 + 发送（不占一整行高度；与 [actionsActive] 同步高亮）
class _EmojiFloatingActions extends StatelessWidget {
  const _EmojiFloatingActions({
    required this.onBackspace,
    required this.onSend,
    required this.actionsActive,
  });

  final VoidCallback onBackspace;
  final VoidCallback? onSend;
  final bool actionsActive;

  static const Color _sendActiveBg = Color(0xFFFF4D5E);
  static const Color _sendInactiveBg = Color(0xFFFFCCD0);
  static const Color _backspaceActiveBg = Color(0xFFC8C8C8);
  static const Color _backspaceInactiveBg = Color(0xFFECECEC);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Material(
          color: actionsActive ? _backspaceActiveBg : _backspaceInactiveBg,
          elevation: actionsActive ? 2 : 0,
          shadowColor: actionsActive ? Colors.black26 : Colors.transparent,
          borderRadius: BorderRadius.circular(8.r),
          child: InkWell(
            onTap: actionsActive ? onBackspace : null,
            borderRadius: BorderRadius.circular(8.r),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 13.w, vertical: 9.h),
              child: Icon(
                Icons.backspace_outlined,
                size: 21.r,
                color: actionsActive ? Colors.black87 : const Color(0xFFBDBDBD),
              ),
            ),
          ),
        ),
        SizedBox(width: 10.w),
        Material(
          color: actionsActive ? _sendActiveBg : _sendInactiveBg,
          elevation: actionsActive ? 2 : 0,
          shadowColor: actionsActive ? Colors.black26 : Colors.transparent,
          borderRadius: BorderRadius.circular(8.r),
          child: InkWell(
            onTap: onSend,
            borderRadius: BorderRadius.circular(8.r),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 9.h),
              child: Text(
                '发送',
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w600,
                  color: actionsActive ? Colors.white : const Color(0xFFFFEBEE).withValues(alpha: 0.95),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _EmojiTabChip extends StatelessWidget {
  const _EmojiTabChip({
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22.r),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        curve: Curves.easeOut,
        padding: EdgeInsets.all(10.r),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: selected ? Colors.white : Colors.transparent,
        ),
        child: Icon(
          icon,
          size: 24.r,
          color: selected ? const Color(0xFF1296DB) : const Color(0xFF777777),
        ),
      ),
    );
  }
}

class _CollectedStickerTile extends StatelessWidget {
  const _CollectedStickerTile({required this.sticker, required this.onTap});

  final CollectedSticker sticker;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(10.r),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Stack(
          fit: StackFit.expand,
          children: [
            ExtendedImage.network(
              sticker.thumbnailUrl,
              fit: BoxFit.cover,
              loadStateChanged: (state) {
                if (state.extendedImageLoadState == LoadState.failed) {
                  return ColoredBox(
                    color: const Color(0xFFE8E8E8),
                    child: Icon(Icons.broken_image_outlined, size: 28.r, color: Colors.grey),
                  );
                }
                return null;
              },
            ),
            if (sticker.isGif)
              Positioned(
                right: 4.w,
                bottom: 4.h,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                  child: Text(
                    'GIF',
                    style: TextStyle(color: Colors.white, fontSize: 9.sp, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _QuickChip extends StatelessWidget {
  const _QuickChip({
    required this.emoji,
    required this.label,
    required this.onTap,
  });

  final String emoji;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.r),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18.r),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18.r),
              border: Border.all(color: const Color(0xFFE0E0E0)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(emoji, style: TextStyle(fontSize: 14.sp)),
                SizedBox(width: 4.w),
                Text(
                  label,
                  style: TextStyle(fontSize: 13.sp, color: Colors.black87),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  const _RoundIconButton({
    required this.icon,
    required this.onTap,
    this.iconColor,
  });

  final IconData icon;
  final VoidCallback onTap;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22.r),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 6.h),
        child: Icon(icon, size: 24.r, color: iconColor ?? Colors.black54),
      ),
    );
  }
}
