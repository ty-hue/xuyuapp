import 'package:bilbili_project/components/custom_input.dart';
import 'package:bilbili_project/components/with_statusBar_color.dart';
import 'package:bilbili_project/pages/Home/comps/contact_list_item.dart';
import 'package:bilbili_project/pages/Home/comps/contact_name_filter.dart';
import 'package:bilbili_project/pages/Message/comps/more_chat.dart';
import 'package:bilbili_project/pages/Message/comps/search_history.dart';
import 'package:bilbili_project/routes/app_router.dart';
import 'package:bilbili_project/utils/message_search_recent_storage.dart';
import 'package:bilbili_project/viewmodels/Message/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SearchView extends StatefulWidget {
  final Function() cancelSearch;
  final List<ContactItem> searchResult;
  SearchView({Key? key, required this.cancelSearch, required this.searchResult})
      : super(key: key);

  @override
  _SearchViewState createState() => _SearchViewState();
}

class _SearchViewState extends State<SearchView> {
  final TextEditingController _searchController = TextEditingController();
  List<ContactItem> _recentContacts = [];

  @override
  void initState() {
    super.initState();
    _loadRecentContacts();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadRecentContacts() async {
    final list = await MessageSearchRecentStorage.load();
    if (!mounted) return;
    setState(() {
      _recentContacts = list;
    });
  }

  Future<void> _clearRecentSearches() async {
    await MessageSearchRecentStorage.clear();
    if (!mounted) return;
    setState(() {
      _recentContacts = [];
    });
  }

  Future<void> _recordRecentContact(ContactItem contact) async {
    await MessageSearchRecentStorage.add(contact);
    await _loadRecentContacts();
  }

  void _onSearchTextChanged(String _) {
    setState(() {});
  }

  List<ContactItem> get _filteredContacts => filterContactsByName(
        widget.searchResult,
        _searchController.text,
      );

  bool get _hasSearchQuery => _searchController.text.trim().isNotEmpty;

  Future<void> _onSearchResultContactTap(ContactItem contact) async {
    if (_hasSearchQuery) {
      await _recordRecentContact(contact);
    }
    if (!mounted) return;
    ChatRoute().push(context);
  }

  void _onHistoryContactTap(ContactItem contact) {
    ChatRoute().push(context);
  }

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
                    onChanged: _onSearchTextChanged,
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

  Widget _buildSearchResultsPanel() {
    final list = _filteredContacts;
    if (list.isEmpty) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 32.h),
        child: Center(
          child: Text(
            '无匹配结果',
            style: TextStyle(
              fontSize: 14.sp,
              color: Color.fromRGBO(186, 186, 189, 1),
            ),
          ),
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '联系人',
          style: TextStyle(
            fontSize: 14.sp,
            color: Color.fromRGBO(166, 166, 166, 1),
          ),
        ),
        SizedBox(height: 12.h),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: list.length,
          separatorBuilder: (_, _) => const SizedBox.shrink(),
          itemBuilder: (context, index) {
            final item = list[index];
            return GestureDetector(
              onTap: () => _onSearchResultContactTap(item),
              child: ContactListItem(
                padding: EdgeInsets.symmetric(vertical: 20.h),
                decoration: BoxDecoration(
                  border: Border.all(width: 0, color: Colors.transparent),
                ),
                contactItem: item,
                leading: CircleAvatar(
                  radius: 30.r,
                  backgroundColor: Color.fromRGBO(243, 243, 244, 1),
                  backgroundImage: NetworkImage(item.avatar),
                ),
                trailing: SizedBox(
                  width: 80.w,
                  height: 32.h,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color.fromRGBO(253, 44, 85, 1),
                    ),
                    onPressed: () => _onSearchResultContactTap(item),
                    child: Text(
                      '发私信',
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ],
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
            child: !_hasSearchQuery
                ? Column(
                    spacing: 20.h,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SearchHistory(
                        recentContacts: _recentContacts,
                        onClearAllConfirmed: _clearRecentSearches,
                        onHistoryItemTap: _onHistoryContactTap,
                      ),
                      MoreChat(searchResult: widget.searchResult),
                    ],
                  )
                : _buildSearchResultsPanel(),
          ),
        ),
      ),
    );
  }
}
