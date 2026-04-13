import 'package:bilbili_project/layout/home_feed_playback_scope.dart';
import 'package:bilbili_project/layout/mine_side_menu_scope.dart';
import 'package:bilbili_project/pages/Mine/comps/drawer_menu.dart';
import 'package:bilbili_project/routes/app_router.dart';
import 'package:bilbili_project/routes/index.dart' show router;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class ShellPage extends StatefulWidget {
  final StatefulNavigationShell navigationShell;

  const ShellPage({super.key, required this.navigationShell});

  @override
  State<ShellPage> createState() => _ShellPageState();
}

class _ShellPageState extends State<ShellPage>
    with SingleTickerProviderStateMixin {
  /// [StatefulNavigationShell] 分支顺序：0 首页 / 1 朋友 / 2 消息 / 3 我的
  static const int _kMineBranchIndex = 3;

  late final AnimationController _drawerCtrl;

  /// 右缘向左滑打开侧栏时，与 [AnimationController] 联动
  bool _mineEdgeDragging = false;
  double _panStartDrawerValue = 0;
  double _panAccumDx = 0;

  /// 遮罩上向右滑关闭侧栏
  bool _scrimDrawerDragging = false;
  double _scrimPanStartDrawerValue = 0;
  double _scrimPanAccumDx = 0;

  @override
  void initState() {
    super.initState();
    _drawerCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    router.routerDelegate.addListener(_onRouterChanged);
  }

  void _onRouterChanged() {
    if (mounted) setState(() {});
  }

  /// 首页视频：仅底部选中首页且顶层路由仍是 `/`（例如未 push 全屏页）时可播。
  bool _allowHomeFeedPlayback() {
    if (widget.navigationShell.currentIndex != 0) return false;
    final path = router.routeInformationProvider.value.uri.path;
    return path.isEmpty || path == '/';
  }

  @override
  void dispose() {
    router.routerDelegate.removeListener(_onRouterChanged);
    _drawerCtrl.dispose();
    super.dispose();
  }

  void _openMineDrawer() => _drawerCtrl.forward();

  void _closeMineDrawer() => _drawerCtrl.reverse();

  void _snapMineDrawerAfterPan(double velocityX) {
    if (velocityX < -500) {
      _drawerCtrl.forward();
    } else if (velocityX > 500) {
      _drawerCtrl.reverse();
    } else if (_drawerCtrl.value > 0.35) {
      _drawerCtrl.forward();
    } else {
      _drawerCtrl.reverse();
    }
  }

  int _branchToBottomIndex(int branchIndex) {
    if (branchIndex >= 2) {
      return branchIndex + 1;
    }
    return branchIndex;
  }

  void _onBottomTap(BuildContext context, int index) {
    if (_drawerCtrl.value > 0) {
      _closeMineDrawer();
    }
    if (index == 2) {
      final s = GoRouterState.of(context);
      CreateRoute(fromUrl: s.fullPath).push(context);
      return;
    }
    final branchIndex = index > 2 ? index - 1 : index;
    widget.navigationShell.goBranch(
      branchIndex,
      initialLocation: branchIndex == widget.navigationShell.currentIndex,
    );
  }

  Widget _buildBottomBar(BuildContext context, int bottomIndex) {
    const barBg = Color.fromARGB(255, 27, 25, 25);

    Widget textItem(int index, String title) {
      final selected = bottomIndex == index;
      return Expanded(
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => _onBottomTap(context, index),
          child: Center(
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15.0.sp,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                color: selected ? Colors.white : Colors.grey,
              ),
            ),
          ),
        ),
      );
    }

    final plusButton = Container(
      padding: EdgeInsets.symmetric(vertical: 4.0.h, horizontal: 12.0.w),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(8.0.r),
        border: Border.all(color: Colors.white, width: 2.0.w),
      ),
      child: Icon(
        Icons.add,
        color: Colors.white,
        size: 20.r,
        fontWeight: FontWeight.bold,
      ),
    );

    return Material(
      color: barBg,
      child: SafeArea(
        child: SizedBox(
          height: 52.h + 20.h,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              textItem(0, '首页'),
              textItem(1, '朋友'),
              Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => _onBottomTap(context, 2),
                  child: Center(child: plusButton),
                ),
              ),
              textItem(3, '消息'),
              textItem(4, '我的'),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final drawerW = width * 0.65;
    final bottomIndex = _branchToBottomIndex(widget.navigationShell.currentIndex);
    final bottomNavH = MediaQuery.paddingOf(context).bottom + 52.h + 20.h;

    return MineSideMenuScope(
      open: _openMineDrawer,
      close: _closeMineDrawer,
      child: Stack(
        clipBehavior: Clip.hardEdge,
        children: [
          Positioned(
            top: 0,
            right: 0,
            bottom: 0,
            width: drawerW,
            child: DrawerMenuPanel(
              navigatorContext: context,
              onBeforeItemTap: _closeMineDrawer,
            ),
          ),
          AnimatedBuilder(
            animation: _drawerCtrl,
            builder: (context, _) {
              final rawT = _drawerCtrl.value;
              final t = Curves.easeOutCubic.transform(rawT);
              final dx = -drawerW * t;
              return Transform.translate(
                offset: Offset(dx, 0),
                child: PopScope(
                  canPop: rawT < 0.001,
                  onPopInvokedWithResult: (didPop, _) {
                    if (!didPop && rawT > 0.001) {
                      _closeMineDrawer();
                    }
                  },
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Scaffold(
                        body: HomeFeedPlaybackScope(
                          allowPlayback: _allowHomeFeedPlayback(),
                          child: widget.navigationShell,
                        ),
                        bottomNavigationBar: _buildBottomBar(context, bottomIndex),
                      ),
                      if (rawT > 0.01)
                        Positioned(
                          left: 0,
                          right: 0,
                          top: 0,
                          bottom: bottomNavH,
                          child: GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: _closeMineDrawer,
                            onHorizontalDragStart: (_) {
                              _drawerCtrl.stop();
                              setState(() {
                                _scrimDrawerDragging = true;
                                _scrimPanStartDrawerValue = _drawerCtrl.value;
                                _scrimPanAccumDx = 0;
                              });
                            },
                            onHorizontalDragUpdate: (details) {
                              if (!_scrimDrawerDragging) return;
                              _scrimPanAccumDx += details.delta.dx;
                              _drawerCtrl.value =
                                  (_scrimPanStartDrawerValue -
                                          _scrimPanAccumDx / drawerW)
                                      .clamp(0.0, 1.0);
                            },
                            onHorizontalDragEnd: (details) {
                              if (!_scrimDrawerDragging) return;
                              setState(() => _scrimDrawerDragging = false);
                              _snapMineDrawerAfterPan(
                                details.velocity.pixelsPerSecond.dx,
                              );
                            },
                            onHorizontalDragCancel: () {
                              if (!_scrimDrawerDragging) return;
                              setState(() => _scrimDrawerDragging = false);
                              _snapMineDrawerAfterPan(0);
                            },
                            child: ColoredBox(
                              color: Colors.black.withValues(alpha: 0.45 * rawT),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
          ListenableBuilder(
            listenable: _drawerCtrl,
            builder: (context, _) {
              final onMine =
                  widget.navigationShell.currentIndex == _kMineBranchIndex;
              final showEdge = onMine &&
                  (_drawerCtrl.value < 0.98 || _mineEdgeDragging);
              if (!showEdge) return const SizedBox.shrink();
              return Positioned(
                right: 0,
                top: 0,
                bottom: bottomNavH,
                width: 28.w,
                child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onHorizontalDragStart: (_) {
                    if (widget.navigationShell.currentIndex !=
                        _kMineBranchIndex) {
                      return;
                    }
                    setState(() {
                      _mineEdgeDragging = true;
                      _panStartDrawerValue = _drawerCtrl.value;
                      _panAccumDx = 0;
                    });
                    _drawerCtrl.stop();
                  },
                  onHorizontalDragUpdate: (details) {
                    if (!_mineEdgeDragging) return;
                    if (widget.navigationShell.currentIndex !=
                        _kMineBranchIndex) {
                      setState(() => _mineEdgeDragging = false);
                      _snapMineDrawerAfterPan(0);
                      return;
                    }
                    _panAccumDx += details.delta.dx;
                    _drawerCtrl.value =
                        (_panStartDrawerValue - _panAccumDx / drawerW)
                            .clamp(0.0, 1.0);
                  },
                  onHorizontalDragEnd: (details) {
                    if (!_mineEdgeDragging) return;
                    setState(() => _mineEdgeDragging = false);
                    _snapMineDrawerAfterPan(
                      details.velocity.pixelsPerSecond.dx,
                    );
                  },
                  onHorizontalDragCancel: () {
                    if (!_mineEdgeDragging) return;
                    setState(() => _mineEdgeDragging = false);
                    _snapMineDrawerAfterPan(0);
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
