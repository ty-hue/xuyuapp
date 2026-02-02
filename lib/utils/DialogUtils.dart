import 'package:flutter/material.dart';

class DialogUtils {
  final Widget child;
  DialogUtils(this.child);
   showCustomDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.zero, // 去掉系统默认边距
          child: child,
        );
      },
    );
  }
}
