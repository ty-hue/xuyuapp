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
  SheetUtils(this.child);
  Future<T?> openAsyncSheet<T>({
    Color? barrierColor,
    required BuildContext context,
  }) async {
    final T? result = await showModalBottomSheet<T>(
      isScrollControlled: true, // 设置为true，让底部弹窗的高度可以自定义
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor:
          barrierColor ?? Theme.of(context).bottomSheetTheme.modalBarrierColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
      ),
      clipBehavior: Clip.antiAlias,
      builder: (BuildContext context) {
        return SafeArea(
          child: Material(
            type: MaterialType.transparency,
            child: _DeferredSheetMount(child: child),
          ),
        );
      },
    );
    return result;
  }
}
