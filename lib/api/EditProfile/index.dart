
import 'package:bilbili_project/constants/index.dart';
import 'package:bilbili_project/utils/DioRequest.dart';
import 'package:bilbili_project/viewmodels/EditProfile/index.dart';

Future<List<AreaGroup>> getCountryList() async {
  final response = await dioRequest.get(HttpConstants.GET_COUNTRY_LIST);
  return (response as List<dynamic>).map((e) => AreaGroup.fromJson(e as Map<String, dynamic>)).toList();
}

Future<List<AreaGroup>> getProvinceList(Map<String, dynamic> queryParams) async {
  final response = await dioRequest.get(HttpConstants.GET_PROVINCE_LIST, queryParameters: queryParams);
  return (response as List<dynamic>).map((e) => AreaGroup.fromJson(e as Map<String, dynamic>)).toList();
}

Future<List<AreaGroup>> getCityList(Map<String, dynamic> queryParams) async {
  final response = await dioRequest.get(HttpConstants.GET_CITY_LIST, queryParameters: queryParams);
  return (response as List<dynamic>).map((e) => AreaGroup.fromJson(e as Map<String, dynamic>)).toList();
}