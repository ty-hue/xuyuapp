import 'package:bilbili_project/viewmodels/Create/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class BeautyfiterSheetSekeleton extends StatefulWidget {
  final int initSelectedIndex;
  final ValueChanged<int> onSelectedIndexChanged;
  final bool flag;
  final String title;
  final List<BeautyItem> beautyItems;
  final Function(BeautyItem, double, bool) setBeautyOptions;
  final Function(bool) resetBeautyOptions;
  BeautyfiterSheetSekeleton({
    Key? key,
    required this.title,
    required this.beautyItems,
    required this.setBeautyOptions,
    required this.resetBeautyOptions,
    required this.flag,
    this.initSelectedIndex = -1,
    required this.onSelectedIndexChanged,
  }) : super(key: key);

  @override
  _BeautyfiterSheetSekeletonState createState() =>
      _BeautyfiterSheetSekeletonState();
}

class _BeautyfiterSheetSekeletonState extends State<BeautyfiterSheetSekeleton> {
  double _progressValue = 0.0; // 进度条的值
  late int selectedIndex; // 选中的索引
  @override
  void initState() {
    super.initState();
    selectedIndex = widget.initSelectedIndex;
    if (selectedIndex != -1) {
      setState(() {
      _progressValue = widget.beautyItems[selectedIndex].value * 100.0;
    });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16.0.r)),
      child: Container(
        padding: EdgeInsets.only(
          left: 24.0.w,
          right: 24.0.w,
          top: 12.0.h,
          bottom: 44.0.h,
        ),
        color: Color.fromRGBO(25, 25, 25, 1),
        child: Column(
          spacing: 20.0.h,
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: 40.0.h,
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
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        widget.resetBeautyOptions(widget.flag);
                        setState(() {
                          selectedIndex = -1;
                        });
                      },
                      child: Row(
                        spacing: 4.0.w,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.refresh,
                            color: Colors.white,
                            size: 24.0.sp,
                          ),
                          Text(
                            '重置',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14.0.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // 美颜滤镜公用的滑动条
            selectedIndex != 0 && selectedIndex != -1
                ? Material(
                    color: Colors.transparent,
                    child: Slider(
                      activeColor: Color.fromRGBO(254, 44, 85, 1),
                      inactiveColor: Color.fromRGBO(222, 184, 159, 1),
                      thumbColor: Colors.white,
                      value: _progressValue,
                      min: 0,
                      max: 100,
                      divisions: 100, // 👈 必须加
                      label: _progressValue.round().toString(), // 👈 加这个
                      onChanged: (value) {
                        setState(() {
                          _progressValue = value;
                          widget.setBeautyOptions(
                            widget.beautyItems[selectedIndex],
                            value / 100,
                            widget.flag,
                          );
                        });
                      },
                    ),
                  )
                : Container(),
            SizedBox(
              width: double.infinity,
              height: 100.0.h,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: widget.beautyItems.length,
                shrinkWrap: true,
                separatorBuilder: (context, index) {
                  return SizedBox(width: 12.w); // 间距
                },
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedIndex = index;
                        widget.onSelectedIndexChanged(index);
                        if (widget.beautyItems[index].type != null) {
                          print('${widget.beautyItems[index].type}- ${widget.beautyItems[index].value}');
                          _progressValue =
                              widget.beautyItems[index].value * 100;
                        } else {
                          _progressValue = 0.0;
                          widget.setBeautyOptions(
                            widget.beautyItems[index],
                            0.0,
                            widget.flag,
                          );
                        }
                      });
                    },
                    child: Column(
                      spacing: 4.0.h,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(16.0.r),
                          child: Container(
                            width: 65.0.w,
                            height: 65.0.h,
                            decoration: BoxDecoration(
                              color: Color.fromRGBO(58, 57, 58, 1),
                            ),
                            alignment: Alignment.center,
                            child: widget.beautyItems[index].type != null
                                ? Image.asset(
                                    widget.beautyItems[index].icon,
                                    fit: BoxFit.fill,
                                  )
                                : Icon(
                                    FontAwesomeIcons.ban,
                                    color: Color.fromRGBO(143, 141, 142, 1),
                                    size: 36.0.sp,
                                  ),
                          ),
                        ),
                        Text(
                          widget.beautyItems[index].title,
                          style: TextStyle(
                            color: selectedIndex == index
                                ? Colors.white
                                : Color.fromRGBO(58, 57, 58, 1),
                            fontSize: 14.0.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        widget.beautyItems[index].type != null
                            ? Container(
                                width: 4.0.w,
                                height: 4.0.h,
                                decoration: BoxDecoration(
                                  color: selectedIndex == index
                                      ? Colors.white
                                      : Color.fromRGBO(58, 57, 58, 1),
                                  shape: BoxShape.circle,
                                ),
                              )
                            : SizedBox.shrink(),
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
