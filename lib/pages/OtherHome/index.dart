import 'package:bilbili_project/components/default_dialog_skeleton.dart';
import 'package:bilbili_project/layout/mine_side_menu_scope.dart';
import 'package:bilbili_project/routes/app_router.dart';
import 'package:bilbili_project/utils/DialogUtils.dart';
import 'package:bilbili_project/utils/NumberUtils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';

class OtherHomePage extends StatefulWidget {
  OtherHomePage({Key? key}) : super(key: key);

  @override
  State<OtherHomePage> createState() => _OtherHomePageState();
}

class _OtherHomePageState extends State<OtherHomePage>
    with TickerProviderStateMixin {
  late TabController _tabController; // tabs标签页容器的控制器
  // 1. 创建一个 GlobalKey，类型为 RenderSliverPersistentHeader
  final GlobalKey _headerKey = GlobalKey(); // 获取吸顶组件的实例
  // 定义一个常量来表示 TabBar 的高度
  static final double _tabBarHeight = 58.0.h;

  /// 个人资料图以下、TabBar 以上的固定区块高度（与 _buildDataShow / _buildSignature / _buildFollowAndMessageButton 一致）
  static final double _kBlockDataShow = 56.h;
  static final double _kBlockSignature = 52.h;
  static final double _kBlockFollow = 80.h;
  static const double _kProfileBaseHeight = 240;
  static const double _kMaxPullStretch = 200;
  // 定义一个 ScrollController 来控制 CustomScrollView 的滚动
  final ScrollController _scrollController = ScrollController();
  double opacity = 0.0;
  double contraryOpacity = 1.0; // 与 opacity 反向：TabBar 刚好吸顶时（t==1）为 0
  /// 下拉时额外增加的「资料头图」高度（松手后以动画收回）
  double _headerStretch = 0;

  /// TabBar 是否固定在导航栏下方（与 pinned Sliver 不同：需叠在 nav 之下）
  bool _showPinnedTabBar = false;
  late AnimationController _stretchSnapController;
  double _stretchSnapFrom = 0;
  @override
  void initState() {
    super.initState();

    _stretchSnapController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    )..addListener(_onStretchSnapTick);
    _stretchSnapController.addStatusListener(_onStretchSnapStatus);

    _tabController = TabController(length: 3, vsync: this);
    // 2. 监听滚动事件：opacity / contraryOpacity 与 TabBar 吸顶阈值对齐
    _scrollController.addListener(() {
      _updatePinnedTabBar();
      _applyNavBarOpacityFromScroll();
      setState(() {});
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _applyNavBarOpacityFromScroll();
        setState(() {});
      }
    });
  }

  /// 内嵌 TabBar 上沿刚好贴到导航栏下沿时，列表已滚动的距离（与 [_pinnedTabBarShouldShow] 使用同一几何关系）
  double _scrollExtentWhenTabReachesNavBar() {
    if (!mounted) return 1.0;
    final statusBar = MediaQuery.of(context).padding.top;
    final pinLine = _navBarBottomY(statusBar);
    final yTabTop = _contentTopBeforeTabs;
    final raw = yTabTop - pinLine;
    return raw <= 0 ? 1.0 : raw;
  }

  void _applyNavBarOpacityFromScroll() {
    if (!mounted || !_scrollController.hasClients) return;
    final sPin = _scrollExtentWhenTabReachesNavBar();
    final off = _scrollController.offset;
    final t = (off / sPin).clamp(0.0, 1.0);
    // TabBar 刚好吸顶时 off == sPin，t == 1（与 [_pinnedTabBarShouldShow] 同一阈值）
    opacity = t;
    contraryOpacity = 1.0 - t;
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Color.fromRGBO(22, 22, 22, opacity),
        statusBarIconBrightness: opacity > 0.5
            ? Brightness.light
            : Brightness.light,
        statusBarBrightness: opacity > 0.5 ? Brightness.dark : Brightness.dark,
      ),
    );
  }

  void _onStretchSnapTick() {
    if (!mounted) return;
    setState(() {
      _headerStretch =
          _stretchSnapFrom *
          (1.0 - Curves.easeOut.transform(_stretchSnapController.value));
      final next = _pinnedTabBarShouldShow();
      if (next != _showPinnedTabBar) {
        _showPinnedTabBar = next;
      }
      _applyNavBarOpacityFromScroll();
    });
  }

  void _onStretchSnapStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed && mounted) {
      // reset() 会把 value 置回 0，会再触发 _onStretchSnapTick；若仍保留旧的
      // _stretchSnapFrom，公式会变成「原拉伸量 × 1」把高度又拉回去。
      _stretchSnapFrom = 0;
      _stretchSnapController.reset();
      setState(() {
        _headerStretch = 0;
        final next = _pinnedTabBarShouldShow();
        if (next != _showPinnedTabBar) {
          _showPinnedTabBar = next;
        }
        _applyNavBarOpacityFromScroll();
      });
    }
  }

  double get _contentTopBeforeTabs {
    return _kProfileBaseHeight.h +
        _headerStretch +
        _kBlockDataShow +
        _kBlockSignature +
        _kBlockFollow;
  }

  double _navBarBottomY(double statusBarHeight) => statusBarHeight + 56.h;

  bool _pinnedTabBarShouldShow() {
    if (!mounted || !_scrollController.hasClients) return _showPinnedTabBar;
    final statusBar = MediaQuery.of(context).padding.top;
    final yTabTop = _contentTopBeforeTabs;
    final pinLine = _navBarBottomY(statusBar);
    return _scrollController.offset >= yTabTop - pinLine;
  }

  void _updatePinnedTabBar() {
    if (!mounted || !_scrollController.hasClients) return;
    final next = _pinnedTabBarShouldShow();
    if (next != _showPinnedTabBar) {
      setState(() => _showPinnedTabBar = next);
    }
  }

  /// 下拉拉长资料区：不用负 scroll offset（会顶出整页空白），只在列表顶部用指针位移累加高度
  void _onPullStretchPointerMove(PointerMoveEvent e) {
    if (_stretchSnapController.isAnimating) return;
    if (!_scrollController.hasClients) return;
    final off = _scrollController.offset;
    if (off > 0.5) return;

    final dy = e.delta.dy;
    if (dy == 0) return;

    final next = (_headerStretch + dy).clamp(0.0, _kMaxPullStretch);
    if (next == _headerStretch) return;

    setState(() {
      _headerStretch = next;
      final show = _pinnedTabBarShouldShow();
      if (show != _showPinnedTabBar) {
        _showPinnedTabBar = show;
      }
    });
  }

  void _trySnapStretchBack() {
    if (_headerStretch <= 0 || _stretchSnapController.isAnimating) return;
    _stretchSnapFrom = _headerStretch;
    _stretchSnapController.forward(from: 0);
  }

  bool _handleScrollNotification(ScrollNotification n) {
    if (n is ScrollEndNotification) {
      _trySnapStretchBack();
    }
    return false;
  }

  // 组件卸载时的清理操作
  @override
  void dispose() {
    _stretchSnapController.removeListener(_onStretchSnapTick);
    _stretchSnapController.removeStatusListener(_onStretchSnapStatus);
    _stretchSnapController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  // 完全的自定义appBar
  PreferredSizeWidget _buildNavBar(double statusBarHeight) {
    final double appBarTotalHeight = statusBarHeight + 56.h;

    return PreferredSize(
      preferredSize: Size.fromHeight(appBarTotalHeight),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        margin: EdgeInsets.only(top: statusBarHeight),
        height: 56.h,
        color: Colors.transparent,
        child: Stack(
          children: [
            Positioned(
              left: 16.w,
              bottom: 0,
              top: 0,
              child: Row(
                spacing: 10.w,
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () {
                      context.pop();
                    },
                    child: Container(
                      padding: EdgeInsets.all(8.w * contraryOpacity),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18.r),
                        color: Colors.black.withOpacity(0.44 * contraryOpacity),
                      ),
                      child: Icon(
                        Icons.arrow_back_ios_new,
                        color: Colors.white,
                        size: 20.r,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (opacity > 0.5)
                    Stack(
                      children: [
                        StadiumFollowChip(
                          avatarUrl:
                              'https://q2.itc.cn/q_70/images03/20241227/0ae89dca3cc34a0d9c04e22cd5f1f6ac.jpeg',
                          height: 34.h,
                          onFollowButtonTap: _onFollowButtonTap,
                        ),
                        Positioned.fill(
                          child: IgnorePointer(
                            ignoring: true,
                            child: ClipRRect(
                            borderRadius: BorderRadius.circular(17.h),
                            child: Container(
                              color: Colors.white.withOpacity(contraryOpacity),
                            ),
                          ),
                          )
                        ),
                      ],
                    ),
                ],
              ),
            ),
            Positioned(
              right: 16.w,
              bottom: 0,
              top: 0,
              child: Row(
                spacing: 10.w,
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    onTap: () {
                      SearchPageRoute().push(context);
                    },
                    child: Container(
                      padding: EdgeInsets.all(8.w * contraryOpacity),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18.r),
                        // 黑色半透明背景
                        color: Colors.black.withOpacity(0.44 * contraryOpacity),
                      ),
                      child: Row(
                        spacing: 8.w,
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.search,
                            color: Colors.white,
                            size: 20.r,
                            fontWeight: FontWeight.bold,
                          ),
                        ],
                      ),
                    ),
                  ),
                  Builder(
                    builder: (context) {
                      return GestureDetector(
                        onTap: () {
                          MineSideMenuScope.of(context).open();
                        },
                        child: Container(
                          padding: EdgeInsets.all(8.w * contraryOpacity),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(18.r),
                            color: Colors.black.withOpacity(
                              0.44 * contraryOpacity,
                            ),
                          ),
                          child: Row(
                            spacing: 8.w,
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Icon(
                                FontAwesomeIcons.ellipsis,
                                color: Colors.white,
                                size: 20.r,
                                fontWeight: FontWeight.bold,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// TabBar 行（列表内与导航栏下吸顶处共用，需同一 TabController）
  Widget _buildTabBarRow({Key? tabBarKey}) {
    return Container(
      key: tabBarKey,
      decoration: BoxDecoration(
        color: const Color.fromRGBO(22, 22, 22, 1),
        border: Border.all(width: 0, color: Color.fromRGBO(22, 22, 22, 1)),
      ),
      height: _tabBarHeight,
      alignment: Alignment.center,
      child: TabBar(
        controller: _tabController,
        indicatorColor: const Color.fromARGB(255, 190, 173, 21),
        indicatorWeight: 3.h,
        indicatorSize: TabBarIndicatorSize.tab,
        dividerHeight: 0,
        tabs: [
          Tab(child: Text('作品')),
          Tab(child: Text('收藏')),
          Tab(child: Text('喜欢')),
        ],
        labelStyle: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold),
        unselectedLabelStyle: TextStyle(
          fontSize: 14.sp,
          fontWeight: FontWeight.bold,
        ),
        labelColor: Colors.white,
        unselectedLabelColor: Colors.grey,
      ),
    );
  }

  // 个人数据展示
  Widget _buildDataShow() {
    return Container(
      decoration: BoxDecoration(
        color: Color.fromRGBO(22, 22, 22, 1),
        border: Border.all(width: 0, color: Color.fromRGBO(22, 22, 22, 1)),
      ),
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
            onTap: () {
              // 弹出dialog
              DialogUtils(
                DefaultDialgSkeleton(
                  isSingleBtn: true,
                  rightBtnText: '我知道了',
                  child: Container(
                    alignment: Alignment.center,
                    height: 180.h,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.asset(
                          'lib/assets/agree_dialog.png',
                          height: 80.h,
                          fit: BoxFit.fitHeight,
                        ),
                        SizedBox(height: 20.h),
                        Text(
                          '“llg”共获得 6 个赞',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 10.h),
                        Text(
                          '获赞数包含作品、私密',
                          style: TextStyle(color: Colors.grey, fontSize: 14.sp),
                        ),
                      ],
                    ),
                  ),
                ),
              ).showCustomDialog(context);
            },
            child: Center(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Row(
                  spacing: 4.w,
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      NumberUtils.formatLikeCount(1000000),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '获赞',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          ),
          Expanded(
            child: GestureDetector(
            onTap: () {
              RelationshipRoute(initialIndex: 1).push(context);
            },
            child: Center(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Row(
                  spacing: 4.w,
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      NumberUtils.formatLikeCount(1000000),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '关注',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          ),
          Expanded(
            child: GestureDetector(
            onTap: () {
              RelationshipRoute(initialIndex: 2).push(context);
            },
            child: Center(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Row(
                  spacing: 4.w,
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      NumberUtils.formatLikeCount(1000000),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '粉丝',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
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
    );
  }

  // 背景图片 + 头像 + 用户名 + 账号
  /// [extraHeight] 下拉时增加的额外高度，松手后通过 [_stretchSnapController] 动画归零
  Widget _buildProfileInfo({double extraHeight = 0}) {
    return GestureDetector(
      onTap: () {
        PreviewRoute(
          mode: '1',
          tag: '',
          imageUrl:
              'https://pic.rmb.bdstatic.com/a5a5448a468ca88ebc57ef6bdbec13ee@wm_1,k_cGljX2JqaHdhdGVyLmpwZw==',
        ).push(context);
      },
      child: Container(
        alignment: Alignment.bottomLeft,
        width: double.infinity,
        height: _kProfileBaseHeight.h + extraHeight,
        decoration: BoxDecoration(
          border: Border.all(width: 0, color: Color.fromRGBO(22, 22, 22, 1)),
          image: DecorationImage(
            image: NetworkImage(
              'https://pic.rmb.bdstatic.com/a5a5448a468ca88ebc57ef6bdbec13ee@wm_1,k_cGljX2JqaHdhdGVyLmpwZw==',
            ),
            fit: BoxFit.cover,
          ),
        ),
        child: Padding(
          padding: EdgeInsets.only(
            left: 20.w,
            right: 20.w,
            top: 20.h,
            bottom: 10.h,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTap: () {
                  PreviewRoute(
                    mode: '0',
                    tag: 'avatar',
                    imageUrl:
                        'https://ww2.sinaimg.cn/mw690/008yzw28ly1hwmic0i3o4j30u00u0djl.jpg',
                  ).push(context);
                },
                child:  Container(
                    width: 100.r,
                    height: 100.r,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.white, width: 2.w),
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        image: NetworkImage(
                          'https://ww2.sinaimg.cn/mw690/008yzw28ly1hwmic0i3o4j30u00u0djl.jpg',
                        ),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                
              ),

              SizedBox(width: 10.w),
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '央视新闻',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),

                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // 认证图标
                      Icon(
                        FontAwesomeIcons.check,
                        color: Color.fromRGBO(240, 190, 96, 1),
                        size: 16.r,
                      ),
                      Text(
                        '絮语创作者',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 个性签名
  Widget _buildSignature() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: const Color.fromRGBO(22, 22, 22, 1),
        // 官方的bug
        border: Border.all(width: 0, color: Color.fromRGBO(22, 22, 22, 1)),
      ),
      child:
          // 超出自动换行
          Text(
            '点击添加介绍，让大家认识你...',
            style: TextStyle(color: Colors.white, fontSize: 14.sp),
          ),
    );
  }

  // 关注 + 私信按钮
  Widget _buildFollowAndMessageButton() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: const Color.fromRGBO(22, 22, 22, 1),
        border: Border.all(width: 0, color: Color.fromRGBO(22, 22, 22, 1)),
      ),
      height: 80.h,
      child: Row(
        spacing: 10.w,
        children: [
          Expanded(
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Color.fromRGBO(254, 43, 84, 1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18.r),
                ),
              ),
              onPressed: () {
                _onFollowButtonTap();
              },
              label: Text(
                '关注',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              icon: Icon(
                FontAwesomeIcons.plus,
                color: Colors.white,
                size: 16.r,
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Color.fromRGBO(57, 57, 57, 1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18.r),
              ),
            ),
            onPressed: () {
              _onMessageButtonTap();
            },
            child: Icon(
              FontAwesomeIcons.solidPaperPlane,
              color: Colors.white,
              size: 16.r,
            ),
          ),
        ],
      ),
    );
  }

  // 关注按钮事件
  void _onFollowButtonTap() {
    print('关注');
  }

  // 私信
  void _onMessageButtonTap() {
    print('私信');
  }

  @override
  Widget build(BuildContext context) {
    double statusBarHeight = MediaQuery.of(context).padding.top;
    const Color pageBg = Color.fromRGBO(22, 22, 22, 1);
    return Scaffold(
      backgroundColor: pageBg,
      appBar: _buildNavBar(statusBarHeight),
      extendBody: true,
      extendBodyBehindAppBar: true, // 让body出现在appBar区域的正下方
      body: Stack(
        clipBehavior: Clip.none,
        children: [
          const Positioned.fill(child: ColoredBox(color: pageBg)),
          Listener(
            behavior: HitTestBehavior.translucent,
            onPointerMove: (PointerEvent e) {
              if (e is PointerMoveEvent) {
                _onPullStretchPointerMove(e);
              }
            },
            onPointerUp: (_) => _trySnapStretchBack(),
            onPointerCancel: (_) => _trySnapStretchBack(),
            child: NotificationListener<ScrollNotification>(
              onNotification: _handleScrollNotification,
              child: CustomScrollView(
                controller: _scrollController,
                physics: const ClampingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics(),
                ),
                slivers: [
                  SliverToBoxAdapter(
                    child: _buildProfileInfo(extraHeight: _headerStretch),
                  ),
                  SliverToBoxAdapter(
                    child: Stack(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _buildDataShow(),
                            _buildSignature(),
                            _buildFollowAndMessageButton(),
                          ],
                        ),
                        Positioned.fill(
                          child: IgnorePointer(
                            ignoring: true,
                            child: Container(
                              color: Color.fromRGBO(
                                22,
                                22,
                                22,
                                1 - contraryOpacity,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: _showPinnedTabBar
                        ? ColoredBox(
                            color: pageBg,
                            child: SizedBox(height: _tabBarHeight),
                          )
                        : _buildTabBarRow(tabBarKey: _headerKey),
                  ),
                  SliverToBoxAdapter(
                    child: SizedBox(
                      height: 1000.h,
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          Container(
                            color: const Color.fromRGBO(22, 22, 22, 1),
                            child: Center(
                              child: Text(
                                '作品',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20.sp,
                                ),
                              ),
                            ),
                          ),
                          Container(
                            color: const Color.fromRGBO(22, 22, 22, 1),
                            child: Center(
                              child: Text(
                                '收藏',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20.sp,
                                ),
                              ),
                            ),
                          ),
                          Container(
                            color: const Color.fromRGBO(22, 22, 22, 1),
                            child: Center(
                              child: Text(
                                '喜欢',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20.sp,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_showPinnedTabBar)
            Positioned(
              top: _navBarBottomY(statusBarHeight),
              left: 0,
              right: 0,
              child: Material(
                elevation: 4,
                color: const Color.fromRGBO(22, 22, 22, 1),
                child: _buildTabBarRow(tabBarKey: _headerKey),
              ),
            ),
        ],
      ),
    );
  }
}

class StadiumFollowChip extends StatelessWidget {
  const StadiumFollowChip({
    super.key,
    required this.avatarUrl,
    required this.onFollowButtonTap,
    this.height = 26,
  });

  final String avatarUrl;
  final double height;
  final Function() onFollowButtonTap;

  @override
  Widget build(BuildContext context) {
    final h = height;
    return Material(
      color: Color.fromRGBO(251, 241, 244, 1), // 浅粉底，按设计改
      borderRadius: BorderRadius.circular(h / 2),
      clipBehavior: Clip.antiAlias, // 水波纹也被裁成跑道形
      child: InkWell(
        onTap: () {
          onFollowButtonTap();
        },
        child: SizedBox(
          height: h,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 关键：直径 == 外层高度，左顶格 → 与外层左弧完全一致
              ClipOval(
                child: SizedBox(
                  width: h,
                  height: h,
                  child: Image.network(avatarUrl, fit: BoxFit.cover),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 8, right: 14),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  spacing: 4.w,
                  children: [
                    Icon(
                      FontAwesomeIcons.plus,
                      color: Color(0xFFE91E8C),
                      size: 14.r,
                    ),
                    Text(
                      '关注',
                      style: TextStyle(
                        color: const Color(0xFFE91E8C),
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
