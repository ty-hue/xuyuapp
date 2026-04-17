import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

/// 圆角由 [SheetUtils] 打开的 modal [Material.shape] 统一裁剪，此处不再套 [ClipRRect]。
class VideoLongPressSheetSkeleton extends StatefulWidget {
  VideoLongPressSheetSkeleton({Key? key}) : super(key: key);

  @override
  _VideoLongPressSheetSkeletonState createState() =>
      _VideoLongPressSheetSkeletonState();
}

class _VideoLongPressSheetSkeletonState
    extends State<VideoLongPressSheetSkeleton> {
  Widget bulidItem({
    required IconData icon,
    required String title,
    isnedline = true,
    Widget? extraChild,
    VoidCallback? onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,

        child: Container(
          padding: EdgeInsets.symmetric(vertical: 16.0.h),
          decoration: BoxDecoration(
            // 下边框
            border: Border(
              bottom: isnedline
                  ? BorderSide(color: Colors.grey.withOpacity(0.3), width: 1.w)
                  : BorderSide.none,
            ),
          ),
          child: Row(
            spacing: 14.w,
            children: [
              // 倍速icon
              Icon(icon, size: 24.sp, color: Color.fromRGBO(25, 27, 38, 1)),
              Expanded(
                child: Row(
                  spacing: 30.w,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16.sp,
                        color: Color.fromRGBO(62, 63, 72, 1),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    extraChild ?? SizedBox.shrink(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 倍速list
  List<String> speedList = ['0.75', '1.0', '1.25', '1.5', '2.0', '3.0'];

  // 倍数调节方法
  void _onSpeedTap(String speed) {
    print(speed);
  }

  // 清屏播放方法
  void _onClearScreenTap() {
    print('清屏播放');
  }

  // 举报方法
  void _onReportTap() {
    print('举报');
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.all(Radius.circular(16.r)),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.0.w, vertical: 24.0.h),
        decoration: BoxDecoration(color: Color.fromRGBO(242, 243, 244, 1)),
        child: Container(
          padding: EdgeInsets.only(left: 24.0.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(Radius.circular(16.r)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              bulidItem(
                icon: FontAwesomeIcons.forward,
                title: '倍速',
                extraChild: Expanded(
                  child: Row(
                    spacing: 16.w,
                    children: [
                      ...speedList.map(
                        (e) => GestureDetector(
                          onTap: () {
                            _onSpeedTap(e);
                          },
                          child: Text(
                            e,
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: Color.fromRGBO(124, 125, 131, 1),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // 全屏icon
              bulidItem(
                icon: FontAwesomeIcons.expand,
                title: '清屏播放',
                onTap: _onClearScreenTap,
              ),
              bulidItem(
                icon: FontAwesomeIcons.triangleExclamation,
                title: '举报',
                isnedline: false,
                onTap: _onReportTap,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
