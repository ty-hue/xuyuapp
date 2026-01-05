import 'package:bilbili_project/pages/Mine/index.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MineRoute extends GoRouteData {
  const MineRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return  MinePage();
  }
}


