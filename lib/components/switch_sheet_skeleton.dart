import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class SwitchSheetSkeleton extends StatefulWidget {
  final bool
  immediatelyClose; // 两种模式：一种是自身状态改变后立即关闭弹窗(true)，另一种是等待用户操作后关闭弹窗(false)
  final String title;
  final String subTitle;
  final String label;
  final bool value;
  final ValueChanged<bool>? onChanged; // 在immediatelyClose为true时，onChanged为空
  final Color? backgroundColor;
  final bool isNeedCloseIcon;
  final Color? closeIconColor;
  final String? avatarUrl;
  SwitchSheetSkeleton({
    Key? key,
    required this.title,
    required this.subTitle,
    required this.label,
    this.immediatelyClose = true,
    required this.value,
    this.onChanged,
    this.backgroundColor,
    this.isNeedCloseIcon = true,
    this.closeIconColor,
    this.avatarUrl,
  }) : super(key: key);

  @override
  State<SwitchSheetSkeleton> createState() => _SwitchSheetSkeletonState();
}

class _SwitchSheetSkeletonState extends State<SwitchSheetSkeleton> {
  bool value = false;
  @override
  void initState() {
    super.initState();
    value = widget.value;
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.all(Radius.circular(16.r)),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        color: widget.backgroundColor ?? Color.fromRGBO(243, 243, 245, 1),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                widget.isNeedCloseIcon
                    ? IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: Icon(Icons.close, color: Colors.black),
                      )
                    : SizedBox.shrink(),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Column(
                  children: [
                    widget.avatarUrl != null
                        ? ClipOval(
                            child: Image.network(
                              widget.avatarUrl!,
                              fit: BoxFit.cover,
                              width: 80.w,
                              height: 80.h,
                            ),
                          )
                        : Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          padding: EdgeInsets.all(20.w),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(shape: BoxShape.circle),
                          child: Icon(FontAwesomeIcons.userGroup, size: 50.r, color: widget.closeIconColor ?? Color.fromRGBO(111,111,119, 1)),
                        ),
                        !value
                            ? Positioned(
                                bottom: 0,
                                right: -18.w,
                                child: Container(
                                  width: 40.w,
                                  height: 40.h,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Color.fromRGBO(254, 44, 85, 1),
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 4.w,
                                    ),
                                  ),
                                  // 我需要 运算符减 的 图标
                                  child: Icon(
                                    FontAwesomeIcons.minus,
                                    size: 24.r,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              )
                            : SizedBox.shrink(),
                      ],
                    ),
                      
                    SizedBox(height: 20.h),
                    Text(
                      widget.title,
                      style: TextStyle(
                        fontSize: 18.sp,
                        color: Colors.black,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 20.h),
                    SizedBox(
                      width: MediaQuery.of(context).size.width - 40.w,
                      child: Text(
                        widget.subTitle,
                        style: TextStyle(fontSize: 14.sp, color: Colors.grey),
                        textAlign: TextAlign.center,
                        softWrap: true,
                      ),
                    ),
                    SizedBox(height: 20.h),
                    Container(
                      width: MediaQuery.of(context).size.width - 40.w,
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 4.h,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10.r),
                        color: Colors.white,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            widget.label,
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: Colors.black,
                            ),
                          ),
                          Switch(
                            value: value,
                            onChanged: (newValue) {
                              // 切换开关状态
                              setState(() {
                                // 更新自身状态
                                value = newValue;
                                // 通知外部更新状态
                                if (!widget.immediatelyClose) {
                                  widget.onChanged?.call(value);
                                } else {
                                  Navigator.pop(context, value);
                                }
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
