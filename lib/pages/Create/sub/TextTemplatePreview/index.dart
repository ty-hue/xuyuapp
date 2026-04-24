import 'dart:ui' as ui;

import 'package:bilbili_project/pages/Create/sub/ReleasePreparation/release_preparation_args.dart';
import 'package:bilbili_project/pages/Create/sub/TextTemplatePreview/text_template_preview_args.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

/// 文字模板预览独立页：顶栏（返回 / 音乐 / 设置）+ 主卡片 + 模板条 + 底部「下一步」。
/// 无右侧工具栏、无「限时日常」。
class TextTemplatePreviewPage extends StatefulWidget {
  const TextTemplatePreviewPage({super.key});

  @override
  State<TextTemplatePreviewPage> createState() => _TextTemplatePreviewPageState();
}

class _StoryTemplate {
  const _StoryTemplate({
    required this.id,
    required this.stripLabel,
    required this.decoration,
    required this.textAlignment,
    required this.padL,
    required this.padT,
    required this.padR,
    required this.padB,
    this.thumbIcon,
    this.thumbGradient,
  });

  final String id;
  final String stripLabel;
  final BoxDecoration decoration;
  final Alignment textAlignment;
  final double padL;
  final double padT;
  final double padR;
  final double padB;
  final IconData? thumbIcon;
  final Gradient? thumbGradient;
}

class _TextTemplatePreviewPageState extends State<TextTemplatePreviewPage> {
  late final TextTemplatePreviewArgs _args;
  final GlobalKey _cardKey = GlobalKey();
  int _selectedIndex = 1;
  String? _musicLabel;

  static const _outerGreen = Color(0xFF3DDC84);

