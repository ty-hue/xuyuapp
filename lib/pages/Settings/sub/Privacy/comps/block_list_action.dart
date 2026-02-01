import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class BlockListAction extends StatefulWidget {
  BlockListAction({Key? key}) : super(key: key);

  @override
  State<BlockListAction> createState() => _BlockListActionState();
}

class _BlockListActionState extends State<BlockListAction> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.r),
        color: Color.fromRGBO(29, 31, 43, 1),
      ),
      child: ListView.builder(
        itemCount: 10,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              // 去他人主页
              print('去他人主页');
            },
            child: Container(
              padding: EdgeInsets.only(left: 16.w),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ClipOval(
                    child: Image.network(
                      'https://img2.baidu.com/it/u=3763202793,1627758777&fm=253&fmt=auto&app=138&f=JPEG?w=500&h=500',
                      fit: BoxFit.cover,
                      width: 50.w,
                      height: 50.h,
                    ),
                  ),

                  SizedBox(width: 12.w),
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.only(
                        top: 20.h,
                        bottom: 20.h,
                        right: 16.w,
                      ),
                      decoration: BoxDecoration(
                        // 底部边框
                        border: Border(
                          bottom: BorderSide(
                            color: Color.fromRGBO(44, 47, 62, 1),
                            width: 1.w,
                          ),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,

                        children: [
                          Expanded(
                            child: Column(
                              spacing: 2.h,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Felixly',
                                  style: TextStyle(
                                    color: Color.fromRGBO(255, 255, 255, 1),
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w500,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Text(
                                  '直播时间上午八点到晚上12点，直播时间上午八点到晚上12点，',
                                  style: TextStyle(
                                    color: Color.fromRGBO(128, 132, 144, 1),
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w400,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: 20.w),
                          SizedBox(
                            height: 36.h,
                            width: 120.w,
                            child: ElevatedButton(
                              onPressed: () {
                                // 解除拉黑
                                print('解除拉黑');
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color.fromRGBO(62, 65, 74, 1),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.r),
                                ),
                              ),
                              child: Text(
                                '解除拉黑',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
