import 'package:bilbili_project/components/with_statusBar_color.dart';
import 'package:bilbili_project/pages/Message/sub/Chat/chat_history_search_page.dart';
import 'package:bilbili_project/pages/Message/sub/Chat/set_chat_background_sheet.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

/// 进入「聊天信息」页时通过 [GoRouterState.extra] 传入；缺省与 [ChatPage] 演示数据一致。
class ChatInfoPageArgs {
  const ChatInfoPageArgs({
    this.peerTitle = '心似❤️朝阳☀️',
    this.peerAvatarUrl,
  });

  final String peerTitle;
  final String? peerAvatarUrl;
}

/// 私信会话设置：聊天信息（与产品示意图一致的卡片列表 + 开关交互）。
class ChatInfoPage extends StatefulWidget {
  const ChatInfoPage({
    super.key,
    required this.args,
  });

  final ChatInfoPageArgs args;

  @override
  State<ChatInfoPage> createState() => _ChatInfoPageState();
}

class _ChatInfoPageState extends State<ChatInfoPage> {
  /// 消息免打扰
  bool _mute = false;

  /// 置顶聊天
  bool _pin = false;

  static const Color _pageBg = Color(0xFFF2F2F7);
  static const Color _chevron = Color(0xFFC7C7CC);

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.paddingOf(context).top;
    final args = widget.args;

