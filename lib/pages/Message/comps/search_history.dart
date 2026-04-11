import 'package:bilbili_project/components/default_dialog_skeleton.dart';
import 'package:bilbili_project/utils/DialogUtils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SearchHistory extends StatefulWidget {
  SearchHistory({Key? key}) : super(key: key);

  @override
  _SearchHistoryState createState() => _SearchHistoryState();
}

class _SearchHistoryState extends State<SearchHistory> {
  // 清空搜索历史
  void _clearSearchHistory() {
     // 弹出dialog
          DialogUtils(
            DefaultDialgSkeleton(
              rightBtnText: "清除",
              onRightBtnTap: () {
                Navigator.pop(context);
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
          ).showCustomDialog(context);
  }
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      spacing: 20.h,
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
            GestureDetector(
              onTap: () {
                _clearSearchHistory();
              },
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
        SizedBox(
          height: 80.h,
          child: ListView.builder(
            itemCount: 6,
            scrollDirection: Axis.horizontal,
            itemBuilder: (context, index) {
              return Padding(
                padding: EdgeInsets.only(
                  left: index == 0 ? 0 : 16.w,
                  right: 16.w,
                ),
                child: GestureDetector(
                  onTap: () {
                    print('点击了用户$index');
                  },
                  child: SizedBox(
                    width: 60.w,
                    child: Column(
                      spacing: 4.h,
                      children: [
                        ClipOval(
                          child: Image.network(
                            'https://wx4.sinaimg.cn/mw690/70e1e519ly1i9xgh6g04ej20sg0sggsj.jpg',
                            width: 56.w,
                            height: 56.w,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Text(
                          '用户昵称xxxxxxxxxx',
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
