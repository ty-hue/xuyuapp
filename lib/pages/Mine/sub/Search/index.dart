import 'package:bilbili_project/constants/index.dart';
import 'package:bilbili_project/utils/mineSearchHistoryManager.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'comps/default.dart';
import 'comps/Result/result.dart';

class SearchPage extends StatefulWidget {
  SearchPage({Key? key}) : super(key: key);

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  @override
  void initState() {
    super.initState();
    // 初始化搜索历史
    mineSearchHistoryManager.init();
    searchHistory = mineSearchHistoryManager.getSearchHistory();
  }

  List<String> searchHistory = [];
  bool isExpanded = false; // 是否展开历史记录，默认折叠只显示两条
  final TextEditingController _searchController = TextEditingController();
  String _searchCategory = ''; // 默认 为空

  // 搜索状态
  SearchState _searchState = SearchState.idle;
  // 请求结果
  List<String> searchResult = [];
  // 分页参数
  Map<String, num> pagination = {'page': 1, 'pageSize': 10};
  int _searchToken = 0; // 返回上一个组件时，可能有请求正在进行，这个变量可以用于作废请求

  // 请求方法
  Future<void> _search() async {
    _searchToken++;
    int currentToken = _searchToken;
    _searchCategory == '' ? _searchCategory = '0' : _searchCategory;
    print('category: $_searchCategory');
    print('pagination: $pagination');
    setState(() {
      _searchState = SearchState.searching;
    });
    await Future.delayed(Duration(seconds: 3));
    // 作废请求的关键步骤
    if(!mounted || currentToken != _searchToken){
      return;
    }
    setState(() {
      _searchState = SearchState.searchComplete;
    });
  }

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
      });
    }
  }

  // 清理数据
  void _clearData(){
    setState(() {
      // 作废请求
      _searchToken++;
      _searchState = SearchState.idle;
      _searchController.clear();
      searchResult.clear();
      _searchCategory = '';
      pagination = {'page': 1, 'pageSize': 10};
    });
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
                if (_searchState == SearchState.idle) {
                  context.pop();
                  return;
                }
                _clearData();
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
              onTap: () async {
                if (_searchController.text.isNotEmpty) {
                  _recordSearchHistory(_searchController.text);
                  // 失去焦点
                  FocusScope.of(context).unfocus();
                  mineSearchHistoryManager.setSearchHistory(searchHistory);
                  await _search();
                  setState(() {});
                }
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
          body: _searchState == SearchState.idle
              ? DefaultView(
                  searchData: _search, // 搜索数据方法
                  searchController: _searchController, // 搜索框控制器
                  statusBarHeight: statusBarHeight,
                  searchCategory: _searchCategory,
                  searchHistory: searchHistory,
                  isExpanded: isExpanded,
                  toggleExpanded: (bool val) {
                    setState(() {
                      isExpanded = val;
                    });
                  },
                  changeCategory: (String category) {
                    setState(() {
                      _searchCategory = category;
                    });
                  },
                  updateSearchHistory:
                      ({
                        String history = '',
                        required EditSearchHistory editType,
                      }) {
                        if (history.isEmpty &&
                            editType == EditSearchHistory.clear) {
                          setState(() {
                            searchHistory.clear();
                          });
                        }
                        if (editType == EditSearchHistory.add) {
                          _recordSearchHistory(history);
                        }
                        if (editType == EditSearchHistory.remove) {
                          setState(() {
                            searchHistory.remove(history);
                          });
                        }
                      },
                )
              : ResultView(statusBarHeight: statusBarHeight),
        ),
      ),
    );
  }
}
