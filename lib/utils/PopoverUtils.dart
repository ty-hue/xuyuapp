import 'package:flutter/material.dart';
import 'package:popover/popover.dart';

/// 供调用方在自定义方向、过渡等时使用（避免再单独依赖 `package:popover/popover.dart`）。
export 'package:popover/popover.dart' show PopoverDirection, PopoverTransition;

/// 项目内统一 Popover 入口。
///
/// **[context] 必须是锚点控件上的 [BuildContext]**（例如用 [Builder] 包住按钮后取到的 context）。
/// 不要使用 [State] 在 [build] 里顶层的 context，否则锚区会变成整页，弹层可能画到屏幕外。
class PopoverUtils {
  PopoverUtils._();

  static Future<T?> show<T extends Object?>({
    required BuildContext context,
    required WidgetBuilder bodyBuilder,
    PopoverDirection direction = PopoverDirection.bottom,
    PopoverTransition transition = PopoverTransition.scale,
    Color backgroundColor = Colors.white,
    Color barrierColor = Colors.transparent,
    Duration transitionDuration = const Duration(milliseconds: 200),
    double radius = 8,
    List<BoxShadow> shadow = const [
      BoxShadow(color: Color(0x1F000000), blurRadius: 5),
    ],
    double arrowWidth = 24,
    double arrowHeight = 12,
    double arrowDxOffset = 0,
    double arrowDyOffset = 0,
    double contentDyOffset = 0,
    double contentDxOffset = 0,
    bool barrierDismissible = true,
    double? width,
    double? height,
    VoidCallback? onPop,
    BoxConstraints? constraints,
    RouteSettings? routeSettings,
    String? barrierLabel,
    Widget Function(Animation<double> animation, Widget child)?
        popoverTransitionBuilder,
    Key? key,
    bool allowClicksOnBackground = false,
  }) {
    return showPopover<T>(
      context: context,
      bodyBuilder: bodyBuilder,
      direction: direction,
      transition: transition,
      backgroundColor: backgroundColor,
      barrierColor: barrierColor,
      transitionDuration: transitionDuration,
      radius: radius,
      shadow: shadow,
      arrowWidth: arrowWidth,
      arrowHeight: arrowHeight,
      arrowDxOffset: arrowDxOffset,
      arrowDyOffset: arrowDyOffset,
      contentDyOffset: contentDyOffset,
      contentDxOffset: contentDxOffset,
      barrierDismissible: barrierDismissible,
      width: width,
      height: height,
      onPop: onPop,
      constraints: constraints,
      routeSettings: routeSettings,
      barrierLabel: barrierLabel,
      popoverTransitionBuilder: popoverTransitionBuilder,
      key: key,
      allowClicksOnBackground: allowClicksOnBackground,
    );
  }
}
