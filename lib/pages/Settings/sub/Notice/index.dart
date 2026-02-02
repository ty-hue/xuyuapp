import 'package:bilbili_project/components/select_sheet_skeleton.dart';
import 'package:bilbili_project/components/static_app_bar.dart';
import 'package:bilbili_project/components/with_statusBar_color.dart';
import 'package:bilbili_project/pages/Settings/comps/group_item.dart';
import 'package:bilbili_project/pages/Settings/comps/group_title.dart';
import 'package:bilbili_project/pages/Settings/sub/General/comps/watch_history_action.dart';
import 'package:bilbili_project/pages/Settings/sub/Notice/comps/privacy_msg_action.dart';
import 'package:bilbili_project/routes/app_router.dart';
import 'package:bilbili_project/routes/settings_routes/action_page_route.dart';
import 'package:bilbili_project/utils/SheetUtils.dart';
import 'package:bilbili_project/viewmodels/Settings/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class NoticePage extends StatefulWidget {
  NoticePage({Key? key}) : super(key: key);

  @override
  State<NoticePage> createState() => _NoticeState();
}

class _NoticeState extends State<NoticePage> {
  bool isHotspot = false;
  bool isTopNotice = false;
  bool isFriendNotice = false;
  bool isCareNotice = false;
  String _workNoticeValue = '0';
  String _likeNoticeValue = '0';
  String _commentNoticeValue = '0';
  String _careNoticeValue = '0';
  void _careNoticeOnChanged(String value) {
    print('careNoticeValue: $value');
    setState(() {
      _careNoticeValue = value;
    });
  }

  void _commentNoticeOnChanged(String value) {
    print('commentNoticeValue: $value');
    setState(() {
      _commentNoticeValue = value;
    });
  }

  void _likeNoticeOnChanged(String value) {
    print('likeNoticeValue: $value');
    setState(() {
      _likeNoticeValue = value;
    });
  }

  void _workNoticeOnChanged(String value) {
    print('workNoticeValue: $value');
    setState(() {
      _workNoticeValue = value;
    });
  }

