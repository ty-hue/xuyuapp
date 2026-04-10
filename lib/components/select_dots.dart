import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SelectDots extends StatefulWidget {
  int selectedIndex;
  double width;
  double height;
  List<String> labels;
  ValueChanged<int> onChanged;
  Color labelColor; // 默认文字颜色
  Color selectedColor; // 选中文字颜色
  Color? selectedBgColor; // 选中点颜色
  Color? bgColor; // 背景颜色
  double? borderRadius; // 圆角
  SelectDots({
    Key? key,
    required this.width,
    required this.height,
    required this.labels,
    required this.selectedIndex,
    required this.onChanged,
     this.labelColor = const Color.fromRGBO(157, 157, 159, 1),
     this.selectedColor = Colors.white,
     this.selectedBgColor,
     this.bgColor,
     this.borderRadius,
  }) : super(key: key);

  @override
  State<SelectDots> createState() => _SelectDotsState();
}

class _SelectDotsState extends State<SelectDots> {
  late int selectedIndex;
  @override
  void initState() {
    super.initState();
    selectedIndex = widget.selectedIndex;
  }

  @override
  void didUpdateWidget(SelectDots oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedIndex != oldWidget.selectedIndex) {
      selectedIndex = widget.selectedIndex;
    }
  }

  @override
  Widget build(BuildContext context) {
    final segW = widget.width / widget.labels.length;
    // 激活项为完整胶囊形（椭圆/stadium）
    final pillR = math.min(segW / 2, widget.height / 2);
    final br = widget.borderRadius ?? 20.r;
    final trackColor = widget.bgColor ?? const Color.fromRGBO(70, 70, 72, 1);
    // 半透明叠在圆角上容易在四角露出底色/黑边；改为与轨道色 alpha 合成后的实色
    final highlightColor = widget.selectedBgColor ??
        Color.alphaBlend(Colors.white.withValues(alpha: 0.3), trackColor);

    return Material(
      color: trackColor,
      borderRadius: BorderRadius.circular(br),
      clipBehavior: Clip.antiAlias,
      child: SizedBox(
        width: widget.width,
        height: widget.height,
        child: Stack(
          fit: StackFit.expand,
          clipBehavior: Clip.hardEdge,
          children: [
            // 先画胶囊背景，再画文字，避免高亮层盖住标签
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
              left: selectedIndex * segW,
              top: 0,
              child: IgnorePointer(
                child: Container(
                  width: segW,
                  height: widget.height,
                  decoration: BoxDecoration(
                    color: highlightColor,
                    borderRadius: BorderRadius.circular(pillR),
                  ),
                ),
              ),
            ),
            Row(
              children: [
                ...List.generate(
                  widget.labels.length,
                  (index) => Expanded(
                    child: GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onTap: () {
                        setState(() {
                          selectedIndex = index;
                          widget.onChanged(index);
                        });
                      },
                      child: Center(
                        child: Text(
                          widget.labels[index],
                          style: TextStyle(
                            color: selectedIndex == index
                                ? widget.selectedColor
                                : widget.labelColor,
                            fontSize: 14.sp,
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.none,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
