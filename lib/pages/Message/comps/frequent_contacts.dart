import 'package:bilbili_project/viewmodels/Message/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class FrequentContacts extends StatefulWidget {
  FrequentContacts({Key? key}) : super(key: key);

  @override
  _FrequentContactsState createState() => _FrequentContactsState();
}

class _FrequentContactsState extends State<FrequentContacts> {
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
  @override
  Widget build(BuildContext context) {
    // 宽高须一致：.w / .h 缩放不同会导致 ClipOval 成椭圆，头像易被左右裁切感
    final double avatarSize = 65.r;

    return SizedBox(
      width: double.infinity,
      height: 110.h,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: frequentContacts.length + 1,
        itemBuilder: (context, index) {
          // 设置状态按钮
          if (index == frequentContacts.length) {
            return Padding(
              padding: EdgeInsets.symmetric(horizontal: 10.w),
              child: GestureDetector(
                onTap: () {
                  // 跳转设置页面
                  print('跳转设置页面');
                },
                child: Column(
                  spacing: 4.h,
                  children: [
                    // 头像
                    Container(
                      width: avatarSize,
                      height: avatarSize,
                      decoration: BoxDecoration(
                        color: Color.fromRGBO(243, 243, 244, 1),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Icon(
                          FontAwesomeIcons.gear,
                          size: 24.sp,
                          color: Color.fromRGBO(196, 196, 197, 1),
                        ),
                      ),
                    ),
                    // 名字
                    Text(
                      '状态设置',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.black,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
          // 设置联系人列表项
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 10.w),
            child: GestureDetector(
              onTap: () {
                // 跳转联系人页面
                print('跳转联系人页面');
              },
              child: Column(
                spacing: 4.h,
                children: [
                  // 头像
                  ClipOval(
                    child: SizedBox(
                      width: avatarSize,
                      height: avatarSize,
                      child: Image.network(
                        frequentContacts[index].avatar,
                        fit: BoxFit.cover,
                        alignment: Alignment.center,
                      ),
                    ),
                  ),
                  // 名字
                  Text(
                    frequentContacts[index].name,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.black,
                      fontWeight: FontWeight.w500,
                    ),
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
