/// 从写文字 / 写长文进入模板预览路由前由 [TextTemplatePreviewNav.setPending] 写入。
enum TextPreviewSourceMode {
  shortText,
  longArticle,
}

class TextTemplatePreviewArgs {
  TextTemplatePreviewArgs({
    required this.mode,
    this.shortText = '',
    this.longTitle = '',
    this.longBody = '',
  });

  final TextPreviewSourceMode mode;
  final String shortText;
  final String longTitle;
  final String longBody;

  String get overlayPrimaryText {
    if (mode == TextPreviewSourceMode.shortText) {
      return shortText.trim();
    }
    final t = longTitle.trim();
    final b = longBody.trim();
    if (t.isEmpty) return b;
    if (b.isEmpty) return t;
    return '$t\n\n$b';
  }

  String get releaseDescription {
    if (mode == TextPreviewSourceMode.shortText) return shortText.trim();
    final t = longTitle.trim();
    final b = longBody.trim();
    if (b.isEmpty) return t;
    if (t.isEmpty) return b;
    return b;
  }

  String get releaseTitle {
    if (mode == TextPreviewSourceMode.longArticle) {
      return longTitle.trim();
    }
    return '';
  }
}

class TextTemplatePreviewNav {
  static TextTemplatePreviewArgs? _pending;
  static TextTemplatePreviewArgs? _consumed;

  static void setPending(TextTemplatePreviewArgs args) {
    _consumed = null;
    _pending = args;
  }

  static TextTemplatePreviewArgs readOnce() {
    if (_consumed != null) return _consumed!;
    final a = _pending ??
        TextTemplatePreviewArgs(mode: TextPreviewSourceMode.shortText, shortText: '');
    _pending = null;
    _consumed = a;
    return a;
  }

  static void reset() {
    _consumed = null;
    _pending = null;
  }
}
