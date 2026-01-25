import 'package:bilbili_project/pages/Report/sub/repot_last.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:photo_manager/photo_manager.dart';

class ReportLastRoute extends GoRouteData {
  final String firstReportTypeCode;
  final String secondReportTypeCode;
  
  ReportLastRoute({required this.firstReportTypeCode, required this.secondReportTypeCode});
  @override
  Widget build(BuildContext context, GoRouterState state) {
    final selectedImages = state.extra as List<AssetEntity>? ?? [];
    return ReportLastPage(
      firstReportTypeCode: firstReportTypeCode,
      secondReportTypeCode: secondReportTypeCode,
      selectedImages: selectedImages,
    );
  }
}