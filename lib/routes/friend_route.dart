import 'package:bilbili_project/pages/friend/index.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class FriendRoute extends GoRouteData {
  const FriendRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return  FriendPage();
  }
}


