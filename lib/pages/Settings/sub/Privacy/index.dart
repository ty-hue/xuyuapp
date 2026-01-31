import 'package:bilbili_project/components/select_sheet_skeleton.dart';
import 'package:bilbili_project/components/static_app_bar.dart';
import 'package:bilbili_project/components/switch_sheet_skeleton.dart';
import 'package:bilbili_project/components/with_statusBar_color.dart';
import 'package:bilbili_project/pages/Settings/comps/group_item.dart';
import 'package:bilbili_project/pages/Settings/comps/group_title.dart';
import 'package:bilbili_project/routes/app_router.dart';
import 'package:bilbili_project/routes/settings_routes/action_page_route.dart';

import 'package:bilbili_project/utils/SheetUtils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class PrivacyPage extends StatefulWidget {
  PrivacyPage({Key? key}) : super(key: key);

  @override
  State<PrivacyPage> createState() => _PrivacyState();
}

class _PrivacyState extends State<PrivacyPage> {
  Widget _buildGroupName(String groupName) {
    return GroupTitleView(title: groupName);
  }

  Widget _buildGroupItem({
    required String itemName,
    IconData icon = Icons.arrow_forward_ios,
    bool needUnderline = true,
    bool needTrailingIcon = true,
    required Function()? cb,
    bool isFirst = false, // 是否为第一个
    bool isNeedIcon = false, // 是否需要图标
    Widget attachedWidget = const SizedBox.shrink(), // 附加文本默认空字符串
  }) {
    return GroupItemView(
      itemName: itemName,
      icon: icon,
      needUnderline: needUnderline,
      needTrailingIcon: needTrailingIcon,
      cb: cb,
      isFirst: isFirst,
      isNeedIcon: isNeedIcon,
      attachedWidget: attachedWidget,
    );
  }

  bool isAllowDontFollowSearch = false;
  // 修改isAllowDontFollowSearch
  Future<void> _setAllowDontFollowSearch(bool value) async {
    // 1. 发送请求
    // 2. 更新状态
    setState(() {
      isAllowDontFollowSearch = value;
    });
  }

  bool isAllowPulicInOtherList = false;
  // 修改_setAllowPulicInOtherList
  Future<void> _setAllowPulicInOtherList(bool value) async {
    setState(() {
      isAllowPulicInOtherList = value;
    });
  }

  // isAllowRecommend
  bool isAllowRecommend = false;
  // 修改isAllowRecommend
  Future<void> _setAllowRecommend(bool value) async {
    setState(() {
      isAllowRecommend = value;
    });
  }

  // isAllowRecommendOtherToMe
  bool isAllowRecommendOtherToMe = false;
  // 修改isAllowRecommendOtherToMe
  Future<void> _setAllowRecommendOtherToMe(bool value) async {
    setState(() {
      isAllowRecommendOtherToMe = value;
    });
  }

  // isAllowVisitor
  bool isAllowVisitor = false;
  // 修改isAllowVisitor
  Future<void> _setAllowVisitor(bool value) async {
    setState(() {
      isAllowVisitor = value;
    });
  }

  // isAllowBrowseRecord
  bool isAllowBrowseRecord = false;
  // 修改isAllowBrowseRecord
  Future<void> _setAllowBrowseRecord(bool value) async {
    setState(() {
      isAllowBrowseRecord = value;
    });
  }

  // 关注和粉丝列表对应的值
  String currentFollowListValue = '0';
  // 初始数据
  final List<Map<String, String>> followListItems = [
    {'title': '公开可见', 'subTitle': '', 'value': '0'},
    {'title': '私密', 'subTitle': '仅自己可见', 'value': '1'},
  ];
  // 修改followListValue
  Future<void> _setFollowListValue(String value) async {
    setState(() {
      currentFollowListValue = value;
    });
  }

  // 关注和粉丝列表对应的值
  String currentWhoCanAddValue = '0';
  // 初始数据
  final List<Map<String, String>> whoCanAddItems = [
    {'title': '所有人', 'subTitle': '', 'value': '0'},
    {'title': '我关注的人', 'subTitle': '', 'value': '1'},
    {'title': '互相关注的人', 'subTitle': '', 'value': '2'},
  ];
  // 修改whoCanAddValue
  Future<void> _setWhoCanAddValue(String value) async {
    setState(() {
      currentWhoCanAddValue = value;
    });
  }

