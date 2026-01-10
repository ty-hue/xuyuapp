import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AgePickerSheet extends StatefulWidget {
  final Function(DateTime) onConfirm;

  const AgePickerSheet({required this.onConfirm, Key? key}) : super(key: key);

  @override
  State<AgePickerSheet> createState() => _AgePickerSheetState();
}

class _AgePickerSheetState extends State<AgePickerSheet> {
  int year = 2000;
  int month = 1;
  int day = 1;

  late FixedExtentScrollController yearController;
  late FixedExtentScrollController monthController;
  late FixedExtentScrollController dayController;

  final int startYear = 1945;
  late int currentYear;
  bool _isShowAge = false;
  @override
  void initState() {
    super.initState();

    currentYear = DateTime.now().year;

    yearController = FixedExtentScrollController(
      initialItem: year - startYear, // 2000 对应 index
    );

    monthController = FixedExtentScrollController(initialItem: month - 1);

    dayController = FixedExtentScrollController(initialItem: day - 1);
  }

  @override
  void dispose() {
    yearController.dispose();
    monthController.dispose();
    dayController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final yearCount = currentYear - startYear + 1;

    return Container(
      height: 260.0.h,
      decoration:  BoxDecoration(
        color: Color.fromRGBO(198, 199, 199, 1),
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.0.r)),
      ),
      child: Column(
        children: [
          // 顶部操作栏
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0.w, vertical: 12.0.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Row(
                    children: [
                      Text('不展示', style: TextStyle(color: Colors.black, fontSize: 14.0.sp),),
                      SizedBox(width: 4.0.w),
                      Switch(
                        value: _isShowAge,
                        onChanged: (v) {
                          setState(() {
                            _isShowAge = v;
                          });
                        },
                      ),
                    ],
                  ),
                ),

                GestureDetector(
                  onTap: () {
                    widget.onConfirm(DateTime(year, month, day));
                    Navigator.pop(context);
                  },
                  child: const Text('确定', style: TextStyle(color: Color.fromRGBO(254,49,89, 1))),
                ),
              ],
            ),
          ),

          Divider(height: 1.0.h,),



          Expanded(
            child: IgnorePointer(
              ignoring: !_isShowAge, // 👈 关键
              child: Opacity(
                opacity: _isShowAge ? 1.0 : 0.4, // 可选：禁用态视觉反馈
                child: Row(
                  children: [
                    _buildPicker(
                      controller: yearController,
                      items: List.generate(
                        yearCount,
                        (i) => '${startYear + i}年',
                      ),
                      onSelected: (i) => year = startYear + i,
                    ),
                    _buildPicker(
                      controller: monthController,
                      items: List.generate(12, (i) => '${i + 1}月'),
                      onSelected: (i) => month = i + 1,
                    ),
                    _buildPicker(
                      controller: dayController,
                      items: List.generate(31, (i) => '${i + 1}日'),
                      onSelected: (i) => day = i + 1,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPicker({
    required List<String> items,
    required FixedExtentScrollController controller,
    required Function(int) onSelected,
  }) {
    return Expanded(
      child: CupertinoPicker(
        scrollController: controller,
        itemExtent: 36.0.h,
        onSelectedItemChanged: onSelected,
        children: items
            .map(
              (e) =>
                  Center(child: Text(e, style:  TextStyle(fontSize: 16.0.sp))),
            )
            .toList(),
      ),
    );
  }
}
