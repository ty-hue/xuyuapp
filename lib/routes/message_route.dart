import 'package:bilbili_project/pages/Message/index.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MessageRoute extends GoRouteData {
  const MessageRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return  MessagePage();
  }
}


