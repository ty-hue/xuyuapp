import 'package:bilbili_project/layout/shell_page.dart';
import 'package:bilbili_project/pages/Login/index.dart';
import 'package:bilbili_project/pages/Mine/sub/EditProfile/index.dart';
import 'package:bilbili_project/routes/create_routes/create_route.dart';
import 'package:bilbili_project/routes/friend_routes/friend_route.dart';
import 'package:bilbili_project/routes/login_routes/choose_phone_prefix_route.dart';
import 'package:bilbili_project/routes/login_routes/fill_code_route.dart';
import 'package:bilbili_project/routes/login_routes/other_phone_login_route.dart';
import 'package:bilbili_project/routes/message_routes/message_route.dart';
import 'package:bilbili_project/routes/mine_routes/mine_route.dart';
import 'package:bilbili_project/routes/mine_routes/select_city_route.dart';
import 'package:bilbili_project/routes/mine_routes/select_country_route.dart';
import 'package:bilbili_project/routes/mine_routes/select_province_route.dart';
import 'package:bilbili_project/routes/mine_routes/update_user_info_field_route.dart';
import 'package:bilbili_project/viewmodels/EditProfile/index.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'home_routes/home_route.dart';


part 'app_router.g.dart';
// 登录路由
@TypedGoRoute<LoginRoute>(
  path: '/login',
  routes: [
    // Add sub-routes
    TypedGoRoute<OtherPhoneLoginRoute>(
      path: 'other_phone_login',
      routes: [
        TypedGoRoute<FillCodeRoute>(path: 'fill_code'),
        TypedGoRoute<ChoosePhonePrefixRoute>(path: 'choose_phone_prefix'),
      ],
    ),
  ],
)
class LoginRoute extends GoRouteData {
  const LoginRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return LoginPage();
  }
}

// 这两个路由本身是在mine路由下的子路由，但是由于它们不能显示底部导航栏，所以把它们提示为顶级路由
@TypedGoRoute<EditProfileRoute>(
  path: '/mine/edit_profile',
  routes: [
    // 修改普通文本类型字段
    TypedGoRoute<UpdateUserInfoFieldRoute>(path: 'update_user_info_field'),
    // 选择地址
    TypedGoRoute<SelectCountryRoute>(path: 'select_country', routes: [
      TypedGoRoute<SelectProvinceRoute>(path: 'select_province', routes: [
        TypedGoRoute<SelectCityRoute>(path: 'select_city'),
      ]),
    ]),
  ],
)

class EditProfileRoute extends GoRouteData {
  final bool? dontSettingAddress;
  const EditProfileRoute({this.dontSettingAddress});

  @override
  Widget build(BuildContext context, GoRouterState state) {
    final address = state.extra as AddressResult?;
    return  EditProfilePage(address: address, dontSettingAddress: dontSettingAddress,);
  }
}


// 五个分支
@TypedStatefulShellRoute<ShellRouteData>(
  branches: [
    TypedStatefulShellBranch<HomeBranchData>(
      routes: [TypedGoRoute<HomeRoute>(path: '/')],
    ),
    TypedStatefulShellBranch<FriendBranchData>(
      routes: [TypedGoRoute<FriendRoute>(path: '/friend')],
    ),
    TypedStatefulShellBranch<CreateBranchData>(
      routes: [TypedGoRoute<CreateRoute>(path: '/create')],
    ),
    TypedStatefulShellBranch<MessageBranchData>(
      routes: [TypedGoRoute<MessageRoute>(path: '/message')],
    ),
    TypedStatefulShellBranch<MineBranchData>(
      routes: [TypedGoRoute<MineRoute>(path: '/mine')],
    ),
  ],
)
class ShellRouteData extends StatefulShellRouteData {
  const ShellRouteData();

  @override
  Widget builder(
    BuildContext context,
    GoRouterState state,
    StatefulNavigationShell navigationShell,
  ) {
    return ShellPage(navigationShell: navigationShell);
  }
}

class HomeBranchData extends StatefulShellBranchData {
  const HomeBranchData();
}

class MineBranchData extends StatefulShellBranchData {
  const MineBranchData();
}

class MessageBranchData extends StatefulShellBranchData {
  const MessageBranchData();
}

class FriendBranchData extends StatefulShellBranchData {
  const FriendBranchData();
}

class CreateBranchData extends StatefulShellBranchData {
  const CreateBranchData();
}
