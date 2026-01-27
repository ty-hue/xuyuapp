import 'package:bilbili_project/utils/DialogUtils.dart';
import 'package:bilbili_project/utils/mineSearchHistoryManager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

enum EditSearchHistory { add, remove, clear }

class DefaultView extends StatefulWidget {
  final double statusBarHeight;
  final String searchCategory;
  final List<String> searchHistory;
  final bool isExpanded;
  final Function(bool) toggleExpanded; // 切换是否展开搜索历史
  final Function(String) changeCategory; // 切换搜索范围
  final Function({String history, required EditSearchHistory editType})
  updateSearchHistory; // 用于操作搜索历史List
  final TextEditingController searchController; // 搜索框控制器
  final Future<void> Function() searchData; // 搜索数据方法

  DefaultView({
    Key? key,
    required this.statusBarHeight,
    required this.searchCategory,
    required this.searchHistory,
    required this.isExpanded,
    required this.toggleExpanded,
    required this.changeCategory,
    required this.updateSearchHistory,
    required this.searchController, // 搜索框控制器
    required this.searchData, // 搜索数据方法
  }) : super(key: key);

  @override
  State<DefaultView> createState() => _DefaultViewState();
}

class _DefaultViewState extends State<DefaultView> {
  // get 搜索历史
  List<Widget> get _currentSearchHistory {
    if (widget.searchHistory.length <= 2) {
      return _buildHistory();
    }
    if (widget.isExpanded) {
      return _buildHistory();
    }
    return [..._buildHistory().sublist(0, 2)];
  }

  List<Widget> _buildHistory() {
    return List.generate(
      widget.searchHistory.length,
      (index) => _buildSearchHistoryItem(widget.searchHistory[index]),
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
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(
            color: category == widget.searchCategory
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
              color: category == widget.searchCategory
                  ? Color.fromRGBO(253, 211, 63, 1)
                  : Colors.white,
            ),
            SizedBox(width: 8.w),
            Text(
              scope,
              style: TextStyle(
                fontSize: 14.0.sp,
                color: category == widget.searchCategory
                    ? Color.fromRGBO(253, 211, 63, 1)
                    : Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
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
              onTap: () async {
                widget.updateSearchHistory(
                  history: history,
                  editType: EditSearchHistory.add,
                );
                mineSearchHistoryManager.setSearchHistory(widget.searchHistory);
                widget.searchController.text = history; // 赋值给搜索框控制器
                // 失去焦点
                FocusScope.of(context).unfocus();
                // 搜索数据
                await widget.searchData();
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
                widget.updateSearchHistory(
                  history: history,
                  editType: EditSearchHistory.remove,
                );
                mineSearchHistoryManager.setSearchHistory(widget.searchHistory);
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

  // 是否显示 清除全部搜索历史按钮
  Widget get _showClearAll {
    if (widget.searchHistory.length > 2 && widget.isExpanded) {
      return GestureDetector(
        onTap: () {
          // 弹出dialog
          DialogUtils.showCustomDialog(
            context,
            Builder(
              builder: (context) {
                return Container(
                  width: 200.w,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 20.w),
                        alignment: Alignment.center,
                        height: 100.h,
                        child: Text(
                          '历史记录清除后无法恢复，是否清除全部记录',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Color.fromRGBO(34, 35, 46, 1),
                            fontSize: 14.sp,
                          ),
                        ),
                      ),

                      Container(
                        width: double.infinity,
                        height: 50.h,
                        decoration: BoxDecoration(
                          // 上边框
                          border: Border(
                            top: BorderSide(
                              color: Colors.grey.withOpacity(0.3),
                              width: 1.w,
                            ),
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(
                              child: TextButton(
                                // 矩形按钮 无圆角
                                style: TextButton.styleFrom(
                                  padding: EdgeInsets.zero,
                                  shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.zero,
                                  ),
                                ),
                                onPressed: () => Navigator.pop(context),
                                child: Text(
                                  "取消",
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 15.sp,
                                  ),
                                ),
                              ),
                            ),
                            Container(
                              width: 1.w,
                              height: 30.h,
                              color: Colors.grey.withOpacity(0.3),
                            ),
                            Expanded(
                              child: TextButton(
                                // 矩形按钮 无圆角
                                style: TextButton.styleFrom(
                                  padding: EdgeInsets.zero,
                                  shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.zero,
                                  ),
                                ),
                                onPressed: () {
                                  setState(() {
                                    widget.updateSearchHistory(
                                      editType: EditSearchHistory.clear,
                                    );
                                    widget.toggleExpanded(false);
                                    mineSearchHistoryManager
                                        .removeSearchHistory();
                                  });
                                  Navigator.pop(context);
                                },
                                child: Text(
                                  "清除",
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 15.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        },
        child: Text(
          '清除全部搜索历史',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 14.0.sp, color: Colors.grey),
        ),
      );
    }
    if (widget.searchHistory.length > 2 && !widget.isExpanded) {
      return GestureDetector(
        onTap: () {
          setState(() {
            widget.toggleExpanded(true);
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
    return Container(
      height: double.infinity,
      color: Color.fromRGBO(22, 24, 35, 1),
      padding: EdgeInsets.only(
        left: 26.w,
        right: 26.w,
        bottom: 0.h,
        top: widget.statusBarHeight + 46.h + 20.h,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Column(
            children: widget.searchHistory.isNotEmpty
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
                    Divider(height: 1.h, color: Colors.white.withOpacity(0.2)),
                    SizedBox(height: 28.h),
                  ]
                : [],
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                '选择搜索范围',
                style: TextStyle(fontSize: 16.0.sp, color: Colors.white),
              ),
              SizedBox(height: 20.h),
              GridView.count(
                padding: EdgeInsets.zero,
                mainAxisSpacing: 20.w,
                crossAxisSpacing: 20.h,
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
                        widget.changeCategory('0');
                      });
                    },
                  ),
                  _buildSearchScopeItem(
                    category: '1',
                    scope: '收藏',
                    icon: FontAwesomeIcons.bookmark,
                    onTap: () {
                      setState(() {
                        widget.changeCategory('1');
                      });
                    },
                  ),
                  _buildSearchScopeItem(
                    category: '2',
                    scope: '作品',
                    icon: FontAwesomeIcons.video,
                    onTap: () {
                      setState(() {
                        widget.changeCategory('2');
                      });
                    },
                  ),
                  _buildSearchScopeItem(
                    category: '3',
                    scope: '私密',
                    icon: FontAwesomeIcons.lock,
                    onTap: () {
                      setState(() {
                        widget.changeCategory('3');
                      });
                    },
                  ),
                  _buildSearchScopeItem(
                    category: '4',
                    scope: '观看历史',
                    icon: FontAwesomeIcons.history,
                    onTap: () {
                      setState(() {
                        widget.changeCategory('4');
                      });
                    },
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
