import 'package:bilbili_project/pages/Create/sub/TextTemplatePreview/text_template_preview_args.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

enum _WriteMode { shortText, longArticle }

class TextView extends StatefulWidget {
  const TextView({
    super.key,
    /// 父级在 [TextView] 之下、仍占屏幕最底区域的高度（如创作页底部 Tab 栏）。
    /// 键盘的 [MediaQuery.viewInsets] 从屏幕底边算起，需减去这段高度，底部工具栏才会贴在键盘上缘。
    this.belowSiblingHeight = 0,
  });

  final double belowSiblingHeight;

  @override
  State<TextView> createState() => _TextViewState();
}

class _TextViewState extends State<TextView> {
  static const Color _bgBlack = Color(0xFF000000);
  static const Color _cardGrey = Color(0xFF1C1C1C);
  /// 「下一步」激活态：略提高亮度与饱和度，避免在深色底上发灰发闷。
  static const Color _accentButton = Color(0xFFD32F2F);
  static const Color _hintGrey = Color(0xFF8A8A8A);
  static const Color _nextDisabledBg = Color.fromRGBO(55, 55, 55, 0.72);
  static const Color _nextDisabledFg = Color.fromRGBO(255, 255, 255, 0.38);

  final TextEditingController _shortController = TextEditingController();
  final FocusNode _shortFocus = FocusNode();

  final TextEditingController _longTitleController = TextEditingController();
  final TextEditingController _longBodyController = TextEditingController();
  final FocusNode _longTitleFocus = FocusNode();
  final FocusNode _longBodyFocus = FocusNode();

  _WriteMode _mode = _WriteMode.shortText;

  @override
  void initState() {
    super.initState();
    _shortFocus.addListener(_onShortFocusChanged);
    _longTitleFocus.addListener(_onLongFocusChanged);
    _longBodyFocus.addListener(_onLongFocusChanged);
    _shortController.addListener(() => setState(() {}));
    _longTitleController.addListener(() => setState(() {}));
    _longBodyController.addListener(() => setState(() {}));
  }

  void _onShortFocusChanged() => setState(() {});

  void _onLongFocusChanged() => setState(() {});

  @override
  void dispose() {
    _shortFocus.removeListener(_onShortFocusChanged);
    _longTitleFocus.removeListener(_onLongFocusChanged);
    _longBodyFocus.removeListener(_onLongFocusChanged);
    _shortFocus.dispose();
    _longTitleFocus.dispose();
    _longBodyFocus.dispose();
    _shortController.dispose();
    _longTitleController.dispose();
    _longBodyController.dispose();
    super.dispose();
  }

  TextEditingController get _activeLongField {
    if (_longBodyFocus.hasFocus) return _longBodyController;
    if (_longTitleFocus.hasFocus) return _longTitleController;
    return _longBodyController;
  }

  /// 长文底部工具栏字数：正文聚焦显示正文字数，否则标题聚焦显示标题字数。
  int get _longToolbarCharCount {
    if (_longBodyFocus.hasFocus) return _longBodyController.text.characters.length;
    if (_longTitleFocus.hasFocus) return _longTitleController.text.characters.length;
    return 0;
  }

  /// 写文字：任意非空内容即可激活「下一步」。
  bool get _shortNextEnabled => _shortController.text.characters.isNotEmpty;

  /// 写长文：标题至少 2 字且正文至少 100 字。
  bool get _longNextEnabled =>
      _longTitleController.text.characters.length >= 2 &&
      _longBodyController.text.characters.length >= 100;

  /// 顶部「下一步」是否可点（随当前模式与输入内容变化）。
  bool get _topNextEnabled =>
      _mode == _WriteMode.shortText ? _shortNextEnabled : _longNextEnabled;

  TextStyle _shortBaseStyle(BuildContext context) {
    return TextStyle(
      fontSize: 22.sp,
      height: 1.35,
      color: Colors.white,
      fontWeight: FontWeight.w400,
    );
  }

  double _measureHeight(
    BuildContext context,
    String text,
    double fontSize,
    double maxWidth,
    TextStyle baseStyle,
  ) {
    if (text.isEmpty) return 0;
    final painter = TextPainter(
      text: TextSpan(
        text: text,
        style: baseStyle.copyWith(fontSize: fontSize),
      ),
      textDirection: Directionality.of(context),
      textScaler: MediaQuery.textScalerOf(context),
      maxLines: null,
    )..layout(maxWidth: maxWidth);
    return painter.height;
  }

