import 'package:bilbili_project/components/custom_input.dart';
import 'package:bilbili_project/pages/Home/comps/bulid_groups_view.dart';
import 'package:bilbili_project/pages/Home/comps/contact_list_item.dart';
import 'package:bilbili_project/pages/Home/comps/my_groups_view.dart';
import 'package:bilbili_project/viewmodels/Message/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class VideoShareExpandedSheetSkeleton extends StatefulWidget {
  VideoShareExpandedSheetSkeleton({Key? key}) : super(key: key);

  @override
  _VideoShareExpandedSheetSkeletonState createState() =>
      _VideoShareExpandedSheetSkeletonState();
}

class _VideoShareExpandedSheetSkeletonState
    extends State<VideoShareExpandedSheetSkeleton> {
  final TextEditingController _textEditingController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  int _currentPanelIndex = 0; // 0:联系人列表 1:建群分享 2:我的群聊

  @override
  void initState() {
    super.initState();
    _searchFocusNode.addListener(_onSearchFocusChanged);
  }

  void _onSearchFocusChanged() {
    if (!mounted) return;
    setState(() {});
  }

  void _onCancelTap() {
    _searchFocusNode.unfocus();
  }

  void _onInputChanged(String val) {
    setState(() {});
  }

  // 发送按钮
  void _sendButtonTap() {
    print('发送按钮');
  }

  @override
  void dispose() {
    _searchFocusNode.removeListener(_onSearchFocusChanged);
    _searchFocusNode.dispose();
    _textEditingController.dispose();
    super.dispose();
  }

  // 模拟联系人列表数据
  List<ContactItem> frequentContacts = [
    ContactItem(
      name: '张三',
      avatar:
          'https://q6.itc.cn/q_70/images03/20250306/355fba6a5cb049f5b98c2ed9f03cc5e1.jpeg',
      lastMessage: '你好',
      lastMessageTime: '2021-01-01 12:00:00',
      unreadCount: '1',
    ),
    ContactItem(
      name: '李四',
      avatar:
          'https://q2.itc.cn/q_70/images03/20250623/337b5e62a9444bcda5d4b1aee5cddf54.jpeg',
      lastMessage: '你好',
      lastMessageTime: '2021-01-01 12:00:00',
      unreadCount: '1',
    ),
    ContactItem(
      name: '王五',
      avatar:
          'https://gimg2.baidu.com/image_search/src=http%3A%2F%2Fci.xiaohongshu.com%2F0f978950-9630-58ff-e79a-3ac8f7dfbfcc%3FimageView2%2F2%2Fw%2F1080%2Fformat%2Fjpg&refer=http%3A%2F%2Fci.xiaohongshu.com&app=2002&size=f9999,10000&q=a80&n=0&g=0n&fmt=auto?sec=1778439524&t=3a4b5e1b129df6428ba6c91242e46436',
      lastMessage: '你好',
      lastMessageTime: '2021-01-01 12:00:00',
      unreadCount: '1',
    ),
    ContactItem(
      name: '赵六',
      avatar:
          'https://wx4.sinaimg.cn/mw690/70e1e519ly1i9xgh6g04ej20sg0sggsj.jpg',
      lastMessage: '你好',
      lastMessageTime: '2021-01-01 12:00:00',
      unreadCount: '1',
    ),
    ContactItem(
      name: '孙七',
      avatar:
          'https://ww3.sinaimg.cn/mw690/6c79248dly1iba2jh0rpzj20wr0wb42e.jpg',
      lastMessage: '你好',
      lastMessageTime: '2021-01-01 12:00:00',
      unreadCount: '1',
    ),
    ContactItem(
      name: '王五',
      avatar:
          'https://gimg2.baidu.com/image_search/src=http%3A%2F%2Fci.xiaohongshu.com%2F0f978950-9630-58ff-e79a-3ac8f7dfbfcc%3FimageView2%2F2%2Fw%2F1080%2Fformat%2Fjpg&refer=http%3A%2F%2Fci.xiaohongshu.com&app=2002&size=f9999,10000&q=a80&n=0&g=0n&fmt=auto?sec=1778439524&t=3a4b5e1b129df6428ba6c91242e46436',
      lastMessage: '你好',
      lastMessageTime: '2021-01-01 12:00:00',
      unreadCount: '1',
    ),
    ContactItem(
      name: '赵六',
      avatar:
          'https://wx4.sinaimg.cn/mw690/70e1e519ly1i9xgh6g04ej20sg0sggsj.jpg',
      lastMessage: '你好',
      lastMessageTime: '2021-01-01 12:00:00',
      unreadCount: '1',
    ),
    ContactItem(
      name: '孙七',
      avatar:
          'https://ww3.sinaimg.cn/mw690/6c79248dly1iba2jh0rpzj20wr0wb42e.jpg',
      lastMessage: '你好',
      lastMessageTime: '2021-01-01 12:00:00',
      unreadCount: '1',
    ),
    ContactItem(
      name: '王五',
      avatar:
          'https://gimg2.baidu.com/image_search/src=http%3A%2F%2Fci.xiaohongshu.com%2F0f978950-9630-58ff-e79a-3ac8f7dfbfcc%3FimageView2%2F2%2Fw%2F1080%2Fformat%2Fjpg&refer=http%3A%2F%2Fci.xiaohongshu.com&app=2002&size=f9999,10000&q=a80&n=0&g=0n&fmt=auto?sec=1778439524&t=3a4b5e1b129df6428ba6c91242e46436',
      lastMessage: '你好',
      lastMessageTime: '2021-01-01 12:00:00',
      unreadCount: '1',
    ),
    ContactItem(
      name: '赵六',
      avatar:
          'https://wx4.sinaimg.cn/mw690/70e1e519ly1i9xgh6g04ej20sg0sggsj.jpg',
      lastMessage: '你好',
      lastMessageTime: '2021-01-01 12:00:00',
      unreadCount: '1',
    ),
    ContactItem(
      name: '孙七',
      avatar:
          'https://ww3.sinaimg.cn/mw690/6c79248dly1iba2jh0rpzj20wr0wb42e.jpg',
      lastMessage: '你好',
      lastMessageTime: '2021-01-01 12:00:00',
      unreadCount: '1',
    ),
  ];

  //  显示 建群分享ui
  void _showBuildGroupShareUI() {
    setState(() {
      _currentPanelIndex = 1;
    });
  }

  // 显示 我的群聊ui
  void _showMyGroupUI() {
    setState(() {
      _currentPanelIndex = 2;
    });
  }

  void backToContacts() {
    setState(() {
      _currentPanelIndex = 0;
    });
  }

  Widget _buildContactsPanel() {
    return ListView.builder(
      key: const ValueKey('contacts_panel'),
      itemCount: frequentContacts.length + 2,
      itemBuilder: (context, index) {
        if (index == 0) {
          return GestureDetector(
            onTap: () {
              _showBuildGroupShareUI();
            },
            child: ContactListItem(
              contactItem: ContactItem(
                name: '建群分享',
                avatar: '',
                lastMessage: '',
                lastMessageTime: '',
                unreadCount: '',
              ),
              leading: Container(
                width: 48.r,
                height: 48.r,
                decoration: BoxDecoration(
                  color: Color.fromRGBO(243, 243, 244, 1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  FontAwesomeIcons.comments,
                  size: 20.sp,
                  color: Color.fromRGBO(78, 79, 87, 1),
                ),
              ),
              trailing: GestureDetector(
                onTap: () {
                  _showBuildGroupShareUI();
                },
                // 向右的箭头
                child: Icon(
                  FontAwesomeIcons.angleRight,
                  size: 18.sp,
                  color: Color.fromRGBO(78, 79, 87, 1),
                ),
              ),
            ),
          );
        }
        if (index == 1) {
          return GestureDetector(
            onTap: () {
              _showMyGroupUI();
            },
            child: ContactListItem(
              contactItem: ContactItem(
                name: '我的群聊',
                avatar: '',
                lastMessage: '',
                lastMessageTime: '',
                unreadCount: '',
              ),
              leading: Container(
                width: 48.r,
                height: 48.r,
                decoration: BoxDecoration(
                  color: Color.fromRGBO(243, 243, 244, 1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  FontAwesomeIcons.userGroup,
                  size: 20.sp,
                  color: Color.fromRGBO(78, 79, 87, 1),
                ),
              ),
              trailing: GestureDetector(
                onTap: () {
                  _showMyGroupUI();
                },
                // 向右的箭头
                child: Icon(
                  FontAwesomeIcons.angleRight,
                  size: 18.sp,
                  color: Color.fromRGBO(78, 79, 87, 1),
                ),
              ),
            ),
          );
        }
        return ContactListItem(
          contactItem: frequentContacts[index - 2],
          leading: CircleAvatar(
            radius: 24.r,
            backgroundColor: Color.fromRGBO(243, 243, 244, 1),
            backgroundImage: NetworkImage(frequentContacts[index - 2].avatar),
          ),
          trailing: SizedBox(
            width: 80.w,
            height: 32.h,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Color.fromRGBO(253, 44, 85, 1),
              ),
              onPressed: () {
                _sendButtonTap();
              },
              child: Text(
                '发送',
                style: TextStyle(
                  fontSize: 13.sp,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildOverlayPanel() {
    if (_currentPanelIndex == 1) {
      return Container(
        key: const ValueKey('build_group_panel'),
        color: Colors.white,
        width: double.infinity,
        height: double.infinity,
        child: BulidGroupsView(onBack: backToContacts),
      );
    }

    if (_currentPanelIndex == 2) {
      return Container(
        key: const ValueKey('my_groups_panel'),
        color: Colors.white,
        width: double.infinity,
        height: double.infinity,
        child: MyGroupsView(onBack: backToContacts),
      );
    }

    return const SizedBox.shrink(key: ValueKey('empty_overlay_panel'));
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.all(Radius.circular(16.r)),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.65,
        color: Colors.white,
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 24.h),
        child: Stack(
          children: [
            Column(
              spacing: 12.h,
              mainAxisSize: MainAxisSize.min,
              children: [
                // 搜索栏
                SizedBox(
                  height: 46.h,
                  child: Stack(
                    clipBehavior: Clip.hardEdge,
                    children: [
                      Positioned.fill(
                        child: AnimatedPadding(
                          duration: const Duration(milliseconds: 220),
                          curve: Curves.easeInOut,
                          padding: EdgeInsets.only(
                            right: _searchFocusNode.hasFocus ? 52.w : 0,
                          ),
                          child: CustomInputView(
                            hintText: '搜索',
                            fillColor: Color.fromRGBO(243, 243, 244, 1),
                            onChanged: _onInputChanged,
                            controller: _textEditingController,
                            focusNode: _searchFocusNode,
                          ),
                        ),
                      ),
                      Positioned(
                        right: 0,
                        top: 0,
                        bottom: 0,
                        child: SizedBox(
                          width: 52.w,
                          child: AnimatedOpacity(
                            duration: const Duration(milliseconds: 220),
                            curve: Curves.easeInOut,
                            opacity: _searchFocusNode.hasFocus ? 1.0 : 0.0,
                            child: IgnorePointer(
                              ignoring: !_searchFocusNode.hasFocus,
                              child: Align(
                                alignment: Alignment.centerRight,
                                child: TextButton(
                                  style: TextButton.styleFrom(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 4.w,
                                    ),
                                    minimumSize: Size.zero,
                                    tapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                  ),
                                  onPressed: _onCancelTap,
                                  child: Text(
                                    '取消',
                                    style: TextStyle(
                                      fontSize: 15.sp,
                                      color: Color.fromRGBO(32, 32, 33, 1),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // 联系人列表  / 搜索结果
                Expanded(child: _buildContactsPanel()),
              ],
            ),
            Positioned.fill(
              child: IgnorePointer(
                ignoring: _currentPanelIndex == 0,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 260),
                  switchInCurve: Curves.easeOutCubic,
                  switchOutCurve: Curves.easeOutCubic,
                  transitionBuilder: (child, animation) {
                    final slideAnimation = Tween<Offset>(
                      begin: const Offset(1, 0),
                      end: Offset.zero,
                    ).animate(animation);
                    return SlideTransition(
                      position: slideAnimation,
                      child: child,
                    );
                  },
                  child: _buildOverlayPanel(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
