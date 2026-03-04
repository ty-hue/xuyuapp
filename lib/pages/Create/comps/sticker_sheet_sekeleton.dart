import 'package:bilbili_project/components/cover_with_loading.dart';
import 'package:bilbili_project/components/text_auto_scroll.dart';
import 'package:bilbili_project/viewmodels/Create/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

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
  late int selectedIndex = 0;
  bool isStickerCoverLoading = false;
  @override
  void initState() {
    super.initState();
    selectedIndex = widget.initSelectedIndex;
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16.0.r)),
      child: Container(
        color: Color.fromRGBO(1, 1, 1, 0.8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: 10.0.h,
          children: [
            Container(
              width: double.infinity,
              height: 50.0.h,
              color: Color.fromRGBO(1, 1, 1, 0.5),
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
                      child: Icon(FontAwesomeIcons.ban, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16.0.w),
              height: 200.0.h,
              child: GridView.builder(
                itemCount: widget.stickerItems.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 5,
                  mainAxisSpacing: 16.0.h,
                  crossAxisSpacing: 16.0.w,
                ),
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () async{
                      if (selectedIndex == index) {
                        setState(() {
                          selectedIndex = -1;
                        });
                        widget.onSelectedIndexChanged(-1);
                      } else {
                        setState(() {
                          selectedIndex = index;
                        });
                        setState(() {
                          isStickerCoverLoading = true;
                        });
                       await widget.onSelectedIndexChanged(index);
                       setState(() {
                        isStickerCoverLoading = false;
                       });
                      }
                    },
                    child: Column(
                      spacing: 4.0.h,
                      children: [
                        Expanded(
                          child: CoverWithLoading(
                            isLoading: isStickerCoverLoading,
                            isActive: selectedIndex == index,
                            imagePath: widget.stickerItems[index].icon,
                          ),
                        ),
                        TextAutoScroll(
                          isActive: selectedIndex == index,
                          text: widget.stickerItems[index].name,
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
