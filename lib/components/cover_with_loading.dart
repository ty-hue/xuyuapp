import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CoverWithLoading extends StatefulWidget {
  final bool isLoading;
  final double borderRadius;
  final Color activeBorderColor;
  final double borderWidth;
  final Color borderColor;
  final String imagePath;
  final bool isActive;
  CoverWithLoading({
    Key? key,
    required this.isLoading,
    required this.isActive,
    this.borderRadius = 8.0,
    this.activeBorderColor = Colors.white,
    this.borderWidth = 2.0,
    this.borderColor = Colors.transparent,
    required this.imagePath,
  }) : super(key: key);

  @override
  _CoverWithLoadingState createState() => _CoverWithLoadingState();
}

class _CoverWithLoadingState extends State<CoverWithLoading> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(widget.borderRadius.r),
        border: Border.all(
          color: widget.isActive
              ? widget.activeBorderColor
              : widget.borderColor,
          width: widget.borderWidth.w,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(widget.borderRadius.r),
        child: Stack(
          children: [
            AnimatedScale(
              scale: widget.isLoading && widget.isActive ? 1.2 : 1.0,
              duration: Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              child: Image.asset(widget.imagePath, fit: BoxFit.cover),
            ),
            widget.isActive && widget.isLoading
                ? Positioned.fill(
                    child: Container(
                      color: Colors.transparent,
                      child: CircularProgressIndicator(
                        padding: EdgeInsets.all(10.0.w),
                        value: null,
                        color: Colors.white,
                        strokeWidth: 2.0.w,
                      ),
                    ),
                  )
                : SizedBox.shrink(),
          ],
        ),
      ),
    );
  }
}
