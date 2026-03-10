import 'dart:typed_data';

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
  final CarouselSliderController? _controller = CarouselSliderController(); // 轮播图控制器
  List<AssetEntityImage> images = [];
  List<Uint8List> imageBytes = [];
  int currentIndex = 0; // 当前选中的图片索引
  bool isPause = false; // 是否暂停播放
  @override
  initState() {
    super.initState();
    () async {
      images = widget.assets.map((asset) => AssetEntityImage(asset)).toList();

      for (var asset in widget.assets) {
        final byteData = await asset.originBytes;
        if (byteData != null) {
          imageBytes.add(byteData);
        }
      }
    }().then((value) {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: CarouselSlider(
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
              autoPlayInterval: Duration(seconds: 3),
              autoPlayAnimationDuration: Duration(milliseconds: 800),
              autoPlayCurve: Curves.fastOutSlowIn,
              pauseAutoPlayOnTouch: true,
              onPageChanged: (index, reason) {
                print(index);
                setState(() {
                  currentIndex = index;
                });
              },
            ),
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 20.h,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                spacing: 6.w,
                mainAxisSize: MainAxisSize.min,
                children: [
                  ...Iterable<int>.generate(imageBytes.length).map(
                    (int pageIndex) => Flexible(
                      child: GestureDetector(
                        onTap: () {
                          _controller?.animateToPage(pageIndex);
                        },
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10.r),
                          child: Container(
                            width: 56.w,
                            height: 56.h,
                            padding: EdgeInsets.all(2.w),
                            decoration: BoxDecoration(
                              color: currentIndex == pageIndex
                                  ? Colors.white
                                  : Colors.transparent,
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10.r), // 圆角
                              child: Stack(
                                children: [
                                  Positioned.fill(
                                    child: Image.memory(
                                      imageBytes[pageIndex],
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  currentIndex == pageIndex
                                      ? Positioned.fill(
                                          child: Center(
                                            child: GestureDetector(
                                              onTap: () {
                                                setState(() {
                                                  isPause = !isPause;
                                                });
                                              },
                                              child: Icon(
                                                isPause
                                                    ? Icons.play_arrow
                                                    : Icons.pause,
                                                color: Colors.white,
                                                size: 32.sp,
                                              ),
                                            ),
                                          ),
                                        )
                                      : Container(),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
