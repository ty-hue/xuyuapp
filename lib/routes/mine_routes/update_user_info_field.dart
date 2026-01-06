import 'package:bilbili_project/pages/Mine/sub/EditProfile/sub/UpdateUserInfoField/index.dart';
import 'package:bilbili_project/pages/Mine/sub/EditProfile/sub/UpdateUserInfoField/params/params.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';


class UpdateUserInfoFieldRoute extends GoRouteData {
  const UpdateUserInfoFieldRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    final extra = state.extra as UpdateUserInfoFieldParams? ?? UpdateUserInfoFieldParams(
      title: '',
      initialValue: '',
      maxLength: 0,
      tip: '',
    );
    return  UpdateUserInfoFieldPage(extra: extra);
  }
}
