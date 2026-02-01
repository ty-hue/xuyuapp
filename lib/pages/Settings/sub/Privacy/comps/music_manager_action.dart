import 'package:bilbili_project/components/select_sheet_skeleton.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MusicManagerAction extends StatefulWidget {
  MusicManagerAction({Key? key}) : super(key: key);

  @override
  State<MusicManagerAction> createState() => _MusicManagerActionState();
}

class _MusicManagerActionState extends State<MusicManagerAction> {
  String _musicManagerValue = '0';
  final List<Map<String, String>> _musicManagerOptions = [
    {'value': '0', 'title': '公开可见', 'subTitle': ''},
    {'value': '1', 'title': '仅对自己可见', 'subTitle': '收藏的音乐仅对自己可见'},
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
          label: '我收藏的音乐',
          value: _musicManagerValue,
          onChanged: (value) {
            setState(() {
              _musicManagerValue = value;
            });
          },
          items: _musicManagerOptions,
        ),
      ],
    );
  }
}
