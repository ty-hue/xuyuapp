import 'package:bilbili_project/pages/Home/index.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';


class HomeRoute extends GoRouteData {
  const HomeRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return  HomePage();
  }
}


