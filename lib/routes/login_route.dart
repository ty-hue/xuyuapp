import 'package:bilbili_project/pages/Login/index.dart';
import 'package:bilbili_project/pages/Login/sub/OtherPhoneLogin/index.dart';
import 'package:bilbili_project/pages/Login/sub/OtherPhoneLogin/params/params.dart';
import 'package:bilbili_project/pages/Login/sub/OtherPhoneLogin/sub/ChoosePhonePrefix/index.dart';
import 'package:bilbili_project/pages/Login/sub/OtherPhoneLogin/sub/FillCode/index.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

part 'login_route.g.dart';

@TypedGoRoute<LoginRoute>(
  path: '/login',
    routes: [ // Add sub-routes
      TypedGoRoute<OtherPhoneLoginRoute>(
        path: 'other_phone_login',
        routes: [
          TypedGoRoute<FillCodeRoute>(
            path: 'fill_code',
          ),
          TypedGoRoute<ChoosePhonePrefixRoute>(
            path: 'choose_phone_prefix',
          ),
        ]
      )
    ]
)
class LoginRoute extends GoRouteData {
  const LoginRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return  LoginPage();
  }
}

class OtherPhoneLoginRoute extends GoRouteData {
  const OtherPhoneLoginRoute();
  @override
  Widget build(BuildContext context, GoRouterState state) {
    final extra = state.extra as OtherPhoneLoginParams? ?? const OtherPhoneLoginParams(
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
    return  FillCodePage();
  }
}

class ChoosePhonePrefixRoute extends GoRouteData {
  const ChoosePhonePrefixRoute();
  @override
  Widget build(BuildContext context, GoRouterState state) {
    return  ChoosePhonePrefixPage();
  }
}