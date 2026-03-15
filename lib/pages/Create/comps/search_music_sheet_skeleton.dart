import 'package:bilbili_project/components/custom_input.dart';
import 'package:bilbili_project/components/loading.dart';
import 'package:bilbili_project/constants/index.dart';
import 'package:bilbili_project/pages/Create/comps/history_trash.dart';
import 'package:bilbili_project/pages/Create/comps/search_music_list_item.dart';
import 'package:bilbili_project/pages/Create/comps/search_music_result.dart';
import 'package:bilbili_project/utils/mineSearchHistoryManager.dart';
import 'package:bilbili_project/viewmodels/Create/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SearchMusicSheetSkeleton extends StatefulWidget {
  SearchMusicSheetSkeleton({Key? key}) : super(key: key);

  @override
  _SearchMusicSheetSkeletonState createState() =>
      _SearchMusicSheetSkeletonState();
}

class _SearchMusicSheetSkeletonState extends State<SearchMusicSheetSkeleton> {
  String keyword = '';
  int selectIndex = -1;
  // 改变选中项
  Future<void> changeSelectIndex(int index) async {
    setState(() {
      selectIndex = index;
    });
  }

  PlayStatus playStatus = PlayStatus.normal;
  // 改变播放状态
  Future<void> changePlayStatus(PlayStatus status) async {
    setState(() {
      playStatus = status;
    });
  }

