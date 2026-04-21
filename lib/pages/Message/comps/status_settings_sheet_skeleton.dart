import 'package:bilbili_project/pages/Message/comps/select_part_users_sheet_skeleton.dart';
import 'package:bilbili_project/utils/SheetUtils.dart';
import 'package:bilbili_project/viewmodels/Message/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class StatusSettingsSheetSkeleton extends StatefulWidget {
  StatusSettingsSheetSkeleton({Key? key}) : super(key: key);

  @override
  _StatusSettingsSheetSkeletonState createState() =>
      _StatusSettingsSheetSkeletonState();
}

class _StatusSettingsSheetSkeletonState
    extends State<StatusSettingsSheetSkeleton> {
  StatusSettingsItemType selectedType = StatusSettingsItemType.online;

  List<ContactItem> selectedNotToWhoUsers = [];

  List<ContactItem> selectedPartVisibleUsers = [];

  List<StatusSettingsItem> items = [
    StatusSettingsItem(
      title: '开启在线状态',
      icon: Icons.online_prediction,
      isSelected: true,
      type: StatusSettingsItemType.online,
    ),
    StatusSettingsItem(
      title: '不给谁看',
      icon: Icons.person_off,
      isSelected: false,
      type: StatusSettingsItemType.notToWho,
    ),
    StatusSettingsItem(
      title: '部分可见',
      icon: Icons.groups,
      isSelected: false,
      type: StatusSettingsItemType.partVisible,
    ),
    StatusSettingsItem(
      title: '关闭在线状态',
      icon: Icons.wifi_off,
      isSelected: false,
      type: StatusSettingsItemType.closeOnline,
    ),
  ];

  Widget get statusMarkerUI {
    if (selectedType == StatusSettingsItemType.online ||
        selectedType == StatusSettingsItemType.partVisible ||
        selectedType == StatusSettingsItemType.notToWho) {
      return Positioned(
        right: 0,
        bottom: 0,
        child: Container(
          width: 30.r,
          height: 30.r,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Container(
              width: 20.r,
              height: 20.r,
              decoration: BoxDecoration(
                color: Color.fromRGBO(77, 210, 43, 1),
                shape: BoxShape.circle,
              ),
            ),
          ),
        ),
      );
    }
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0.h,
      child: Container(
        alignment: Alignment.center,
        child: Container(
          width: 72.w,
          height: 34.h,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20.r),
          ),
          child: Center(
            child: Container(
              alignment: Alignment.center,
              width: 60.w,
              height: 26.h,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20.r),
                color: Color.fromRGBO(57, 59, 68, 1),
              ),
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 2.h),
              child: Text(
                '隐身',
                style: TextStyle(
                  fontSize: 13.sp,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildItem({
    required StatusSettingsItem item,
    bool isNeedUnderline = true,
    required Function() onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8.r),
        child: Container(
          alignment: Alignment.center,
          padding: EdgeInsets.symmetric(horizontal: 12.w),
          height: 68.h,
          decoration: BoxDecoration(
            // 底部边框
            border: Border(
              bottom: isNeedUnderline
                  ? BorderSide(color: Colors.grey.withOpacity(0.2), width: 1.w)
                  : BorderSide.none,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                spacing: 10.w,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    item.icon,
                    size: 28.sp,
                    color: selectedType == item.type
                        ? Color.fromRGBO(254, 61, 99, 1)
                        : Color.fromRGBO(34, 34, 36, 1),
                  ),
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: item.title,
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            color: selectedType == item.type
                                ? Color.fromRGBO(254, 61, 99, 1)
                                : Color.fromRGBO(24, 24, 25, 1),
                          ),
                        ),
                        if ((item.type == StatusSettingsItemType.partVisible &&
                                selectedPartVisibleUsers.isNotEmpty) ||
                            (item.type == StatusSettingsItemType.notToWho &&
                                selectedNotToWhoUsers.isNotEmpty))
                          TextSpan(
                            text:
                                ' · ${item.type == StatusSettingsItemType.partVisible
                                    ? selectedPartVisibleUsers.length
                                    : item.type == StatusSettingsItemType.notToWho
                                    ? selectedNotToWhoUsers.length
                                    : 0}人',
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                              color: selectedType == item.type
                                  ? Color.fromRGBO(254, 61, 99, 1)
                                  : Color.fromRGBO(24, 24, 25, 1),
                            ),
                          ),
                      ],
                    ),
                  ),
                  if ((item.type == StatusSettingsItemType.partVisible &&
                          selectedPartVisibleUsers.isNotEmpty) ||
                      (item.type == StatusSettingsItemType.notToWho &&
                          selectedNotToWhoUsers.isNotEmpty))
                    GestureDetector(
                      onTap: () => _onItemTap(item, editMode: true),
                      child: Icon(
                        Icons.edit,
                        size: 20.sp,
                        color: item.type == selectedType
                            ? Color.fromRGBO(254, 61, 99, 1)
                            : Color.fromRGBO(24, 24, 25, 1),
                      ),
                    ),
                ],
              ),
              SizedBox(
                width: 24.sp,
                height: 24.sp,
                child: item.type == selectedType
                    ? Icon(
                        Icons.check,
                        size: 24.sp,
                        color: const Color.fromRGBO(212, 93, 130, 1),
                      )
                    : const SizedBox(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<ContactItem> users = [
    ContactItem(
      name: '张三',
      avatar:
          'https://q8.itc.cn/q_70/images03/20250114/d9d8d1106f454c2b83ea395927bfc020.jpeg',
      lastMessage: '你好',
      lastMessageTime: '2025-01-01 12:00:00',
      unreadCount: '1',
    ),
    ContactItem(
      name: '李四',
      avatar:
          'https://q8.itc.cn/q_70/images03/20250114/d9d8d1106f454c2b83ea395927bfc020.jpeg',
      lastMessage: '你好',
      lastMessageTime: '2025-01-01 12:00:00',
      unreadCount: '1',
    ),
    ContactItem(
      name: '王五',
      avatar:
          'https://q8.itc.cn/q_70/images03/20250114/d9d8d1106f454c2b83ea395927bfc020.jpeg',
      lastMessage: '你好',
      lastMessageTime: '2025-01-01 12:00:00',
      unreadCount: '1',
    ),
    ContactItem(
      name: '赵六',
      avatar:
          'https://q8.itc.cn/q_70/images03/20250114/d9d8d1106f454c2b83ea395927bfc020.jpeg',
      lastMessage: '你好',
      lastMessageTime: '2025-01-01 12:00:00',
      unreadCount: '1',
    ),
    ContactItem(
      name: '孙七',
      avatar:
          'https://q8.itc.cn/q_70/images03/20250114/d9d8d1106f454c2b83ea395927bfc020.jpeg',
      lastMessage: '你好',
      lastMessageTime: '2025-01-01 12:00:00',
      unreadCount: '1',
    ),
    ContactItem(
      name: '周八',
      avatar:
          'https://q8.itc.cn/q_70/images03/20250114/d9d8d1106f454c2b83ea395927bfc020.jpeg',
      lastMessage: '你好',
      lastMessageTime: '2025-01-01 12:00:00',
      unreadCount: '1',
    ),
    ContactItem(
      name: '吴九',
      avatar:
          'https://q8.itc.cn/q_70/images03/20250114/d9d8d1106f454c2b83ea395927bfc020.jpeg',
      lastMessage: '你好',
      lastMessageTime: '2025-01-01 12:00:00',
      unreadCount: '1',
    ),
    ContactItem(
      name: '郑十',
      avatar:
          'https://q8.itc.cn/q_70/images03/20250114/d9d8d1106f454c2b83ea395927bfc020.jpeg',
      lastMessage: '你好',
      lastMessageTime: '2025-01-01 12:00:00',
      unreadCount: '1',
    ),
  ];
  // 打开选择部分用户sheet
  Future<List<ContactItem>?> openSelectPartUsersSheet(
    StatusSettingsItemType type,
    List<ContactItem> selectedUsers,
  ) async {
    final result = await SheetUtils(
      SelectPartUsersSheetSkeleton(
        type: type,
        users: users,
        selectedUsers: selectedUsers,
      ),
    ).openAsyncSheet(context: context);
    return result;
  }

  // item onTap
  void _onItemTap(StatusSettingsItem item, {bool editMode = false}) async {
    if (item.type == StatusSettingsItemType.partVisible) {
      if (selectedPartVisibleUsers.isNotEmpty && !editMode) {
        setState(() {
          selectedType = StatusSettingsItemType.partVisible;
        });
        return;
      }
      final result = await openSelectPartUsersSheet(
        StatusSettingsItemType.partVisible,
        selectedPartVisibleUsers,
      );

      if (result != null) {
        setState(() {
          selectedPartVisibleUsers = result;
          if (selectedPartVisibleUsers.isNotEmpty) {
            selectedType = StatusSettingsItemType.partVisible;
          } else {
            selectedType = StatusSettingsItemType.online;
          }
        });
      }
    } else if (item.type == StatusSettingsItemType.notToWho) {
      if (selectedNotToWhoUsers.isNotEmpty && !editMode) {
        setState(() {
          selectedType = StatusSettingsItemType.notToWho;
        });
        return;
      }
      final result = await openSelectPartUsersSheet(
        StatusSettingsItemType.notToWho,
        selectedNotToWhoUsers,
      );
      if (result != null) {
        setState(() {
          selectedNotToWhoUsers = result;
          if (selectedNotToWhoUsers.isNotEmpty) {
            selectedType = StatusSettingsItemType.notToWho;
          } else {
            selectedType = StatusSettingsItemType.online;
          }
        });
      }
    } else {
      setState(() {
        selectedType = item.type;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.all(Radius.circular(16.r)),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.65,
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 24.h),
        color: Color.fromRGBO(243, 243, 244, 1),
        child: Column(
          spacing: 18.h,
          children: [
            // 头像
            Stack(
              clipBehavior: Clip.none,
              children: [
                CircleAvatar(
                  radius: 48.r,
                  backgroundColor: Colors.white,
                  backgroundImage: NetworkImage(
                    'https://q8.itc.cn/q_70/images03/20250114/d9d8d1106f454c2b83ea395927bfc020.jpeg',
                  ),
                ),
                statusMarkerUI,
              ],
            ),
            Text(
              '在线状态',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: Color.fromRGBO(27, 28, 39, 1),
              ),
            ),
            Text(
              '开启后，互相关注的人可以看到对方的在线状态，群聊中会展示在线人数。',
              style: TextStyle(
                fontSize: 14.sp,
                color: Color.fromRGBO(146, 147, 152, 1),
              ),
              textAlign: TextAlign.center,
            ),

            Container(
              padding: EdgeInsets.only(left: 16.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Column(
                children: [
                  ...List.generate(items.length, (index) {
                    if (index == items.length - 1) {
                      return _buildItem(
                        item: items[index],
                        isNeedUnderline: false,
                        onTap: () => _onItemTap(items[index]),
                      );
                    }
                    return _buildItem(
                      item: items[index],
                      onTap: () => _onItemTap(items[index]),
                    );
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
