import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SelectSheetSkeleton extends StatefulWidget {
  final bool
  immediatelyClose; // 两种模式：一种是自身状态改变后立即关闭弹窗(true)，另一种是等待用户操作后关闭弹窗(false)
  final String label;
  final String value;
  final ValueChanged<String>? onChanged; // 在immediatelyClose为true时，onChanged为空
  final Color? backgroundColor;
  final Color? closeIconColor;
  final List<Map<String, String>> items;

  SelectSheetSkeleton({
    Key? key,
    required this.label,
    this.immediatelyClose = true,
    required this.value,
    this.onChanged,
    this.backgroundColor,
    this.closeIconColor,
    required this.items,
  }) : super(key: key);

  @override
  State<SelectSheetSkeleton> createState() => _SelectSheetSkeletonState();
}

class _SelectSheetSkeletonState extends State<SelectSheetSkeleton> {
  String value = '';
  @override
  void initState() {
    super.initState();
    value = widget.value;
  }

  Widget _buildItem({
    required Map<String, String> item,
     bool isNeedUnderline = true,
  }) {
    return GestureDetector(
      onTap: () {
        if (widget.immediatelyClose) {
          setState(() {
            value = item['value'] ?? '';
            Navigator.pop(context);
          });
        } else {
          setState(() {
            value = item['value'] ?? '';
            widget.onChanged?.call(item['value'] ?? '');
          });
        }
      },
      child: Container(
        alignment: Alignment.center,
        padding: EdgeInsets.symmetric(horizontal: 12.w),
        height: 68.h,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.r),
          // 底部边框
          border: Border(
            bottom: isNeedUnderline
                ? BorderSide(color: Colors.grey.withOpacity(0.2), width: 1.w)
                : BorderSide.none,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              spacing: item['subTitle'] != '' ? 4.h : 0,
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['title'] ?? '',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                item['subTitle'] != ''
                    ? Text(
                        item['subTitle'] ?? '',
                        style: TextStyle(fontSize: 12.sp, color: Colors.grey),
                      )
                    : SizedBox.shrink(),
              ],
            ),
            SizedBox(
              width: 24.sp,
              height: 24.sp,
              child: value == item['value']
                  ? Icon(
                      Icons.check,
                      size: 24.sp,
                      color: const Color.fromRGBO(212, 93, 130, 1),
                    )
                  : const SizedBox(),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.all(Radius.circular(16.r)),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 24.h),
        color: widget.backgroundColor ?? Color.fromRGBO(243, 243, 245, 1),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              widget.label,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
              textAlign: TextAlign.left,
            ),
            SizedBox(height: 8.h),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ...List.generate(widget.items.length, (index) {
                    if (index == widget.items.length - 1) {
                      return _buildItem(
                        item: widget.items[index],
                        isNeedUnderline: false,
                      );
                    }
                    return _buildItem(
                      item: widget.items[index],
                    );
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
