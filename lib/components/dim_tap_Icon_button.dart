import 'package:flutter/material.dart';

/// 无圆形/矩形水波纹背景；按下时仅图标变暗，抬起恢复（与默认 [IconButton] 区分）。
class   DimTapIconButton extends StatefulWidget {
  const DimTapIconButton({
    required this.icon,
    required this.size,
    required this.color,
    this.onPressed,
  });

  final IconData icon;
  final double size;
  final Color color;
  final VoidCallback? onPressed;

  @override
  State<DimTapIconButton> createState() => DimTapIconButtonState();
}

class DimTapIconButtonState extends State<DimTapIconButton> {
  bool _pressed = false;

  Color get _iconColor {
    if (widget.onPressed == null) {
      return widget.color.withValues(alpha: 0.38);
    }
    if (!_pressed) return widget.color;
    return widget.color.withValues(alpha: widget.color.a * 0.45);
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      enabled: widget.onPressed != null,
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          minWidth: kMinInteractiveDimension,
          minHeight: kMinInteractiveDimension,
        ),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: widget.onPressed == null
              ? null
              : (_) => setState(() => _pressed = true),
          onTapUp: widget.onPressed == null
              ? null
              : (_) => setState(() => _pressed = false),
          onTapCancel: widget.onPressed == null
              ? null
              : () => setState(() => _pressed = false),
          onTap: widget.onPressed,
          child: Center(
            child: Icon(widget.icon, size: widget.size, color: _iconColor),
          ),
        ),
      ),
    );
  }
}
