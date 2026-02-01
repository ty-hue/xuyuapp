import 'package:bilbili_project/pages/Settings/sub/General/index.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';


class GeneralRoute extends GoRouteData {
  const GeneralRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return  GeneralPage();
  }
}
