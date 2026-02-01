import 'package:bilbili_project/pages/Settings/sub/About/index.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';


class AboutRoute extends GoRouteData {
  const AboutRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return  AboutPage();
  }
}
