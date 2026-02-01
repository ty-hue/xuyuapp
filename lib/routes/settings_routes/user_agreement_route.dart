import 'package:bilbili_project/pages/Settings/sub/UserAgreement/index.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';


class UserAgreementRoute extends GoRouteData {
  const UserAgreementRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return  UserAgreementPage();
  }
}
