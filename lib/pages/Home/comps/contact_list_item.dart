import 'package:bilbili_project/viewmodels/Message/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ContactListItem extends StatefulWidget {
  final ContactItem contactItem;
  final Widget leading;
  final Widget trailing;
  final BoxDecoration? decoration;
  final EdgeInsetsGeometry? padding;
  final TextStyle? textStyle;
  ContactListItem({
    Key? key,
    required this.contactItem,
    required this.leading,
    required this.trailing,
    this.decoration,
    this.padding,
    this.textStyle,
  }) : super(key: key);

  @override
  _ContactListItemState createState() => _ContactListItemState();
}

class _ContactListItemState extends State<ContactListItem> {
  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: 12.w,
      children: [
        widget.leading,
        Expanded(
          child: Container(
            padding: widget.padding ?? EdgeInsets.symmetric(vertical: 16.h),
            decoration: widget.decoration ?? BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  width: 1,
                  color: Colors.grey.withValues(alpha: 0.2),
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(child: Text(
                  widget.contactItem.name,
                  style: widget.textStyle ?? TextStyle(
                    fontSize: 16.sp,
                    color: Color.fromRGBO(22, 24, 35, 1),
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),),
                SizedBox(width: 24.w),
                widget.trailing,
              ],
            ),
          ),
        ),
      ],
    );
  }
}
