import 'package:bilbili_project/components/select_sheet_skeleton.dart';
import 'package:bilbili_project/components/with_switch_list_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class PrivateMessageAction extends StatefulWidget {
  PrivateMessageAction({Key? key}) : super(key: key);

  @override
  State<PrivateMessageAction> createState() => _PrivateMessageActionState();
}

class _PrivateMessageActionState extends State<PrivateMessageAction> {
  bool isShowMsgDetail = false;
  String _privateMessageValue = '0';
  final List<Map<String, String>> _privateMessageOptions = [
    {'value': '0', 'title': '全部', 'subTitle': ''},
    {'value': '1', 'title': '我关注的人', 'subTitle': ''},
    {'value': '2', 'title': '互相关注的人', 'subTitle': ''},
    {'value': '3', 'title': '我的朋友', 'subTitle': ''},
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
          label: '谁可以私信我',
          value: _privateMessageValue,
          onChanged: (value) {
            setState(() {
              _privateMessageValue = value;
            });
          },
          items: _privateMessageOptions,
        ),
        SizedBox(height: 30.h),
        ClipRRect(
          borderRadius: BorderRadius.circular(8.r),
          child: WithSwitchListItem(
            isNeedUnderline: false,
            title: '私信通知显示消息详情',
            value: isShowMsgDetail,
            onChanged: (value) {
              setState(() {
                isShowMsgDetail = value;
              });
            },
          ),
        ),
      ],
    );
  }
}
