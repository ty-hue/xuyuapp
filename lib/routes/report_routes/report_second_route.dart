import 'package:bilbili_project/pages/Report/sub/report_second.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ReportSecondRoute extends GoRouteData {
  final String firstReportTypeCode;
  
  ReportSecondRoute({required this.firstReportTypeCode});
  @override
  Widget build(BuildContext context, GoRouterState state) {
    return ReportSecondPage(
      firstReportTypeCode: firstReportTypeCode,
    );
  }

}