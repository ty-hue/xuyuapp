import 'package:bilbili_project/viewmodels/Message/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class AvatarWithNicknameList extends StatefulWidget {
  final List<ContactItem> items; // 头像和昵称列表
  final Function() onEndButtonTap; // 结束按钮点击回调
  final String endButtonText; // 结束按钮文本
  final double? outBoxHeight; // 外层盒子高度
  final double? avatarSize; // 头像大小
  final TextStyle? endButtonTextStyle; // 结束按钮文本样式
  final Widget? endButtonIcon; // 结束按钮图标
  final TextStyle? itemTextStyle; // 列表项文本样式
  final EdgeInsetsGeometry? itemPadding; // 列表项内边距
  final Color? endButtonBackgroundColor; // 结束按钮背景颜色
  final Function(int index) onItemTap; // 列表项点击回调
  final List<int>? selectedContactIndexList; // 选中的联系人索引数组
  AvatarWithNicknameList({
    Key? key,
    required this.items,
    required this.onEndButtonTap,
    required this.endButtonText,
    this.outBoxHeight,
    this.avatarSize,
    this.endButtonTextStyle,
    this.endButtonIcon,
    this.itemTextStyle,
    this.itemPadding,
    this.endButtonBackgroundColor,
    required this.onItemTap,
    this.selectedContactIndexList,
  }) : super(key: key);

  @override
  _AvatarWithNicknameListState createState() => _AvatarWithNicknameListState();
}

class _AvatarWithNicknameListState extends State<AvatarWithNicknameList> {
  // 是否显示私信发送文本编辑框
  bool get isShowFormEdit {
    if (widget.selectedContactIndexList != null) {
      if (widget.selectedContactIndexList!.isNotEmpty) {
        return true;
      }
      return false;
    }
    return false;
  }

  // 是否显示选中状态
  bool isShowSelectedStatus(int index) {
    if (widget.selectedContactIndexList != null) {
      if (widget.selectedContactIndexList!.contains(index)) {
        return true;
      }
      return false;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    // 宽高须一致：.w / .h 缩放不同会导致 ClipOval 成椭圆，头像易被左右裁切感
    final double avatarSize = widget.avatarSize ?? 65.r;

    return SizedBox(
      width: double.infinity,
      height: widget.outBoxHeight ?? 110.h,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: widget.items.length + 1,
        itemBuilder: (context, index) {
          // 设置状态按钮
          if (index == widget.items.length) {
            return Padding(
              padding: EdgeInsets.symmetric(horizontal: 10.w),
              child: GestureDetector(
                onTap: () {
                  widget.onEndButtonTap();
                },
                child: Column(
                  spacing: 4.h,
                  children: [
                    // 头像
                    Container(
                      width: avatarSize,
                      height: avatarSize,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color:
                            widget.endButtonBackgroundColor ??
                            Color.fromRGBO(243, 243, 244, 1),
                      ),
                      child: Center(
                        child:
                            widget.endButtonIcon ??
                            Icon(
                              FontAwesomeIcons.gear,
                              size: 24.sp,
                              color: Color.fromRGBO(196, 196, 197, 1),
                            ),
                      ),
                    ),
                    // 结束按钮文本
                    Text(
                      widget.endButtonText,
                      style:
                          widget.endButtonTextStyle ??
                          TextStyle(
                            fontSize: 14.sp,
                            color: Colors.black,
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                  ],
                ),
              ),
            );
          }
          // 设置联系人列表项
          return Padding(
            padding:
                widget.itemPadding ?? EdgeInsets.symmetric(horizontal: 10.w),
            child: GestureDetector(
              onTap: () {
                // 跳转联系人页面
                widget.onItemTap(index);
              },
              child: Column(
                spacing: 4.h,
                children: [
                  // 头像
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      ClipOval(
                        child: SizedBox(
                          width: avatarSize,
                          height: avatarSize,
                          child: Image.network(
                            widget.items[index].avatar,
                            fit: BoxFit.cover,
                            alignment: Alignment.center,
                          ),
                        ),
                      ),
                      // 选中状态背景
                      if (isShowSelectedStatus(index))
                        Positioned.fill(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.3),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      // 选中状态右下角小圆点
                      if (isShowSelectedStatus(index))
                        Positioned(
                          right: -6.w,
                          bottom: -4.h,
                          child: Container(
                            width: 30.r,
                            height: 30.r,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Container(
                                width: 24.r,
                                height: 24.r,
                                decoration: BoxDecoration(
                                  color: Color.fromRGBO(253, 56, 87, 1),
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Icon(
                                    FontAwesomeIcons.check,
                                    size: 12.sp,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  // 名字
                  Text(
                    widget.items[index].name,
                    style:
                        widget.itemTextStyle ??
                        TextStyle(
                          fontSize: 14.sp,
                          color: Colors.black,
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
