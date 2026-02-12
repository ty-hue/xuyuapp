import 'package:bilbili_project/components/default_dialog_skeleton.dart';
import 'package:bilbili_project/components/static_app_bar.dart';
import 'package:bilbili_project/components/with_statusBar_color.dart';
import 'package:bilbili_project/pages/Settings/comps/group_item.dart';
import 'package:bilbili_project/pages/Settings/comps/group_title.dart';
import 'package:bilbili_project/routes/app_router.dart';
import 'package:bilbili_project/routes/settings_routes/about_route.dart';
import 'package:bilbili_project/routes/settings_routes/account_safe_route.dart';
import 'package:bilbili_project/routes/settings_routes/cache_route.dart';
import 'package:bilbili_project/routes/settings_routes/declaration_route.dart';
import 'package:bilbili_project/routes/settings_routes/general_route.dart';
import 'package:bilbili_project/routes/settings_routes/notice_route.dart';
import 'package:bilbili_project/routes/settings_routes/permission_description_route.dart';
import 'package:bilbili_project/routes/settings_routes/permission_route.dart';
import 'package:bilbili_project/routes/settings_routes/privacy_policy_route.dart';
import 'package:bilbili_project/routes/settings_routes/privacy_route.dart';
import 'package:bilbili_project/routes/settings_routes/switch_account_route.dart';
import 'package:bilbili_project/routes/settings_routes/theme_route.dart';
import 'package:bilbili_project/routes/settings_routes/user_agreement_route.dart';
import 'package:bilbili_project/utils/DialogUtils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SettingsPage extends StatefulWidget {
  SettingsPage({Key? key}) : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsState();
}

class _SettingsState extends State<SettingsPage> {
  // 打开退出登录dialog
  void _showLogoutDialog() {
    DialogUtils(
      DefaultDialgSkeleton(
        onRightBtnTap: () {
          // 退出登录
        },
        leftTextStyle: TextStyle(
          color: Color.fromRGBO(93, 141, 206, 1),
          fontWeight: FontWeight.bold,
          fontSize: 15.sp,
        ),
        rightTextStyle: TextStyle(
          color: Color.fromRGBO(93, 141, 206, 1),
          fontSize: 15.sp,
        ),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 20.h),
          width: 200.w,
          alignment: Alignment.center,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                '退出?',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 15.sp,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              Text(
                '@llg',
                style: TextStyle(color: Colors.black, fontSize: 15.sp),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    ).showCustomDialog(context);
  }

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
                          cb: () {
                            GeneralRoute().push(context);
                          },
                        ),
                        _buildGroupItem(
                          itemName: '通知设置',
                          icon: Icons.notifications,
                          cb: () {
                            NoticeRoute().push(context);
                          },
                        ),
                        _buildGroupItem(
                          itemName: '背景设置',
                          icon: Icons.wallpaper,
                          cb: () {
                            ThemeRoute().push(context);
                          },
                        ),
                        _buildGroupItem(
                          itemName: '清理缓存',
                          icon: Icons.cleaning_services,
                          cb: () {
                            CacheRoute().push(context);
                          },
                        ),
                        _buildGroupItem(
                          itemName: '系统权限',
                          icon: Icons.system_update_alt,
                          needUnderline: false,
                          cb: () {
                            PermissionRoute().push(context);
                          },
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
                          cb: () {
                            AboutRoute().push(context);
                          },
                        ),
                        _buildGroupItem(
                          itemName: '用户协议',
                          icon: Icons.description,
                          cb: () {
                            UserAgreementRoute().push(context);
                          },
                        ),
                        _buildGroupItem(
                          itemName: '隐私政策及简明版',
                          icon: Icons.privacy_tip,
                          cb: () {
                            PrivacyPolicyRoute().push(context);
                          },
                        ),
                        _buildGroupItem(
                          itemName: '应用权限',
                          icon: Icons.perm_identity,
                          cb: () {
                            PermissionDescriptionRoute().push(context);
                          },
                        ),
                        _buildGroupItem(
                          itemName: '开源软件声明',
                          icon: Icons.code,
                          cb: () {
                            DeclarationRoute().push(context);
                          },
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
                          cb: () {
                            SwitchAccountRoute().push(context);
                          },
                        ),
                        _buildGroupItem(
                          itemName: '退出登录',
                          icon: Icons.exit_to_app,
                          needUnderline: false,
                          needTrailingIcon: false,
                          cb: () => _showLogoutDialog(),
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
