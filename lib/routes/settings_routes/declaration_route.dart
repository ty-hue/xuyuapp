import 'package:bilbili_project/pages/Settings/sub/Declaration/index.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';


class DeclarationRoute extends GoRouteData {
  const DeclarationRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return  DeclarationPage();
  }
}