  /// 在 [minFont, maxFont] 内取最大字号，使多行文本高度不超过 [maxHeight]。
  double _fitFontSizeForBox({
    required BuildContext context,
    required String text,
    required double maxWidth,
    required double maxHeight,
    required TextStyle baseStyle,
    required double minFont,
    required double maxFont,
  }) {
    if (text.isEmpty) return maxFont;
    if (_measureHeight(context, text, maxFont, maxWidth, baseStyle) <= maxHeight) {
      return maxFont;
    }
    var low = minFont;
    var high = maxFont;
    for (var i = 0; i < 28; i++) {
      final mid = (low + high) / 2;
      final h = _measureHeight(context, text, mid, maxWidth, baseStyle);
      if (h <= maxHeight) {
        low = mid;
      } else {
        high = mid;
      }
    }
    return low.clamp(minFont, maxFont);
  }

  void _insertAtShortSelection(String chunk) {
    final v = _shortController.value;
    final t = v.text;
    final s = v.selection;
    final start = s.start >= 0 ? s.start : t.length;
    final end = s.end >= 0 ? s.end : t.length;
    final newText = t.replaceRange(start, end, chunk);
    final newOffset = start + chunk.length;
    _shortController.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: newOffset),
    );
  }

  void _insertLongAtCursor(String chunk) {
    final c = _activeLongField;
    final v = c.value;
    final t = v.text;
    final s = v.selection;
    final start = s.start >= 0 ? s.start : t.length;
    final end = s.end >= 0 ? s.end : t.length;
    final newText = t.replaceRange(start, end, chunk);
    final newOffset = start + chunk.length;
    c.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: newOffset),
    );
  }

  void _openTextTemplatePreview() {
    FocusScope.of(context).unfocus();
    TextTemplatePreviewNav.setPending(
      TextTemplatePreviewArgs(
        mode: _mode == _WriteMode.shortText
            ? TextPreviewSourceMode.shortText
            : TextPreviewSourceMode.longArticle,
        shortText: _shortController.text,
        longTitle: _longTitleController.text,
        longBody: _longBodyController.text,
      ),
    );
    context.push('/create/text_template_preview');
  }

  void _longWrapMarkdown(String left, String right) {
    final c = _activeLongField;
    final t = c.text;
    final s = c.selection;
    var start = s.start >= 0 ? s.start : t.length;
    var end = s.end >= 0 ? s.end : t.length;
    if (end < start) {
      final tmp = start;
      start = end;
      end = tmp;
    }
    if (start == end) {
      final ins = '$left$right';
      final newText = t.replaceRange(start, end, ins);
      c.value = TextEditingValue(
        text: newText,
        selection: TextSelection.collapsed(offset: start + left.length),
      );
    } else {
      final sel = t.substring(start, end);
      final newText = t.replaceRange(start, end, '$left$sel$right');
      c.value = TextEditingValue(
        text: newText,
        selection: TextSelection.collapsed(offset: start + left.length + sel.length + right.length),
      );
    }
  }

  void _longInsertLinePrefix(String prefix) {
    final c = _activeLongField;
    final t = c.text;
    final pos = c.selection.baseOffset.clamp(0, t.length);
    final lineStart = t.lastIndexOf('\n', pos > 0 ? pos - 1 : 0) + 1;
    final newText = t.replaceRange(lineStart, lineStart, prefix);
    c.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: pos + prefix.length),
    );
  }

  Future<void> _longPickImage() async {
    final x = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (!mounted || x == null) return;
    final escaped = x.path.replaceAll('\\', '/').replaceAll(')', '%29');
    _insertLongAtCursor('\n![]($escaped)\n');
  }

  Widget _topBar(BuildContext context) {
    // 左右同宽占位，中间 tabs 相对整条顶栏（可视宽度）水平居中。
    final double sideSlot = 100.w;
    // 写文字：顶部「下一步」始终显示。写长文：标题或正文聚焦时显示顶部「下一步」（不依赖 viewInsets，避免键盘未推 inset 时不显示）。
    final longEditing = _longTitleFocus.hasFocus || _longBodyFocus.hasFocus;
    final showTopNext =
        _mode == _WriteMode.shortText || (_mode == _WriteMode.longArticle && longEditing);
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 8.h),
      child: Row(
        children: [
          SizedBox(
            width: sideSlot,
            child: Align(
              alignment: Alignment.centerLeft,
              child: IconButton(
                padding: EdgeInsets.zero,
                constraints: BoxConstraints.tightFor(width: 44.w, height: 44.h),
                icon: Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20.sp),
                onPressed: () {
                  if (Navigator.of(context).canPop()) {
                    Navigator.of(context).maybePop();
                  }
                },
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _tabLabel('写文字', _mode == _WriteMode.shortText, () {
                    setState(() => _mode = _WriteMode.shortText);
                    _longTitleFocus.unfocus();
                    _longBodyFocus.unfocus();
                  }),
                  SizedBox(width: 28.w),
                  _tabLabel('写长文', _mode == _WriteMode.longArticle, () {
                    setState(() => _mode = _WriteMode.longArticle);
                    _shortFocus.unfocus();
                  }),
                ],
              ),
            ),
          ),
          SizedBox(
            width: sideSlot,
            child: Align(
              alignment: Alignment.centerRight,
              child: showTopNext
                  ? TextButton(
                      style: TextButton.styleFrom(
                        backgroundColor: _accentButton,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: _nextDisabledBg,
                        disabledForegroundColor: _nextDisabledFg,
                        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6.r),
                        ),
                      ),
                      onPressed: _topNextEnabled ? _openTextTemplatePreview : null,
                      child: Text('下一步', style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500)),
                    )
                  : const SizedBox.shrink(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _tabLabel(String label, bool selected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w500,
              color: selected ? Colors.white : _hintGrey,
            ),
          ),
          SizedBox(height: 6.h),
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: 3.h,
            width: selected ? 40.w : 0,
            decoration: BoxDecoration(
              color: selected ? Colors.white : Colors.transparent,
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),
        ],
      ),
    );
  }

  Widget _shortTextBody(BuildContext context) {
    final horizontalPad = 18.w;
    final verticalPad = 20.h;
    final quotePaddingTop = 8.h;
    final quotePaddingLeft = 8.w;

    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 8.h),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final innerW = (constraints.maxWidth - horizontalPad * 2).clamp(40.0, double.infinity);
          final innerH = (constraints.maxHeight - verticalPad * 2).clamp(40.0, double.infinity);

          final base = _shortBaseStyle(context);
          final maxFont = 22.sp;
          final minFont = 11.sp;
          final content = _shortController.text;
          final fontSize = _fitFontSizeForBox(
            context: context,
            text: content,
            maxWidth: innerW,
            maxHeight: innerH,
            baseStyle: base,
            minFont: minFont,
            maxFont: maxFont,
          );

          final hintSize = content.isEmpty ? maxFont : fontSize;

          return DecoratedBox(
            decoration: BoxDecoration(
              color: _cardGrey,
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16.r),
              child: Stack(
                children: [
                  Positioned(
                    top: quotePaddingTop,
                    left: quotePaddingLeft,
                    child: IgnorePointer(
                      child: Text(
                        '“',
                        style: TextStyle(
                          fontSize: 72.sp,
                          height: 1,
                          color: Colors.white.withValues(alpha: 0.06),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  Positioned.fill(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(
                        horizontalPad,
                        verticalPad,
                        horizontalPad,
                        verticalPad,
                      ),
                      child: TextField(
                        controller: _shortController,
                        focusNode: _shortFocus,
                        expands: true,
                        maxLines: null,
                        minLines: null,
                        textAlignVertical: TextAlignVertical.top,
                        keyboardType: TextInputType.multiline,
                        cursorColor: Colors.red,
                        cursorWidth: 2,
                        style: base.copyWith(fontSize: fontSize),
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                          hintText: '分享你的想法',
                          hintStyle: base.copyWith(
                            fontSize: hintSize,
                            color: _hintGrey,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _longArticleBody(BuildContext context) {
    final titleStyle = TextStyle(
      fontSize: 22.sp,
      height: 1.3,
      color: Colors.white,
      fontWeight: FontWeight.w500,
    );
    final bodyStyle = TextStyle(
      fontSize: 16.sp,
      height: 1.45,
      color: Colors.white,
    );

    // 写长文：未聚焦标题/正文时显示底部「下一步」；聚焦编辑时在顶部显示「下一步」。
    final longEditing = _longTitleFocus.hasFocus || _longBodyFocus.hasFocus;
    final showBottomNext = !longEditing;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 0),
          child: TextField(
            controller: _longTitleController,
            focusNode: _longTitleFocus,
            style: titleStyle,
            cursorColor: Colors.red,
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: '输入标题: 2-30个字',
              hintStyle: titleStyle.copyWith(color: Colors.white.withValues(alpha: 0.85)),
            ),
          ),
        ),
        Expanded(
          child: Padding(
            padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 12.h),
            child: TextField(
              controller: _longBodyController,
              focusNode: _longBodyFocus,
              expands: true,
              maxLines: null,
              minLines: null,
              textAlignVertical: TextAlignVertical.top,
              keyboardType: TextInputType.multiline,
              style: bodyStyle,
              cursorColor: Colors.red,
              decoration: InputDecoration(
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
                hintText: '发表你的想法，内容将自动保存',
                hintStyle: bodyStyle.copyWith(color: _hintGrey),
              ),
            ),
          ),
        ),
        if (showBottomNext)
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 12.h + MediaQuery.paddingOf(context).bottom),
            child: SizedBox(
              width: double.infinity,
              height: 48.h,
              child: TextButton(
                style: TextButton.styleFrom(
                  backgroundColor: _accentButton,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: _nextDisabledBg,
                  disabledForegroundColor: _nextDisabledFg,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6.r),
                  ),
                ),
                onPressed: _longNextEnabled ? _openTextTemplatePreview : null,
                child: Text('下一步', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600)),
              ),
            ),
          ),
      ],
    );
  }

  static const double _accessoryBarHeight = 36;

  Widget _keyboardAccessoryKeyButton(String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: SizedBox(
        width: 44,
        height: _accessoryBarHeight,
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: Colors.white,
              fontSize: 18.sp,
              fontWeight: label == '#' ? FontWeight.w700 : FontWeight.w500,
              height: 1,
            ),
          ),
        ),
      ),
    );
  }

  Widget _keyboardAccessory(BuildContext context) {
    // 放在 SafeArea 外（见 build），与根 Material 同宽，贴齐屏幕左右无间隙。
    return SizedBox(
      width: double.infinity,
      height: _accessoryBarHeight,
      child: Material(
        color: const Color(0xFF121212),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _keyboardAccessoryKeyButton('@', () => _insertAtShortSelection('@')),
            _keyboardAccessoryKeyButton('#', () => _insertAtShortSelection('#')),
            const Spacer(),
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 0),
                alignment: Alignment.center,
              ),
              onPressed: () => FocusScope.of(context).unfocus(),
              child: Text(
                '完成',
                style: TextStyle(fontSize: 15.sp, height: 1),
              ),
            ),
            SizedBox(width: 4.w),
          ],
        ),
      ),
    );
  }

  static const double _longAccessoryBarHeight = 40;

  Widget _longToolbarTap({required VoidCallback onTap, required Widget child}) {
    return InkWell(
      onTap: onTap,
      child: SizedBox(
        width: 40,
        height: _longAccessoryBarHeight,
        child: Center(child: child),
      ),
    );
  }

  Widget _keyboardAccessoryLong(BuildContext context) {
    final countStyle = TextStyle(
      color: Colors.white.withValues(alpha: 0.75),
      fontSize: 14.sp,
      height: 1,
    );
    return SizedBox(
      width: double.infinity,
      height: _longAccessoryBarHeight,
      child: Material(
        color: const Color(0xFF121212),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.only(left: 4.w),
                child: Row(
                  children: [
                    _longToolbarTap(
                      onTap: () => _longWrapMarkdown('**', '**'),
                      child: Text(
                        'B',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 17.sp,
                          fontWeight: FontWeight.w700,
                          height: 1,
                        ),
                      ),
                    ),
                    _longToolbarTap(
                      onTap: () => _longWrapMarkdown('*', '*'),
                      child: Text(
                        'I',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 17.sp,
                          fontStyle: FontStyle.italic,
                          fontWeight: FontWeight.w500,
                          height: 1,
                        ),
                      ),
                    ),
                    _longToolbarTap(
                      onTap: () => _longInsertLinePrefix('> '),
                      child: Icon(Icons.format_quote, color: Colors.white, size: 21.sp),
                    ),
                    _longToolbarTap(
                      onTap: () => _longPickImage(),
                      child: Icon(Icons.image_outlined, color: Colors.white, size: 21.sp),
                    ),
                    _longToolbarTap(
                      onTap: () => _longInsertLinePrefix('- '),
                      child: Icon(Icons.format_list_bulleted, color: Colors.white, size: 21.sp),
                    ),
                    _longToolbarTap(
                      onTap: () => _insertLongAtCursor('## '),
                      child: Text(
                        'T',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 17.sp,
                          fontWeight: FontWeight.w600,
                          height: 1,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Text('$_longToolbarCharCount 字', style: countStyle),
            SizedBox(width: 6.w),
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 0),
              ),
              onPressed: () => FocusScope.of(context).unfocus(),
              child: Text('收起', style: TextStyle(fontSize: 15.sp, height: 1)),
            ),
            SizedBox(width: 6.w),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final kbRaw = MediaQuery.viewInsetsOf(context).bottom;
    // 键盘 inset 相对整屏底边；本组件底边已在「下方 sibling」之上，只垫起真正压到编辑区的部分。
    final kbInset = (kbRaw - widget.belowSiblingHeight).clamp(0.0, double.infinity);
    return Padding(
      padding: EdgeInsets.only(bottom: kbInset),
      child: Material(
        color: _bgBlack,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: SafeArea(
                top: true,
                bottom: false,
                left: false,
                right: false,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _topBar(context),
                    Expanded(
                      child: _mode == _WriteMode.shortText
                          ? _shortTextBody(context)
                          : _longArticleBody(context),
                    ),
                  ],
                ),
              ),
            ),
            if (_mode == _WriteMode.shortText && _shortFocus.hasFocus) _keyboardAccessory(context),
            if (_mode == _WriteMode.longArticle &&
                (_longTitleFocus.hasFocus || _longBodyFocus.hasFocus))
              _keyboardAccessoryLong(context),
          ],
        ),
      ),
    );
  }
}
