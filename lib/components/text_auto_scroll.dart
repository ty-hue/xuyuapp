import 'package:flutter/material.dart';
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
    this.style = const TextStyle(
      fontSize: 12.0,
      color: Color.fromRGBO(255, 255, 255, 0.5),
    ),
    this.activeTextStyle = const TextStyle(
      fontSize: 12.0,
      fontWeight: FontWeight.bold,
      color: Colors.white,
    ),
  }) : super(key: key);

  @override
  _TextAutoScrollState createState() => _TextAutoScrollState();
}

class _TextAutoScrollState extends State<TextAutoScroll> {
  @override
  Widget build(BuildContext context) {
    return TextScroll(
      widget.text,
      velocity: widget.isActive
          ? Velocity(pixelsPerSecond: Offset(50, 0)) // 正常滚动速度
          : Velocity(pixelsPerSecond: Offset(0, 0)), // 停止滚动
      style: widget.isActive
          ? widget.activeTextStyle
          : widget.style, // 可根据需要调整文字大小
      mode: TextScrollMode.endless, // 让滚动是循环的
    );
  }
}
