import 'package:bilbili_project/pages/ChoosePhonePrefix/index.dart';
import 'package:bilbili_project/pages/Create/index.dart';
import 'package:bilbili_project/pages/EditProfile/index.dart';
import 'package:bilbili_project/pages/FillCode/index.dart';
import 'package:bilbili_project/pages/Login/index.dart';
import 'package:bilbili_project/pages/OtherPhoneLogin/index.dart';
import 'package:bilbili_project/pages/friend/index.dart';
import 'package:bilbili_project/pages/Home/index.dart';
import 'package:bilbili_project/pages/Message/index.dart';
import 'package:bilbili_project/pages/Mine/index.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../layout/ScaffoldWithBottomNavBar.dart';

// 返回路由根组件
Widget getRootWidget() {
  return MaterialApp.router(routerConfig: _routerConfig);
}

//  返回路由配置
final _routerConfig = GoRouter(
  initialLocation: '/',
  routes: <RouteBase>[
    GoRoute(path: '/login', builder: (context, state) => LoginPage()),
    GoRoute(
      path: '/other-phone-login',
      builder: (context, state){
        final country = state.extra ?? {'code': '+86'};
        country as Map<String, String>;
        return OtherPhoneLoginPage(country: country);
      },
    ),
    GoRoute(
      path: '/fill-code',
      builder: (context, state) => FillCodePage(),
    ),
      GoRoute(
      path: '/choose-phone-prefix',
      builder: (context, state) => ChoosePhonePrefixPage(),
    ),
    GoRoute(path: '/edit-profile', builder: (context, state) => EditProfilePage()),
    GoRoute(path: '/create', builder: (context, state) => CreatePage()),
    ShellRoute(
      builder: (context, state, child) =>
          ScaffoldWithBottomNavBar(child: child),
      routes: [
        GoRoute(path: '/', builder: (context, state) => HomePage()),
        GoRoute(path: '/friend', builder: (context, state) => FriendPage()),
        GoRoute(path: '/message', builder: (context, state) => MessagePage()),
        GoRoute(path: '/mine', builder: (context, state) => MinePage()),
      ],
    ),
  ],
);
