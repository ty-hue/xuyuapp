import 'package:bilbili_project/constants/index.dart';
import 'package:bilbili_project/utils/mineSearchHistoryManager.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';

class SearchPage extends StatefulWidget {
  SearchPage({Key? key}) : super(key: key);

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  @override
  void initState() {
    super.initState();
    mineSearchHistoryManager.init();
    searchHistory = mineSearchHistoryManager.getSearchHistory();
  }

  List<String> searchHistory = [];
  bool isExpanded = false; // 是否展开历史记录，默认折叠只显示两条
  final TextEditingController _searchController = TextEditingController();
  String _searchCategory = ''; // 默认 为空

  // 搜索状态
  final SearchState _searchState = SearchState.idle;

  // 记录搜索关键字方法
  void _recordSearchHistory(String keyword) {
    if (keyword.isNotEmpty) {
      // 检查是否已存在相同的搜索历史
      if (searchHistory.contains(keyword)) {
        // 如果已存在，将其移动到最前面
        searchHistory.remove(keyword);
      }
      setState(() {
        searchHistory.insert(0, keyword);
        mineSearchHistoryManager.setSearchHistory(searchHistory);
      });
    }
  }

  // 搜索历史 item
  Widget _buildSearchHistoryItem(String history) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () {
                _recordSearchHistory(history);
                mineSearchHistoryManager.setSearchHistory(searchHistory);
                _searchController.text = history;
                // 失去焦点
                FocusScope.of(context).unfocus();
              },
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(
                    FontAwesomeIcons.history,
                    size: 16.0.sp,
                    color: Colors.grey,
                  ),
                  SizedBox(width: 10.w),
                  Text(
                    history,
                    style: TextStyle(fontSize: 16.0.sp, color: Colors.white),
                  ),
                ],
              ),
            ),
          ),

          GestureDetector(
            onTap: () {
              setState(() {
                searchHistory.remove(history);
                mineSearchHistoryManager.setSearchHistory(searchHistory);
              });
            },
            child: Icon(
              FontAwesomeIcons.close,
              size: 16.0.w,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  // 搜索范围item
  Widget _buildSearchScopeItem({
    required String scope,
    required IconData icon,
    required String category,
    required Function() onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        alignment: Alignment.center,
        height: 10.h,
        padding: EdgeInsets.symmetric(vertical: 5.h, horizontal: 10.w),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(
            color: category == _searchCategory
                ? Color.fromRGBO(253, 211, 63, 1)
                : Color.fromRGBO(64, 66, 75, 1),
            width: 1.w,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 爱心图标
            Icon(
              icon,
              size: 15.0.w,
              color: category == _searchCategory
                  ? Color.fromRGBO(253, 211, 63, 1)
                  : Colors.white,
            ),
            SizedBox(width: 8.w),
            Text(
              scope,
              style: TextStyle(
                fontSize: 14.0.sp,
                color: category == _searchCategory
                    ? Color.fromRGBO(253, 211, 63, 1)
                    : Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

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
                        controller: _searchController,
                        onFieldSubmitted: (value) {
                          _recordSearchHistory(value);
                        },
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
              onTap: () {
                if (_searchController.text.isNotEmpty) {
                  _recordSearchHistory(_searchController.text);
                }
              },
              child: Container(
                width: 40.0.w,
                alignment: Alignment.center,
                child: Text(
                  '搜索',
                  style: TextStyle(fontSize: 16.0.sp, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildHistory() {
    return List.generate(
      searchHistory.length,
      (index) => _buildSearchHistoryItem(searchHistory[index]),
    );
  }

  // get 搜索历史
  List<Widget> get _currentSearchHistory {
    if (searchHistory.length <= 2) {
      return _buildHistory();
    }
    if (isExpanded) {
      return _buildHistory();
    }
    return [..._buildHistory().sublist(0, 2)];
  }

  // 是否显示 清除全部搜索历史按钮
  Widget get _showClearAll {
    if (searchHistory.length > 2 && isExpanded) {
      return GestureDetector(
        onTap: () {
          setState(() {
            searchHistory.clear();
            isExpanded = false;
            mineSearchHistoryManager.removeSearchHistory();
          });
        },
        child: Text(
          '清除全部搜索历史',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 14.0.sp, color: Colors.grey),
        ),
      );
    }
    if (searchHistory.length > 2 && !isExpanded) {
      return GestureDetector(
        onTap: () {
          setState(() {
            isExpanded = true;
          });
        },
        child: Text(
          '全部搜索记录',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 14.0.sp, color: Colors.grey),
        ),
      );
    }
    return Container();
  }

  @override
  Widget build(BuildContext context) {
    double statusBarHeight = MediaQuery.of(context).padding.top;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Color.fromRGBO(22, 24, 35, 1), // Android
        statusBarIconBrightness: Brightness.light, // Android 图标白色
        statusBarBrightness: Brightness.dark, // iOS 白字
      ),
      child: SafeArea(
        top: false,
        child: Scaffold(
          extendBodyBehindAppBar: true,
          appBar: _buildNavBar(statusBarHeight),
          body: Container(
            height: double.infinity,
            color: Color.fromRGBO(22, 24, 35, 1),
            padding: EdgeInsets.only(
              left: 26.w,
              right: 26.w,
              bottom: 0.h,
              top: statusBarHeight + 46.h + 20.h,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Column(
                  children: searchHistory.isNotEmpty
                      ? [
                          ListView(
                            padding: EdgeInsets.zero,
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            children: _currentSearchHistory,
                          ),
                          SizedBox(height: 10.h),
                          _showClearAll,

                          SizedBox(height: 20.h),
                          Divider(
                            height: 1.h,
                            color: Colors.white.withOpacity(0.2),
                          ),
                          SizedBox(height: 28.h),
                        ]
                      : [],
                ),
                Container(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        '选择搜索范围',
                        style: TextStyle(
                          fontSize: 16.0.sp,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 20.h),
                      GridView.count(
                        padding: EdgeInsets.zero,
                        mainAxisSpacing: 20.w,
                        crossAxisSpacing: 20.w,
                        childAspectRatio: 3.0,
                        crossAxisCount: 3,
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        children: [
                          _buildSearchScopeItem(
                            category: '0',
                            scope: '喜欢',
                            icon: FontAwesomeIcons.heart,
                            onTap: () {
                              setState(() {
                                _searchCategory = '0';
                              });
                            },
                          ),
                          _buildSearchScopeItem(
                            category: '1',
                            scope: '收藏',
                            icon: FontAwesomeIcons.bookmark,
                            onTap: () {
                              setState(() {
                                _searchCategory = '1';
                              });
                            },
                          ),
                          _buildSearchScopeItem(
                            category: '2',
                            scope: '作品',
                            icon: FontAwesomeIcons.video,
                            onTap: () {
                              setState(() {
                                _searchCategory = '2';
                              });
                            },
                          ),
                          _buildSearchScopeItem(
                            category: '3',
                            scope: '私密',
                            icon: FontAwesomeIcons.lock,
                            onTap: () {
                              setState(() {
                                _searchCategory = '3';
                              });
                            },
                          ),
                          _buildSearchScopeItem(
                            category: '4',
                            scope: '观看历史',
                            icon: FontAwesomeIcons.history,
                            onTap: () {
                              setState(() {
                                _searchCategory = '4';
                              });
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
