import 'dart:typed_data';

import 'package:bilbili_project/components/loading.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';

class PhotoPreview extends StatefulWidget {
  final List<AssetEntity> assets; // 图片资源
  PhotoPreview({Key? key, required this.assets}) : super(key: key);

  @override
  _PhotoPreviewState createState() => _PhotoPreviewState();
}

class _PhotoPreviewState extends State<PhotoPreview> {
  final CarouselSliderController? _controller = CarouselSliderController();
  List<AssetEntityImage> images = [];
  List<Uint8List> imageBytes = [];
  int currentIndex = 0;
  bool isPause = false;
  bool isLoading = true; // 新增：标记数据是否加载完成
  List<GlobalKey> itemKeys = [];

  @override
  void initState() {
    super.initState();
    // 初始化GlobalKey（基于assets长度，避免空列表问题）
    itemKeys = List.generate(widget.assets.length, (index) => GlobalKey());
    _loadImageData();
  }

  // 抽离异步加载逻辑，增加加载状态管理
  Future<void> _loadImageData() async {
    try {
      // 初始化图片组件列表
      images = widget.assets.map((asset) => AssetEntityImage(asset)).toList();
      
      // 异步加载图片字节数据
      for (var asset in widget.assets) {
        final byteData = await asset.originBytes;
        if (byteData != null) {
          imageBytes.add(byteData);
        }
      }
    } catch (e) {
      print("图片加载失败: $e");
    } finally {
      // 加载完成后更新状态，标记为非加载中
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  // 修复滚动方法：增加空值判断，避免空指针
  void scrollToItem(int index) {
    // 边界判断：索引超出范围或key的context未创建时直接返回
    if (index < 0 || index >= itemKeys.length) return;
    final context = itemKeys[index].currentContext;
    if (context == null) return;

    Scrollable.ensureVisible(
      context,
      alignment: 0.5,
      duration: const Duration(milliseconds: 300),
      curve: Curves.ease,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 1. 轮播图区域：兼容未加载完成的情况
        Positioned.fill(
          child: isLoading 
              ? const Center(child: FetchLoadingView()) // 加载中占位
              : CarouselSlider(
                  carouselController: _controller,
                  items: images,
                  options: CarouselOptions(
                    height: double.infinity,
                    aspectRatio: 16 / 9,
                    viewportFraction: 1.0,
                    initialPage: 0,
                    enableInfiniteScroll: false,
                    reverse: false,
                    autoPlay: !isPause,
                    autoPlayInterval: const Duration(seconds: 3),
                    autoPlayAnimationDuration: const Duration(milliseconds: 800),
                    autoPlayCurve: Curves.fastOutSlowIn,
                    pauseAutoPlayOnTouch: true,
                    onPageChanged: (index, reason) {
                      setState(() {
                        currentIndex = index;
                      });
                      // 延迟调用滚动，确保UI已构建完成
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        scrollToItem(index);
                      });
                    },
                  ),
                ),
        ),

        // 2. 底部指示器区域：核心修复
        Positioned(
          left: 0,
          right: 0,
          bottom: 20.h,
          child: isLoading 
              ? const SizedBox() // 加载中隐藏指示器
              : SizedBox(
                  height: 60.h,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: widget.assets.length, // 用assets长度而非images（避免异步问题）
                    padding: EdgeInsets.symmetric(horizontal: 10.w), // 增加内边距优化体验
                    itemBuilder: (context, pageIndex) {
                      return GestureDetector(
                        key: itemKeys[pageIndex],
                        onTap: () {
                          _controller?.animateToPage(pageIndex);
                          // 点击时延迟滚动，确保页面切换完成
                          Future.delayed(const Duration(milliseconds: 100), () {
                            scrollToItem(pageIndex);
                          });
                        },
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10.r),
                          child: Container(
                            width: 56.w,
                            height: 56.h,
                            margin: EdgeInsets.symmetric(horizontal: 3.w), // 替换padding为margin，避免选中样式变形
                            decoration: BoxDecoration(
                              border: Border.all( // 用边框替代背景色，更美观且避免透传问题
                                color: currentIndex == pageIndex ? Colors.white : Colors.transparent,
                                width: 2.w,
                              ),
                              borderRadius: BorderRadius.circular(10.r),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8.r), // 适配边框宽度，避免圆角被遮挡
                              child: Stack(
                                children: [
                                  Positioned.fill(
                                    // 核心修复：增加空值判断，避免索引越界
                                    child: imageBytes.length > pageIndex
                                        ? Image.memory(
                                            imageBytes[pageIndex],
                                            fit: BoxFit.cover,
                                          )
                                        : // 图片未加载完成时的占位
                                            Container(color: Colors.grey[200]),
                                  ),
                                  // 播放/暂停按钮：仅在选中项显示
                                  if (currentIndex == pageIndex)
                                    Positioned.fill(
                                      child: Center(
                                        child: GestureDetector(
                                          // 阻止点击穿透到外层的页面切换
                                          onTap: (() {
                                            setState(() {
                                              isPause = !isPause;
                                            });
                                          }),
                                          child: Container(
                                            width: 32.sp,
                                            height: 32.sp,
                                            decoration: BoxDecoration(
                                              color: Colors.black54,
                                              borderRadius: BorderRadius.circular(16.sp),
                                            ),
                                            child: Icon(
                                              isPause ? Icons.play_arrow : Icons.pause,
                                              color: Colors.white,
                                              size: 20.sp,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
        ),
      ],
    );
  }
}