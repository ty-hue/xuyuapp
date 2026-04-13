import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 首帧只显示轻量占位，下一帧再挂载真实 sheet，让 [showModalBottomSheet] 的滑入动画先执行，
/// 避免首帧同步构建/解码大量子组件拖死主线程（预览卡顿、动画像「闪一下」）。
class _DeferredSheetMount extends StatefulWidget {
  const _DeferredSheetMount({required this.child});
  final Widget child;

  @override
  State<_DeferredSheetMount> createState() => _DeferredSheetMountState();
}

class _DeferredSheetMountState extends State<_DeferredSheetMount> {
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() => _ready = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_ready) {
      final h = MediaQuery.sizeOf(context).height * 0.42;
      return SizedBox(
        width: double.infinity,
        height: h,
        child: ClipRRect(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
          child: const ColoredBox(color: Color.fromRGBO(25, 25, 25, 1)),
        ),
      );
    }
    return widget.child;
  }
}

class SheetUtils {
  final Widget child;
  /// 为 true 时首帧只显示占位，下一帧再挂载 [child]，减轻首帧卡顿（顶层大 sheet 建议开启）。
  /// 在**已打开的 sheet 上再弹第二层**时建议设为 false，避免占位高度与真实内容不一致导致跳动，
  /// 并配合 [openAsyncSheet] 的 `useRootNavigator: true` 减少动画竞争。
  final bool deferHeavyChild;

  SheetUtils(this.child, {this.deferHeavyChild = true});

  Future<T?> openAsyncSheet<T>({
    Color? barrierColor,
    required BuildContext context,
    /// 嵌套 bottom sheet 时设为 true，由根 Navigator 承接路由，动画更稳。
    bool useRootNavigator = false,
  }) async {
    final T? result = await showModalBottomSheet<T>(
      isScrollControlled: true, // 设置为true，让底部弹窗的高度可以自定义
      context: context,
      useRootNavigator: useRootNavigator,
      backgroundColor: Colors.transparent,
      barrierColor:
          barrierColor ?? Theme.of(context).bottomSheetTheme.modalBarrierColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
      ),
      clipBehavior: Clip.antiAlias,
      builder: (BuildContext context) {
        final body = deferHeavyChild
            ? _DeferredSheetMount(child: child)
            : child;
        return SafeArea(
          child: Material(
            type: MaterialType.transparency,
            child: body,
          ),
        );
      },
    );
    return result;
  }
}
