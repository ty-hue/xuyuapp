import 'package:bilbili_project/components/expandable_text.dart';
import 'package:bilbili_project/components/text_auto_scroll.dart';
import 'package:bilbili_project/components/custom_video_player.dart';
import 'package:bilbili_project/utils/NumberUtils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class VideoListItem extends StatefulWidget {
  VideoListItem({Key? key}) : super(key: key);

  @override
  _VideoListItemState createState() => _VideoListItemState();
}

class _VideoListItemState extends State<VideoListItem>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 6), // 一圈耗时
      vsync: this,
    )..repeat(); // 重复无限次
  }

  Widget _buildVideoAttatchInfoItem({
    required IconData icon,
    required String count,
    required Function() onTap,
    required String title,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      spacing: 4.h,
      children: [
        // 爱心
        GestureDetector(
          onTap: () {
            onTap();
          },
          child: Icon(icon, color: Colors.white, size: 39.sp),
        ),
        Text(
          int.parse(count) == 0
              ? title
              : NumberUtils.formatLikeCount(int.parse(count)),
          style: TextStyle(color: Colors.white, fontSize: 15.sp),
        ),
      ],
    );
  }

  // 点击分享
  void _onShareTap() {
    print('点击了分享');
  }

  // 点击点赞
  void _onLikeTap() {
    print('点击了点赞');
  }

  // 点击评论
  void _onCommentTap() {
    print('点击了评论');
  }

  // 点击收藏
  void _onCollectTap() {
    print('点击了收藏');
  }

  @override
  void dispose() {
    // 释放资源
    _controller.dispose();
    super.dispose();
  }

  // 点击唱片
  void _onAlbumTap() {
    print('点击了唱片');
  }

  // 点击关注
  void _onFollowTap() {
    print('点击了关注');
  }

  // 点击头像
  void _onAvatarTap() {
    print('点击了头像');
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 视频流
        Positioned.fill(
          child: CustomVideoPlayer(
            url:
                'https://v11-web-prime.douyinvod.com/video/tos/cn/tos-cn-ve-15c000-ce/ogxAVfr1UwceBOBEQR0iAlCeaE2iI4Uh0HUoGa/?a=6383&ch=164&cr=3&dr=0&lr=all&cd=0%7C0%7C0%7C3&cv=1&br=896&bt=896&cs=0&ds=2&ft=_-iaryThRR0sT1C4-Dv2Nc0iPMgzbLLYFp-U_41u.12JNv7TGW&mime_type=video_mp4&qs=0&rc=ZWY4NjVkNDhmNDQ3NTpmOEBpajo4O245cmxwOTMzbGkzNEBfNmNhXmJiXjUxLl8tMzI0YSNeNV5oMmRzaG5hLS1kLWJzcw%3D%3D&btag=80000e00008000&cquery=100B_100x_100z_100o_101s&dy_q=1774265346&expire=1774276156&feature_id=f5241e7604dff1d9d6c943fd20bd51a2&l=20260323192905FCCF254D45F66A15F9A2&ply_type=4&policy=4&signature=5cd79f5b1f9ac77baf03094229f932df&tk=webid&__vid=7617112071184222641&webid=3336119d6ecc0f2721002588cf880fbc4753b1582d4c54bc5f80aa9273463f0213bb51e0d7ae36184569b59983f68e4483365d3775bf64d98f22957fda87abb26e8d75ed619c3f728fbf26de4dbd0749fb1d6ef60a3f0fdc245325565428984c477384986634ec83f2e52a1b15f59c0478a14901ca91a23f086f6eb2ee67b9d642eaaed18146907052033bd040fa007cddcbdbad6dba8bf5ea4c7e00d9246cd0-2f50206b9074c3910aa9f388e4947e98&fid=22fdb1c15bde60389a6d95e7d6f707ec',
          ),
        ),
        // 右侧信息
        Positioned(
          right: 12.w,
          bottom: 40.h,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Column(
                spacing: 20.h,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 头像
                  Container(
                    width: 68.w,
                    height: 90.h,
                    child: Container(
                      width: 68.w,
                      height: 68.h,
                      padding: EdgeInsets.all(2.w),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                      ),
                      child: Stack(
                        clipBehavior: Clip.none,

                        children: [
                          Positioned.fill(
                            child: GestureDetector(
                              onTap: _onAvatarTap,
                              child: CircleAvatar(
                                backgroundImage: AssetImage(
                                  'lib/assets/avatar.webp',
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: -4.h,
                            left: 0,
                            right: 0,
                            child: GestureDetector(
                              behavior: HitTestBehavior.translucent,
                              onTap: _onFollowTap,
                              child: Container(
                                width: 30.w,
                                height: 30.h,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Color.fromRGBO(251, 48, 89, 1),
                                ),
                                child: Icon(
                                  Icons.add,
                                  color: Colors.white,
                                  size: 24.sp,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // 头像
                  ),
                  // 点赞
                  _buildVideoAttatchInfoItem(
                    title: '点赞',
                    icon: FontAwesomeIcons.heart,
                    count: '336000',
                    onTap: _onLikeTap,
                  ),
                  // 评论数
                  _buildVideoAttatchInfoItem(
                    title: '评论',
                    icon: FontAwesomeIcons.commenting,
                    count: '5000',
                    onTap: _onCommentTap,
                  ),
                  // 收藏
                  _buildVideoAttatchInfoItem(
                    title: '收藏',
                    icon: FontAwesomeIcons.star,
                    count: '50000',
                    onTap: _onCollectTap,
                  ),
                  // 分享
                  _buildVideoAttatchInfoItem(
                    title: '分享',
                    icon: FontAwesomeIcons.share,
                    count: '0',
                    onTap: _onShareTap,
                  ),
                  // 唱片
                  GestureDetector(
                    onTap: _onAlbumTap,
                    child: RotationTransition(
                      turns: _controller,
                      child: CircleAvatar(
                        radius: 24.r,
                        backgroundImage: AssetImage('lib/assets/avatar.webp'),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        // 底部信息
        Positioned(
          bottom: 24.h,
          left: 0,
          right: 0,
          child: Padding(
            padding: EdgeInsetsGeometry.symmetric(horizontal: 12.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    spacing: 12.h,
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.6,
                        child: Text(
                          '@重生之我能升级xxxxxxx',
                          style: TextStyle(
                            fontSize: 24.sp,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            overflow: TextOverflow.ellipsis,
                          ),
                          maxLines: 1,
                        ),
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.65,
                        child: ExpandableText(
                          text: '视频标题视频标题视频标题视频标题视频标题视频标题视频标题视频标题视频标题视频标题视频标题',
                        ),
                      ),
                      GestureDetector(
                        onTap: _onAlbumTap,
                        child:Row(
                        spacing: 4.w,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(4.r),
                            ),
                            padding: EdgeInsets.all(4.w),
                            alignment: Alignment.center,
                            child: Row(
                              spacing: 2.w,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '背景音乐',
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Icon(
                                  Icons.music_note,
                                  color: Colors.white,
                                  size: 14.sp,
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            width: 100.w,
                            child: TextAutoScroll(
                              isActive: true,
                              text: '龙转风（live）-周杰伦',
                            ),
                          ),
                        ],
                      ),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
