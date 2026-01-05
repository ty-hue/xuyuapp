import 'package:bilbili_project/pages/Create/index.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CreateRoute extends GoRouteData {
  const CreateRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return  CreatePage();
  }
}


