import 'package:bilbili_project/pages/Create/comps/audio_visualizer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class MusicListItem extends StatefulWidget {
  final bool isNeedStarIcon;
  MusicListItem({Key? key,  this.isNeedStarIcon = true}) : super(key: key);

  @override
  _MusicListItemState createState() => _MusicListItemState();
}

class _MusicListItemState extends State<MusicListItem> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            spacing: 8.w,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              // 封面图片
              Container(
                width: 52.w,
                height: 52.h,
                padding: EdgeInsets.all(3.w),
                decoration: BoxDecoration(
                  color: Color.fromRGBO(223, 112, 137, 1),
                  borderRadius: BorderRadius.circular(10.w),
                ),
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10.w),
                      child: Image.asset(
                        'lib/assets/avatar.webp',
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(10.w),
                        ),
                        child: Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 2.w,
                            padding: EdgeInsets.all(18.w),
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // 音乐信息 和 操作按钮
              Expanded(
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 8.h),
                  decoration: BoxDecoration(
                    // 底部边框
                    border: Border(
                      bottom: BorderSide(
                        color: Color.fromRGBO(219, 219, 219, 1),
                        width: 1.w,
                      ),
                    ),
                  ),
                  child: Row(
                    spacing: 20.w,
                    children: [
                      Expanded(
                        child: Column(
                          spacing: 4.h,
                          children: [
                            Row(
                              spacing: 4.w,
                              children: [
                                Expanded(
                                  child: Text(
                                    '享受现在的当下享受现在的当下享受现在的当下享受现在的当下',
                                    style: TextStyle(
                                      color: Color.fromRGBO(50, 49, 54, 1),
                                      fontSize: 18.sp,
                                      letterSpacing: 1.sp,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                AudioVisualizer(
                                  numberOfBars: 3,
                                  minHeight: 0.2,
                                  maxHeight: 1.0,
                                  duration: const Duration(milliseconds: 300),
                                ),
                              ],
                            ),
                            Row(
                              spacing: 4.w,
                              children: [
                                SizedBox(
                                  width: 100.w,
                                  child: Text(
                                    '享受现在的当下享受现在的当下享受现在的当下享受现在的当下',
                                    style: TextStyle(
                                      color: Color.fromRGBO(184, 184, 184, 1),
                                      fontSize: 13.sp,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Text(
                                  '·',
                                  style: TextStyle(
                                    color: Color.fromRGBO(184, 184, 184, 1),
                                    fontSize: 13.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  '03:20',
                                  style: TextStyle(
                                    color: Color.fromRGBO(184, 184, 184, 1),
                                    fontSize: 13.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          GestureDetector(
                            onTap: () {
                              print('点击裁剪');
                            },
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 14.w),
                              child: Icon(
                                // 剪刀图标
                                FontAwesomeIcons.scissors,
                                color: Color.fromRGBO(43, 42, 47, 1),
                                size: 20.sp,
                              ),
                            ),
                          ),
                          widget.isNeedStarIcon ? GestureDetector(
                            onTap: () {
                              print('点击了收藏');
                            },
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 14.w),
                              child: Icon(
                                // 收藏（五角星）
                                FontAwesomeIcons.star,
                                color: Color.fromRGBO(43, 42, 47, 1),
                                size: 24.sp,
                              ),
                            ),
                          ) : SizedBox.shrink(),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
