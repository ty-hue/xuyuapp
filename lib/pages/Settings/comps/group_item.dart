import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class GroupItemView extends StatelessWidget {
  final String itemName;
  final IconData icon;
  final bool needUnderline;
  final bool needTrailingIcon;
  final Function()? cb;
  final bool isFirst; // 是否为第一个
  final Color backgroundColor; // 背景颜色
  final Widget attachedWidget; 
  final bool isNeedIcon; // 是否需要图标
  GroupItemView({
    Key? key,
    required this.itemName,
    required this.icon,
    this.needUnderline = true,
    this.needTrailingIcon = true,
    this.isFirst = false,
    this.backgroundColor = const Color.fromRGBO(35, 35, 35, 1),
    required this.cb,
    this.attachedWidget = const SizedBox.shrink(), // 附加文本默认空字符串
    this.isNeedIcon = true
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: backgroundColor, // 默认背景
      // 如果isFirst为true 则设置左上和右上的圆角， 如果needUnderline为true 则设置左下和右下的圆角 其余情况无圆角
      borderRadius: BorderRadius.vertical(
        top: isFirst ? Radius.circular(8.r) : Radius.zero,
        bottom: !needUnderline ? Radius.circular(8.r) : Radius.zero,
      ),

      clipBehavior: Clip.antiAlias, // ⭐️关键

      child: InkWell(
        onTap: cb,
        splashColor: Colors.white.withOpacity(0.08), // 水波纹
        highlightColor: Colors.white.withOpacity(0.05), // 按下态 ⭐
        child: SizedBox(
          height: 54.h,
          child: Padding(
            padding: EdgeInsets.only(left: 16.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                isNeedIcon
                ? Icon(icon, color: Colors.grey, size: 20.r)
                : const SizedBox.shrink(),
                SizedBox(width: 10.w),
                Expanded(
                  child: Container(
                    padding: EdgeInsets.only(right: 16.w),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: needUnderline
                            ? BorderSide(color: Colors.grey, width: 0.5.w)
                            : BorderSide.none,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          itemName,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Row(
                          spacing: 4.w,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            attachedWidget,
                            needTrailingIcon
                                ? Icon(
                                    Icons.arrow_forward_ios,
                                    color: Colors.grey,
                                    size: 14.r,
                                  )
                                : const SizedBox.shrink(),
                          ],
                        ),
                      ],
                    ),
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
