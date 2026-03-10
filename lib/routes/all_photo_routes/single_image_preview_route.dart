import 'dart:typed_data';
import 'package:bilbili_project/pages/AllPhoto/sub/single_image_preview.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SingleImagePreviewRoute extends GoRouteData {
  const SingleImagePreviewRoute();
  @override
  Widget build(BuildContext context, GoRouterState state) {
    final imageMap = state.extra as Map<String, Uint8List?>? ?? {};
    return SingleImagePreviewPage(imageMap: imageMap);
  }
}
