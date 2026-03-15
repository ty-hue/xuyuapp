import 'package:bilbili_project/viewmodels/Create/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class SearchMusicListItem extends StatefulWidget {
  final int selfIndex;
  final int selectIndex;
  final PlayStatus playStatus;
  final Future<void> Function(int index) changeSelectIndex;
  final Future<void> Function(PlayStatus status) changePlayStatus;
  SearchMusicListItem({
    Key? key,
    required this.selectIndex,
    required this.playStatus,
    required this.changeSelectIndex,
    required this.changePlayStatus,
    required this.selfIndex,
  }) : super(key: key);

  @override
  _SearchMusicListItemState createState() => _SearchMusicListItemState();
}

class _SearchMusicListItemState extends State<SearchMusicListItem> {
  // 点击列表项
  void _onTap() async {
    // 通知父组件更新选中索引
    await widget.changeSelectIndex(widget.selfIndex);
    await widget.changePlayStatus(PlayStatus.normal);

    if (widget.playStatus == PlayStatus.pause &&
        widget.selfIndex == widget.selectIndex) {
      await widget.changePlayStatus(PlayStatus.loading);
      // 执行暂停操作
      await Future.delayed(Duration(milliseconds: 1000));
      await widget.changePlayStatus(PlayStatus.normal);
      return;
    }
    await widget.changePlayStatus(PlayStatus.loading);
    // 执行播放音频函数
    await Future.delayed(Duration(milliseconds: 2000));
    // 成功播放后，更新播放状态为暂停
    await widget.changePlayStatus(PlayStatus.pause);
  }

  // 播放图标
  Widget get _playIcon {
    if (widget.selfIndex != widget.selectIndex) {
      return Icon(FontAwesomeIcons.play, size: 24.sp, color: Colors.white);
    } else {
      if (widget.playStatus == PlayStatus.pause) {
        return Icon(FontAwesomeIcons.pause, size: 24.sp, color: Colors.white);
      }
      if (widget.playStatus == PlayStatus.loading) {
        return CircularProgressIndicator(
          strokeWidth: 2.w,
          padding: EdgeInsets.all(24.w),
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        );
      }
      return Icon(FontAwesomeIcons.play, size: 24.sp, color: Colors.white);
    }
  }

  bool get _showActions =>
      widget.playStatus == PlayStatus.pause &&
      widget.selfIndex == widget.selectIndex;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        _onTap();
      },
      child: Stack(
        children: [
          Container(
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
                      width: 74.w,
                      height: 74.h,
                      padding: EdgeInsets.all(3.w),

                      child: Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4.w),
                            child: Image.asset(
                              'lib/assets/avatar.webp',
                              fit: BoxFit.cover,
                            ),
                          ),
                          Positioned.fill(
                            child: Container(child: Center(child: _playIcon)),
                          ),
                        ],
                      ),
                    ),
                    // 音乐信息 和 操作按钮
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 8.h),
                        child: Row(
                          spacing: 20.w,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                spacing: 4.h,
                                children: [
                                  Row(
                                    spacing: 4.w,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          '享受现在的当下享受现在的当下享受现在的当下享受现在的当下',
                                          style: TextStyle(
                                            color: Color.fromRGBO(
                                              50,
                                              49,
                                              54,
                                              1,
                                            ),
                                            fontSize: 18.sp,
                                            letterSpacing: 1.sp,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    spacing: 4.w,
                                    children: [
                                      SizedBox(
                                        width: 100.w,
                                        child: Text(
                                          '享受现在的当下享受现在的当下享受现在的当下享受现在的当下',
                                          style: TextStyle(
                                            color: Color.fromRGBO(
                                              184,
                                              184,
                                              184,
                                              1,
                                            ),
                                            fontSize: 13.sp,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      Text(
                                        '03:20',
                                        style: TextStyle(
                                          color: Color.fromRGBO(
                                            184,
                                            184,
                                            184,
                                            1,
                                          ),
                                          fontSize: 13.sp,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            AnimatedContainer(
                              duration: Duration(milliseconds: 300),
                              width: _showActions ? 170.w : 46.w,
                              child: Container(),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          AnimatedPositioned(
            duration: Duration(milliseconds: 300),
            right: _showActions ? 0 : -80.w,
            top: 0,
            bottom: 0,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              spacing: 22.w,
              children: [
                GestureDetector(
                  onTap: () {
                    if (!_showActions) {
                      _onTap();
                      return;
                    } else {
                      print('点击了裁剪');
                    }
                  },
                  child: AnimatedOpacity(
                    duration: Duration(milliseconds: 300),
                    opacity: _showActions ? 1 : 0,
                    child: Container(
                      width: 24.w,
                      height: 24.h,
                      child: Icon(
                        // 剪刀图标
                        FontAwesomeIcons.scissors,
                        color: Color.fromRGBO(43, 42, 47, 1),
                        size: 20.sp,
                      ),
                    ),
                  ),
                ),

                GestureDetector(
                  onTap: () {
                    print('点击了收藏');
                  },
                  child: Container(
                    width: 24.w,
                    height: 24.h,
                    child: Icon(
                      // 收藏（五角星）
                      FontAwesomeIcons.star,
                      color: Color.fromRGBO(43, 42, 47, 1),
                      size: 24.sp,
                    ),
                  ),
                ),

                Container(
                  width: 78.w,
                  height: 34.h,

                  child: ElevatedButton(
                    onPressed: () {
                      print('点击了使用');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color.fromRGBO(252, 47, 83, 1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                    ),
                    child: Text(
                      '使用',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14.sp,
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
