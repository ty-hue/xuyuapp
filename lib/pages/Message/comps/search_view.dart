import 'package:bilbili_project/components/custom_input.dart';
import 'package:bilbili_project/components/with_statusBar_color.dart';
import 'package:bilbili_project/pages/Message/comps/more_chat.dart';
import 'package:bilbili_project/pages/Message/comps/search_history.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SearchView extends StatefulWidget {
  final Function() cancelSearch;
  SearchView({Key? key, required this.cancelSearch}) : super(key: key);

  @override
  _SearchViewState createState() => _SearchViewState();
}

class _SearchViewState extends State<SearchView> {
  final TextEditingController _searchController = TextEditingController();
  // 处理输入事件
  void _onChanged(String value) {
    setState(() {
      _searchController.text = value;
    });
  }

  // 自定义navbar
  PreferredSizeWidget _buildNavBar(double statusBarHeight) {
    final double appBarTotalHeight = statusBarHeight + 46.h;
    return PreferredSize(
      preferredSize: Size.fromHeight(appBarTotalHeight),
      child: Container(
        color: Colors.transparent,
        margin: EdgeInsets.only(top: statusBarHeight + 6.h),
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        height: 44.h,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              flex: 1,
              child: Container(
                alignment: Alignment.center,
                child: Form(
                  child: CustomInputView(
                    controller: _searchController,
                    hintText: '搜索联系人、群聊或聊天记录',
                    fillColor: Color.fromRGBO(243, 243, 245, 1),
                    // 与 hint 字号一致，避免行高按 18 与 14 不一致导致前缀图标与文字难对齐
                    textStyle: TextStyle(
                      fontSize: 14.sp,
                      height: 1.2,
                      color: Colors.black,
                    ),
                    hintStyle: TextStyle(
                      color: Color.fromRGBO(186, 186, 189, 1),
                      fontSize: 14.sp,
                      height: 1.2,
                    ),
                    onChanged: (value) {
                      // 处理输入事件
                      _onChanged(value);
                    },
                  ),
                ),
              ),
            ),
            SizedBox(width: 10.w),
            GestureDetector(
              onTap: () async {
                widget.cancelSearch();
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    '取消',
                    style: TextStyle(fontSize: 14.0.sp, color: Colors.black),
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
      statusBarColor: Colors.transparent,
      child: Scaffold(
        appBar: _buildNavBar(MediaQuery.of(context).padding.top),
        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
          child: SingleChildScrollView(
            child: _searchController.text.isEmpty
                ? Column(spacing: 20.h, children: [SearchHistory(), MoreChat()])
                : Container(color: Colors.red),
          ),
        ),
      ),
    );
  }
}
