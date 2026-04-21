import 'package:bilbili_project/components/avatar_with_nickname_list.dart';
import 'package:bilbili_project/components/dim_tap_Icon_button.dart';
import 'package:bilbili_project/components/static_app_bar.dart';
import 'package:bilbili_project/components/with_statusBar_color.dart';
import 'package:bilbili_project/pages/Message/comps/contacts_list.dart';
import 'package:bilbili_project/pages/Message/comps/search_view.dart';
import 'package:bilbili_project/routes/app_router.dart';
import 'package:bilbili_project/utils/PopoverUtils.dart';
import 'package:bilbili_project/viewmodels/Message/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class MessagePage extends StatefulWidget {
  MessagePage({Key? key}) : super(key: key);

  @override
  State<MessagePage> createState() => _MessagePageState();
}

class _MessagePageState extends State<MessagePage> {
  bool isSearch = false;
  // 点击搜索按钮
  void _onSearch() {
    setState(() {
      isSearch = true;
    });
  }

  // 取消搜索
  void cancelSearch() {
    setState(() {
      isSearch = false;
    });
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
  ];
  // 列表项点击回调
  void _onItemTap(int index) {
    ChatRoute().push(context);
  }
  @override
  Widget build(BuildContext context) {
    return WithStatusbarColorView(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.dark,
      child: Stack(
        children: [
          Scaffold(
            appBar: StaticAppBar(
              backgroundColor: Colors.white,
              statusBarHeight: MediaQuery.of(context).padding.top,
              title: '消息',
              titleColor: Colors.black,
              titleFontWeight: FontWeight.w600,
              titleFontSize: 20.sp,
              actions: [
                DimTapIconButton(
                  icon: FontAwesomeIcons.search,
                  size: 22.sp,
                  color: Colors.black,
                  onPressed: () {
                    _onSearch();
                  },
                ),

                Builder(
                  builder: (anchorContext) {
                    return DimTapIconButton(
                      icon: FontAwesomeIcons.plus,
                      size: 22.sp,
                      color: Colors.black,
                      onPressed: () {
                        PopoverUtils.show(
                          context: anchorContext,
                          bodyBuilder: (context) => Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    onTap: () {
                                      print('发起群聊');
                                    },
                                    splashColor: Color.fromRGBO(
                                      207,
                                      72,
                                      53,
                                      0.2,
                                    ),
                                    highlightColor: Color.fromRGBO(
                                      207,
                                      72,
                                      53,
                                      0.1,
                                    ),
                                    child: Padding(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 20.w,
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        spacing: 12.0.w,
                                        children: [
                                          // 群聊图标
                                          Icon(
                                            FontAwesomeIcons.comment,
                                            size: 20.0.sp,
                                            color: Colors.black,
                                          ),
                                          Text(
                                            '发起群聊',
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 16.0.sp,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Divider(
                                height: 1.0.h,
                                color: Colors.grey.withOpacity(0.2),
                              ),
                              Expanded(
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    onTap: () {
                                      AddFriendRoute().push(context);
                                      Navigator.pop(context);
                                    },
                                    splashColor: Color.fromRGBO(
                                      207,
                                      72,
                                      53,
                                      0.2,
                                    ),
                                    highlightColor: Color.fromRGBO(
                                      207,
                                      72,
                                      53,
                                      0.1,
                                    ),
                                    child: Padding(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 20.w,
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        spacing: 12.0.w,
                                        children: [
                                          Icon(
                                            FontAwesomeIcons.userPlus,
                                            size: 20.0.sp,
                                            color: Colors.black,
                                          ),
                                          Text(
                                            '添加朋友',
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 16.0.sp,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          onPop: () {},
                          width: 180.w,
                          height: 130.h,
                          arrowHeight: 15.h,
                          arrowWidth: 30.w,
                        );
                      },
                    );
                  },
                ),
              ],
            ),
            body: Container(
              color: Colors.white,
              padding: EdgeInsets.all(16.w),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AvatarWithNicknameList(
                      items: frequentContacts,
                      onEndButtonTap: () {
                        print('跳转设置页面');
                      },
                      endButtonText: '状态设置',
                      onItemTap: _onItemTap,
                    ),
                    ContactsList(),
                    Container(
                      height: 60.h,
                      child: Center(
                        child: Text(
                          '暂时没有更多了',
                          style: TextStyle(color: Colors.grey, fontSize: 14.sp),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (isSearch)
            Positioned.fill(child: SearchView(cancelSearch: cancelSearch, searchResult: frequentContacts)),
        ],
      ),
    );
  }
}

