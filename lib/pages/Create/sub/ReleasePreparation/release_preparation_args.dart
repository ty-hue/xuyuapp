import 'dart:typed_data';

/// 进入发布准备页前由创作侧写入，页面 [pullPending] 读取一次。
enum ReleaseWorkKind {
  video,
  photo,
  text,
}

/// 将设置里的比例串转为 **宽/高**（用于 [AspectRatio]）。
double releaseCoverAspectRatioFromShoot(String? raw) {
  final s = (raw ?? '9:16').trim();
  if (s == '3:4' || s == '3/4') return 3 / 4;
  return 9 / 16;
}

/// 文字作品封面画布固定 9:16（竖幅）。
const double kReleaseTextCoverAspectRatio = 9 / 16;

class ReleasePreparationArgs {
  ReleasePreparationArgs({
    required this.kind,
    this.videoPath,
    this.photoPath,
    this.photoBytes,
    this.shootAspectRatio,
    this.initialTitle,
    this.initialBody,
  });

  final ReleaseWorkKind kind;
  final String? videoPath;
  final String? photoPath;
  final Uint8List? photoBytes;
  /// 相机设置 `9:16` / `3:4`，用于视频/照片封面外框比例。
  final String? shootAspectRatio;
  /// 进入页时预填正文用（如模板标题 + 描述会合并进输入框）。
  final String? initialTitle;
  final String? initialBody;

  factory ReleasePreparationArgs.video({
    String? path,
    String? shootAspectRatio,
  }) {
    return ReleasePreparationArgs(
      kind: ReleaseWorkKind.video,
      videoPath: path,
      shootAspectRatio: shootAspectRatio,
    );
  }

  factory ReleasePreparationArgs.photo({
    String? path,
    Uint8List? bytes,
    String? shootAspectRatio,
    String? initialTitle,
    String? initialBody,
  }) {
    return ReleasePreparationArgs(
      kind: ReleaseWorkKind.photo,
      photoPath: path,
      photoBytes: bytes,
      shootAspectRatio: shootAspectRatio,
      initialTitle: initialTitle,
      initialBody: initialBody,
    );
  }

  factory ReleasePreparationArgs.text({
    String? title,
    String? body,
  }) {
    return ReleasePreparationArgs(
      kind: ReleaseWorkKind.text,
      initialTitle: title,
      initialBody: body,
    );
  }
}

class ReleasePreparationNav {
  static ReleasePreparationArgs? _pending;

  static void setPending(ReleasePreparationArgs args) {
    _pending = args;
  }

  static ReleasePreparationArgs pullPending() {
    final a = _pending ?? ReleasePreparationArgs.text();
    _pending = null;
    return a;
  }
}
