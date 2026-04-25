import 'package:bilbili_project/pages/Create/sub/NetworkSingleImagePreview/index.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// 创作流单图网络预览；[imageUrl] 通过 `push(..., extra: String)` 传入。
class NetworkSingleImagePreviewRoute extends GoRouteData {
  const NetworkSingleImagePreviewRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    final extra = state.extra;
    final imageUrl = extra is String ? extra : '';
    return NetworkSingleImagePreviewPage(imageUrl: imageUrl);
  }
}
