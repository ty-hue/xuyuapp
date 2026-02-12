import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SelectDots extends StatefulWidget {
  int selectedIndex;
  double width;
  double height;
  List<String> labels;
  ValueChanged<int> onChanged;
  SelectDots({
    Key? key,
    required this.width,
    required this.height,
    required this.labels,
    required this.selectedIndex,
    required this.onChanged,
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
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20.r),
      child: Stack(
        children: [
          Container(
            width: widget.width,
            height: widget.height,
            decoration: BoxDecoration(color: Color.fromRGBO(70, 70, 72, 1)),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ...List.generate(
                  widget.labels.length,
                  (index) => Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedIndex = index;
                          widget.onChanged(index);
                        });
                      },
                      child: Container(
                        alignment: Alignment.center,
                        child: Text(
                          widget.labels[index],
                          style: TextStyle(
                            color: selectedIndex == index
                                ? Colors.white
                                : Color.fromRGBO(157, 157, 159, 1),
                            fontSize: 14.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          AnimatedPositioned(
            duration: const Duration(milliseconds: 250), // 动画时长
            curve: Curves.easeInOut, // 动画曲线（很关键）
            left: selectedIndex * (widget.width / widget.labels.length),
            top: 0,
            child: Container(
              width: widget.width / widget.labels.length,
              height: widget.height,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.3),
                borderRadius: BorderRadius.circular(20.r),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
