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
    final borderW = 2.w;
    return Stack(
      fit: StackFit.expand,
      children: [
        // 底图与圆角裁剪：铺满父级，不受选中描边挤压（描边叠在上方）。
        ClipRRect(
          borderRadius: BorderRadius.circular(thumbRadius),
          clipBehavior: Clip.antiAlias,
          child: ColoredBox(
            color: const Color.fromRGBO(58, 57, 58, 1),
            child: imagePath.isNotEmpty
                ? Image.asset(
                    imagePath,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                    alignment: Alignment.center,
                    errorBuilder: (context, error, stackTrace) =>
                        Center(child: _fallbackIcon()),
                  )
                : Center(child: _fallbackIcon()),
          ),
        ),
        // 选中描边与内容同圆角，叠画在最上层，不改变 Image 布局约束。
        if (isActive)
          Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(thumbRadius),
                  border: Border.all(color: Colors.white, width: borderW),
                ),
              ),
            ),
          ),
        if (isLoading)
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(thumbRadius),
              clipBehavior: Clip.antiAlias,
              child: ColoredBox(
                color: Colors.black26,
                child: Center(
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
