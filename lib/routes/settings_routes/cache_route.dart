import 'package:bilbili_project/pages/Settings/sub/Cache/index.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';


class CacheRoute extends GoRouteData {
  const CacheRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return  CachePage();
  }
}
