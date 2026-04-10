import 'package:bilbili_project/components/cover_with_loading.dart';
import 'package:bilbili_project/components/text_auto_scroll.dart';
import 'package:bilbili_project/viewmodels/Create/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

/// 特效（AR）选择 bottom sheet。
class StickerSheetSekeleton extends StatefulWidget {
  final String title;
  final List<StickerItem> stickerItems;
  final Future<void> Function(int index) onSelectedIndexChanged;
  final int initSelectedIndex;
  final VoidCallback resetStickerIndex;

  StickerSheetSekeleton({
    Key? key,
    required this.title,
    required this.stickerItems,
    required this.onSelectedIndexChanged,
    required this.initSelectedIndex,
    required this.resetStickerIndex,
  }) : super(key: key);

  @override
  _StickerSheetSekeletonState createState() => _StickerSheetSekeletonState();
}

class _StickerSheetSekeletonState extends State<StickerSheetSekeleton> {
  late int selectedIndex;
  int? loadingIndex;

  @override
  void initState() {
    super.initState();
    final init = widget.initSelectedIndex;
    if (init < 0) {
      selectedIndex = -1;
    } else if (init >= widget.stickerItems.length) {
      selectedIndex = 0;
    } else {
      selectedIndex = init;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16.0.r)),
      child: Container(
        color: const Color.fromRGBO(1, 1, 1, 0.8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: 10.0.h,
          children: [
            Container(
              width: double.infinity,
              height: 50.0.h,
              color: const Color.fromRGBO(1, 1, 1, 0.5),
              child: Stack(
                children: [
                  Align(
                    alignment: Alignment.center,
                    child: Text(
                      widget.title,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16.0.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton(
                      onPressed: () {
                        widget.resetStickerIndex();
                        setState(() {
                          selectedIndex = -1;
                        });
                      },
                      child: const Icon(FontAwesomeIcons.ban, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16.0.w),
              height: 210.0.h,
              child: GridView.builder(
                physics: const ClampingScrollPhysics(),
                itemCount: widget.stickerItems.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 5,
                  mainAxisSpacing: 16.0.h,
                  crossAxisSpacing: 16.0.w,
                  childAspectRatio: 0.62,
                ),
                itemBuilder: (context, index) {
                  final item = widget.stickerItems[index];
                  final label = item.label ?? item.name;
                  return GestureDetector(
                    onTap: () async {
                      if (selectedIndex == index) {
                        setState(() {
                          selectedIndex = -1;
                        });
                        await widget.onSelectedIndexChanged(-1);
                      } else {
                        setState(() {
                          selectedIndex = index;
                          loadingIndex = index;
                        });
                        await widget.onSelectedIndexChanged(index);
                        if (mounted) {
                          setState(() {
                            loadingIndex = null;
                          });
                        }
                      }
                    },
                    child: Column(
                      spacing: 4.0.h,
                      children: [
                        Expanded(
                          child: CoverWithLoading(
                            isLoading: loadingIndex == index,
                            isActive: selectedIndex == index,
                            imagePath: item.icon,
                            name: item.name,
                          ),
                        ),
                        SizedBox(
                          height: 36.h,
                          child: Align(
                            alignment: Alignment.center,
                            child: TextAutoScroll(
                              isActive: selectedIndex == index,
                              text: label,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
