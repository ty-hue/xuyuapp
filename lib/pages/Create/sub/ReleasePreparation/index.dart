import 'dart:io';
import 'dart:math' as math;

import 'package:bilbili_project/pages/Create/sub/ReleasePreparation/release_preparation_args.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:video_player/video_player.dart';

class ReleasePreparationPage extends StatefulWidget {
  const ReleasePreparationPage({super.key});

  @override
  State<ReleasePreparationPage> createState() => _ReleasePreparationPageState();
}

class _ReleasePreparationPageState extends State<ReleasePreparationPage> {
  late final ReleasePreparationArgs _args;
  final TextEditingController _bodyController = TextEditingController();
  final FocusNode _bodyFocus = FocusNode();

  /// 模板等同时带标题与描述时，合并进单一正文框。
  static String _mergeInitialBody(String? title, String? body) {
    final t = (title ?? '').trim();
    final b = (body ?? '').trim();
    if (t.isEmpty) return b;
    if (b.isEmpty) return t;
    return '$t\n\n$b';
  }

  static const _privacyOptions = [
    '公开 · 所有人可见',
    '好友可见',
    '仅自己可见',
  ];

  int _privacyIndex = 0;

  static const Color _bg = Color(0xFF121212);
  static const Color _fieldBg = Color(0xFF2C2C2C);
  static const Color _chipBg = Color(0xFF3A3A3A);
  static const Color _accent = Color(0xFFE5395C);

  @override
  void initState() {
    super.initState();
    _args = ReleasePreparationNav.pullPending();
    _bodyController.text =
        _mergeInitialBody(_args.initialTitle, _args.initialBody);
  }

  @override
  void dispose() {
    _bodyController.dispose();
    _bodyFocus.dispose();
    super.dispose();
  }

  bool get _canPublish {
    if (_bodyController.text.trim().isNotEmpty) return true;
    switch (_args.kind) {
      case ReleaseWorkKind.video:
        final p = _args.videoPath;
        return p != null && p.isNotEmpty;
      case ReleaseWorkKind.photo:
        if (_args.photoBytes != null && _args.photoBytes!.isNotEmpty) {
          return true;
        }
        final path = _args.photoPath;
        return path != null && path.isNotEmpty;
      case ReleaseWorkKind.text:
        return false;
    }
  }

  double get _coverBoxAspect {
    if (_args.kind == ReleaseWorkKind.text) {
      return kReleaseTextCoverAspectRatio;
    }
    return releaseCoverAspectRatioFromShoot(_args.shootAspectRatio);
  }

