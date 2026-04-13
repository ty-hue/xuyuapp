import 'package:flutter/material.dart';
import 'package:bilbili_project/utils/ToastUtils.dart';

/// 全局轻提示：[show] 走 [ToastUtils] 的 Overlay，不依赖页面是否有 [Scaffold]；
/// [showSnackBar] 走 [scaffoldMessengerKey]（无 context 时使用）。
class AppMessenger {
  AppMessenger._();

  static final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  static ScaffoldMessengerState? get _m => scaffoldMessengerKey.currentState;

  /// 通用提示（与 SnackBar 等效体验）：经 [Overlay] 绘制，适合 `/create` 等无 [Scaffold] 页。
  static void show(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 2),
  }) {
    ToastUtils.showToastReplace(context, msg: message, duration: duration);
  }

  /// 无 [context] 时尝试仅用全局 SnackBar（可能无效）。
  static void showSnackBar(
    String message, {
    Duration duration = const Duration(seconds: 2),
    SnackBarAction? action,
  }) {
    final m = _m;
    if (m == null) return;
    m
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          duration: duration,
          action: action,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        ),
      );
  }
}
