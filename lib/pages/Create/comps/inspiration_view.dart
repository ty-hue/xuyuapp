import 'package:bilbili_project/components/appBar_back_icon_btn.dart';
import 'package:bilbili_project/components/static_app_bar.dart';
import 'package:bilbili_project/components/with_statusBar_color.dart';
import 'package:bilbili_project/pages/Create/comps/video_preview.dart';
import 'package:bilbili_project/routes/app_router.dart';
import 'package:bilbili_project/routes/create_routes/network_single_image_preview_route.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

TextStyle _inspirationPlainTextStyle({
  required Color color,
  required double fontSize,
  FontWeight? fontWeight,
  double? height,
  double? letterSpacing,
  List<Shadow>? shadows,
}) {
  return TextStyle(
    color: color,
    fontSize: fontSize,
    fontWeight: fontWeight,
    height: height,
    letterSpacing: letterSpacing,
    shadows: shadows,
    decoration: TextDecoration.none,
    decorationColor: Colors.transparent,
  );
}

/// 顶部主标题：渐变字 + 左侧装饰竖条，偏杂志/展陈气质。
class _InspirationArtTitle extends StatelessWidget {
  const _InspirationArtTitle();

  @override
  Widget build(BuildContext context) {
    final titleStyle = TextStyle(
      fontSize: 26.sp,
      fontWeight: FontWeight.w600,
      height: 1.12,
      letterSpacing: 3.2,
      color: Colors.white,
      decoration: TextDecoration.none,
      shadows: [
        Shadow(
          color: const Color(0xFF6B4EE6).withValues(alpha: 0.35),
          blurRadius: 18,
          offset: const Offset(0, 4),
        ),
        Shadow(
          color: Colors.black.withValues(alpha: 0.55),
          blurRadius: 6,
          offset: const Offset(0, 2),
        ),
      ],
    );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 3.5.w,
          height: 30.h,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(3.r),
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFFFFD89B),
                Color(0xFFC9A0FF),
                Color(0xFF7DD3FC),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFC9A0FF).withValues(alpha: 0.45),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
        ),
        SizedBox(width: 14.w),
        Expanded(
          child: ShaderMask(
            blendMode: BlendMode.srcIn,
            shaderCallback: (bounds) => const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFFFFF4E0),
                Color(0xFFE8D4FF),
                Color(0xFFB8EAFF),
              ],
              stops: [0.0, 0.48, 1.0],
            ).createShader(bounds),
            child: Text('创作灵感', style: titleStyle),
          ),
        ),
      ],
    );
  }
}

/// 创作灵感：展示可自由使用的影像参考（Picsum、开源样片等），仅作 UI 演示。
class InspirationView extends StatefulWidget {
  const InspirationView({super.key});

  @override
  State<InspirationView> createState() => _InspirationViewState();
}

enum _InspirationKind { image, video }

class _InspirationItem {
  const _InspirationItem({
    required this.kind,
    required this.title,
    required this.subtitle,
    required this.coverUrl,
    this.previewVideoUrl,
  });

  final _InspirationKind kind;
  final String title;
  final String subtitle;
  final String coverUrl;
  /// 仅 [kind] == video 时使用；与 [coverUrl] 海报对应的样片地址。
  final String? previewVideoUrl;
}

class _InspirationViewState extends State<InspirationView> {
  static const Color _bg = Color(0xFF000000);
  static const Color _card = Color(0xFF141414);
  static const Color _muted = Color(0xFF8A8A8A);
  static const Color _chipBorder = Color(0xFF2E2E2E);

