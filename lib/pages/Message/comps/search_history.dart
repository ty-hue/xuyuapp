import 'package:bilbili_project/components/default_dialog_skeleton.dart';
import 'package:bilbili_project/viewmodels/Message/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SearchHistory extends StatelessWidget {
  final List<ContactItem> recentContacts;
  final Future<void> Function() onClearAllConfirmed;
  final void Function(ContactItem contact) onHistoryItemTap;

  const SearchHistory({
    Key? key,
    required this.recentContacts,
    required this.onClearAllConfirmed,
    required this.onHistoryItemTap,
  }) : super(key: key);

  void _showClearDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.zero,
          child: DefaultDialgSkeleton(
            leftBtnText: '取消',
            rightBtnText: '确定',
            onLeftBtnTap: () => Navigator.pop(dialogContext),
            onRightBtnTap: () async {
              Navigator.pop(dialogContext);
              await onClearAllConfirmed();
            },
            child: Container(
              width: 250.w,
              alignment: Alignment.center,
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 20.h),
              child: Text(
                '历史记录清除后无法恢复，是否清除全部记录',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color.fromRGBO(34, 35, 46, 1),
                  fontSize: 14.sp,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      spacing: 20.h,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '最近搜索',
              style: TextStyle(
                fontSize: 14.sp,
                color: Color.fromRGBO(166, 166, 166, 1),
              ),
            ),
            if (recentContacts.isNotEmpty)
              GestureDetector(
                onTap: () => _showClearDialog(context),
                child: Text(
                  '清空',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Color.fromRGBO(166, 166, 166, 1),
                  ),
                ),
              ),
          ],
        ),
        if (recentContacts.isEmpty)
          Padding(
            padding: EdgeInsets.only(bottom: 8.h),
            child: Text(
              '暂无最近搜索',
              style: TextStyle(
                fontSize: 13.sp,
                color: Color.fromRGBO(186, 186, 189, 1),
              ),
            ),
          )
        else
          SizedBox(
            height: 80.h,
            child: ListView.builder(
              itemCount: recentContacts.length,
              scrollDirection: Axis.horizontal,
              itemBuilder: (context, index) {
                final item = recentContacts[index];
                return Padding(
                  padding: EdgeInsets.only(
                    left: index == 0 ? 0 : 16.w,
                    right: 16.w,
                  ),
                  child: GestureDetector(
                    onTap: () => onHistoryItemTap(item),
                    child: SizedBox(
                      width: 60.w,
                      child: Column(
                        spacing: 4.h,
                        children: [
                          ClipOval(
                            child: Image.network(
                              item.avatar,
                              width: 56.w,
                              height: 56.w,
                              fit: BoxFit.cover,
                              errorBuilder: (_, _, _) => Container(
                                width: 56.w,
                                height: 56.w,
                                color: Color.fromRGBO(243, 243, 244, 1),
                                alignment: Alignment.center,
                                child: Icon(
                                  Icons.person,
                                  size: 28.sp,
                                  color: Color.fromRGBO(186, 186, 189, 1),
                                ),
                              ),
                            ),
                          ),
                          Text(
                            item.name,
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: Colors.black,
                              overflow: TextOverflow.ellipsis,
                            ),
                            maxLines: 1,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}
