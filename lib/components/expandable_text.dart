import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ExpandableText extends StatefulWidget {
  final String text;
  final TextStyle? style;

  const ExpandableText({Key? key, required this.text, this.style}) : super(key: key);

  @override
  State<ExpandableText> createState() => _ExpandableTextState();
}

class _ExpandableTextState extends State<ExpandableText> {
  bool expanded = false;

  @override
  Widget build(BuildContext context) {
    final textStyle = widget.style ?? TextStyle(fontSize: 14.sp, color: Colors.white, fontWeight: FontWeight.w500,);

    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxWidth;

        if (expanded) {
          return GestureDetector(
            onTap: () => setState(() => expanded = false),
            child: Text(widget.text, style: textStyle,),
          );
        }

        final textPainter = TextPainter(
          text: TextSpan(text: widget.text, style: textStyle),
          maxLines: 1,
          textDirection: TextDirection.ltr,
        )..layout(maxWidth: maxWidth);

        // 如果没超出
        if (!textPainter.didExceedMaxLines) {
          return Text(widget.text);
        }

        // 计算可显示的截断文本
        int endIndex = widget.text.length;
        String truncated = widget.text;

        while (endIndex > 0) {
          truncated = widget.text.substring(0, endIndex) + "...展开";

          final tp = TextPainter(
            text: TextSpan(text: truncated, style: textStyle),
            maxLines: 1,
            textDirection: TextDirection.ltr,
          )..layout(maxWidth: maxWidth);

          if (!tp.didExceedMaxLines) break;
          endIndex--;
        }

        return GestureDetector(
          onTap: () => setState(() => expanded = true),
          child: RichText(
            text: TextSpan(
              style: textStyle,
              children: [
                TextSpan(text: widget.text.substring(0, endIndex)),
                TextSpan(text: "..."),
                TextSpan(
                  text: "展开",
                  style: textStyle,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}