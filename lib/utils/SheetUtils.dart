import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SheetUtils {
  final Widget child;
  SheetUtils(this.child);
   Future<T?> openAsyncSheet<T>({
    Color? barrierColor,
    required BuildContext context,
  }) async {
    final T? result = await showModalBottomSheet<T>(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: barrierColor ?? Theme.of(context).bottomSheetTheme.modalBarrierColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: child,
        );
      },
    );
    return result;
  }
}


