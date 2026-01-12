import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class VisitorSettingSheet extends StatefulWidget {
  final bool initialValue;

  const VisitorSettingSheet({
    required this.initialValue,
  });

  @override
  State<VisitorSettingSheet> createState() => _VisitorSettingSheetState();
}

class _VisitorSettingSheetState extends State<VisitorSettingSheet> {
  late bool _value;

  @override
  void initState() {
    super.initState();
    _value = widget.initialValue;
  }

  @override
  Widget build(BuildContext context) {
    return  ClipRRect(
              borderRadius: BorderRadius.all(Radius.circular(16.r)),
              child: Container(
                height: 380.h,
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
                color: Colors.white,
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        IconButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          icon: Icon(Icons.close, color: Colors.black),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Column(
                          children: [
                            Stack(
                              clipBehavior: Clip.none,
                              children: [
                                Container(
                                  padding: EdgeInsets.all(20.w),
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.black,
                                      width: 2.w,
                                    ),
                                  ),
                                  child: Icon(
                                    FontAwesomeIcons.userGroup,
                                    size: 40.r,
                                  ),
                                ),
                                Positioned(
                                  bottom: 0,
                                  right: -18.w,
                                  child: Container(
                                    width: 40.w,
                                    height: 40.h,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Color.fromRGBO(254, 44, 85, 1),
                                      border: Border.all(
                                        color: Colors.white,
                                        width: 4.w,
                                      ),
                                    ),
                                    // 我需要 运算符减 的 图标
                                    child: Icon(
                                      FontAwesomeIcons.minus,
                                      size: 24.r,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 20.h),
                            Text(
                              '主页访客',
                              style: TextStyle(
                                fontSize: 18.sp,
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 20.h),
                            SizedBox(
                              width: MediaQuery.of(context).size.width - 40.w,
                              child: Text(
                                '关闭后，你查看他人主页时不会留下记录，同时，你也无法查看谁访问了你的主页。',
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  color: Colors.grey,
                                ),
                                textAlign: TextAlign.center,
                                softWrap: true,
                              ),
                            ),
                            SizedBox(height: 20.h),
                            Container(
                              width: MediaQuery.of(context).size.width - 40.w,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '展示主页访客',
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      color: Colors.black,
                                    ),
                                  ),
                                  Switch(
                                    value: _value,
                                    onChanged: (value) {
                                      // 切换开关状态
                                      setState(() {
                                        _value = value;
                                      });
                                      // 关闭弹窗
                                      Navigator.pop(context, value);
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
  }
}
