import 'package:bilbili_project/components/default_dialog_skeleton.dart';
import 'package:bilbili_project/utils/DialogUtils.dart';
import 'package:bilbili_project/utils/mineSearchHistoryManager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

enum EditSearchHistory { add, remove, clear }

class HistoryTrash extends StatefulWidget {
  final List<String> searchHistory;
  final bool isExpanded;
  final Function(bool) toggleExpanded; // 切换是否展开搜索历史
  final Function({String history, required EditSearchHistory editType})
  updateSearchHistory; // 用于操作搜索历史List
  final TextEditingController searchController; // 搜索框控制器
  final Future<void> Function() searchData; // 搜索数据方法
  final MineSearchHistoryManager musicSearchHistoryManager;
  HistoryTrash({
    Key? key,
    required this.searchHistory,
    required this.isExpanded,
    required this.toggleExpanded,
    required this.updateSearchHistory,
    required this.searchController, // 搜索框控制器
    required this.searchData, // 搜索数据方法
    required this.musicSearchHistoryManager,
  }) : super(key: key);

  @override
  State<HistoryTrash> createState() => _HistoryTrashState();
}

class _HistoryTrashState extends State<HistoryTrash> {
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
                widget.musicSearchHistoryManager.setSearchHistory(widget.searchHistory);
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
                    style: TextStyle(fontSize: 16.0.sp, color: Colors.grey),
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
                widget.musicSearchHistoryManager.setSearchHistory(widget.searchHistory);
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
          DialogUtils(
            DefaultDialgSkeleton(
              rightBtnText: "清除",
              onRightBtnTap: () {
                setState(() {
                  widget.updateSearchHistory(editType: EditSearchHistory.clear);
                  widget.toggleExpanded(false);
                  widget.musicSearchHistoryManager.removeSearchHistory();
                });
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
                    Divider(height: 1.h, color: Colors.grey.withOpacity(0.4)),
                    SizedBox(height: 28.h),
                  ]
                : [],
          ),
        ],
      ),
    );
  }
}
