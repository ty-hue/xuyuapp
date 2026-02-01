import 'package:bilbili_project/pages/Settings/sub/Permission/index.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';


class PermissionRoute extends GoRouteData {
  const PermissionRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return  PermissionPage();
  }
}
