import 'package:bilbili_project/components/custom_input.dart';
import 'package:bilbili_project/pages/Home/comps/contact_list_item.dart';
import 'package:bilbili_project/pages/Home/comps/contact_name_filter.dart';
import 'package:bilbili_project/viewmodels/Message/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SelectPartUsersSheetSkeleton extends StatefulWidget {
  final StatusSettingsItemType type;
  final List<ContactItem> users;
  final List<ContactItem> selectedUsers;
  SelectPartUsersSheetSkeleton({
    Key? key,
    required this.type,
    required this.users,
    required this.selectedUsers,
  }) : super(key: key);

  @override
  _SelectPartUsersSheetSkeletonState createState() =>
      _SelectPartUsersSheetSkeletonState();
}

class _SelectPartUsersSheetSkeletonState
    extends State<SelectPartUsersSheetSkeleton> {
  final TextEditingController _searchController = TextEditingController();
  List<ContactItem> selectedContacts = [];

  List<ContactItem> get _filteredUsers => filterContactsByName(
        widget.users,
        _searchController.text,
      );

  bool get _hasSearchQuery => _searchController.text.trim().isNotEmpty;

  void _onSearchTextChanged(String _) {
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    selectedContacts = widget.selectedUsers;
  }

  // 选中用户/取消选中
  void _onSelectedContact(ContactItem contact) {
    if (selectedContacts.contains(contact)) {
      selectedContacts.remove(contact);
    } else {
      selectedContacts.add(contact);
    }
    setState(() {});
  }

  // 完成
  void _onCompleteTap() {
    Navigator.pop(context, selectedContacts);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.all(Radius.circular(16.r)),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.65,
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 24.h),
        decoration: BoxDecoration(color: Color.fromRGBO(243, 243, 244, 1)),
        child: Column(
          spacing: 18.h,
          children: [
            Text(
              widget.type.label,
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: Color.fromRGBO(27, 28, 39, 1),
              ),
            ),
            SizedBox(
              height: 48.h,
              child: CustomInputView(
                prefixIcon: Icon(
                  Icons.search,
                  size: 24.sp,
                  color: Color.fromRGBO(115, 116, 123, 1),
                ),
                hintText: '搜索',
                hintStyle: TextStyle(
                  color: Color.fromRGBO(115, 116, 123, 1),
                  fontSize: 16.sp,
                ),
                onChanged: _onSearchTextChanged,
                controller: _searchController,
              ),
            ),
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16.r),
                child: _hasSearchQuery && _filteredUsers.isEmpty
                    ? Center(
                        child: Text(
                          '无匹配结果',
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: Color.fromRGBO(186, 186, 189, 1),
                          ),
                        ),
                      )
                    : ListView.builder(
                        itemCount: _filteredUsers.length,
                        itemBuilder: (context, index) {
                          final item = _filteredUsers[index];
                          return ContactListItem(
                            contactItem: item,
                            leading: CircleAvatar(
                              radius: 24.r,
                              backgroundColor: Color.fromRGBO(
                                243,
                                243,
                                244,
                                1,
                              ),
                              backgroundImage: NetworkImage(item.avatar),
                            ),
                            trailing: Checkbox(
                              side: BorderSide(
                                color: Color.fromRGBO(188, 188, 188, 1),
                                width: 1.w,
                              ),
                              activeColor: Color.fromRGBO(255, 41, 81, 1),
                              checkColor: Colors.white,
                              value: selectedContacts.contains(item),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.r),
                              ),
                              onChanged: (value) {
                                _onSelectedContact(item);
                              },
                            ),
                          );
                        },
                      ),
              ),
            ),
            SizedBox(
              width: double.infinity,
              height: 48.h,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color.fromRGBO(255, 41, 81, 1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                ),
                onPressed: _onCompleteTap,
                child: Text(
                  '完成(${selectedContacts.length})',
                  style: TextStyle(color: Colors.white, fontSize: 16.sp),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
