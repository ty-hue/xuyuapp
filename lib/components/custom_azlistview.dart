import 'package:azlistview/azlistview.dart';
import 'package:bilbili_project/components/appBar_back_icon_btn.dart';
import 'package:bilbili_project/components/static_app_bar.dart';
import 'package:bilbili_project/components/with_statusBar_color.dart';
import 'package:bilbili_project/routes/app_router.dart';
import 'package:bilbili_project/viewmodels/EditProfile/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class CustomAzlistview extends StatefulWidget {
  final bool isSelectPhoneMode; // 是否是选择电话前缀模式
  final List<AreaGroup> areaList;
  final Function(AreaItem) onSelect;
  final bool? isCountry;
  CustomAzlistview({
    this.isSelectPhoneMode = false,
    required this.areaList,
    required this.onSelect,
    this.isCountry,
    Key? key,
  }) : super(key: key);

  @override
  State<CustomAzlistview> createState() => _CustomAzlistviewState();
}

class _CustomAzlistviewState extends State<CustomAzlistview> {
  Widget _buildHeaderItem() {
    return Container(
      width: MediaQuery.of(context).size.width,
      padding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          GestureDetector(
            onTap: () {
              EditProfileRoute(dontSettingAddress: true).push(context);
            },
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 20, horizontal: 8),
              // 添加底部边框
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: Colors.white.withOpacity(0.1),
                    width: 0.5,
                  ),
                ),
              ),
              child: Text(
                '暂不设置',
                style: TextStyle(fontSize: 14, color: Colors.white),
              ),
            ),
          ),

          Container(
            padding: EdgeInsets.symmetric(vertical: 20, horizontal: 8),
            // 添加底部边框
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Colors.white.withOpacity(0.1),
                  width: 0.5,
                ),
              ),
            ),
            child: Column(
              spacing: 24,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Text(
                      '其他地区',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
                SizedBox(height: 4),
                GestureDetector(
                  onTap: () {
                    widget.onSelect(
                      AreaItem(
                        code: '1',
                        name: '中国',
                        hasSub: true,
                        groupCn: 'Z',
                        phonePrefix: '+86',
                      ),
                    );
                  },
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 4),
                    child: Text(
                      '中国',
                      style: TextStyle(fontSize: 14, color: Colors.white),
                    ),
                  ),
                ),
                SizedBox(height: 4),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 选择电话前缀模式专用
  Widget _buildPhoneHeaderItem() {
    final _areaItem = AreaItem(
      code: '1',
      name: '中国大陆',
      hasSub: true,
      groupCn: 'Z',
      phonePrefix: '+86',
    );
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.white.withOpacity(0.1),
            width: 0.5.w,
          ),
        ),
      ),
      width: MediaQuery.of(context).size.width,
      // padding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ListTile(
                contentPadding: EdgeInsets.only(left: 16.0.w, right: 16.0.w),
                trailing: Container(
                  width: 60.0.w,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    _areaItem.phonePrefix,
                    style: TextStyle(fontSize: 14.sp, color: Colors.grey),
                  ),
                ),
                title: Text(
                  _areaItem.name,
                  style: TextStyle(fontSize: 14.0.sp, color: Colors.white),
                ),
                onTap: () {
                  widget.onSelect(_areaItem);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WithStatusbarColorView(
      statusBarColor: Color.fromRGBO(22, 22, 22, 1),
      child: Scaffold(
        appBar: StaticAppBar(
          statusBarHeight: MediaQuery.of(context).padding.top,
          backgroundColor: Color.fromRGBO(22, 22, 22, 1),
          title: '选择地区',
          titleFontWeight: FontWeight.bold,
          titleColor: Colors.white,
        ),
        body: Container(
          decoration: BoxDecoration(
            color: Color.fromRGBO(22, 22, 22, 1),
            border: Border(
              top: BorderSide(
                color: Colors.white.withOpacity(0.1),
                width: 0.5.w,
              ),
            ),
          ),
          child: AzListView(
            hapticFeedback: true,
            susItemHeight: 40.0.h,
            padding: EdgeInsets.zero,
            data: widget.areaList, // 每个 item 需要实现 ISuspensionBean
            susItemBuilder: (context, index) {
              if (index == 0 && widget.isCountry == true) {
                return Container();
              }
              final item = widget.areaList[index];
              return Container(
                color: Color.fromRGBO(22, 22, 22, 1),
                width: MediaQuery.of(context).size.width,
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.symmetric(
                  vertical: 8.0.h,
                  horizontal: 16.0.w,
                ),
                child: Text(
                  item.group,
                  style: TextStyle(
                    fontSize: 16.0.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              );
            },
            itemCount: widget.areaList.length,
            itemBuilder: (context, index) {
              if (index == 0 && widget.isCountry == true) {
                if (widget.isSelectPhoneMode) {
                  return _buildPhoneHeaderItem();
                } else {
                  return _buildHeaderItem();
                }
              }
              final item = widget.areaList[index].items;
              return Container(
                padding: EdgeInsets.only(bottom: 30.0.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: List.generate(item.length, (index) {
                    return Container(
                      padding: index == item.length - 1
                          ? EdgeInsets.only(bottom: 20.0.h)
                          : EdgeInsets.only(bottom: 0),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: index != item.length - 1
                              ? BorderSide.none
                              : BorderSide(
                                  color: Colors.white.withOpacity(0.1),
                                  width: 0.5.w,
                                ),
                        ),
                      ),
                      child: ListTile(
                        contentPadding: EdgeInsets.only(
                          left: 16.0.w,
                          right: 16.0.w,
                        ),
                        trailing: widget.isSelectPhoneMode
                            ? Container(
                                width: 60.0.w,
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  item[index].phonePrefix,
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    color: Colors.grey,
                                  ),
                                ),
                              )
                            : null,
                        title: Text(
                          item[index].name,
                          style: TextStyle(
                            fontSize: 14.0.sp,
                            color: Colors.white,
                          ),
                        ),
                        onTap: () {
                          widget.onSelect(item[index]);
                        },
                      ),
                    );
                  }),
                ),
              );
            },
            indexBarData: widget.areaList
                .map((e) => e.group)
                .toList(), // A-Z 索引
            indexBarOptions: IndexBarOptions(
              needRebuild: true,
              selectTextStyle: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
              selectItemDecoration: BoxDecoration(shape: BoxShape.circle),
            ),
          ),
        ),
      ),
    );
  }
}
