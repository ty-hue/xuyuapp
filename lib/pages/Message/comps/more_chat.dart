import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MoreChat extends StatefulWidget {
  MoreChat({Key? key}) : super(key: key);

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

          itemBuilder: (context, index) {
            return Material(
              color: Colors.white,
              child: InkWell(
                splashColor: Colors.black.withValues(alpha: 0.06),
                highlightColor: Colors.black.withValues(alpha: 0.04),
                onTap: () {
                  print('点击了用户$index');
                },
                child: Padding(
                  padding: EdgeInsets.only(
                    top: index == 0 ? 0 : 6.h,
                    bottom: 6.h,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            ClipOval(
                              child: Image.network(
                                'https://wx4.sinaimg.cn/mw690/70e1e519ly1i9xgh6g04ej20sg0sggsj.jpg',
                                width: 62.w,
                                height: 62.h,
                                fit: BoxFit.cover,
                              ),
                            ),
                            SizedBox(width: 10.w),
                            Expanded(
                              child: Text(
                                '用户昵称xxxxxxxxxxxxxxxxxxxxxxxxxxxx',
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  color: Colors.black,
                                  overflow: TextOverflow.ellipsis,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 1,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 14.w),
                      SizedBox(
                        width: 100.w,
                        height: 36.h,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color.fromRGBO(243, 243, 244, 1),
                            foregroundColor: Colors.black,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6.r),
                            ),
                          ),
                          onPressed: () {
                            print('点击了发消息');
                          },
                          child: Text(
                            '发私信',
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
          separatorBuilder: (context, index) => const SizedBox.shrink(),
          itemCount: 10,
        ),
      ],
    );
  }
}
