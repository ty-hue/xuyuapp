import 'package:bilbili_project/pages/Settings/sub/SwitchAccount/index.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';


class SwitchAccountRoute extends GoRouteData {
  const SwitchAccountRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return  SwitchAccountPage();
  }
}
