import 'package:bilbili_project/components/with_statusBar_color.dart';
import 'package:bilbili_project/pages/Mine/sub/WatchHistory/sub/HistorySearch/comps/default.dart';
import 'package:bilbili_project/pages/Mine/sub/WatchHistory/sub/HistorySearch/comps/result.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';

class HistorySearchPage extends StatefulWidget {
  HistorySearchPage({Key? key}) : super(key: key);

  @override
  State<HistorySearchPage> createState() => _HistorySearchPageState();
}

class _HistorySearchPageState extends State<HistorySearchPage> {
  final TextEditingController _searchController = TextEditingController();
  bool _isShowResult = false;
  // 自定义navbar
  PreferredSizeWidget _buildNavBar(double statusBarHeight) {
    final double appBarTotalHeight = statusBarHeight + 46.h;
    return PreferredSize(
      preferredSize: Size.fromHeight(appBarTotalHeight),
      child: Container(
        color: Color.fromRGBO(22, 24, 35, 1),
        margin: EdgeInsets.only(top: statusBarHeight + 6.h),
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        height: 40.h,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            GestureDetector(
              onTap: () {
                context.pop();
              },
              child: Icon(
                Icons.arrow_back_ios_new,
                color: Colors.white,
                size: 20.0.w,
              ),
            ),
            SizedBox(width: 10.w),
            Expanded(
              flex: 1,
              child: Container(
                alignment: Alignment.center,
                child: Form(
                  child: Stack(
                    children: [
                      TextFormField(
                        autofocus: true,
                        controller: _searchController,
                        onFieldSubmitted: (value) {},
                        validator: (value) {
                          return null;
                        },
                        cursorColor: Color.fromRGBO(209, 176, 40, 1), // 光标颜色
                        cursorWidth: 2.w, // 光标宽度
                        cursorHeight: 20.h, // 光标高度，可选，不设置默认文字高度
                        cursorRadius: Radius.circular(2.r), // 光标圆角
                        style: TextStyle(
                          fontSize: 14.0.sp, // 设置输入文字的大小
                          color: Colors.white, // 设置输入文字的颜色
                          // fontWeight: FontWeight.bold, // 还可以设置粗细等
                        ),
                        decoration: InputDecoration(
                          // 2. 设置提示文字的样式
                          hintStyle: TextStyle(
                            fontSize: 14.0.sp, // 设置提示文字的大小
                            color: Colors.grey[500], // 设置提示文字的颜色
                          ),
                          contentPadding: EdgeInsets.only(
                            left: 40.0.w,
                          ), // 内容内边距
                          hintText: "搜索你赞过的视频",
                          fillColor: Color.fromRGBO(86, 87, 95, 1),
                          filled: true,
                          // ⭐ 圆角无边框
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.r),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.r),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.r),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      Positioned(
                        top: 0,
                        bottom: 0,
                        left: 0,
                        child: GestureDetector(
                          onTap: () {
                            // 处理点击事件
                            setState(() {
                              _isShowResult = true;
                            });
                          },
                          child: Container(
                            width: 40.0.w,
                            alignment: Alignment.center,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Icon(
                                  FontAwesomeIcons.search,
                                  size: 16.0.w,
                                  color: Colors.grey,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(width: 10.w),
            GestureDetector(
              onTap: () async {
                setState(() {
                  _isShowResult = true;
                });
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    '搜索',
                    style: TextStyle(fontSize: 14.0.sp, color: Colors.white),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WithStatusbarColorView(
      statusBarColor: Color.fromRGBO(22, 24, 35, 1),
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: _buildNavBar(MediaQuery.of(context).padding.top),
        body: Container(
          color: Color.fromRGBO(22, 24, 35, 1),
          child: _isShowResult ? HistorySearchResult() : HistorySearchDefault()
        ),
      ),
    );
  }
}
