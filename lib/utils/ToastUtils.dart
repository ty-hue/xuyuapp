import 'package:flutter/material.dart';

class ToastUtils {
  static OverlayEntry? _entry;
  static bool _isShowing = false;

  static void showToast(
    BuildContext context, {
    String msg = '刷新成功',
    Duration duration = const Duration(seconds: 2),
  }) {
    if (_isShowing) return;
    _isShowing = true;

    _entry = OverlayEntry(
      builder: (_) => _ToastWidget(msg: msg),
    );

    Overlay.of(context).insert(_entry!);

    Future.delayed(duration, () {
      _entry?.remove();
      _entry = null;
      _isShowing = false;
    });
  }
}

class _ToastWidget extends StatelessWidget {
  final String msg;

  const _ToastWidget({required this.msg});

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: IgnorePointer(
        child: Center(
          child: Material(
            color: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 12,
              ),
              decoration: BoxDecoration(
                color: Color.fromRGBO(57,59,68, 1),
                borderRadius: BorderRadius.circular(40),
              ),
              child: Text(
                msg,
                style: const TextStyle(color: Colors.white),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

