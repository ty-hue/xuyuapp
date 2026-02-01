import 'package:bilbili_project/pages/Settings/sub/Notice/index.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';


class NoticeRoute extends GoRouteData {
  const NoticeRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return  NoticePage();
  }
}
