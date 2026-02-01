import 'package:bilbili_project/pages/Settings/sub/Theme/index.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';


class ThemeRoute extends GoRouteData {
  const ThemeRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return  ThemePage();
  }
}