  // 是否设置为私密账号
  bool isPrivateAccount = false;
  // 修改isPrivateAccount
  Future<void> _setPrivateAccount(bool value) async {
    setState(() {
      isPrivateAccount = value;
    });
  }

  Future<void> _openSwitchSheet({
    required String title,
    required String subTitle,
    required String label,
    required bool value,
    ValueChanged<bool>? onChanged,
    bool immediatelyClose = false,
    bool isNeedCloseIcon = false,
    required IconData titleIcon,
  }) async {
    await SheetUtils(
      SwitchSheetSkeleton(
        immediatelyClose: immediatelyClose,
        title: title,
        subTitle: subTitle,
        label: label,
        value: value,
        onChanged: onChanged,
        isNeedCloseIcon: isNeedCloseIcon,
        titleIcon: titleIcon,
      ),
    ).openAsyncSheet<bool>(context: context);
  }

  Future<void> _openSelectSheet({
    required String label,
    required String value,
    ValueChanged<String>? onChanged,
    bool immediatelyClose = false,
    required List<Map<String, String>> items,
  }) async {
    await SheetUtils(
      SelectSheetSkeleton(
        immediatelyClose: immediatelyClose,
        label: label,
        value: value,
        onChanged: onChanged,
        items: items,
      ),
    ).openAsyncSheet<String>(context: context);
  }

