import 'package:bilbili_project/pages/Home/comps/contact_list_item.dart';
import 'package:bilbili_project/routes/app_router.dart';
import 'package:bilbili_project/viewmodels/Message/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MoreChat extends StatefulWidget {
  final List<ContactItem> searchResult;
  MoreChat({Key? key, required this.searchResult}) : super(key: key);

  @override
  _MoreChatState createState() => _MoreChatState();
}

class _MoreChatState extends State<MoreChat> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      spacing: 20.h,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              '更多聊天',
              style: TextStyle(
                fontSize: 14.sp,
                color: Color.fromRGBO(166, 166, 166, 1),
              ),
            ),
          ],
        ),

        // 外层 SingleChildScrollView 已在竖直方向滚动，ListView 必须 shrinkWrap，
        // 否则在无限高度约束下无法完成布局（RenderBox was not laid out）。
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: widget.searchResult.length,
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () {
                ChatRoute().push(context);
              },
              child: ContactListItem(
                padding: EdgeInsets.symmetric(vertical: 20.h),
                // 无边框
                decoration: BoxDecoration(
                  border: Border.all(width: 0, color: Colors.transparent),
                ),
                contactItem: widget.searchResult[index],
                leading: CircleAvatar(
                  radius: 30.r,
                  backgroundColor: Color.fromRGBO(243, 243, 244, 1),
                  backgroundImage: NetworkImage(
                    widget.searchResult[index].avatar,
                  ),
                ),
                trailing: SizedBox(
                  width: 80.w,
                  height: 32.h,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color.fromRGBO(253, 44, 85, 1),
                    ),
                    onPressed: () {
                      ChatRoute().push(context);
                    },
                    child: Text(
                      '发私信',
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
          separatorBuilder: (context, index) => const SizedBox.shrink(),
        ),
      ],
    );
  }
}
