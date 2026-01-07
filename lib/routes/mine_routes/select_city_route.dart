import 'package:bilbili_project/pages/Mine/sub/EditProfile/sub/SelectCountry/sub/SelectProvince/sub/SelectCity/index.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';


class SelectCityRoute extends GoRouteData {
  final String countryCode;
  final String provinceCode;
  const SelectCityRoute({required this.countryCode, required this.provinceCode});

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return  SelectCity(countryCode: countryCode, provinceCode: provinceCode);
  }
}


