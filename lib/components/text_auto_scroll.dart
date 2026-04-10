import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:text_scroll/text_scroll.dart';

class TextAutoScroll extends StatefulWidget {
  final bool isActive;
  final TextStyle style;
  final TextStyle activeTextStyle;
  final String text;

  TextAutoScroll({
    Key? key,
    required this.isActive,
    required this.text,
    TextStyle? style,
    TextStyle? activeTextStyle,
  })  : style = style ??
            TextStyle(
              fontSize: 12.sp,
              height: 1.35,
              color: const Color.fromRGBO(255, 255, 255, 0.5),
            ),
        activeTextStyle = activeTextStyle ??
            TextStyle(
              fontSize: 12.sp,
              height: 1.35,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
        super(key: key);

  @override
  _TextAutoScrollState createState() => _TextAutoScrollState();
}

class _TextAutoScrollState extends State<TextAutoScroll> {
  @override
  Widget build(BuildContext context) {
    final resolved = widget.isActive ? widget.activeTextStyle : widget.style;
    return TextScroll(
      widget.text,
      velocity: widget.isActive
          ? const Velocity(pixelsPerSecond: Offset(50, 0))
          : const Velocity(pixelsPerSecond: Offset(0, 0)),
      style: resolved,
      textAlign: TextAlign.center,
      mode: TextScrollMode.endless,
    );
  }
}
