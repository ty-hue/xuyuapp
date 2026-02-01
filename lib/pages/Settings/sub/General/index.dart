import 'package:bilbili_project/components/static_app_bar.dart';
import 'package:bilbili_project/components/with_statusBar_color.dart';
import 'package:bilbili_project/pages/Settings/comps/group_item.dart';
import 'package:bilbili_project/pages/Settings/comps/group_title.dart';
import 'package:bilbili_project/pages/Settings/sub/General/comps/watch_history_action.dart';
import 'package:bilbili_project/pages/Settings/sub/General/comps/work_show_action.dart';
import 'package:bilbili_project/routes/app_router.dart';
import 'package:bilbili_project/routes/settings_routes/action_page_route.dart';
import 'package:bilbili_project/viewmodels/Settings/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class GeneralPage extends StatefulWidget {
  GeneralPage({Key? key}) : super(key: key);

  @override
  State<GeneralPage> createState() => _GeneralState();
}

class _GeneralState extends State<GeneralPage> {
  bool isSaveImageComment = false;
  @override
  Widget build(BuildContext context) {
    return WithStatusbarColorView(
      statusBarColor: Color.fromRGBO(22, 24, 36, 1),
      child: Scaffold(
        appBar: StaticAppBar(
          title: '通用设置',
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
                      GroupTitleView(title: '作品'),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          GroupItemView(
                            icon: Icons.view_list,
                            backgroundColor: Color.fromRGBO(29, 31, 43, 1),
                            isFirst: true,
                            needUnderline: false,
                            itemName: '作品视图',
                            cb: () {
                              context.push(
                                ActionPageRoute().location,
                                extra: ActionPageParams(
                                  title: '作品视图',
                                  child: WorkShowAction(),
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
                      GroupTitleView(title: '功能'),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          GroupItemView(
                            backgroundColor: Color.fromRGBO(29, 31, 43, 1),
                            isFirst: true,
                            itemName: '观看历史',
                            attachedWidget: Text(
                              '开启',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 13.sp,
                              ),
                            ),
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
                          GroupItemView(
                            needTrailingIcon: false,
                            needUnderline: false,
                            backgroundColor: Color.fromRGBO(29, 31, 43, 1),
                            itemName: '发布的图片评论支持他人保存',
                            icon: Icons.save_alt,
                            attachedWidget: SizedBox(
                              width: 40.w,
                              child: Switch(
                                value: isSaveImageComment,
                                onChanged: (value) {
                                  setState(() {
                                    isSaveImageComment = value;
                                  });
                                },
                              ),
                            ),
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
