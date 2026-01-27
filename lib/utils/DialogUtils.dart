import 'package:flutter/material.dart';

class DialogUtils {
  static showCustomDialog(BuildContext context,Widget child) {
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
