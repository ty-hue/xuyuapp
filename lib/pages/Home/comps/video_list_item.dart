import 'package:bilbili_project/components/expandable_text.dart';
import 'package:bilbili_project/components/text_auto_scroll.dart';
import 'package:bilbili_project/components/custom_video_player.dart';
import 'package:bilbili_project/pages/Home/comps/video_comment_sheet_skeleton.dart';
import 'package:bilbili_project/pages/Home/comps/video_share_sheet_skeleton.dart';
import 'package:bilbili_project/utils/NumberUtils.dart';
import 'package:bilbili_project/utils/SheetUtils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class VideoListItem extends StatefulWidget {
  /// 是否为纵向列表当前停留的这一条；用于自动播放 / 滑走时暂停。
  final bool isActive;

  VideoListItem({Key? key, this.isActive = true}) : super(key: key);

  @override
  _VideoListItemState createState() => _VideoListItemState();
}

class _VideoListItemState extends State<VideoListItem>
    with TickerProviderStateMixin {
  late final AnimationController _recordRotationController;
  late final AnimationController _likeBurstController;
  late final Animation<double> _likeScaleAnimation;
  late final AnimationController _collectBurstController;
  late final Animation<double> _collectScaleAnimation;

  /// 关注作者：点击 + 后先播「白底红✔」小幅放大再消失。
  late final AnimationController _followAckController;
  late final Animation<double> _followAckScale;
  late final Animation<double> _followAckOpacity;

  bool _followedAuthor = false;
  bool _followAckPlaying = false;

  bool _isLiked = false;
  int _likeCount = 336000;

  bool _isCollected = false;
  int _collectCount = 50000;

  static const Color _likeRed = Color(0xFFFF2D55);
  /// 收藏点亮后的金黄色（白 → 金渐变）
  static const Color _collectGold = Color(0xFFFFC94A);

  @override
  void initState() {
    super.initState();
    _recordRotationController = AnimationController(
      duration: const Duration(seconds: 6),
      vsync: this,
    )..repeat();

    _likeBurstController = AnimationController(
      duration: const Duration(milliseconds: 720),
      vsync: this,
    );
    _likeScaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.52).chain(
          CurveTween(curve: Curves.easeOutCubic),
        ),
        weight: 38,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.52, end: 1.0).chain(
          CurveTween(curve: Curves.elasticOut),
        ),
        weight: 62,
      ),
    ]).animate(_likeBurstController);

    _likeBurstController.addListener(() => setState(() {}));

    _collectBurstController = AnimationController(
      duration: const Duration(milliseconds: 720),
      vsync: this,
    );
    _collectScaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.52).chain(
          CurveTween(curve: Curves.easeOutCubic),
        ),
        weight: 38,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.52, end: 1.0).chain(
          CurveTween(curve: Curves.elasticOut),
        ),
        weight: 62,
      ),
    ]).animate(_collectBurstController);

    _collectBurstController.addListener(() => setState(() {}));

    _followAckController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 680),
    );
    _followAckScale = Tween<double>(begin: 1.0, end: 1.22).animate(
      CurvedAnimation(
        parent: _followAckController,
        curve: const Interval(0.0, 0.45, curve: Curves.easeOutCubic),
      ),
    );
    _followAckOpacity = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _followAckController,
        curve: const Interval(0.48, 1.0, curve: Curves.easeIn),
      ),
    );
    _followAckController.addListener(() => setState(() {}));
    _followAckController.addStatusListener((status) {
      if (status != AnimationStatus.completed || !mounted) return;
      setState(() {
        _followedAuthor = true;
        _followAckPlaying = false;
      });
      _followAckController.reset();
    });
  }

  void _playLikeBurstAnimation() {
    _likeBurstController.forward(from: 0);
  }

  void _playCollectBurstAnimation() {
    _collectBurstController.forward(from: 0);
  }

  /// 双击视频：未点赞时点亮右侧爱心并播放动效；已点赞不重复点亮。
  void _onDoubleTapLikeFromVideo() {
    if (!_isLiked) {
      setState(() {
        _isLiked = true;
        _likeCount++;
      });
      _playLikeBurstAnimation();
      _onLikeTap();
    }
  }

  Widget _buildLikeColumn() {
    final colorProgress = CurvedAnimation(
      parent: _likeBurstController,
      curve: const Interval(0.0, 0.5, curve: Curves.easeOutCubic),
    ).value;
    final double colorT;
    if (!_isLiked) {
      colorT = 0;
    } else if (!_likeBurstController.isAnimating) {
      colorT = 1;
    } else {
      colorT = colorProgress.clamp(0.0, 1.0);
    }
    final heartColor =
        Color.lerp(Colors.white, _likeRed, colorT) ?? Colors.white;

    return Column(
      mainAxisSize: MainAxisSize.min,
      spacing: 4.h,
      children: [
        GestureDetector(
          onTap: _onLikeIconTap,
          child: AnimatedBuilder(
            animation: _likeScaleAnimation,
            builder: (context, child) {
              final scale = _likeBurstController.isDismissed
                  ? 1.0
                  : _likeScaleAnimation.value;
              return Transform.scale(
                scale: scale,
                child: child,
              );
            },
            child: Icon(
              FontAwesomeIcons.solidHeart,
              color: heartColor,
              size: 39.sp,
              shadows: _isLiked &&
                      _likeBurstController.isAnimating &&
                      _likeBurstController.value > 0.08
                  ? [
                      Shadow(
                        color: _likeRed.withValues(
                          alpha: 0.5 *
                              (1 - _likeBurstController.value * 0.45),
                        ),
                        blurRadius: 14,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
          ),
        ),
        Text(
          _likeCount == 0
              ? '点赞'
              : NumberUtils.formatLikeCount(_likeCount),
          style: TextStyle(color: Colors.white, fontSize: 15.sp),
        ),
      ],
    );
  }

  void _onLikeIconTap() {
    setState(() {
      if (_isLiked) {
        _isLiked = false;
        if (_likeCount > 0) _likeCount--;
      } else {
        _isLiked = true;
        _likeCount++;
        _playLikeBurstAnimation();
      }
    });
    print('点击了点赞');
  }

  Widget _buildCollectColumn() {
    final colorProgress = CurvedAnimation(
      parent: _collectBurstController,
      curve: const Interval(0.0, 0.5, curve: Curves.easeOutCubic),
    ).value;
    final double colorT;
    if (!_isCollected) {
      colorT = 0;
    } else if (!_collectBurstController.isAnimating) {
      colorT = 1;
    } else {
      colorT = colorProgress.clamp(0.0, 1.0);
    }
    final starColor =
        Color.lerp(Colors.white, _collectGold, colorT) ?? Colors.white;

    return Column(
      mainAxisSize: MainAxisSize.min,
      spacing: 4.h,
      children: [
        GestureDetector(
          onTap: _onCollectIconTap,
          child: AnimatedBuilder(
            animation: _collectScaleAnimation,
            builder: (context, child) {
              final scale = _collectBurstController.isDismissed
                  ? 1.0
                  : _collectScaleAnimation.value;
              return Transform.scale(
                scale: scale,
                child: child,
              );
            },
            child: Icon(
              FontAwesomeIcons.solidStar,
              color: starColor,
              size: 39.sp,
              shadows: _isCollected &&
                      _collectBurstController.isAnimating &&
                      _collectBurstController.value > 0.08
                  ? [
                      Shadow(
                        color: _collectGold.withValues(
                          alpha: 0.55 *
                              (1 - _collectBurstController.value * 0.45),
                        ),
                        blurRadius: 14,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
          ),
        ),
        Text(
          _collectCount == 0
              ? '收藏'
              : NumberUtils.formatLikeCount(_collectCount),
          style: TextStyle(color: Colors.white, fontSize: 15.sp),
        ),
      ],
    );
  }

  void _onCollectIconTap() {
    setState(() {
      if (_isCollected) {
        _isCollected = false;
        if (_collectCount > 0) _collectCount--;
      } else {
        _isCollected = true;
        _collectCount++;
        _playCollectBurstAnimation();
      }
    });
    if (_isCollected) {
      _onCollectTap();
    } else {
      print('取消收藏');
    }
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
    SheetUtils(
      const VideoShareSheetSkeleton(),
      deferHeavyChild: false,
    ).openAsyncSheet<void>(context: context);
    print('点击了分享');
  }

  // 点击点赞（双击视频时也会调用，便于打日志 / 请求接口）
  void _onLikeTap() {
    print('点赞事件');
  }

  // 点击评论
  void _onCommentTap() {
    SheetUtils(
      const VideoCommentSheetSkeleton(),
      deferHeavyChild: false,
    ).openAsyncSheet<void>(context: context);
    print('点击了评论');
  }

  // 点击收藏
  void _onCollectTap() {
    print('点击了收藏');
  }

  @override
  void dispose() {
    _recordRotationController.dispose();
    _likeBurstController.dispose();
    _collectBurstController.dispose();
    _followAckController.dispose();
    super.dispose();
  }

  // 点击唱片
  void _onAlbumTap() {
    print('点击了唱片');
  }

  // 点击关注
  void _onFollowTap() {
    if (_followedAuthor || _followAckPlaying) return;
    // TODO: 请求关注接口
    setState(() => _followAckPlaying = true);
    _followAckController.forward(from: 0);
    print('点击了关注');
  }

  Widget _buildFollowBadgeBelowAvatar() {
    if (_followedAuthor) return const SizedBox.shrink();

    if (_followAckPlaying) {
      return Positioned(
        bottom: -4.h,
        left: 0,
        right: 0,
        child: IgnorePointer(
          child: FadeTransition(
            opacity: _followAckOpacity,
            child: ScaleTransition(
              scale: _followAckScale,
              child: Center(
                child: Container(
                  width: 30.w,
                  height: 30.h,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                  ),
                  child: Icon(
                    Icons.check,
                    color: Color.fromRGBO(251, 48, 89, 1),
                    size: 18.sp,
                    weight: 900,
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Positioned(
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
    );
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
            isActive: widget.isActive,
            onDoubleTapLike: _onDoubleTapLikeFromVideo,
            url:
                'https://vdept3.bdstatic.com/mda-scnhg803xt32vc4n/360p/h264/1774268589069318420/mda-scnhg803xt32vc4n.mp4?v_from_s=hkapp-haokan-hna&auth_key=1776084566-0-0-a4e330861894f9810f613fa8c9d2bc2c&bcevod_channel=searchbox_feed&cr=0&cd=0&pd=1&pt=3&logid=2966509307&vid=1421899744954427798&klogid=2966509307&abtest=',
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
                          _buildFollowBadgeBelowAvatar(),
                        ],
                      ),
                    ),

                    // 头像
                  ),
                  // 点赞（双击视频未点赞时会动画变红）
                  _buildLikeColumn(),
                  // 评论数
                  _buildVideoAttatchInfoItem(
                    title: '评论',
                    icon: FontAwesomeIcons.solidCommentDots,
                    count: '5000',
                    onTap: _onCommentTap,
                  ),
                  // 收藏（未收藏时点按：与点赞同款缩放动效并变为金黄）
                  _buildCollectColumn(),
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
                      turns: _recordRotationController,
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
                              isActive: widget.isActive,
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
