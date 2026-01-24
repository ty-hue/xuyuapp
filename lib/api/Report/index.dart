
import 'package:bilbili_project/constants/index.dart';
import 'package:bilbili_project/utils/DioRequest.dart';
import 'package:bilbili_project/viewmodels/Report/index.dart';

Future<List<ReportTypeItem>> getFirstReportLevels() async {
  final response = await dioRequest.get(HttpConstants.GET_FIRST_REPORT_TYPE_LIST);
  return (response as List<dynamic>).map((e) => ReportTypeItem.fromJson(e as Map<String, dynamic>)).toList();
}

Future<List<ReportTypeItem>> getSecondReportLevelsByFirstCode(Map<String, dynamic> queryParams) async {
  final response = await dioRequest.get(HttpConstants.GET_SECOND_REPORT_TYPE_LIST, queryParameters: queryParams);
  return (response as List<dynamic>).map((e) => ReportTypeItem.fromJson(e as Map<String, dynamic>)).toList();
}