  /// 样片常用公开地址（Google Hosted），与海报对应作品一致，便于联调预览。
  static const List<_InspirationItem> _catalog = [
    _InspirationItem(
      kind: _InspirationKind.video,
      title: 'Big Buck Bunny',
      subtitle: 'Blender 基金会 · CC BY 3.0 动画短片',
      coverUrl:
          'https://upload.wikimedia.org/wikipedia/commons/thumb/c/c5/Big_buck_bunny_poster_big.png/640px-Big_buck_bunny_poster_big.png',
      previewVideoUrl:
          'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4',
    ),
    _InspirationItem(
      kind: _InspirationKind.video,
      title: 'Sintel',
      subtitle: 'Blender 基金会 · CC BY 3.0 动画短片',
      coverUrl:
          'https://upload.wikimedia.org/wikipedia/commons/thumb/f/f5/Sintel_poster_thumb.jpg/640px-Sintel_poster_thumb.jpg',
      previewVideoUrl:
          'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/Sintel.mp4',
    ),
    _InspirationItem(
      kind: _InspirationKind.video,
      title: 'Elephants Dream',
      subtitle: 'Blender 基金会 · CC 授权首部开源动画',
      coverUrl:
          'https://upload.wikimedia.org/wikipedia/commons/thumb/2/27/Elephants_DreamCover_sidebar.jpg/640px-Elephants_DreamCover_sidebar.jpg',
      previewVideoUrl:
          'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4',
    ),
    _InspirationItem(
      kind: _InspirationKind.image,
      title: '自然光影',
      subtitle: 'Lorem Picsum（Unsplash 图集）',
      coverUrl: 'https://picsum.photos/id/1018/800/1000',
    ),
    _InspirationItem(
      kind: _InspirationKind.image,
      title: '海岸与浪',
      subtitle: 'Lorem Picsum（Unsplash 图集）',
      coverUrl: 'https://picsum.photos/id/1050/800/1000',
    ),
    _InspirationItem(
      kind: _InspirationKind.image,
      title: '城市建筑',
      subtitle: 'Lorem Picsum（Unsplash 图集）',
      coverUrl: 'https://picsum.photos/id/1076/800/1000',
    ),
    _InspirationItem(
      kind: _InspirationKind.image,
      title: '森林小径',
      subtitle: 'Lorem Picsum（Unsplash 图集）',
      coverUrl: 'https://picsum.photos/id/1023/800/1000',
    ),
    _InspirationItem(
      kind: _InspirationKind.image,
      title: '极简静物',
      subtitle: 'Lorem Picsum（Unsplash 图集）',
      coverUrl: 'https://picsum.photos/id/1060/800/1000',
    ),
    _InspirationItem(
      kind: _InspirationKind.image,
      title: '远山与雾',
      subtitle: 'Lorem Picsum（Unsplash 图集）',
      coverUrl: 'https://picsum.photos/id/1067/800/1000',
    ),
  ];

  static const List<String> _chipLabels = ['全部', '影像', '短片'];

  int _chipIndex = 0;

  List<_InspirationItem> get _visible {
    switch (_chipIndex) {
      case 1:
        return _catalog.where((e) => e.kind == _InspirationKind.image).toList();
      case 2:
        return _catalog.where((e) => e.kind == _InspirationKind.video).toList();
      default:
        return _catalog;
    }
  }

