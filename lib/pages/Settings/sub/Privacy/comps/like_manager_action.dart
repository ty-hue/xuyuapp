import 'package:bilbili_project/components/select_sheet_skeleton.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class LikeManagerAction extends StatefulWidget {
  LikeManagerAction({Key? key}) : super(key: key);

  @override
  State<LikeManagerAction> createState() => _LikeManagerActionState();
}

class _LikeManagerActionState extends State<LikeManagerAction> {
  String _likeManagerValue = '0';
  final List<Map<String, String>> _likeManagerOptions = [
    {'value': '0', 'title': '公开可见', 'subTitle': ''},
    {'value': '1', 'title': '私密', 'subTitle': '仅自己可见'},
  ];
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SelectSheetSkeleton(
          itemTitleColor: Colors.white,
          itemIconColor: Color.fromRGBO(244, 52, 106, 1),
          innerBoxColor: Color.fromRGBO(29, 31, 43, 1),
          itemHeight: 54.h,
          borderRadius: Radius.circular(0.r),
          backgroundColor: Colors.transparent,
          outBoxPadding: EdgeInsets.zero,
          immediatelyClose: false,
          label: '主页喜欢列表',
          value: _likeManagerValue,
          onChanged: (value) {
            setState(() {
              _likeManagerValue = value;
            });
          },
          items: _likeManagerOptions,
        ),
      ],
    );
  }
}
