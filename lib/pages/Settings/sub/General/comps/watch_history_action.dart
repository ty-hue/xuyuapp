import 'package:bilbili_project/components/with_switch_list_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class WatchHistoryAction extends StatefulWidget {
  WatchHistoryAction({Key? key}) : super(key: key);

  @override
  _WatchHistoryActionState createState() => _WatchHistoryActionState();
}

class _WatchHistoryActionState extends State<WatchHistoryAction> {
  bool isOpenUserRecord = false;
  bool isOpenVideoRecord = false;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8.r),
          child: WithSwitchListItem(
            height: 130.h,
            title: '用户访问记录',
            isNeedUnderline: false,
            subTitle: '开启后，你可以看见30天内自己曾经访问过的人以及经常访问的人。',
            value: isOpenUserRecord,
            onChanged: (value) {
              setState(() {
                isOpenUserRecord = value;
              });
            },
          ),
        ),
        SizedBox(height: 24.h),
        ClipRRect(
          borderRadius: BorderRadius.circular(8.r),
          child: WithSwitchListItem(
            height: 130.h,
            title: '视频浏览记录',
            isNeedUnderline: false,
            subTitle: '开启后，你可以查看自己浏览过的视频。',
            value: isOpenVideoRecord,
            onChanged: (value) {
              setState(() {
                isOpenVideoRecord = value;
              });
            },
          ),
        ),
      ],
    );
  }
}
