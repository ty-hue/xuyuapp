import 'package:bilbili_project/components/with_statusBar_color.dart';
import 'package:bilbili_project/utils/SaveImageUtils.dart';
import 'package:bilbili_project/utils/ToastUtils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:photo_view/photo_view.dart';

/// 单张网络图全屏预览：左上角关闭、底部保存。
class NetworkSingleImagePreviewPage extends StatefulWidget {
  const NetworkSingleImagePreviewPage({
    super.key,
    required this.imageUrl,
  });

  final String imageUrl;

  @override
  State<NetworkSingleImagePreviewPage> createState() =>
      _NetworkSingleImagePreviewPageState();
}

class _NetworkSingleImagePreviewPageState
    extends State<NetworkSingleImagePreviewPage> {
  bool _saving = false;

  Future<void> _onSave() async {
    if (widget.imageUrl.isEmpty || _saving) return;
    setState(() => _saving = true);
    try {
      await saveImageUtils.saveNetworkImage(widget.imageUrl);
      if (!mounted) return;
      ToastUtils.showToast(context, msg: '已保存到相册');
    } catch (_) {
      if (!mounted) return;
      ToastUtils.showToast(context, msg: '保存失败，请检查网络与相册权限');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final url = widget.imageUrl;
    final pad = MediaQuery.paddingOf(context);
    return WithStatusbarColorView(
      statusBarColor: Colors.black,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          fit: StackFit.expand,
          clipBehavior: Clip.none,
          children: [
            if (url.isEmpty)
              Center(
                child: Text(
                  '无效图片地址',
                  style: TextStyle(color: Colors.white54, fontSize: 15.sp),
                ),
              )
            else
              PhotoView(
                imageProvider: NetworkImage(url),
                minScale: PhotoViewComputedScale.contained,
                maxScale: PhotoViewComputedScale.covered * 3.5,
                backgroundDecoration: const BoxDecoration(color: Colors.black),
                loadingBuilder: (context, event) {
                  final v = event?.expectedTotalBytes;
                  final loaded = event?.cumulativeBytesLoaded ?? 0;
                  double? p;
                  if (v != null && v > 0) p = loaded / v;
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 36.w,
                          height: 36.w,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            value: p,
                            color: const Color(0xFF7C7C7C),
                            backgroundColor: const Color(0xFF2A2A2A),
                          ),
                        ),
                        SizedBox(height: 14.h),
                        Text(
                          '加载中…',
                          style: TextStyle(
                            color: Colors.white38,
                            fontSize: 13.sp,
                          ),
                        ),
                      ],
                    ),
                  );
                },
                errorBuilder: (context, err, stack) => Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 32.w),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.broken_image_outlined,
                          size: 48.sp,
                          color: Colors.white24,
                        ),
                        SizedBox(height: 12.h),
                        Text(
                          '图片加载失败',
                          style: TextStyle(
                            color: Colors.white54,
                            fontSize: 14.sp,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            /// 物理左上角（不受 RTL `start` 影响），并避让状态栏 / 刘海。
            Positioned(
              left: pad.left + 10.w,
              top: pad.top + 6.h,
              child: _GlassIconButton(
                onPressed: () => context.pop(),
                icon: Icons.close_rounded,
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(24.w, 0, 24.w, 20.h),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18.r),
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFF3D3D3D),
                          Color(0xFF1A1A1A),
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.45),
                          blurRadius: 24,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(1.2.r),
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16.5.r),
                          color: const Color(0xFF121212),
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: url.isEmpty || _saving ? null : _onSave,
                            borderRadius: BorderRadius.circular(16.5.r),
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                vertical: 16.h,
                                horizontal: 20.w,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  if (_saving)
                                    SizedBox(
                                      width: 22.w,
                                      height: 22.w,
                                      child: const CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Color(0xFFE8E8E8),
                                      ),
                                    )
                                  else
                                    Icon(
                                      Icons.download_rounded,
                                      color: const Color(0xFFF0F0F0),
                                      size: 22.sp,
                                    ),
                                  SizedBox(width: 10.w),
                                  Text(
                                    _saving ? '保存中…' : '保存图片',
                                    style: TextStyle(
                                      color: const Color(0xFFF2F2F2),
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GlassIconButton extends StatelessWidget {
  const _GlassIconButton({
    required this.onPressed,
    required this.icon,
  });

  final VoidCallback onPressed;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        customBorder: const CircleBorder(),
        child: Ink(
          width: 44.r,
          height: 44.r,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withValues(alpha: 0.12),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.18),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.35),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Icon(icon, color: Colors.white, size: 26.sp),
        ),
      ),
    );
  }
}
