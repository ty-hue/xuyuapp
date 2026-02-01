import 'package:bilbili_project/pages/Settings/comps/group_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class PrivacyMsgAction extends StatefulWidget {
  PrivacyMsgAction({Key? key}) : super(key: key);

  @override
  _PrivacyMsgActionState createState() => _PrivacyMsgActionState();
}

class _PrivacyMsgActionState extends State<PrivacyMsgAction> {
  bool isOpenPrivacyMsg = false;
  bool isOpenVideoMsg = false;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Column(
          spacing: 8.h,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                GroupItemView(
                  needTrailingIcon: false,
                  attachedWidget: SizedBox(
                    width: 50.w,
                    child: Switch(
                      value: isOpenPrivacyMsg,
                      onChanged: (value) {
                        setState(() {
                          isOpenPrivacyMsg = value;
                        });
                      },
                    ),
                  ),
                  isFirst: true,
                  backgroundColor: Color.fromRGBO(29, 31, 43, 1),
                  itemName: '私信',
                  icon: Icons.message,
                  cb: () {},
                ),
                GroupItemView(
                  needUnderline: false,
                  needTrailingIcon: false,
                  attachedWidget: SizedBox(
                    width: 50.w,
                    child: Switch(
                      value: isOpenVideoMsg,
                      onChanged: (value) {
                        setState(() {
                          isOpenVideoMsg = value;
                        });
                      },
                    ),
                  ),
                  backgroundColor: Color.fromRGBO(29, 31, 43, 1),
                  itemName: '视频',
                  icon: Icons.video_call,
                  cb: () {},
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
