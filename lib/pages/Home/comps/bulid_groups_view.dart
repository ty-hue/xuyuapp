import 'package:bilbili_project/components/custom_input.dart';
import 'package:bilbili_project/components/static_app_bar.dart';
import 'package:bilbili_project/pages/Home/comps/contact_list_item.dart';
import 'package:bilbili_project/pages/Home/comps/contact_name_filter.dart';
import 'package:bilbili_project/viewmodels/Message/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class BulidGroupsView extends StatefulWidget {
  final Function() onBack;
  final bool isNeedBackButton;
  BulidGroupsView({Key? key, required this.onBack, this.isNeedBackButton = true}) : super(key: key);

  @override
  _BulidGroupsViewState createState() => _BulidGroupsViewState();
}

class _BulidGroupsViewState extends State<BulidGroupsView> {
  final TextEditingController _textEditingController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _searchFocusNode.addListener(_onSearchFocusChanged);
  }

  @override
  void dispose() {
    _searchFocusNode.removeListener(_onSearchFocusChanged);
    _searchFocusNode.dispose();
    _textEditingController.dispose();
    super.dispose();
  }

  void _onSearchFocusChanged() {
    if (!mounted) return;
    setState(() {});
  }

  void _onCancelTap() {
    _textEditingController.clear();
    _searchFocusNode.unfocus();
    setState(() {});
  }

  void _onInputChanged(String value) {
    setState(() {});
  }

  final List<ContactItem> _allContacts = [
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

  List<ContactItem> get _visibleContacts =>
      filterContactsByName(_allContacts, _textEditingController.text);

  // 选中的用户
  List<ContactItem> selectedContacts = [];

  // 选中用户/取消选中
  void _onSelectedContact(ContactItem contact) {
    if (selectedContacts.contains(contact)) {
      selectedContacts.remove(contact);
    } else {
      selectedContacts.add(contact);
    }
    setState(() {});
  }

  // 建群并分享
  void _onBuildGroupAndShareTap() {
    print('建群并分享');
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Colors.white,
      child: Column(
        spacing: 12.h,
        children: [
          StaticAppBar(
            backgroundColor: Colors.transparent,
            title: '建群分享',
            titleFontSize: 18.sp,
            titleFontWeight: FontWeight.w600,
            titleColor: Color.fromRGBO(22, 24, 35, 1),
            leadingChild: GestureDetector(
              onTap: () {
                widget.onBack();
              },
              child: widget.isNeedBackButton ? Icon(
                Icons.arrow_back_ios_new,
                size: 24.sp,
                color: Color.fromRGBO(22, 24, 35, 1),
              ) : SizedBox.shrink(),
            ),
          ),
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
                      hintText: '搜索用户',
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
                              padding: EdgeInsets.symmetric(horizontal: 4.w),
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
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
          Expanded(
            child: ListView.builder(
              itemCount: _visibleContacts.length,
              itemBuilder: (context, index) {
                final contact = _visibleContacts[index];
                return GestureDetector(
                  onTap: () {
                    _onSelectedContact(contact);
                  },
                  child: ContactListItem(
                    // 无边框
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.transparent),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                    contactItem: contact,
                    leading: CircleAvatar(
                      radius: 32.r,
                      backgroundColor: Color.fromRGBO(243, 243, 244, 1),
                      backgroundImage: NetworkImage(
                        contact.avatar,
                      ),
                    ),
                    // 圆型单选框
                    trailing: Checkbox(
                      side: BorderSide(
                        color: Color.fromRGBO(188, 188, 188, 1),
                        width: 1.w,
                      ),
                      activeColor: Color.fromRGBO(255, 41, 81, 1),
                      checkColor: Colors.white,
                      value: selectedContacts.contains(contact),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      onChanged: (value) {
                        _onSelectedContact(contact);
                      },
                    ),
                  ),
                );
              },
            ),
          ),
          SizedBox(
            width: double.infinity,
            height: 46.h,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Color.fromRGBO(255, 41, 81, 1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.r),
                ),
              ),
              onPressed: selectedContacts.length < 2
                  ? null
                  : _onBuildGroupAndShareTap,

              child: Text(
                '建群并分享(${selectedContacts.length})',
                style: TextStyle(
                  fontSize: 16.sp,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
