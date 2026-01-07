import 'package:bilbili_project/pages/Mine/sub/EditProfile/sub/SelectCountry/index.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';


class SelectCountryRoute extends GoRouteData {
  const SelectCountryRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return  SelectCountry();
  }
}


