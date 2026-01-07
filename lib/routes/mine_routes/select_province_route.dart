import 'package:bilbili_project/pages/Mine/sub/EditProfile/sub/SelectCountry/sub/SelectProvince/index.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';


class SelectProvinceRoute extends GoRouteData {
  final String countryCode;
  const SelectProvinceRoute({required this.countryCode});

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return  SelectProvince(countryCode: countryCode);
  }
}


