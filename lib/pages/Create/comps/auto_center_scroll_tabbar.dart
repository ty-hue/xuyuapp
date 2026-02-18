import 'package:flutter/material.dart';

class AutoCenterScrollTabBar extends StatefulWidget {
  final List<String> tabs;
  final int initialIndex;
  final ValueChanged<int> onChanged;
  final TextStyle activeStyle;
  final TextStyle inactiveStyle;
  final EdgeInsets itemPadding;
  final double itemSpacing;
  final Duration animationDuration;
  final Curve animationCurve;
  final double highlightHeight;
  final Color highlightColor;

  const AutoCenterScrollTabBar({
    super.key,
    required this.tabs,
    required this.onChanged,
    this.initialIndex = 0,
    this.itemPadding = const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    this.itemSpacing = 8,
    this.animationDuration = const Duration(milliseconds: 300),
    this.animationCurve = Curves.easeOut,
    this.highlightHeight = 40.0,
    this.highlightColor = Colors.white,
    this.activeStyle = const TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.bold,
      color: Colors.black,
      decoration: TextDecoration.none,
    ),
    this.inactiveStyle = const TextStyle(
      fontSize: 14,
      color: Colors.grey,
      decoration: TextDecoration.none,
    ),
  });

  @override
  State<AutoCenterScrollTabBar> createState() => _AutoCenterScrollTabBarState();
}

class _AutoCenterScrollTabBarState extends State<AutoCenterScrollTabBar> {
  final ScrollController _controller = ScrollController();
  final List<GlobalKey> _itemKeys = [];

  int _currentIndex = 0;
  double _viewportWidth = 0;
  double _highlightWidth = 0;
  bool _isAutoScrolling = false;
  Offset? _dragStart;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _itemKeys.addAll(List.generate(widget.tabs.length, (_) => GlobalKey()));

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _updateHighlightWidth();
      await _scrollToIndex(_currentIndex, jump: true);
      setState(() {});
    });
  }

  double _getItemCenterX(int index) {
    final scrollBox =
        _controller.position.context.storageContext.findRenderObject()
            as RenderBox;
    final itemBox =
        _itemKeys[index].currentContext!.findRenderObject() as RenderBox;

    final scrollGlobal = scrollBox.localToGlobal(Offset.zero);
    final itemGlobal = itemBox.localToGlobal(Offset.zero);

    return (itemGlobal.dx - scrollGlobal.dx) + itemBox.size.width / 2;
  }

  void _updateHighlightWidth() {
    final box =
        _itemKeys[_currentIndex].currentContext!.findRenderObject()
            as RenderBox;
    _highlightWidth = box.size.width + 24;
  }

  Future<void> _scrollToIndex(int index, {bool jump = false}) async {
    if (!_controller.hasClients) return;
    _isAutoScrolling = true;

    final screenCenter = _viewportWidth / 2;
    final itemCenter = _getItemCenterX(index);

    double targetOffset = _controller.offset + (itemCenter - screenCenter);

    // clamp 目标偏移量，避免出现多余滚动
    double contentWidth = 0;
    for (var key in _itemKeys) {
      final box = key.currentContext?.findRenderObject() as RenderBox?;
      if (box != null) contentWidth += box.size.width + widget.itemSpacing;
    }
    if (contentWidth > 0) contentWidth -= widget.itemSpacing;
    final maxOffset = (contentWidth + _viewportWidth) - _viewportWidth;
    targetOffset = targetOffset.clamp(0, maxOffset);

    if (jump) {
      _controller.jumpTo(targetOffset);
    } else {
      await _controller.animateTo(
        targetOffset,
        duration: widget.animationDuration,
        curve: widget.animationCurve,
      );
    }

    _isAutoScrolling = false;
  }

  void _onDragEnd(DragEndDetails details) {
    if (_dragStart == null) return;

    final velocity = details.velocity.pixelsPerSecond.dx;
    int newIndex = _currentIndex;

    if (velocity < -50) {
      // 向左滑动 → 下一个 tab
      if (_currentIndex < widget.tabs.length - 1) newIndex++;
    } else if (velocity > 50) {
      // 向右滑动 → 上一个 tab
      if (_currentIndex > 0) newIndex--;
    }

    if (newIndex != _currentIndex) {
      setState(() => _currentIndex = newIndex);
      widget.onChanged(newIndex);
      _updateHighlightWidth();
      _scrollToIndex(newIndex);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.highlightHeight,
      child: LayoutBuilder(
        builder: (context, constraints) {
          _viewportWidth = constraints.maxWidth;

          return GestureDetector(
            onHorizontalDragStart: (details) {
              _dragStart = details.globalPosition;
            },
            onHorizontalDragEnd: _onDragEnd,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // 高亮容器
                AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeOut,
                  width: _highlightWidth,
                  height: widget.highlightHeight,
                  decoration: BoxDecoration(
                    color: widget.highlightColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                SingleChildScrollView(
                  controller: _controller,
                  scrollDirection: Axis.horizontal,
                  physics: const NeverScrollableScrollPhysics(), // 手势自己处理
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(width: _viewportWidth / 2),
                      ...List.generate(widget.tabs.length, (index) {
                        final isActive = index == _currentIndex;
                        return Padding(
                          padding: EdgeInsets.only(right: widget.itemSpacing),
                          child: GestureDetector(
                            onTap: () {
                              if (_currentIndex != index) {
                                setState(() => _currentIndex = index);
                                widget.onChanged(index);
                                _updateHighlightWidth();
                                _scrollToIndex(index);
                              }
                            },
                            child: Container(
                              key: _itemKeys[index],
                              padding: widget.itemPadding,
                              alignment: Alignment.center,
                              child: Text(
                                widget.tabs[index],
                                style: isActive
                                    ? widget.activeStyle
                                    : widget.inactiveStyle,
                              ),
                            ),
                          ),
                        );
                      }),
                      SizedBox(width: _viewportWidth / 2),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
