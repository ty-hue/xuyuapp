import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

/// 贴纸/特效缩略图：支持 asset 图、空路径时的占位图标、选中描边与加载遮罩。
class CoverWithLoading extends StatelessWidget {
  final bool isLoading;
  final bool isActive;
  final String imagePath;
  /// [imagePath] 为空时用于选择占位图标（如 [StickerItem.name]）。
  final String name;

  const CoverWithLoading({
    super.key,
    required this.isLoading,
    required this.isActive,
    required this.imagePath,
    this.name = '',
  });

  @override
  Widget build(BuildContext context) {
    final thumbRadius = 16.0.r;
    return Stack(
      fit: StackFit.expand,
      children: [
        Container(
          decoration: BoxDecoration(
            color: const Color.fromRGBO(58, 57, 58, 1),
            borderRadius: BorderRadius.circular(thumbRadius),
            border: isActive
                ? Border.all(color: Colors.white, width: 2.w)
                : null,
          ),
          clipBehavior: Clip.antiAlias,
          alignment: Alignment.center,
          child: imagePath.isNotEmpty
              ? Image.asset(
                  imagePath,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => _fallbackIcon(),
                )
              : _fallbackIcon(),
        ),
        if (isLoading)
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black26,
                borderRadius: BorderRadius.circular(thumbRadius),
              ),
              alignment: Alignment.center,
              child: SizedBox(
                width: 24.w,
                height: 24.w,
                child: const CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _fallbackIcon() {
    return name == 'none'
        ? Icon(
            FontAwesomeIcons.ban,
            color: const Color.fromRGBO(143, 141, 142, 1),
            size: 32.0.sp,
          )
        : Icon(
            Icons.view_in_ar,
            color: const Color.fromRGBO(0, 200, 255, 1),
            size: 32.0.sp,
          );
  }
}