  void _onAtFriends() {
    final v = _bodyController.value;
    const chunk = '@';
    final s = v.selection;
    final t = v.text;
    final start = s.start >= 0 ? s.start : t.length;
    final end = s.end >= 0 ? s.end : t.length;
    final newText = t.replaceRange(start, end, chunk);
    _bodyController.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: start + chunk.length),
    );
    _bodyFocus.requestFocus();
  }

  Future<void> _pickPrivacy() async {
    final i = await showModalBottomSheet<int>(
      context: context,
      backgroundColor: const Color(0xFF2A2A2A),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(12.r)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(_privacyOptions.length, (idx) {
              return ListTile(
                title: Text(
                  _privacyOptions[idx],
                  style: TextStyle(color: Colors.white, fontSize: 15.sp),
                ),
                trailing: idx == _privacyIndex
                    ? Icon(Icons.check, color: _accent, size: 22.sp)
                    : null,
                onTap: () => Navigator.pop(ctx, idx),
              );
            }),
          ),
        );
      },
    );
    if (i != null && mounted) setState(() => _privacyIndex = i);
  }

  void _onSaveDraft() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('已存入草稿', style: TextStyle(fontSize: 14.sp)),
        behavior: SnackBarBehavior.floating,
      ),
    );
    context.pop();
  }

  void _onPublish() {
    if (!_canPublish) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('请填写作品正文，或确认已添加视频/照片', style: TextStyle(fontSize: 14.sp)),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('发布请求已提交（演示）', style: TextStyle(fontSize: 14.sp)),
        behavior: SnackBarBehavior.floating,
      ),
    );
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.paddingOf(context).bottom;
    final thumbW = math.min(130.w, MediaQuery.sizeOf(context).width * 0.38);

    return Scaffold(
      backgroundColor: _bg,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: _bg,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20.sp),
          onPressed: () => context.pop(),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: ListView(
              padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 20.h),
              children: [
                _ReleaseCoverSlot(
                  args: _args,
                  boxAspect: _coverBoxAspect,
                  thumbWidth: thumbW,
                  posterText: _bodyController.text,
                ),
                SizedBox(height: 16.h),
                TextField(
                  controller: _bodyController,
                  focusNode: _bodyFocus,
                  minLines: 5,
                  maxLines: 10,
                  style: TextStyle(color: Colors.white, fontSize: 15.sp, height: 1.4),
                  decoration: InputDecoration(
                    hintText: '添加正文…',
                    hintStyle: TextStyle(
                      color: Colors.white.withValues(alpha: 0.35),
                      fontSize: 15.sp,
                    ),
                    filled: true,
                    fillColor: _fieldBg,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.r),
                      borderSide: BorderSide.none,
                    ),
                    alignLabelWithHint: true,
                    contentPadding: EdgeInsets.fromLTRB(14.w, 14.h, 14.w, 14.h),
                  ),
                  onChanged: (_) => setState(() {}),
                ),
                SizedBox(height: 16.h),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Material(
                    color: _chipBg,
                    borderRadius: BorderRadius.circular(6.r),
                    child: InkWell(
                      onTap: _onAtFriends,
                      borderRadius: BorderRadius.circular(6.r),
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
                        child: Text(
                          '@朋友',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.9),
                            fontSize: 14.sp,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20.h),
                Material(
                  color: _fieldBg,
                  borderRadius: BorderRadius.circular(8.r),
                  child: InkWell(
                    onTap: _pickPrivacy,
                    borderRadius: BorderRadius.circular(8.r),
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 16.h),
                      child: Row(
                        children: [
                          Icon(Icons.lock_open_rounded,
                              color: Colors.white70, size: 22.sp),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: Text(
                              _privacyOptions[_privacyIndex],
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 15.sp,
                              ),
                            ),
                          ),
                          Icon(Icons.chevron_right, color: Colors.white38, size: 22.sp),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.fromLTRB(12.w, 10.h, 12.w, 10.h + bottom),
            decoration: const BoxDecoration(
              color: Color(0xFF1A1A1A),
              border: Border(top: BorderSide(color: Color(0x22FFFFFF))),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                TextButton.icon(
                  onPressed: _onSaveDraft,
                  icon: Icon(Icons.folder_outlined, color: Colors.white70, size: 22.sp),
                  label: Text(
                    '存草稿',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.85),
                      fontSize: 14.sp,
                    ),
                  ),
                ),
                const Spacer(),
                Material(
                  color: _accent,
                  borderRadius: BorderRadius.circular(28.r),
                  child: InkWell(
                    onTap: _onPublish,
                    borderRadius: BorderRadius.circular(28.r),
                    child: SizedBox(
                      width: 112.w,
                      height: 48.h,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 26.r,
                            height: 26.r,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.arrow_upward,
                              color: Colors.white,
                              size: 18.sp,
                            ),
                          ),
                          SizedBox(width: 8.w),
                          Text(
                            '发作品',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15.sp,
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
        ],
      ),
    );
  }
}

/// 统一比例「小盒子」：视频首帧 / 照片 / 文字稿均在盒内 [BoxFit.contain]，不变形、不裁切主体。
class _ReleaseCoverSlot extends StatelessWidget {
  const _ReleaseCoverSlot({
    required this.args,
    required this.boxAspect,
    required this.thumbWidth,
    required this.posterText,
  });

