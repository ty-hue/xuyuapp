import 'package:bilbili_project/components/avatar_with_nickname_list.dart';
import 'package:bilbili_project/components/dim_tap_Icon_button.dart';
import 'package:bilbili_project/pages/Home/comps/build_groups_sheet_skeleton.dart';
import 'package:bilbili_project/pages/Home/comps/video_share_expanded_sheet_skeleton.dart';
import 'package:bilbili_project/utils/SheetUtils.dart';
import 'package:bilbili_project/viewmodels/Message/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

/// 分享底部 sheet 占位（屏高 20%）。圆角由 modal [Material.shape] 裁剪。
class VideoShareSheetSkeleton extends StatefulWidget {
  VideoShareSheetSkeleton({Key? key}) : super(key: key);

  @override
  _VideoShareSheetSkeletonState createState() =>
      _VideoShareSheetSkeletonState();
}

class _VideoShareSheetSkeletonState extends State<VideoShareSheetSkeleton> {
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
  Widget _buildShareItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    required Color iconColor,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 10.w),
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          spacing: 4.h,
          children: [
            Container(
              width: 70.r,
              height: 70.r,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
              ),
              child: Center(
                child: Icon(icon, size: 24.sp, color: iconColor),
              ),
            ),
            // 结束按钮文本
            Text(
              title,
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

  // 私信函数
  void _onPrivateMessageTap() {
    SheetUtils(VideoShareExpandedSheetSkeleton()).openAsyncSheet(context: context);
  }

  // 建群分享函数
  void _onGroupShareTap() {
    SheetUtils(BuildGroupsSheetSkeleton()).openAsyncSheet(context: context);
  }

  // 保存到相册函数
  void _onSaveToAlbumTap() {
    print('保存到相册');
  }

  // 举报函数
  void _onReportTap() {
    print('举报');
  }

  // 发送私信函数
  void _onSendPrivateMessageTap() {
    print('发送私信');
  }

  // 选中的联系人索引数组
  List<int> _selectedContactIndexList = [];
  // 添加/删除选中联系人
  void _addOrRemoveSelectedContactIndex(int index) {
    if (_selectedContactIndexList.contains(index)) {
      _selectedContactIndexList.remove(index);
    } else {
      _selectedContactIndexList.add(index);
    }
    setState(() {});
  }

  // 点击联系人项
  void onItemTap(int index) {
    _addOrRemoveSelectedContactIndex(index);
  }

  // 建群并发送函数
  void _onGroupAndSendPrivateMessageTap() {
    print('建群并发送');
  }

  Widget get SendButtonUI {
    if (_selectedContactIndexList.isNotEmpty &&
        _selectedContactIndexList.length > 1) {
      return Row(
        spacing: 16.w,
        crossAxisAlignment: CrossAxisAlignment.stretch,

        children: [
          Expanded(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Color.fromRGBO(254, 45, 85, 1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.r),
                ),
                foregroundColor: Colors.white,
              ),
              onPressed: _onGroupAndSendPrivateMessageTap,
              child: Text(
                '建群并发送',
                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          Expanded(
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Color.fromRGBO(254, 45, 85, 1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.r),
                ),
                foregroundColor: Colors.white,
              ),
              onPressed: _onSendPrivateMessageTap,
              icon: Icon(FontAwesomeIcons.solidPaperPlane, size: 16.sp),
              label: Text(
                '发送',
                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      );
    }
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: Color.fromRGBO(254, 45, 85, 1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.r),
        ),
        foregroundColor: Colors.white,
      ),
      onPressed: _onSendPrivateMessageTap,
      icon: Icon(FontAwesomeIcons.solidPaperPlane, size: 16.sp),
      label: Text(
        '发送',
        style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
      ),
    );
  }

  // sheet底部UI
  Widget get sheetBottomUI {
    if (_selectedContactIndexList.isNotEmpty) {
      return Padding(
        padding: EdgeInsets.only(right: 14.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 分割线
            Divider(height: 1.h, color: Color.fromRGBO(230, 230, 230, 1)),
            // 私信发送文本编辑框
            Container(
              width: double.infinity,
              height: 100.h,
              child: Row(
                spacing: 16.w,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: TextField(
                      expands: true,
                      maxLines: null,
                      minLines: null,
                      textAlignVertical: TextAlignVertical.top,
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.only(
                          left: 16.w,
                          right: 16.w,
                          top: 16.h,
                          bottom: 16.h,
                        ),
                        hintText: '分享此刻的想法',
                        hintStyle: TextStyle(
                          fontSize: 14.sp,
                          color: Color.fromRGBO(170, 170, 170, 1),
                          fontWeight: FontWeight.bold,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16.r),
                          borderSide: BorderSide.none,
                        ),
                        // filled: true,
                        // fillColor: Colors.white,
                      ),
                    ),
                  ),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8.r),
                    child: SizedBox(
                      width: 70.w,
                      height: 70.h,
                      child: Image.network(
                        'https://gips0.baidu.com/it/u=1690853528,2506870245&fm=3028&app=3028&f=JPEG&fmt=auto?w=1024&h=1024',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16.h),
            SizedBox(width: double.infinity, height: 44.h, child: SendButtonUI),
          ],
        ),
      );
    }
    return SizedBox(
      width: double.infinity,
      height: 100.h,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _buildShareItem(
            icon: FontAwesomeIcons.solidPaperPlane,
            title: '私信',
            onTap: _onPrivateMessageTap,
            iconColor: Color.fromRGBO(80, 81, 89, 1),
          ),
          _buildShareItem(
            icon: FontAwesomeIcons.users,
            title: '建群分享',
            onTap: _onGroupShareTap,
            iconColor: Color.fromRGBO(80, 81, 89, 1),
          ),
          _buildShareItem(
            icon: FontAwesomeIcons.download,
            title: '保存到相册',
            onTap: _onSaveToAlbumTap,
            iconColor: Color.fromRGBO(80, 81, 89, 1),
          ),
          _buildShareItem(
            icon: FontAwesomeIcons.triangleExclamation,
            title: '举报',
            onTap: _onReportTap,
            iconColor: Color.fromRGBO(80, 81, 89, 1),
          ),
        ],
      ),
    );
  }
  // 更多按钮点击函数
  void onEndButtonTap() {
    SheetUtils(VideoShareExpandedSheetSkeleton()).openAsyncSheet(context: context);
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16.0.r)),
      child: Container(
        padding: EdgeInsets.only(left: 14.w, top: 14.h, bottom: 14.h),
        color: Color.fromRGBO(242, 243, 244, 1),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '分享给',
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                DimTapIconButton(
                  icon: Icons.close,
                  size: 24.sp,
                  color: Colors.black,
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
            SizedBox(height: 16.h),
            AvatarWithNicknameList(
              endButtonBackgroundColor: Colors.white,
              selectedContactIndexList: _selectedContactIndexList,
              items: frequentContacts,
              onEndButtonTap: onEndButtonTap,
              endButtonText: '更多',
              onItemTap: onItemTap,
              endButtonIcon: Icon(
                // 向右箭头
                FontAwesomeIcons.chevronRight,
                size: 24.sp,
                color: Color.fromRGBO(80, 81, 89, 1),
              ),
            ),
            sheetBottomUI,
          ],
        ),
      ),
    );
  }
}
