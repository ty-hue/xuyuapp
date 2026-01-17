import 'package:bilbili_project/layout/shell_page.dart';
import 'package:bilbili_project/pages/AllPhoto/index.dart';
import 'package:bilbili_project/pages/Login/index.dart';
import 'package:bilbili_project/pages/Mine/sub/EditProfile/index.dart';
import 'package:bilbili_project/pages/Mine/sub/Search/index.dart';
import 'package:bilbili_project/pages/Mine/sub/Visitor/index.dart';
import 'package:bilbili_project/pages/Settings/index.dart';
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
import 'package:extended_image/extended_image.dart';
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

// 设置页 路由
@TypedGoRoute<SettingsPageRoute>(
  path: '/settings',
)
class SettingsPageRoute extends GoRouteData {
  const SettingsPageRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return SettingsPage();
  }
}

// 个人搜索页 路由
@TypedGoRoute<SearchPageRoute>(
  path: '/search_myself',
)
class SearchPageRoute extends GoRouteData {
  const SearchPageRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return SearchPage();
  }
}

// 主页访问 路由
@TypedGoRoute<VisitorPageRoute>(
  path: '/visitor',
)
class VisitorPageRoute extends GoRouteData {
  const VisitorPageRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return VisitorPage();
  }
}
// 所有照片路由
@TypedGoRoute<AllPhotoRoute>(path: '/all_photo')
class AllPhotoRoute extends GoRouteData {
  const AllPhotoRoute();

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) {
    final editorConfig =
        state.extra as EditorConfig? ??
        EditorConfig(
          maxScale: 8.0,
          cropRectPadding: const EdgeInsets.all(0),
          hitTestSize: 20,

          // 🔽 裁剪形状（你可以切换）
          cropAspectRatio: 1.0, // 正方形
          initCropRectType: InitCropRectType.imageRect,
          // CropRectType.rect,
          cornerColor: Colors.white,
          lineColor: Colors.white,
        );
    return CustomTransitionPage(
      key: state.pageKey,
      child: AllPhotoPage(editorConfig: editorConfig),

      transitionDuration: const Duration(milliseconds: 300),

      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final tween = Tween(
          begin: const Offset(0, 1), // 👈 从底部
          end: Offset.zero,
        ).chain(CurveTween(curve: Curves.easeOut));

        return SlideTransition(position: animation.drive(tween), child: child);
      },
    );
  }
}

// 这两个路由本身是在mine路由下的子路由，但是由于它们不能显示底部导航栏，所以把它们提示为顶级路由
@TypedGoRoute<EditProfileRoute>(
  path: '/mine/edit_profile',
  routes: [
    // 修改普通文本类型字段
    TypedGoRoute<UpdateUserInfoFieldRoute>(path: 'update_user_info_field'),
    // 选择地址
    TypedGoRoute<SelectCountryRoute>(
      path: 'select_country',
      routes: [
        TypedGoRoute<SelectProvinceRoute>(
          path: 'select_province',
          routes: [TypedGoRoute<SelectCityRoute>(path: 'select_city')],
        ),
      ],
    ),
  ],
)
class EditProfileRoute extends GoRouteData {
  final bool? dontSettingAddress;
  const EditProfileRoute({this.dontSettingAddress});

  @override
  Widget build(BuildContext context, GoRouterState state) {
    final address = state.extra as AddressResult?;
    return EditProfilePage(
      address: address,
      dontSettingAddress: dontSettingAddress,
    );
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
