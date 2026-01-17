import 'package:bilbili_project/pages/Mine/comps/drawer_menu.dart';
import 'package:bilbili_project/routes/app_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';

class MinePage extends StatefulWidget {
  MinePage({Key? key}) : super(key: key);

  @override
  State<MinePage> createState() => _MinePageState();
}

class _MinePageState extends State<MinePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController; // tabs标签页容器的控制器
  int _currentTabIndex = 0; // 当前激活状态tab标签页的索引值
  // 1. 创建一个 GlobalKey，类型为 RenderSliverPersistentHeader
  final GlobalKey _headerKey = GlobalKey(); // 获取吸顶组件的实例
  // 定义一个常量来表示 TabBar 的高度
  static final double _tabBarHeight = 58.0.h;
  // 定义一个 ScrollController 来控制 CustomScrollView 的滚动
  final ScrollController _scrollController = ScrollController();
  Offset _widgetPosition = Offset.zero;
  double opacity = 0.0;
  double contraryOpacity = 1; // 控制添加朋友 和 新访客
  @override
  void initState() {
    super.initState();

    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _currentTabIndex = _tabController.index;
      });
    });
    // 2. 监听滚动事件 动态计算opacity 和 contraryOpacity
    _scrollController.addListener(() {
      opacity = (_scrollController.offset / _widgetPosition.dy).clamp(0.0, 1.0);
      contraryOpacity = 1 - opacity;
      SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(
          statusBarColor: Color.fromRGBO(22, 22, 22, opacity), // 关键
          statusBarIconBrightness: opacity > 0.5
              ? Brightness.light
              : Brightness.light,
          statusBarBrightness: opacity > 0.5
              ? Brightness.dark
              : Brightness.dark,
        ),
      );
      setState(() {});
    });
    // 在下一帧（Frame）渲染后获取位置
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _getWidgetPosition();
    });
  }

  // 获取吸顶TabBar距离页面最顶部的距离
  void _getWidgetPosition() {
    // 确保 RenderBox 存在
    final RenderBox? renderBox =
        _headerKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox != null) {
      final Offset globalOffset = renderBox.localToGlobal(
        Offset.zero,
      ); // 3. 获取绝对位置
      // 获取状态栏高度 (顶部安全区域)
      setState(() {
        _widgetPosition = Offset(globalOffset.dx, globalOffset.dy); // 4. 计算距离
      });
    }
  }

  // 组件卸载时的清理操作
  @override
  void dispose() {
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
              child: GestureDetector(
                onTap: () {
                  AddFriendRoute().push(context);
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      padding: EdgeInsets.all(8.w),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18.r),
                        color: Color.fromRGBO(
                          88,
                          77,
                          78,
                          0.5,
                        ).withOpacity(contraryOpacity),
                      ),
                      child: Row(
                        spacing: 8.w,
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(
                            FontAwesomeIcons.userPlus,
                            color: Colors.white.withOpacity(contraryOpacity),
                            size: 14.r,
                            fontWeight: FontWeight.bold,
                          ),
                          Text(
                            '添加朋友',
                            style: TextStyle(
                              color: Colors.white.withOpacity(contraryOpacity),
                              fontSize: 12.r,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Center(
              child: Text(
                'llg',
                style: TextStyle(
                  color: Colors.white.withOpacity(opacity),
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                ),
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
                      VisitorPageRoute().push(context);
                    },
                    child: Container(
                      padding: EdgeInsets.all(8.w),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18.r),
                        color: Color.fromRGBO(
                          88,
                          77,
                          78,
                          0.5,
                        ).withOpacity(contraryOpacity),
                      ),
                      child: Row(
                        spacing: 8.w,
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(
                            FontAwesomeIcons.userGroup,
                            color: Colors.white.withOpacity(contraryOpacity),
                            size: 14.r,
                            fontWeight: FontWeight.bold,
                          ),
                          Text(
                            '新访客 3',
                            style: TextStyle(
                              color: Colors.white.withOpacity(contraryOpacity),
                              fontSize: 12.r,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      SearchPageRoute().push(context);
                    },
                    child: Container(
                      padding: EdgeInsets.all(8.w),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18.r),
                        color: Color.fromRGBO(
                          88,
                          77,
                          78,
                          0.5,
                        ).withOpacity(contraryOpacity),
                      ),
                      child: Row(
                        spacing: 8.w,
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(
                            FontAwesomeIcons.search,
                            color: Colors.white,
                            size: 16.r,
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
                          Scaffold.of(context).openEndDrawer();
                        },
                        child: Container(
                          padding: EdgeInsets.all(8.w * contraryOpacity),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(18.r),
                            color: Color.fromRGBO(
                              88,
                              77,
                              78,
                              0.5,
                            ).withOpacity(contraryOpacity),
                          ),
                          child: Row(
                            spacing: 8.w,
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Icon(
                                FontAwesomeIcons.navicon,
                                color: Colors.white,
                                size: 16.r,
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

  // 吸顶 TabBar （包括广告 + tabs标签栏）
  Widget _buildTabBarWidget() {
    return Container(
      key: _headerKey,
      decoration: BoxDecoration(
        color: const Color.fromRGBO(22, 22, 22, 1), // 关键：吸顶后需要背景色来遮挡下方内容
       border: Border.all(
            width: 0,
            color: Color.fromRGBO(22, 22, 22, 1),
          )
      ),
      height: MediaQuery.of(context).padding.top + 56.h + _tabBarHeight,
      child: Column(
        children: [
          _buildAd(MediaQuery.of(context).padding.top + 48.h),
          TabBar(
            controller: _tabController,
            indicatorColor: const Color.fromARGB(255, 190, 173, 21),
            indicatorWeight: 3.h,
            indicatorSize: TabBarIndicatorSize.tab,
            dividerHeight: 0,
            tabs: [
              Tab(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  spacing: 4.w,
                  children: [
                    Text('作品'),
                    Icon(
                      FontAwesomeIcons.lock,
                      size: 12.r,
                      fontWeight: FontWeight.bold,
                    ),
                  ],
                ),
              ),
              Tab(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  spacing: 4.w,
                  children: [
                    Text('推荐'),
                    Icon(
                      FontAwesomeIcons.lock,
                      size: 12.r,
                      fontWeight: FontWeight.bold,
                    ),
                  ],
                ),
              ),
              Tab(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  spacing: 4.w,
                  children: [
                    Text('收藏'),
                    Icon(
                      FontAwesomeIcons.lock,
                      size: 12.r,
                      fontWeight: FontWeight.bold,
                    ),
                  ],
                ),
              ),
              Tab(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  spacing: 4.w,
                  children: [
                    Text('喜欢'),
                    Icon(
                      FontAwesomeIcons.lock,
                      size: 12.r,
                      fontWeight: FontWeight.bold,
                    ),
                  ],
                ),
              ),
            ],
            labelStyle: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold),
            unselectedLabelStyle: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.bold,
            ),
            labelColor: Colors.white,
            unselectedLabelColor: Colors.grey,
          ),
        ],
      ),
    );
  }

  // 絮语商城 观看历史 创作者中心 我的钱包 全部功能
  Widget _buildFunctionList() {
    return Stack(
      children: [
        Container(
          padding: EdgeInsets.only(
            top: 10.h,
            left: 20.w,
            right: 20.w,
            bottom: 20.h,
          ),
          // color: const Color.fromRGBO(22, 22, 22, 1),
          decoration: BoxDecoration(color: const Color.fromRGBO(22, 22, 22, 1),border: Border.all(
            width: 0,
            color: Color.fromRGBO(22, 22, 22, 1),
          )),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                spacing: 4.h,
                children: [
                  Icon(Icons.shop, color: Colors.white, size: 20.r),
                  Text(
                    '絮语商城',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                spacing: 4.h,
                children: [
                  Icon(
                    FontAwesomeIcons.history,
                    color: Colors.white,
                    size: 20.r,
                  ),
                  Text(
                    '观看历史',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                spacing: 4.h,
                children: [
                  Icon(
                    FontAwesomeIcons.lightbulb,
                    color: Colors.white,
                    size: 20.r,
                  ),
                  Text(
                    '创作者中心',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                spacing: 4.h,
                children: [
                  Icon(
                    FontAwesomeIcons.creditCard,
                    color: Colors.white,
                    size: 20.r,
                  ),
                  Text(
                    '我的钱包',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                spacing: 4.h,
                children: [
                  Icon(FontAwesomeIcons.th, color: Colors.white, size: 20.r),
                  Text(
                    '全部功能',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: SizedBox(
            height: 80.h,
            child: Opacity(
              opacity: opacity,
              child: Container(color: const Color.fromRGBO(22, 22, 22, 1)),
            ),
          ),
        ),
      ],
    );
  }

  // 广告
  Widget _buildAd(double totalHeight) {
    return Stack(
      children: [
        Container(
          alignment: Alignment.center,
          height: totalHeight,
          color: const Color.fromRGBO(22, 22, 22, 1),
          child: Container(
            alignment: Alignment.center,
            height: 60.h,
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: SizedBox(
              height: 40.h,
              child: Image.network(
                'https://img1.baidu.com/it/u=1247624760,2892757430&fm=253&fmt=auto&app=120&f=JPEG?w=1175&h=500',
                fit: BoxFit.cover,
                alignment: Alignment.center,
                width: double.infinity,
                height: 40.h,
              ),
            ),
          ),
        ),
        SizedBox(
          height: totalHeight,
          child: Opacity(
            opacity: opacity,
            child: Container(color: const Color.fromRGBO(22, 22, 22, 1)),
          ),
        ),
      ],
    );
  }

  // 个人数据展示
  Widget _buildDataShow() {
    return Container(
      decoration: BoxDecoration(
        color: Color.fromRGBO(22, 22, 22, 1),
        border: Border.all(
            width: 0,
            color: Color.fromRGBO(22, 22, 22, 1),
          )
      ),
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            spacing: 20.w,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '6',
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
              Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '4',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '互关',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '289',
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
              Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '28',
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
            ],
          ),
          GestureDetector(
            onTap: () {
              EditProfileRoute().push(context);
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: Color.fromRGBO(88, 77, 78, 0.5),
                borderRadius: BorderRadius.circular(5.r),
              ),
              child: Text(
                '编辑主页',
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
    );
  }

  // 背景图片 + 头像 + 用户名 + 账号
  Widget _buildProfileInfo() {
    return Container(
      alignment: Alignment.bottomLeft,
      width: double.infinity,
      height: 240.h,
      decoration: BoxDecoration(
       border: Border.all(
            width: 0,
            color: Color.fromRGBO(22, 22, 22, 1),
          ),
        image: DecorationImage(
          image: AssetImage('lib/assets/mine_bg.png'),
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
            Stack(
              children: [
                Container(
                  width: 80.w,
                  height: 80.h,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white, width: 2.w),
                    shape: BoxShape.circle,
                    image: DecorationImage(
                      image: AssetImage('lib/assets/avatar.webp'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: () {
                      context.go('/create');
                    },
                    child: Container(
                      alignment: Alignment.center,
                      width: 24.w,
                      height: 24.h,
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 190, 190, 49),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        FontAwesomeIcons.plus,
                        color: Colors.white,
                        size: 16.r,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(width: 10.w),
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'llg',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                Text(
                  '絮语号：sdk19991212',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // 个性签名
  Widget _buildSignature() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      decoration: BoxDecoration(
        color: const Color.fromRGBO(22, 22, 22, 1),
        // 官方的bug
       border: Border.all(
            width: 0,
            color: Color.fromRGBO(22, 22, 22, 1),
          )
      ),
      child: GestureDetector(
        onTap: () {
          EditProfileRoute().push(context);
        },
        child: Row(
          children: [
            Text(
              '点击添加介绍，让大家认识你...',
              style: TextStyle(color: Colors.white, fontSize: 14.sp),
            ),
            Icon(Icons.edit, color: Colors.white, size: 14.r),
          ],
        ),
      ),
    );
  }

  // 个人标签
  Widget _buildTags() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),

      // color: const Color.fromRGBO(22, 22, 22, 1),
      decoration: BoxDecoration(
        color: const Color.fromRGBO(22, 22, 22, 1),
        boxShadow: [
          BoxShadow(
          color: const Color.fromRGBO(22, 22, 22, 1),
          blurRadius: 0.0,
          spreadRadius: 0.0,
          offset: Offset(0, 2.h),
        ),
        ],
        // 官方的bug
       border: Border.all(
            width: 0,
            color: Color.fromRGBO(22, 22, 22, 1),
          )
      ),
      child: GestureDetector(
        onTap: () {
          EditProfileRoute().push(context);
        },
        child: Row(
          spacing: 6.w,
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: Color.fromRGBO(88, 77, 78, 0.5),
                borderRadius: BorderRadius.circular(5.r),
              ),
              child: Row(
                children: [
                  Text(
                    '我的动态',
                    style: TextStyle(color: Colors.white, fontSize: 11.sp),
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: Color.fromRGBO(88, 77, 78, 0.5),
                borderRadius: BorderRadius.circular(5.r),
              ),
              child: Row(
                children: [
                  Text(
                    '21岁',
                    style: TextStyle(color: Colors.white, fontSize: 11.sp),
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: Color.fromRGBO(88, 77, 78, 0.5),
                borderRadius: BorderRadius.circular(5.r),
                
              ),
              child: Row(
                children: [
                  Icon(Icons.add, color: Colors.white, size: 11.r),
                  Text(
                    '添加其他标签',
                    style: TextStyle(color: Colors.white, fontSize: 11.sp),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double statusBarHeight = MediaQuery.of(context).padding.top;
    return Scaffold(
      endDrawer: DrawerMenu(context: context),
      appBar: _buildNavBar(statusBarHeight),
      extendBody: true,
      extendBodyBehindAppBar: true, // 让body出现在appBar区域的正下方
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          SliverToBoxAdapter(child: _buildProfileInfo()),
          SliverToBoxAdapter(child: _buildDataShow()),
          SliverToBoxAdapter(child: _buildSignature()),
          SliverToBoxAdapter(child: _buildTags()),
          SliverToBoxAdapter(child: _buildFunctionList()),
          SliverPersistentHeader(
            pinned: true, // 关键：设置为 true 以实现吸顶
            delegate: _TabBarHeaderDelegate(
              tabBarWidget: _buildTabBarWidget(),
              height: MediaQuery.of(context).padding.top + 56.h + _tabBarHeight,
            ),
          ),
          // TabBar对应的内容区域
          SliverToBoxAdapter(
            child: SizedBox(
              height: 1000.h,
              child: TabBarView(
                controller: _tabController,
                children: [
                  // 动态页面
                  Container(
                    color: const Color.fromRGBO(22, 22, 22, 1),
                    child: Center(
                      child: Text(
                        '作品',
                        style: TextStyle(color: Colors.white, fontSize: 20.sp),
                      ),
                    ),
                  ),
                  // 作品页面
                  Container(
                    color: const Color.fromRGBO(22, 22, 22, 1),
                    child: Center(
                      child: Text(
                        '推荐',
                        style: TextStyle(color: Colors.white, fontSize: 20.sp),
                      ),
                    ),
                  ),
                  // 收藏页面
                  Container(
                    color: const Color.fromRGBO(22, 22, 22, 1),
                    child: Center(
                      child: Text(
                        '收藏',
                        style: TextStyle(color: Colors.white, fontSize: 20.sp),
                      ),
                    ),
                  ),
                  // 喜欢
                  Container(
                    color: const Color.fromRGBO(22, 22, 22, 1),
                    child: Center(
                      child: Text(
                        '喜欢',
                        style: TextStyle(color: Colors.white, fontSize: 20.sp),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TabBarHeaderDelegate extends SliverPersistentHeaderDelegate {
  final Widget tabBarWidget;
  final double height;
  _TabBarHeaderDelegate({required this.tabBarWidget, required this.height});
  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return tabBarWidget;
  }

  @override
  double get maxExtent => height;

  @override
  double get minExtent => height;

  @override
  bool shouldRebuild(covariant _TabBarHeaderDelegate oldDelegate) {
    return true;
  }
}
