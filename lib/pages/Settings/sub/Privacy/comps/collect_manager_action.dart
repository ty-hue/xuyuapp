import 'package:bilbili_project/components/with_switch_list_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CollectManagerAction extends StatefulWidget {
  CollectManagerAction({Key? key}) : super(key: key);

  @override
  State<CollectManagerAction> createState() => _CollectManagerActionState();
}

class _CollectManagerActionState extends State<CollectManagerAction> {
  bool isPrivateVideo = false;
  bool isPrivateMusic = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          '关闭后，该收藏列表会设为私密',
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.w600,
            color: Colors.grey,
          ),
        ),
        SizedBox(height: 12.h),
        ClipRRect(
          borderRadius: BorderRadius.circular(8.r),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              WithSwitchListItem(
                title: '视频',
                value: isPrivateVideo,
                onChanged: (value) {
                  setState(() {
                    isPrivateVideo = value;
                  });
                },
              ),
              WithSwitchListItem(
                isNeedUnderline: false,
                title: '音乐',
                value: isPrivateMusic,
                onChanged: (value) {
                  setState(() {
                    isPrivateMusic = value;
                  });
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}
