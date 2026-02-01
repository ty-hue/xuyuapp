import 'package:bilbili_project/pages/Settings/sub/PrivacyPolicy/index.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';


class PrivacyPolicyRoute extends GoRouteData {
  const PrivacyPolicyRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return  PrivacyPolicyPage();
  }
}