  @override
  Widget build(BuildContext context) {
    return WithStatusbarColorView(
      statusBarColor: Color.fromRGBO(11, 11, 11, 1),
      child: Scaffold(
        appBar: StaticAppBar(
          title: '隐私设置',
          titleFontWeight: FontWeight.bold,
          backgroundColor: Color.fromRGBO(11, 11, 11, 1),
          statusBarHeight: MediaQuery.of(context).padding.top,
        ),
        body: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.only(
              left: 16.w,
              right: 16.w,
              top: 16.h,
              bottom: 60.h,
            ),
            color: Color.fromRGBO(11, 11, 11, 1),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildGroupName('找到我的方式'),
                SizedBox(height: 10.h),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8.r),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildGroupItem(
                        isNeedIcon: false,
                        isFirst: true,
                        itemName: '可以被没有关注我的人搜索到',
                        attachedWidget: Text(
                          '关闭',
                          style: TextStyle(color: Colors.grey, fontSize: 13.sp),
                        ),
                        cb: () async {
                          await _openSwitchSheet(
                            title: '可以被没有关注我的人搜索到',
                            subTitle:
                                '关闭后，除了你关注的人和你的粉丝外，陌生人在抖音内无法搜到你的账号、视频直播等。你收到的互动可能变少。',
                            label: '可以被没有关注的人搜索到',
                            value: isAllowDontFollowSearch,
                            onChanged: _setAllowDontFollowSearch,
                            titleIcon: FontAwesomeIcons.userGroup,
                          );
                        },
                      ),
                      _buildGroupItem(
                        itemName: '在他人关注和粉丝列表公开出现',
                        attachedWidget: Text(
                          '开启',
                          style: TextStyle(color: Colors.grey, fontSize: 13.sp),
                        ),
                        isNeedIcon: false,
                        cb: () async {
                          await _openSwitchSheet(
                            title: '在他人关注和粉丝列表公开出现',
                            subTitle: '关闭后，你的账号将不显示在他人的关注和粉丝列表中。',
                            label: '在他人关注和粉丝列表公开出现',
                            value: isAllowPulicInOtherList,
                            onChanged: _setAllowPulicInOtherList,
                            titleIcon: FontAwesomeIcons.userGroup,
                          );
                        },
                      ),
                      _buildGroupItem(
                        itemName: '把我推荐给可能认识的人',
                        attachedWidget: Text(
                          '开启',
                          style: TextStyle(color: Colors.grey, fontSize: 13.sp),
                        ),
                        needUnderline: false,
                        cb: () async {
                          await _openSwitchSheet(
                            title: '把我推荐给可能认识的人',
                            subTitle: '关闭后，他人不能通过作品推荐，可能认识的人找到我',
                            label: '把我推荐给可能认识的人',
                            value: isAllowRecommend,
                            onChanged: _setAllowRecommend,
                            titleIcon: FontAwesomeIcons.userGroup,
                          );
                        },
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20.h),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8.r),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Column(
                      children: [
                        _buildGroupItem(
                          isFirst: true,
                          itemName: '黑名单',
                          attachedWidget: Text(
                            '6人',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 13.sp,
                            ),
                          ),
                          cb: () {
                            ActionPageRoute().push(context);
                          },
                        ),
                        _buildGroupItem(
                          itemName: '私密账号',
                          needUnderline: false,
                          attachedWidget: Text(
                            '关闭',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 13.sp,
                            ),
                          ),
                          cb: () async {
                            await _openSwitchSheet(
                              title: '私密账号',
                              subTitle: '关闭后，你的账号将在抖音内公开出现。',
                              label: '私密账号',
                              value: isPrivateAccount,
                              onChanged: _setPrivateAccount,
                              titleIcon: FontAwesomeIcons.lock,
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 20.h),
                _buildGroupName('关注和朋友权限'),
                SizedBox(height: 10.h),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8.r),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Column(
                      children: [
                        _buildGroupItem(
                          isFirst: true,
                          itemName: '关注和粉丝列表',
                          isNeedIcon: false,
                          attachedWidget: Text(
                            '私密',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 13.sp,
                            ),
                          ),
                          cb: () async {
                            await _openSelectSheet(
                              label: '关注和粉丝列表',
                              value: currentFollowListValue,
                              onChanged: _setFollowListValue,
                              items: followListItems,
                            );
                          },
                        ),
                        _buildGroupItem(
                          itemName: '推荐可能认识的人给我',
                          isNeedIcon: false,
                          attachedWidget: Text(
                            '开启',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 13.sp,
                            ),
                          ),
                          cb: () async {
                            await _openSwitchSheet(
                              title: '推荐可能认识的人给我',
                              subTitle: '关闭后，不再接受通讯录的人，可能认识的人和共同朋友等推荐。',
                              label: '推荐可能认识的人给我',
                              value: isAllowRecommendOtherToMe,
                              onChanged: _setAllowRecommendOtherToMe,
                              titleIcon: FontAwesomeIcons.userGroup,
                            );
                          },
                        ),
                        _buildGroupItem(
                          itemName: '谁能加我为好友',
                          isNeedIcon: false,
                          needUnderline: false,
                          attachedWidget: Text(
                            '所有人',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 13.sp,
                            ),
                          ),
                          cb: () async {
                            await _openSelectSheet(
                              label: '谁能加我为好友',
                              value: currentWhoCanAddValue,
                              onChanged: _setWhoCanAddValue,
                              items: whoCanAddItems,
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 20.h),
                _buildGroupName('关注和朋友权限'),
                SizedBox(height: 10.h),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8.r),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Column(
                      children: [
                        _buildGroupItem(
                          isFirst: true,
                          itemName: '主页访客记录',
                          isNeedIcon: false,
                          attachedWidget: Text(
                            '关闭',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 13.sp,
                            ),
                          ),
                          cb: () async {
                            await _openSwitchSheet(
                              title: '主页访客记录',
                              subTitle: '关闭后，无法查看自己主页的访客记录。查看他人主页时也不会留下记录。',
                              label: '主页访客记录',
                              value: isAllowVisitor,
                              onChanged: _setAllowVisitor,
                              titleIcon: FontAwesomeIcons.userGroup,
                            );
                          },
                        ),
                        _buildGroupItem(
                          itemName: '作品浏览记录',
                          isNeedIcon: false,
                          attachedWidget: Text(
                            '关闭',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 13.sp,
                            ),
                          ),
                          needTrailingIcon: true,
                          cb: () async {
                            await _openSwitchSheet(
                              title: '作品浏览记录',
                              subTitle:
                                  '关闭后，将看不到自己作品的浏览记录。你看他人作品也不会留下浏览记录。日常体载的浏览记录不受本开关影响。',
                              label: '作品浏览记录',
                              value: isAllowBrowseRecord,
                              onChanged: _setAllowBrowseRecord,
                              titleIcon: FontAwesomeIcons.userGroup,
                            );
                          },
                        ),
                        _buildGroupItem(
                          itemName: '私信',
                          isNeedIcon: false,
                          cb: () {},
                        ),
                        _buildGroupItem(
                          itemName: '点赞',
                          isNeedIcon: false,
                          cb: () {},
                        ),
                        _buildGroupItem(
                          itemName: '收藏',
                          isNeedIcon: false,
                          cb: () {},
                        ),
                        _buildGroupItem(
                          itemName: '音乐',
                          isNeedIcon: false,
                          needUnderline: false,
                          cb: () {},
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
