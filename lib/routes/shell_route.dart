import 'package:bilbili_project/layout/shell_page.dart';
import 'package:bilbili_project/pages/Login/index.dart';
import 'package:bilbili_project/pages/Login/sub/OtherPhoneLogin/index.dart';
import 'package:bilbili_project/pages/Login/sub/OtherPhoneLogin/params/params.dart';
import 'package:bilbili_project/pages/Login/sub/OtherPhoneLogin/sub/ChoosePhonePrefix/index.dart';
import 'package:bilbili_project/pages/Login/sub/OtherPhoneLogin/sub/FillCode/index.dart';
import 'package:bilbili_project/routes/create_route.dart';
import 'package:bilbili_project/routes/friend_route.dart';
import 'package:bilbili_project/routes/message_route.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'home_route.dart';
import 'mine_route.dart';

part 'shell_route.g.dart';


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
class LoginRoute extends GoRouteData  {
  const LoginRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return LoginPage();
  }
}

class OtherPhoneLoginRoute extends GoRouteData {
  const OtherPhoneLoginRoute();
  @override
  Widget build(BuildContext context, GoRouterState state) {
    final extra =
        state.extra as OtherPhoneLoginParams? ??
        const OtherPhoneLoginParams(
          code: '+86',
          short: 'CN',
          name: '中国',
          en: 'China',
          groupEn: 'C',
          groupCn: 'Z',
        );
    return OtherPhoneLoginPage(extra: extra);
  }
}

class FillCodeRoute extends GoRouteData {
  const FillCodeRoute();
  @override
  Widget build(BuildContext context, GoRouterState state) {
    return FillCodePage();
  }
}

class ChoosePhonePrefixRoute extends GoRouteData {
  const ChoosePhonePrefixRoute();
  @override
  Widget build(BuildContext context, GoRouterState state) {
    return ChoosePhonePrefixPage();
  }
}


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
