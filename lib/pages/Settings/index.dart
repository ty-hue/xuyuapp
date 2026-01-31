import 'package:bilbili_project/components/static_app_bar.dart';
import 'package:bilbili_project/components/with_statusBar_color.dart';
import 'package:bilbili_project/pages/Settings/comps/group_item.dart';
import 'package:bilbili_project/pages/Settings/comps/group_title.dart';
import 'package:bilbili_project/routes/app_router.dart';
import 'package:bilbili_project/routes/settings_routes/account_safe_route.dart';
import 'package:bilbili_project/routes/settings_routes/privacy_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SettingsPage extends StatefulWidget {
  SettingsPage({Key? key}) : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsState();
}

class _SettingsState extends State<SettingsPage> {
  Widget _buildGroupName(String groupName) {
    return GroupTitleView(title: groupName);
  }

  Widget _buildGroupItem({
    required String itemName,
    required IconData icon,
    bool needUnderline = true,
    bool needTrailingIcon = true,
    required Function()? cb,
    bool isFirst = false, // 是否为第一个
  }) {
    return GroupItemView(
      itemName: itemName,
      icon: icon,
      needUnderline: needUnderline,
      needTrailingIcon: needTrailingIcon,
      cb: cb,
      isFirst: isFirst,
    );
  }

  @override
  Widget build(BuildContext context) {
    return WithStatusbarColorView(
      statusBarColor: Color.fromRGBO(11, 11, 11, 1),
      child: Scaffold(
        appBar: StaticAppBar(
          title: '设置',
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
                _buildGroupName('账号'),
                SizedBox(height: 10.h),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8.r),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildGroupItem(
                        isFirst: true,
                        itemName: '账号与安全',
                        icon: Icons.person,
                        cb: () {
                          AccountSafeRoute().push(context);
                        },
                      ),
                      _buildGroupItem(
                        itemName: '隐私设置',
                        icon: Icons.lock,
                        cb: () {
                          PrivacyRoute().push(context);
                        },
                        needUnderline: false,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20.h),
                _buildGroupName('通用'),
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
                          itemName: '通用设置',
                          icon: Icons.settings,
                          cb: () {},
                        ),
                        _buildGroupItem(
                          itemName: '通知设置',
                          icon: Icons.notifications,
                          cb: () {},
                        ),
                        _buildGroupItem(
                          itemName: '通知消息管理',
                          icon: Icons.notifications_active,
                          cb: () {},
                        ),
                        _buildGroupItem(
                          itemName: '聊天与通话设置',
                          icon: Icons.phone,
                          cb: () {},
                        ),
                        _buildGroupItem(
                          itemName: '播放设置',
                          icon: Icons.play_arrow,
                          cb: () {},
                        ),
                        _buildGroupItem(
                          itemName: '背景设置',
                          icon: Icons.wallpaper,
                          cb: () {},
                        ),
                        _buildGroupItem(
                          itemName: '长辈模式',
                          icon: Icons.people_alt,
                          cb: () {},
                        ),
                        _buildGroupItem(
                          itemName: '字体大小',
                          icon: Icons.text_fields,
                          cb: () {},
                        ),
                        _buildGroupItem(
                          itemName: '清理缓存',
                          icon: Icons.cleaning_services,
                          cb: () {},
                        ),
                        _buildGroupItem(
                          itemName: '系统权限',
                          icon: Icons.system_update_alt,
                          needUnderline: false,
                          cb: () {},
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 20.h),
                _buildGroupName('关于'),
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
                          itemName: '关于絮语',
                          icon: Icons.info,
                          cb: () {},
                        ),
                        _buildGroupItem(
                          itemName: '了解与管理广告推送',
                          icon: Icons.ad_units_sharp,
                          cb: () {},
                        ),
                        _buildGroupItem(
                          itemName: '反馈与帮助',
                          icon: Icons.help,
                          cb: () {},
                        ),
                        _buildGroupItem(
                          itemName: '絮语规则中心',
                          icon: Icons.rule,
                          cb: () {},
                        ),
                        _buildGroupItem(
                          itemName: '资质证照',
                          icon: Icons.verified_user,
                          cb: () {},
                        ),
                        _buildGroupItem(
                          itemName: '用户协议',
                          icon: Icons.description,
                          cb: () {},
                        ),
                        _buildGroupItem(
                          itemName: '隐私政策及简明版',
                          icon: Icons.privacy_tip,
                          cb: () {},
                        ),
                        _buildGroupItem(
                          itemName: '应用权限',
                          icon: Icons.perm_identity,
                          cb: () {},
                        ),
                        _buildGroupItem(
                          itemName: '个人信息收集清单',
                          icon: Icons.info,
                          cb: () {},
                        ),
                        _buildGroupItem(
                          itemName: '第三方信息共享清单',
                          icon: Icons.info,
                          cb: () {},
                        ),

                        _buildGroupItem(
                          itemName: '个人信息管理',
                          icon: Icons.info,
                          cb: () {},
                        ),
                        _buildGroupItem(
                          itemName: '开源软件声明',
                          icon: Icons.code,
                          cb: () {},
                          needUnderline: false,
                        ),
                      ],
                    ),
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
                          itemName: '切换账号',
                          icon: Icons.switch_account,
                          cb: () {},
                        ),
                        _buildGroupItem(
                          itemName: '退出登录',
                          icon: Icons.exit_to_app,
                          needUnderline: false,
                          needTrailingIcon: false,
                          cb: () {},
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 60.h),
                Text(
                  '絮语 version 1.0.0',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