  final ReleasePreparationArgs args;
  /// 宽/高。
  final double boxAspect;
  final double thumbWidth;
  /// [ReleaseWorkKind.text] 封面预览用，与正文输入框同源。
  final String posterText;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: SizedBox(
        width: thumbWidth,
        child: AspectRatio(
          aspectRatio: boxAspect,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8.r),
            child: ColoredBox(
              color: Colors.black,
              child: _CoverInner(
                args: args,
                posterText: posterText,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CoverInner extends StatelessWidget {
  const _CoverInner({
    required this.args,
    required this.posterText,
  });

  final ReleasePreparationArgs args;
  final String posterText;

  @override
  Widget build(BuildContext context) {
    switch (args.kind) {
      case ReleaseWorkKind.video:
        final p = args.videoPath;
        if (p == null || p.isEmpty) {
          return _coverPlaceholder(Icons.videocam_off_outlined);
        }
        return _VideoFirstFrameContained(path: p);
      case ReleaseWorkKind.photo:
        if (args.photoBytes != null && args.photoBytes!.isNotEmpty) {
          return Center(
            child: Image.memory(
              args.photoBytes!,
              fit: BoxFit.contain,
              gaplessPlayback: true,
              filterQuality: FilterQuality.high,
            ),
          );
        }
        final path = args.photoPath;
        if (path != null && path.isNotEmpty) {
          return Center(
            child: Image.file(
              File(path),
              fit: BoxFit.contain,
              gaplessPlayback: true,
              filterQuality: FilterQuality.high,
            ),
          );
        }
        return _coverPlaceholder(Icons.image_not_supported_outlined);
      case ReleaseWorkKind.text:
        return _TextPosterCover(content: posterText);
    }
  }

  Widget _coverPlaceholder(IconData icon) {
    return Center(
      child: Icon(icon, color: Colors.white24, size: 40.sp),
    );
  }
}

/// 文字封面：逻辑 9:16 画布，正文整体缩放以装入外盒（contain）。
class _TextPosterCover extends StatelessWidget {
  const _TextPosterCover({required this.content});

  final String content;

  @override
  Widget build(BuildContext context) {
    const designW = 360.0;
    final designH = designW / kReleaseTextCoverAspectRatio;
    final c = content.trim();

    return FittedBox(
      fit: BoxFit.contain,
      alignment: Alignment.center,
      child: SizedBox(
        width: designW,
        height: designH,
        child: DecoratedBox(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF2C2C2C), Color(0xFF121212)],
            ),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
            child: c.isEmpty
                ? Center(
                    child: Text(
                      '正文将显示在封面',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.35),
                        fontSize: 15.sp,
                      ),
                    ),
                  )
                : Center(
                    child: Text(
                      c,
                      textAlign: TextAlign.center,
                      maxLines: 22,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontSize: 16.sp,
                        height: 1.35,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

/// 视频首帧在父级比例盒内 [contain]，不变形。
class _VideoFirstFrameContained extends StatefulWidget {
  const _VideoFirstFrameContained({required this.path});

  final String path;

  @override
  State<_VideoFirstFrameContained> createState() => _VideoFirstFrameContainedState();
}

class _VideoFirstFrameContainedState extends State<_VideoFirstFrameContained> {
  VideoPlayerController? _controller;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final f = File(widget.path);
    if (!await f.exists()) {
      if (mounted) setState(() => _failed = true);
      return;
    }
    final c = VideoPlayerController.file(f);
    try {
      await c.initialize();
      if (!mounted) {
        await c.dispose();
        return;
      }
      await c.setLooping(false);
      await c.pause();
      await c.seekTo(Duration.zero);
      setState(() => _controller = c);
    } catch (_) {
      await c.dispose();
      if (mounted) setState(() => _failed = true);
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_failed) {
      return Center(child: Icon(Icons.videocam_off_outlined, color: Colors.white24, size: 40.sp));
    }
    final c = _controller;
    if (c == null || !c.value.isInitialized) {
      return Center(
        child: SizedBox(
          width: 26.r,
          height: 26.r,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: Colors.white.withValues(alpha: 0.5),
          ),
        ),
      );
    }
    final sz = c.value.size;
    if (sz.width <= 0 || sz.height <= 0) {
      return Center(child: VideoPlayer(c));
    }
    return Center(
      child: FittedBox(
        fit: BoxFit.contain,
        child: SizedBox(
          width: sz.width,
          height: sz.height,
          child: VideoPlayer(c),
        ),
      ),
    );
  }
}