  final List<Map<String, String>> _options = [
    {'value': '0', 'title': '全部', 'subTitle': ''},
    {'value': '1', 'title': '来自关注', 'subTitle': ''},
    {'value': '2', 'title': '来自朋友', 'subTitle': ''},
    {'value': '3', 'title': '都不接收', 'subTitle': ''},
  ];
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
      statusBarColor: Color.fromRGBO(22, 24, 36, 1),
      child: Scaffold(
        appBar: StaticAppBar(
          title: '通知设置',
          titleFontWeight: FontWeight.bold,
          backgroundColor: Color.fromRGBO(22, 24, 36, 1),
          statusBarHeight: MediaQuery.of(context).padding.top,
        ),
        body: Container(
          color: Color.fromRGBO(22, 24, 36, 1),
          height: double.infinity,
          child: SingleChildScrollView(
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.only(
                left: 16.w,
                right: 16.w,
                top: 16.h,
                bottom: 60.h,
              ),
              color: Color.fromRGBO(22, 24, 36, 1),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Column(
                    spacing: 8.h,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      GroupTitleView(title: '互动通知'),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          GroupItemView(
                            icon: Icons.view_list,
                            backgroundColor: Color.fromRGBO(29, 31, 43, 1),
                            isFirst: true,
                            itemName: '点赞',
                            attachedWidget: Text(
                              '都不接收',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 13.sp,
                              ),
                            ),
                            cb: () {
                              _openSelectSheet(
                                label: '点赞',
                                value: _likeNoticeValue,
                                onChanged: _likeNoticeOnChanged,
                                items: _options,
                              );
                            },
                          ),

                          GroupItemView(
                            icon: Icons.view_list,
                            backgroundColor: Color.fromRGBO(29, 31, 43, 1),
                            itemName: '评论',
                            attachedWidget: Text(
                              '都不接收',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 13.sp,
                              ),
                            ),
                            cb: () {
                              _openSelectSheet(
                                label: '评论',
                                value: _commentNoticeValue,
                                onChanged: _commentNoticeOnChanged,
                                items: _options,
                              );
                            },
                          ),
                          GroupItemView(
                            icon: Icons.view_list,
                            backgroundColor: Color.fromRGBO(29, 31, 43, 1),
                            itemName: '关注',
                            needUnderline: false,
                            attachedWidget: Text(
                              '都不接收',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 13.sp,
                              ),
                            ),
                            cb: () {
                              _openSelectSheet(
                                label: '关注',
                                value: _careNoticeValue,
                                onChanged: _careNoticeOnChanged,
                                items: _options,
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 20.h),
                  Column(
                    spacing: 8.h,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      GroupTitleView(title: '消息通知'),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          GroupItemView(
                            isFirst: true,
                            backgroundColor: Color.fromRGBO(29, 31, 43, 1),
                            needUnderline: false,
                            itemName: '私信通知',
                            icon: Icons.history,
                            cb: () {
                              context.push(
                                ActionPageRoute().location,
                                extra: ActionPageParams(
                                  title: '私信通知',
                                  child: PrivacyMsgAction(),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 20.h),
                  Column(
                    spacing: 8.h,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      GroupTitleView(title: '热点通知'),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          GroupItemView(
                            needTrailingIcon: false,
                            isFirst: true,
                            backgroundColor: Color.fromRGBO(29, 31, 43, 1),
                            needUnderline: false,
                            attachedWidget: SizedBox(
                              width: 50.w,
                              child: Switch(
                                value: isHotspot,
                                onChanged: (value) {
                                  setState(() {
                                    isHotspot = value;
                                  });
                                },
                              ),
                            ),
                            itemName: '热点',
                            icon: Icons.history,
                            cb: () {
                              context.push(
                                ActionPageRoute().location,
                                extra: ActionPageParams(
                                  title: '观看历史',
                                  child: WatchHistoryAction(),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 20.h),
                  Column(
                    spacing: 8.h,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      GroupTitleView(title: '内容更新提醒'),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          GroupItemView(
                            isFirst: true,
                            backgroundColor: Color.fromRGBO(29, 31, 43, 1),
                            needUnderline: false,
                            attachedWidget: Text(
                              '都不接收',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 13.sp,
                              ),
                            ),
                            itemName: '作品更新通知',
                            icon: Icons.history,
                            cb: () async {
                              await _openSelectSheet(
                                label: '作品更新通知',
                                value: _workNoticeValue,
                                onChanged: _workNoticeOnChanged,
                                items: _options,
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 20.h),
                  Column(
                    spacing: 8.h,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      GroupTitleView(title: '絮语应用内提醒'),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          GroupItemView(
                            needTrailingIcon: false,
                            attachedWidget: SizedBox(
                              width: 50.w,
                              child: Switch(
                                value: isTopNotice,
                                onChanged: (value) {
                                  setState(() {
                                    isTopNotice = value;
                                  });
                                },
                              ),
                            ),
                            isFirst: true,
                            backgroundColor: Color.fromRGBO(29, 31, 43, 1),
                            itemName: '顶部横幅通知',
                            icon: Icons.history,
                            cb: () {},
                          ),
                          GroupItemView(
                            needTrailingIcon: false,
                            attachedWidget: SizedBox(
                              width: 50.w,
                              child: Switch(
                                value: isFriendNotice,
                                onChanged: (value) {
                                  setState(() {
                                    isFriendNotice = value;
                                  });
                                },
                              ),
                            ),
                            backgroundColor: Color.fromRGBO(29, 31, 43, 1),
                            itemName: '朋友页红点',
                            icon: Icons.history,
                            cb: () {},
                          ),
                          GroupItemView(
                            needTrailingIcon: false,
                            attachedWidget: SizedBox(
                              width: 50.w,
                              child: Switch(
                                value: isCareNotice,
                                onChanged: (value) {
                                  setState(() {
                                    isCareNotice = value;
                                  });
                                },
                              ),
                            ),
                            backgroundColor: Color.fromRGBO(29, 31, 43, 1),
                            needUnderline: false,
                            itemName: '关注页红点',
                            icon: Icons.history,
                            cb: () {},
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
