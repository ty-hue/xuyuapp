import 'package:bilbili_project/components/select_sheet_skeleton.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class WorkShowAction extends StatefulWidget {
  WorkShowAction({Key? key}) : super(key: key);

  @override
  State<WorkShowAction> createState() => _WorkShowActionState();
}

class _WorkShowActionState extends State<WorkShowAction> {
  String _privateMessageValue = '0';
  final List<Map<String, String>> _privateMessageOptions = [
    {'value': '0', 'title': '三列', 'subTitle': '三列展示出封面信息，利于快速查看'},
    {'value': '1', 'title': '双列', 'subTitle': '双列展示出标题和封面，利于他人筛选'},
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
          label: '作品视图',
          value: _privateMessageValue,
          onChanged: (value) {
            setState(() {
              _privateMessageValue = value;
            });
          },
          items: _privateMessageOptions,
        ),
      ],
    );
  }
}
