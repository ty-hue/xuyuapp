import 'package:bilbili_project/components/appBar_back_icon_btn.dart';
import 'package:bilbili_project/components/static_app_bar.dart';
import 'package:bilbili_project/components/with_statusBar_color.dart';
import 'package:bilbili_project/routes/app_router.dart';
import 'package:bilbili_project/utils/SaveImageUtils.dart';
import 'package:bilbili_project/utils/ToastUtils.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:photo_view/photo_view.dart';

class PreviewPage extends StatefulWidget {
  final String mode; // 0 代表 预览头像 1 代表 预览背景图片
  final String imageUrl;
  final String tag;
  PreviewPage({
    Key? key,
    required this.mode,
    required this.imageUrl,
    required this.tag,
  }) : super(key: key);

  @override
  State<PreviewPage> createState() => _PreviewPageState();
}

class _PreviewPageState extends State<PreviewPage> {
  @override
  Widget build(BuildContext context) {
    return WithStatusbarColorView(
      statusBarColor: Colors.black,
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: StaticAppBar(
          statusBarHeight: MediaQuery.of(context).padding.top,
          backgroundColor: Colors.black,
          leadingChild: BackIconBtn(icon: Icons.close, size: 24),
        ),
        body: Container(
          padding: EdgeInsets.symmetric(vertical: 20.h),
          child: Stack(
            children: [
              Align(
                alignment: Alignment.topCenter,
                child: AspectRatio(
                  aspectRatio: 1,
                  child: Hero(
                    tag: widget.tag,
                    child: PhotoView(
                      imageProvider: NetworkImage(widget.imageUrl),
                    ),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10.r),
                    child: Container(
                      height: 102.h,
                      alignment: Alignment.center,
                      padding: EdgeInsets.symmetric(horizontal: 20.w),
                      color: Color.fromRGBO(38, 38, 38, 1),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          GestureDetector(
                            behavior: HitTestBehavior.translucent,
                            onTap: () {
                              widget.mode == '0'
                                  ? AllPhotoRoute().push(context)
                                  : context.push(
                                      AllPhotoRoute().location,
                                      extra: EditorConfig(
                                        maxScale: 8.0,
                                        cropRectPadding: const EdgeInsets.all(
                                          0,
                                        ),
                                        hitTestSize: 20,

                                        // 🔽 裁剪形状（你可以切换）
                                        cropAspectRatio: 2.0, // 长方形
                                        initCropRectType:
                                            InitCropRectType.imageRect,
                                        // CropRectType.rect,
                                        cornerColor: Colors.white,
                                        lineColor: Colors.white,
                                      ),
                                    );
                            },
                            child: SizedBox(
                              height: 50.h,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    spacing: 10.w,
                                    children: [
                                      Icon(
                                        Icons.edit,
                                        color: Colors.white,
                                        size: 20.sp,
                                      ),
                                      Text(
                                        widget.mode == '0' ? '更换头像' : '更换背景',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 16.sp,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Icon(
                                    Icons.arrow_forward_ios,
                                    color: Color.fromRGBO(143, 143, 143, 1),
                                    size: 18.sp,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Divider(
                            height: 1.h,
                            color: Color.fromRGBO(143, 143, 143, 1),
                          ),
                          GestureDetector(
                            behavior: HitTestBehavior.translucent,
                            onTap: () async {
                              try {
                                await saveImageUtils.saveNetworkImage(
                                  widget.imageUrl,
                                );
                                ToastUtils.showToast(context, msg: '保存图片成功');
                              } catch (e) {
                                ToastUtils.showToast(context, msg: '保存图片失败');
                              }
                            },
                            child: SizedBox(
                              height: 50.h,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    spacing: 10.w,
                                    children: [
                                      // 下载图标
                                      Icon(
                                        Icons.download,
                                        color: Colors.white,
                                        size: 20.sp,
                                      ),
                                      Text(
                                        widget.mode == '0' ? '保存头像' : '保存背景图片',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 16.sp,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Icon(
                                    Icons.arrow_forward_ios,
                                    color: Color.fromRGBO(143, 143, 143, 1),
                                    size: 18.sp,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
