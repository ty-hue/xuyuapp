import 'package:bilbili_project/pages/Create/comps/select_music_pane.dart';
import 'package:bilbili_project/pages/Create/comps/upload_music_pane.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MiniMusicSheetSkeleton extends StatefulWidget {
  MiniMusicSheetSkeleton({Key? key}) : super(key: key);

  @override
  _MiniMusicSheetSkeletonState createState() => _MiniMusicSheetSkeletonState();
}

class _MiniMusicSheetSkeletonState extends State<MiniMusicSheetSkeleton> {
  bool isShow = true;
  // 切换显示选择音乐面板还是上传音乐面板
  void toggleShowPane() {
    setState(() {
      isShow = !isShow;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.all(Radius.circular(16.r)),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.5,
        padding: EdgeInsets.only(
          left: 16.w,
          right: 16.w,
          top: 24.h,
          bottom: 0.h,
        ),
        color: Colors.white,
        child: isShow
            ? SelectMusicPane(toggleShowPane: toggleShowPane)
            : UploadMusicPane(toggleShowPane: toggleShowPane),
      ),
    );
  }
}
