import 'package:bilbili_project/pages/Mine/sub/Relationship/comps/block_sheet_skeleton.dart';
import 'package:bilbili_project/pages/Mine/sub/Relationship/comps/person_action_sheet_skeleton.dart';
import 'package:bilbili_project/components/switch_sheet_skeleton.dart';
import 'package:bilbili_project/utils/SheetUtils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class TabViewComp extends StatefulWidget {
  final int currentIndex;
  TabViewComp({Key? key, required this.currentIndex}) : super(key: key);

  @override
  State<TabViewComp> createState() => _TabViewCompState();
}

class _TabViewCompState extends State<TabViewComp> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  bool _isFocused = false;
  @override
  void initState() {
    super.initState();
    _searchFocusNode.addListener(() {
      setState(() {
        _isFocused = _searchFocusNode.hasFocus;
      });
    });
  }

  bool isShowPersonalActionSheet = false;
  bool isShowDontSeeSheet = false;
  bool isShowBlockSheet = false;
  Future<void> _openPersonalActionSheet() async {
    await SheetUtils(
      PersonalActionSheetSkeleton(
        openDontSeeSheet: _openDontSeeSheet,
        openBlockSheet: _openBlockSheet,
      ),
    ).openAsyncSheet<bool>(context: context);
  }

  Future<void> _openDontSeeSheet() async {
    final result = await SheetUtils(
      SwitchSheetSkeleton(
        immediatelyClose: true,
        title: '海阔天空',
        subTitle: '开启后它将看不到我发布的内容',
        label: '不让他看',
        value: isShowDontSeeSheet,
        avatarUrl: 'https://q8.itc.cn/q_70/images03/20250114/d9d8d1106f454c2b83ea395927bfc020.jpeg',
        isNeedCloseIcon: true,
      ),
    ).openAsyncSheet<bool>(context: context);
    if (result != null) {
      // 在这里发送请求更新数据
      print('不让他看：$result');
      setState(() {
        isShowDontSeeSheet = result;
      });
    }
  }

  Future<void> _openBlockSheet() async {
    final result = await SheetUtils(
      BlockSheetSkeleton(
        value: isShowBlockSheet,
      ),
    ).openAsyncSheet<bool>(context: context);
    if (result != null) {
      // 在这里发送请求更新数据
      print('拉黑：$result');
      setState(() {
        isShowBlockSheet = result;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 10.w),
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Stack(
              children: [
                Row(
                  children: [
                    AnimatedContainer(
                      duration: Duration(milliseconds: 300),
                      width: _isFocused
                          ? MediaQuery.of(context).size.width -
                                32.w -
                                20.w -
                                50.w
                          : MediaQuery.of(context).size.width - 32.w - 20.w,
                      height: 40.0.h,
                      child: Form(
                        child: Stack(
                          children: [
                            TextFormField(
                              controller: _searchController,
                              focusNode: _searchFocusNode,
                              // 监听聚焦事件
                              onFieldSubmitted: (value) {},
                              validator: (value) {
                                return null;
                              },
                              cursorColor: Color.fromRGBO(
                                209,
                                176,
                                40,
                                1,
                              ), // 光标颜色
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
                                  color: Color.fromRGBO(
                                    105,
                                    105,
                                    105,
                                    1,
                                  ), // 设置提示文字的颜色
                                ),
                                contentPadding: EdgeInsets.only(
                                  left: 40.0.w,
                                ), // 内容内边距
                                hintText: "搜索用户备注或名字",
                                fillColor: Color.fromRGBO(56, 56, 56, 1),
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Icon(
                                        FontAwesomeIcons.search,
                                        size: 16.0.w,
                                        color: Color.fromRGBO(105, 105, 105, 1),
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
                  ],
                ),
                Positioned(
                  right: 0,
                  top: 0,
                  bottom: 0,
                  child: AnimatedOpacity(
                    opacity: _isFocused ? 1.0 : 0.0,
                    duration: Duration(milliseconds: 600),
                    child: _isFocused
                        ? GestureDetector(
                            onTap: () {
                              // 处理点击事件
                              _searchController.clear();
                              _searchFocusNode.unfocus();
                              setState(() {
                                _isFocused = false;
                              });
                            },
                            child: Container(
                              width: 50.0.w,
                              height: 40.h,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                              child: Text(
                                '取消',
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.bold,
                                  color: Color.fromRGBO(172, 57, 84, 1),
                                ),
                              ),
                            ),
                          )
                        : SizedBox.shrink(),
                  ),
                ),
              ],
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              padding: EdgeInsets.only(top: 16.h),
              height: 40.h,
              child: Row(
                spacing: 4.w,
                children: [
                  Text(
                    '我的${widget.currentIndex == 0
                        ? '互关'
                        : widget.currentIndex == 1
                        ? '关注'
                        : '粉丝'}（27人）',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                      color: Color.fromRGBO(138, 138, 138, 1),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverList.builder(
            itemCount: 30,
            itemBuilder: (context, index) {
              return SizedBox(
                height: 80.h,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 56.0.w,
                      height: 56.0.h,
                      child: CircleAvatar(
                        backgroundImage: NetworkImage(
                          'https://q8.itc.cn/q_70/images03/20250114/d9d8d1106f454c2b83ea395927bfc020.jpeg',
                        ),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () {
                          // 处理点击事件
                          print('点击了用户$index');
                        },
                        child: Container(
                          // height: 80.h,
                          decoration: BoxDecoration(
                            // 底部边框
                            border: Border(
                              bottom: BorderSide(
                                width: 1,
                                color: Colors.white.withOpacity(0.2),
                              ),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                spacing: 6.h,
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '用户昵称',
                                    style: TextStyle(
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Text(
                                    '可能认识的人',
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.normal,
                                      color: Color.fromRGBO(105, 105, 105, 1),
                                    ),
                                  ),
                                ],
                              ),
                              widget.currentIndex == 1 ||
                                      widget.currentIndex == 2
                                  ? Row(
                                      spacing: 8.w,
                                      children: [
                                        SizedBox(
                                          width: 90.w,
                                          height: 30.h,
                                          child: ElevatedButton(
                                            onPressed: () {},
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Color.fromRGBO(
                                                253,
                                                44,
                                                85,
                                                1,
                                              ),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8.r),
                                              ),
                                            ),
                                            child: Text(
                                              '关注',
                                              style: TextStyle(
                                                fontSize: 14.sp,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ),
                                        widget.currentIndex == 2
                                            ? GestureDetector(
                                                onTap: () {
                                                  // 处理点击事件
                                                  _openPersonalActionSheet();
                                                },
                                                child: Icon(
                                                  FontAwesomeIcons.ellipsis,
                                                  size: 16.sp,
                                                  color: Colors.white,
                                                ),
                                              )
                                            : SizedBox.shrink(),
                                      ],
                                    )
                                  : SizedBox.shrink(),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
