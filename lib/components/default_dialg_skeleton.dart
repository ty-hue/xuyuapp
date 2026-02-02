import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class DefaultDialgSkeleton extends StatefulWidget {
  final bool isSingleBtn;
  final Widget child;
  final String? rightBtnText;
  final String? leftBtnText;
  final VoidCallback? onRightBtnTap;
  final VoidCallback? onLeftBtnTap;
  final double? width;
  final TextStyle? rightTextStyle;
  final TextStyle? leftTextStyle;

  DefaultDialgSkeleton({
    Key? key,
    required this.child,
    this.rightBtnText,
    this.leftBtnText,
    this.onRightBtnTap,
    this.onLeftBtnTap,
    this.width,
    this.isSingleBtn = false,
    this.leftTextStyle,
    this.rightTextStyle,
  }) : super(key: key);

  @override
  _DefaultDialgSkeletonState createState() => _DefaultDialgSkeletonState();
}

class _DefaultDialgSkeletonState extends State<DefaultDialgSkeleton> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width ?? 200.w,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          widget.child,
          Container(
            width: double.infinity,
            height: 50.h,
            decoration: BoxDecoration(
              // 上边框
              border: Border(
                top: BorderSide(
                  color: Colors.grey.withOpacity(0.3),
                  width: 1.w,
                ),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                !widget.isSingleBtn
                    ? Expanded(
                        child: TextButton(
                          // 矩形按钮 无圆角
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.zero,
                            ),
                          ),
                          onPressed:
                              widget.onLeftBtnTap ??
                              () => Navigator.pop(context),
                          child: Text(
                            widget.leftBtnText ?? "取消",
                            style: widget.leftTextStyle ?? TextStyle(
                              color: Colors.black,
                              fontSize: 15.sp,
                            ),
                          ),
                        ),
                      )
                    : Container(),
                !widget.isSingleBtn
                    ? Container(
                        width: 1.w,
                        height: 30.h,
                        color: Colors.grey.withOpacity(0.3),
                      )
                    : Container(),
                Expanded(
                  child: TextButton(
                    // 矩形按钮 无圆角
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.zero,
                      ),
                    ),
                    onPressed:
                        widget.onRightBtnTap ??
                        () {
                          // 确定
                          Navigator.pop(context);
                        },
                    child: Text(
                      widget.rightBtnText ?? "确定",
                      style: widget.rightTextStyle ?? TextStyle(
                        color: Colors.black,
                        fontSize: 15.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