    return WithStatusbarColorView(
      statusBarColor: Colors.white,
      child: Scaffold(
        backgroundColor: _pageBg,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildAppBar(context, top),
            Expanded(
              child: ListView(
                padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 24.h),
                children: [
                  _memberCard(args),
                  SizedBox(height: 12.h),
                  _switchCard(
                    children: [
                      _switchTile('消息免打扰', _mute, (v) => setState(() => _mute = v)),
                      _divider(),
                      _switchTile('置顶聊天', _pin, (v) => setState(() => _pin = v)),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  _plainCard(
                    children: [
                      _arrowTile(
                        '查找聊天内容',
                        onTap: () => context.push(
                          '/chat_history_search',
                          extra: ChatHistorySearchPageArgs(
                            peerTitle: args.peerTitle,
                            peerAvatarUrl: args.peerAvatarUrl,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  _plainCard(
                    children: [
                      _arrowTile('设置聊天背景', onTap: () => showSetChatBackgroundSheet(context)),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  _singleActionCard(
                    title: '清空聊天记录',
                    titleColor: const Color(0xFFFF3B30),
                    showChevron: true,
                    onTap: _showClearHistoryBottomSheet,
                  ),
                  SizedBox(height: 12.h),
                  _singleActionCard(
                    title: '举报',
                    titleColor: Colors.black87,
                    showChevron: true,
                    onTap: _onReport,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, double statusBarHeight) {
    return Container(
      padding: EdgeInsets.only(top: statusBarHeight),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFE5E5E5))),
      ),
      child: SizedBox(
        height: 44.h,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: InkWell(
                onTap: () => context.pop(),
                borderRadius: BorderRadius.circular(22.r),
                child: Padding(
                  padding: EdgeInsets.only(left: 8.w, right: 12.w, top: 8.h, bottom: 8.h),
                  child: Icon(Icons.arrow_back_ios_new_rounded, size: 18.r, color: Colors.black87),
                ),
              ),
            ),
            Text(
              '聊天信息',
              style: TextStyle(
                fontSize: 17.sp,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _memberCard(ChatInfoPageArgs args) {
    return _whiteCard(
      child: Column(
        children: [
          Material(
            color: Colors.white,
            child: InkWell(
              onTap: () {},
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                child: Row(
                  children: [
                    _peerAvatar(url: args.peerAvatarUrl),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Text(
                        args.peerTitle,
                        style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w500, color: Colors.black87),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Icon(Icons.chevron_right_rounded, color: _chevron, size: 22.r),
                  ],
                ),
              ),
            ),
          ),
          _dividerFull(),
          Material(
            color: Colors.white,
            child: InkWell(
              onTap: () => context.push('/select_mutual_followers'),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                child: Row(
                  children: [
                    Container(
                      width: 40.r,
                      height: 40.r,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE9E9EA),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.add, color: Colors.black54, size: 22.r),
                    ),
                    SizedBox(width: 12.w),
                    Text(
                      '发起群聊',
                      style: TextStyle(fontSize: 16.sp, color: Colors.black87),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _peerAvatar({String? url}) {
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
              return _avatarPlaceholder(r);
            }
            return null;
          },
        ),
      );
    }
    return _avatarPlaceholder(r);
  }

  Widget _avatarPlaceholder(double r) {
    return CircleAvatar(
      radius: r,
      backgroundColor: const Color(0xFFE5E5EA),
      child: Icon(Icons.person_rounded, size: r, color: Colors.white70),
    );
  }

  Widget _switchCard({required List<Widget> children}) {
    return _whiteCard(child: Column(children: children));
  }

  Widget _plainCard({required List<Widget> children}) {
    return _whiteCard(child: Column(children: children));
  }

  Widget _whiteCard({required Widget child}) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12.r),
        child: child,
      ),
    );
  }

  Widget _divider() => Divider(height: 1.h, thickness: 1, indent: 16.w, endIndent: 16.w, color: const Color(0xFFE5E5EA));

  Widget _dividerFull() => Divider(height: 1.h, thickness: 1, indent: 0, endIndent: 0, color: const Color(0xFFE5E5EA));

  Widget _switchTile(String title, bool value, ValueChanged<bool> onChanged) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: TextStyle(fontSize: 16.sp, color: Colors.black87),
            ),
          ),
          CupertinoSwitch(
            value: value,
            onChanged: onChanged,
            activeTrackColor: const Color(0xFF34C759),
          ),
        ],
      ),
    );
  }

  /// 底部 Action Sheet：说明文案 +「确认清空」+ 独立「取消」（与常见 IM 一致）。
  void _showClearHistoryBottomSheet() {
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.45),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.fromLTRB(12.w, 0, 12.w, bottomInset + 10.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(14.r), bottom: Radius.circular(14.r)),
                child: ColoredBox(
                  color: Colors.white,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: EdgeInsets.fromLTRB(18.w, 18.h, 18.w, 14.h),
                        child: Text(
                          '该聊天记录将在你的所有登录设备上清空，近1年的聊天记录将在「设置-最近删除的聊天记录」中保留7天',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13.sp,
                            height: 1.45,
                            color: const Color(0xFF8E8E93),
                          ),
                        ),
                      ),
                      Divider(height: 1.h, thickness: 0.5, color: const Color(0xFFE5E5EA)),
                      Material(
                        color: Colors.white,
                        child: InkWell(
                          onTap: () {
                            Navigator.pop(ctx);
                            ScaffoldMessenger.maybeOf(context)?.showSnackBar(
                              const SnackBar(content: Text('已清空（演示）')),
                            );
                          },
                          child: SizedBox(
                            width: double.infinity,
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 16.h),
                              child: Text(
                                '确认清空聊天记录',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 17.sp,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFFFF3B30),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 10.h),
              ClipRRect(
                borderRadius: BorderRadius.circular(14.r),
                child: Material(
                  color: Colors.white,
                  child: InkWell(
                    onTap: () => Navigator.pop(ctx),
                    child: SizedBox(
                      width: double.infinity,
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 16.h),
                        child: Text(
                          '取消',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 17.sp,
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _onReport() {
    context.push('/report');
  }

  /// 底部独立一项（单独白卡片）；与 [_arrowTile] 一致可带右侧箭头。
  Widget _singleActionCard({
    required String title,
    required Color titleColor,
    required VoidCallback onTap,
    bool showChevron = false,
  }) {
    return _whiteCard(
      child: Material(
        color: Colors.white,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(fontSize: 16.sp, color: titleColor, fontWeight: FontWeight.w400),
                  ),
                ),
                if (showChevron)
                  Icon(Icons.chevron_right_rounded, color: _chevron, size: 22.r),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _arrowTile(String title, {required VoidCallback onTap}) {
    return Material(
      color: Colors.white,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(fontSize: 16.sp, color: Colors.black87),
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: _chevron, size: 22.r),
            ],
          ),
        ),
      ),
    );
  }
}