  @override
  Widget build(BuildContext context) {
    final visible = _visible;
    final baseStyle = DefaultTextStyle.of(context).style;
    return ColoredBox(
      color: _bg,
      child: SafeArea(
        bottom: false,
        left: false,
        right: false,
        top: true,
        minimum: EdgeInsets.zero,
        child: DefaultTextStyle.merge(
          style: baseStyle.copyWith(
            decoration: TextDecoration.none,
            decorationColor: Colors.transparent,
          ),
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 12.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const _InspirationArtTitle(),
                      SizedBox(height: 8.h),
                      Text(
                        '开源影像与样片参考，点击查看大图或全屏播放',
                        style: _inspirationPlainTextStyle(
                          color: _muted,
                          fontSize: 13.sp,
                          height: 1.4,
                        ),
                      ),
                      SizedBox(height: 16.h),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: List.generate(_chipLabels.length, (i) {
                            final selected = _chipIndex == i;
                            return Padding(
                              padding: EdgeInsets.only(right: 8.w),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () => setState(() => _chipIndex = i),
                                  borderRadius: BorderRadius.circular(20.r),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 180),
                                    curve: Curves.easeOutCubic,
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 16.w,
                                      vertical: 8.h,
                                    ),
                                    decoration: BoxDecoration(
                                      color: selected ? Colors.white : _card,
                                      borderRadius: BorderRadius.circular(20.r),
                                      border: Border.all(
                                        color: selected
                                            ? Colors.white
                                            : _chipBorder,
                                      ),
                                    ),
                                    child: Text(
                                      _chipLabels[i],
                                      style: _inspirationPlainTextStyle(
                                        color: selected ? _bg : Colors.white70,
                                        fontSize: 13.sp,
                                        fontWeight: selected
                                            ? FontWeight.w600
                                            : FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverPadding(
                padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 24.h),
                sliver: SliverGrid(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 12.h,
                    crossAxisSpacing: 12.w,
                    childAspectRatio: 0.62,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      if (index >= visible.length) return null;
                      return _InspirationTile(item: visible[index]);
                    },
                    childCount: visible.length,
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

class _InspirationTile extends StatelessWidget {
  const _InspirationTile({required this.item});

  final _InspirationItem item;

  static const Color _card = Color(0xFF1C1C1C);

  void _onTap(BuildContext context) {
    if (item.kind == _InspirationKind.image) {
      context.push(
        const NetworkSingleImagePreviewRoute().location,
        extra: item.coverUrl,
      );
      return;
    }
    final url = item.previewVideoUrl;
    if (url == null || url.isEmpty) return;
    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => InspirationNetworkVideoPreviewPage(
          title: item.title,
          videoUrl: url,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isVideo = item.kind == _InspirationKind.video;
    return Material(
      color: _card,
      borderRadius: BorderRadius.circular(16.r),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _onTap(context),
        child: Stack(
          fit: StackFit.expand,
          children: [
            ExtendedImage.network(
              item.coverUrl,
              fit: BoxFit.cover,
              cache: true,
              loadStateChanged: (state) {
                switch (state.extendedImageLoadState) {
                  case LoadState.loading:
                    return ColoredBox(
                      color: const Color(0xFF252525),
                      child: Center(
                        child: SizedBox(
                          width: 28.w,
                          height: 28.w,
                          child: const CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Color(0xFF5C5C5C),
                          ),
                        ),
                      ),
                    );
                  case LoadState.failed:
                    return ColoredBox(
                      color: const Color(0xFF252525),
                      child: Icon(
                        Icons.broken_image_outlined,
                        color: Colors.white24,
                        size: 40.sp,
                      ),
                    );
                  case LoadState.completed:
                    return null;
                }
              },
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.05),
                      Colors.black.withValues(alpha: 0.82),
                    ],
                    stops: const [0.35, 0.55, 1],
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.fromLTRB(12.w, 28.h, 12.w, 12.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        item.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: _inspirationPlainTextStyle(
                          color: Colors.white,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          height: 1.25,
                          shadows: const [
                            Shadow(
                              blurRadius: 8,
                              color: Colors.black54,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        item.subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: _inspirationPlainTextStyle(
                          color: Colors.white.withValues(alpha: 0.72),
                          fontSize: 10.sp,
                          height: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            if (isVideo)
              Positioned(
                top: 10.h,
                right: 10.w,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.45),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.w,
                      vertical: 4.h,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.play_arrow_rounded,
                          color: Colors.white,
                          size: 18.sp,
                        ),
                        Text(
                          '短片',
                          style: _inspirationPlainTextStyle(
                            color: Colors.white,
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// 全屏网络样片预览，内嵌项目内 [VideoPreview]（网络源）。
class InspirationNetworkVideoPreviewPage extends StatelessWidget {
  const InspirationNetworkVideoPreviewPage({
    super.key,
    required this.title,
    required this.videoUrl,
  });

  final String title;
  final String videoUrl;

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.paddingOf(context).top;
    return WithStatusbarColorView(
      statusBarColor: Colors.black,
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: StaticAppBar(
          title: title,
          statusBarHeight: top,
          backgroundColor: Colors.black,
          titleFontSize: 16,
          leadingChild: const BackIconBtn(
            icon: Icons.close,
            size: 24,
            color: Colors.white,
          ),
        ),
        body: VideoPreview(networkVideoUrl: videoUrl),
      ),
    );
  }
}
