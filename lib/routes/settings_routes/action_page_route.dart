import 'package:bilbili_project/pages/Settings/sub/action_page.dart';
import 'package:bilbili_project/viewmodels/Settings/index.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ActionPageRoute extends GoRouteData {
  const ActionPageRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    final params =
        state.extra as ActionPageParams? ??
        ActionPageParams(title: '', child: Container());
    return ActionPage(title: params.title, child: params.child);
  }
}
