import 'package:bilbili_project/pages/Login/sub/OtherPhoneLogin/index.dart';
import 'package:bilbili_project/pages/Login/sub/OtherPhoneLogin/params/params.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

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