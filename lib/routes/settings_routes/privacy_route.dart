import 'package:bilbili_project/pages/Settings/sub/Privacy/index.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';


class PrivacyRoute extends GoRouteData {
  const PrivacyRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return  PrivacyPage();
  }
}