  static final List<_StoryTemplate> _templates = [
    _StoryTemplate(
      id: 'custom',
      stripLabel: '自定义',
      thumbGradient: const LinearGradient(
        colors: [Color(0xFF7C4DFF), Color(0xFFFF6EC7)],
      ),
      thumbIcon: Icons.title_rounded,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF2A2A3A), Color(0xFF1A1A24)],
        ),
      ),
      textAlignment: Alignment.center,
      padL: 0.1,
      padT: 0.14,
      padR: 0.1,
      padB: 0.18,
    ),
    _StoryTemplate(
      id: 'dark',
      stripLabel: '换一换',
      thumbIcon: Icons.refresh_rounded,
      decoration: const BoxDecoration(color: Color(0xFF0E0E0E)),
      textAlignment: Alignment.centerLeft,
      padL: 0.1,
      padT: 0.22,
      padR: 0.12,
      padB: 0.2,
    ),
    _StoryTemplate(
      id: 'sky',
      stripLabel: '浅蓝',
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFB3E5FC), Color(0xFF81D4FA)],
        ),
      ),
      textAlignment: Alignment.centerLeft,
      padL: 0.1,
      padT: 0.2,
      padR: 0.1,
      padB: 0.22,
    ),
    _StoryTemplate(
      id: 'cream',
      stripLabel: '奶油',
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFFFF9C4), Color(0xFFFFE082)],
        ),
      ),
      textAlignment: Alignment.center,
      padL: 0.1,
      padT: 0.18,
      padR: 0.1,
      padB: 0.2,
    ),
    _StoryTemplate(
      id: 'pink',
      stripLabel: '粉色',
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFF8BBD0), Color(0xFFF48FB1)],
        ),
      ),
      textAlignment: Alignment.bottomCenter,
      padL: 0.1,
      padT: 0.14,
      padR: 0.1,
      padB: 0.26,
    ),
    _StoryTemplate(
      id: 'mint',
      stripLabel: '薄荷',
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFB2DFDB), Color(0xFF4DB6AC)],
        ),
      ),
      textAlignment: Alignment.center,
      padL: 0.12,
      padT: 0.2,
      padR: 0.12,
      padB: 0.2,
    ),
    _StoryTemplate(
      id: 'sunset',
      stripLabel: '晚霞',
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFFCC80), Color(0xFFFF8A65), Color(0xFFE91E63)],
        ),
      ),
      textAlignment: Alignment.centerLeft,
      padL: 0.1,
      padT: 0.2,
      padR: 0.1,
      padB: 0.2,
    ),
    _StoryTemplate(
      id: 'lavender',
      stripLabel: '薰衣草',
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFE1BEE7), Color(0xFF9575CD)],
        ),
      ),
      textAlignment: Alignment.center,
      padL: 0.1,
      padT: 0.18,
      padR: 0.1,
      padB: 0.22,
    ),
    _StoryTemplate(
      id: 'sand',
      stripLabel: '沙砾',
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFFFF8E1), Color(0xFFFFE0B2), Color(0xFFFFCC80)],
        ),
      ),
      textAlignment: Alignment.topCenter,
      padL: 0.1,
      padT: 0.16,
      padR: 0.1,
      padB: 0.22,
    ),
    _StoryTemplate(
      id: 'forest',
      stripLabel: '森绿',
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF1B3D2F), Color(0xFF0D2818)],
        ),
      ),
      textAlignment: Alignment.bottomLeft,
      padL: 0.1,
      padT: 0.14,
      padR: 0.1,
      padB: 0.24,
    ),
    _StoryTemplate(
      id: 'night',
      stripLabel: '星夜',
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1A237E), Color(0xFF311B92), Color(0xFF4A148C)],
        ),
      ),
      textAlignment: Alignment.center,
      padL: 0.1,
      padT: 0.2,
      padR: 0.1,
      padB: 0.2,
    ),
    _StoryTemplate(
      id: 'ocean',
      stripLabel: '深海',
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF01579B), Color(0xFF006064), Color(0xFF004D40)],
        ),
      ),
      textAlignment: Alignment.centerLeft,
      padL: 0.1,
      padT: 0.22,
      padR: 0.12,
      padB: 0.2,
    ),
    _StoryTemplate(
      id: 'paper',
      stripLabel: '素纸',
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFF5F5F5), Color(0xFFE0E0E0)],
        ),
      ),
      textAlignment: Alignment.centerLeft,
      padL: 0.1,
      padT: 0.2,
      padR: 0.1,
      padB: 0.2,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _args = TextTemplatePreviewNav.readOnce();
  }

  @override
  void dispose() {
    TextTemplatePreviewNav.reset();
    super.dispose();
  }

  _StoryTemplate get _tpl => _templates[_selectedIndex.clamp(0, _templates.length - 1)];

  void _toast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), behavior: SnackBarBehavior.floating),
    );
  }

  Future<void> _captureAndGoRelease() async {
    await Future<void>.delayed(const Duration(milliseconds: 80));
    if (!mounted) return;
    final boundary = _cardKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
    if (boundary == null) {
      _toast('生成封面失败');
      return;
    }
    try {
      final image = await boundary.toImage(pixelRatio: 3);
      final bd = await image.toByteData(format: ui.ImageByteFormat.png);
      final bytes = bd?.buffer.asUint8List();
      if (bytes == null || bytes.isEmpty) {
        _toast('生成封面失败');
        return;
      }
      if (!mounted) return;
      ReleasePreparationNav.setPending(
        ReleasePreparationArgs.photo(
          bytes: bytes,
          shootAspectRatio: '9:16',
          initialTitle: _args.releaseTitle,
          initialBody: _args.releaseDescription,
        ),
      );
      if (!mounted) return;
      context.push('/create/release_preparation');
    } catch (_) {
      _toast('生成封面失败');
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.paddingOf(context).bottom;

    return Scaffold(
      backgroundColor: _outerGreen,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildTopBar(),
            Expanded(
              child: ColoredBox(
                color: _outerGreen,
                child: Center(child: _buildPreviewCard()),
              ),
            ),
            ColoredBox(
              color: _outerGreen,
              child: _buildTemplateStrip(),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 12.h + bottom),
              child: SizedBox(
                width: double.infinity,
                height: 48.h,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFFE5395C),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                  ),
                  onPressed: _captureAndGoRelease,
                  child: Text('下一步', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: EdgeInsets.fromLTRB(4.w, 6.h, 8.w, 8.h),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20.sp),
            onPressed: () => context.pop(),
          ),
          Expanded(
            child: Center(
              child: Material(
                color: Colors.black.withValues(alpha: 0.35),
                borderRadius: BorderRadius.circular(20.r),
                child: InkWell(
                  borderRadius: BorderRadius.circular(20.r),
                  onTap: () {
                    setState(() => _musicLabel = _musicLabel == null ? 'Home' : null);
                  },
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.music_note, color: Colors.white, size: 18.sp),
                        SizedBox(width: 6.w),
                        Text(
                          _musicLabel ?? '选择音乐',
                          style: TextStyle(color: Colors.white, fontSize: 14.sp),
                        ),
                        if (_musicLabel != null) ...[
                          SizedBox(width: 6.w),
                          GestureDetector(
                            onTap: () => setState(() => _musicLabel = null),
                            child: Icon(Icons.close, color: Colors.white70, size: 18.sp),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          // 与左侧返回占位对称，保持音乐条视觉居中
          SizedBox(width: 48.w),
        ],
      ),
    );
  }

  Widget _buildPreviewCard() {
    final w = (MediaQuery.sizeOf(context).width * 0.78).clamp(260.0, 340.0);

    return RepaintBoundary(
      key: _cardKey,
      child: Material(
        color: Colors.transparent,
        child: SizedBox(
          width: w,
          child: AspectRatio(
            aspectRatio: 9 / 16,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16.r),
              child: LayoutBuilder(
                builder: (context, c) {
                  final tw = c.maxWidth;
                  final th = c.maxHeight;
                  final tpl = _tpl;
                  final px = EdgeInsets.fromLTRB(
                    tw * tpl.padL,
                    th * tpl.padT,
                    tw * tpl.padR,
                    th * tpl.padB,
                  );
                  return Stack(
                    fit: StackFit.expand,
                    children: [
                      DecoratedBox(decoration: tpl.decoration),
                      Positioned.fill(
                        child: Padding(
                          padding: px,
                          child: Align(
                            alignment: tpl.textAlignment,
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: tpl.textAlignment,
                              child: ConstrainedBox(
                                constraints: BoxConstraints(maxWidth: tw - px.horizontal),
                                child: _buildOverlayText(tpl),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 10.h,
                        left: 10.w,
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 14.r,
                              backgroundColor: Colors.white24,
                              child: Icon(Icons.person, color: Colors.white, size: 16.sp),
                            ),
                            SizedBox(width: 8.w),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '@user',
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.95),
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  _todayLabel(),
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 11.sp,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Positioned(
                        bottom: 10.h,
                        left: 10.w,
                        child: Text(
                          _timeLabel(),
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 11.sp,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _todayLabel() {
    final n = DateTime.now();
    final m = n.month.toString().padLeft(2, '0');
    final d = n.day.toString().padLeft(2, '0');
    return '$m-$d';
  }

  String _timeLabel() {
    final n = DateTime.now();
    const w = ['周一', '周二', '周三', '周四', '周五', '周六', '周日'];
    final h = n.hour.toString().padLeft(2, '0');
    final mi = n.minute.toString().padLeft(2, '0');
    return '$h:$mi  ${w[(n.weekday - 1).clamp(0, 6)]}';
  }

  static const List<Shadow> _textShadow = [
    Shadow(color: Color(0x88000000), blurRadius: 6, offset: Offset(0, 1)),
  ];

  Widget _buildOverlayText(_StoryTemplate tpl) {
    final raw = _args.overlayPrimaryText;
    final lightBg = tpl.id == 'sky' ||
        tpl.id == 'cream' ||
        tpl.id == 'pink' ||
        tpl.id == 'mint' ||
        tpl.id == 'sunset' ||
        tpl.id == 'lavender' ||
        tpl.id == 'sand' ||
        tpl.id == 'paper';
    final primary = lightBg ? const Color(0xFF1A1A1A) : Colors.white;
    final secondary = lightBg ? const Color(0xDD1A1A1A) : Colors.white.withValues(alpha: 0.92);

    if (raw.isEmpty) {
      return Text(
        '写点内容吧',
        style: TextStyle(
          color: primary.withValues(alpha: 0.45),
          fontSize: 20.sp,
          shadows: lightBg ? null : _textShadow,
        ),
      );
    }
    if (_args.mode == TextPreviewSourceMode.longArticle) {
      final t = _args.longTitle.trim();
      final b = _args.longBody.trim();
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (t.isNotEmpty)
            Text(
              t,
              style: TextStyle(
                color: primary,
                fontSize: 22.sp,
                fontWeight: FontWeight.w700,
                height: 1.25,
                shadows: lightBg ? null : _textShadow,
              ),
            ),
          if (t.isNotEmpty && b.isNotEmpty) SizedBox(height: 10.h),
          if (b.isNotEmpty)
            Text(
              b,
              style: TextStyle(
                color: secondary,
                fontSize: 16.sp,
                height: 1.4,
                shadows: lightBg ? null : _textShadow,
              ),
            ),
        ],
      );
    }
    return Text(
      raw,
      textAlign: TextAlign.left,
      style: TextStyle(
        color: primary,
        fontSize: 28.sp,
        fontWeight: FontWeight.w700,
        height: 1.2,
        shadows: lightBg ? null : _textShadow,
      ),
    );
  }

  Widget _buildTemplateStrip() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(14.w, 4.h, 14.w, 6.h),
          child: Text(
            '提问小卡',
            style: TextStyle(color: Colors.white, fontSize: 15.sp, fontWeight: FontWeight.w600),
          ),
        ),
        SizedBox(
          height: 102.h,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 12.w),
            itemCount: _templates.length,
            separatorBuilder: (context, index) => SizedBox(width: 10.w),
            itemBuilder: (context, i) {
              final t = _templates[i];
              final sel = i == _selectedIndex;
              return GestureDetector(
                onTap: () => setState(() => _selectedIndex = i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 58.w,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10.r),
                    border: Border.all(
                      color: sel ? Colors.white : Colors.white24,
                      width: sel ? 3 : 1,
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8.r),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        if (t.thumbGradient != null)
                          DecoratedBox(decoration: BoxDecoration(gradient: t.thumbGradient)),
                        if (t.thumbGradient == null)
                          DecoratedBox(decoration: t.decoration),
                        if (t.thumbIcon != null)
                          Center(
                            child: Icon(
                              t.thumbIcon,
                              color: Colors.white,
                              size: i == 0 ? 22.sp : 20.sp,
                            ),
                          ),
                        Positioned(
                          bottom: 4.h,
                          left: 0,
                          right: 0,
                          child: Text(
                            t.stripLabel,
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10.sp,
                              fontWeight: FontWeight.w500,
                              shadows: const [
                                Shadow(color: Colors.black54, blurRadius: 4),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