  // 吸顶组件
  Widget _buildTabBarWidget() {
    return Container(
      // 给吸顶组件加背景色，避免和下方内容重叠
      color: Colors.white,
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Text.rich(
        style: TextStyle(
          fontSize: 23.sp,
          fontWeight: FontWeight.bold,
          fontStyle: FontStyle.italic,
        ),
        TextSpan(
          text: '猜',
          style: TextStyle(color: Color.fromRGBO(255, 95, 48, 1)),
          children: [
            TextSpan(
              text: '你',
              style: TextStyle(color: Color.fromRGBO(254, 71, 64, 1)),
              children: [
                TextSpan(
                  text: '喜',
                  style: TextStyle(color: Color.fromRGBO(254, 48, 78, 1)),
                  children: [
                    TextSpan(
                      text: '欢',
                      style: TextStyle(color: Color.fromRGBO(254, 48, 78, 1)),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  List<String> searchHistory = [];
  bool isExpanded = false; // 是否展开历史记录，默认折叠只显示两条
  final TextEditingController _searchController = TextEditingController();
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
    setState(() {
      _searchState = SearchState.searching;
    });
    await Future.delayed(Duration(seconds: 3));
    // 作废请求的关键步骤
    if (!mounted || currentToken != _searchToken) {
      return;
    }
    setState(() {
      _searchState = SearchState.searchComplete;
    });
  }

  // 传递给搜索结果组件的搜索方法
  Future<void> _searchMusic() async {
    await Future.delayed(Duration(seconds: 3));
  }

  late MineSearchHistoryManager musicSearchHistoryManager;
  @override
  void initState() {
    super.initState();
    // 初始化搜索历史
    musicSearchHistoryManager = MineSearchHistoryManager(
      searchKey: GlobalConstants.MUSIC_SEARCH_HISTORY_KEY,
    );
    musicSearchHistoryManager.init().then((value) {
      setState(() {
        searchHistory = musicSearchHistoryManager.getSearchHistory();
      });
    });
  }

  Widget get contentUI {
    if (_searchState == SearchState.searchComplete) {
      return SearchMusicResult(
        searchResult: searchResult,
        search: _searchMusic,
      );
    }
    if (_searchState == SearchState.idle) {
      return CustomScrollView(
        physics: const ClampingScrollPhysics(), // 去掉滚动回弹，体验更自然
        slivers: [
          // 吸顶前的占位内容（滚动这段内容后，吸顶组件就会固定）
          SliverToBoxAdapter(
            child: HistoryTrash(
              musicSearchHistoryManager: musicSearchHistoryManager,
              searchHistory: searchHistory,
              isExpanded: isExpanded,
              toggleExpanded: (bool val) {
                setState(() {
                  isExpanded = val;
                });
              },
              updateSearchHistory:
                  ({String history = '', required EditSearchHistory editType}) {
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
              searchController: _searchController,
              searchData: _search,
            ),
          ), // 模拟搜索栏下方的内容高度
          // 核心：吸顶组件（滚动到搜索栏下边缘时固定）
          SliverPersistentHeader(
            pinned: true, // 必须为true，实现吸顶
            floating: false,
            delegate: _TabBarHeaderDelegate(
              tabBarWidget: _buildTabBarWidget(),
              height: 50.h, // 吸顶组件的高度
            ),
          ),
          // 吸顶后的列表内容
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => SearchMusicListItem(
                selfIndex: index,
                selectIndex: selectIndex,
                playStatus: playStatus,
                changeSelectIndex: changeSelectIndex,
                changePlayStatus: changePlayStatus,
              ),
              childCount: 50, // 模拟 50 个列表项
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              alignment: Alignment.center,
              height: 40.h,
              child: Text(
                '暂时没有更多了',
                style: TextStyle(color: Colors.grey, fontSize: 14.sp),
              ),
            ), // 模拟搜索栏下方的内容高度
          ),
        ],
      );
    }
      return Center(child: FetchLoadingView());
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.all(Radius.circular(16.r)),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.9,
        padding: EdgeInsets.only(
          left: 16.w,
          right: 16.w,
          top: 24.h,
          bottom: 0.h,
        ),
        color: Colors.white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 搜索栏（固定在顶部，不随滚动动）
            SizedBox(
              height: 46.h,
              child: Row(
                spacing: 12.w,
                children: [
                  GestureDetector(
                    onTap: () {
                      if(_searchState == SearchState.searchComplete || _searchState == SearchState.searching){
                        setState(() {
                          _searchToken++;
                          _searchState = SearchState.idle;
                        });
                        return;
                      }
                      Navigator.pop(context);
                    },
                    child: Icon(
                      Icons.arrow_back_ios,
                      color: Color.fromRGBO(24, 26, 37, 1),
                      size: 24.sp,
                    ),
                  ),
                  Expanded(
                    child: CustomInputView(
                      controller: _searchController, // 控制器
                      onFieldSubmitted: (value) {
                        _recordSearchHistory(value);
                      },
                      prefixIcon: Icon(
                        Icons.search,
                        size: 24.0.sp,
                        color: Colors.grey,
                      ),
                      hintText: '搜索歌名',
                      cursorColor: Color.fromRGBO(169, 169, 173, 1),
                      cursorWidth: 2.w,
                      cursorRadius: 12.r,
                      textStyle: TextStyle(
                        color: Colors.black,
                        fontSize: 16.sp,
                      ),
                      hintStyle: TextStyle(color: Colors.grey, fontSize: 16.sp),
                      onChanged: (value) {
                        setState(() {
                          keyword = value;
                        });
                      },
                    ),
                  ),
                  GestureDetector(
                    onTap: () async {
                      if (_searchController.text.isNotEmpty) {
                        _recordSearchHistory(_searchController.text);
                        // 失去焦点
                        FocusScope.of(context).unfocus();
                        musicSearchHistoryManager.setSearchHistory(
                          searchHistory,
                        );
                        await _search();
                        setState(() {});
                      }
                    },
                    child: Text(
                      '搜索',
                      style: TextStyle(
                        color: Color.fromRGBO(24, 26, 37, 1),
                        fontSize: 16.sp,
                        letterSpacing: 2.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // 可滚动区域（包含吸顶组件）
            Expanded(child: contentUI),
          ],
        ),
      ),
    );
  }
}

// 吸顶代理类（优化版）
class _TabBarHeaderDelegate extends SliverPersistentHeaderDelegate {
  final Widget tabBarWidget;
  final double height; // 吸顶组件的高度

  _TabBarHeaderDelegate({required this.tabBarWidget, required this.height});

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    // 固定吸顶组件的高度，确保吸顶后位置稳定
    return Container(
      color: Colors.white,
      alignment: Alignment.centerLeft,
      height: height,
      child: tabBarWidget,
    );
  }

  // 吸顶组件的最大/最小高度（保持一致，避免伸缩）
  @override
  double get maxExtent => height;

  @override
  double get minExtent => height;

  // 只有当子组件变化时才重建
  @override
  bool shouldRebuild(covariant _TabBarHeaderDelegate oldDelegate) {
    return oldDelegate.tabBarWidget != tabBarWidget ||
        oldDelegate.height != height;
  }
}
