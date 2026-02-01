import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class WithSwitchListItem extends StatefulWidget {
  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;
  final double? height;
  final Color? backgroundColor;
  final EdgeInsetsGeometry? padding;
  final TextStyle? titleStyle;
  final bool isNeedUnderline;
  final String? subTitle;
  WithSwitchListItem({
    Key? key,
    required this.title,
    required this.value,
    required this.onChanged,
    this.height,
    this.backgroundColor,
    this.padding,
    this.titleStyle,
    this.isNeedUnderline = true,
    this.subTitle,
  }) : super(key: key);

  @override
  State<WithSwitchListItem> createState() => _WithSwitchListItemState();
}

class _WithSwitchListItemState extends State<WithSwitchListItem> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.height ?? 54.h,
      alignment: Alignment.center,
      padding: widget.padding ?? EdgeInsets.symmetric(horizontal: 12.w),
      decoration: BoxDecoration(
        color: widget.backgroundColor ?? Color.fromRGBO(29, 31, 43, 1),
        border: widget.isNeedUnderline
            ? Border(
                bottom: BorderSide(
                  color: Color.fromRGBO(44, 47, 62, 1),
                  width: 1.w,
                ),
              )
            : null,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.title,
                style: widget.titleStyle ?? TextStyle(color: Colors.white),
              ),
              Switch(
                value: widget.value,
                onChanged: (value) {
                  setState(() {
                    widget.onChanged(value);
                  });
                },
              ),
            ],
          ),
          widget.subTitle != null
              ? Text(widget.subTitle!, style: TextStyle(color: Color.fromRGBO(90,93,102, 1),fontSize: 13.sp,),textAlign: TextAlign.left,)
              : SizedBox.shrink(),
        ],
      ),
    );
  }
}
