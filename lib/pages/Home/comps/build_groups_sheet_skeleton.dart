import 'package:bilbili_project/pages/Home/comps/bulid_groups_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class BuildGroupsSheetSkeleton extends StatefulWidget {
  BuildGroupsSheetSkeleton({Key? key}) : super(key: key);

  @override
  _BuildGroupsSheetSkeletonState createState() =>
      _BuildGroupsSheetSkeletonState();
}

class _BuildGroupsSheetSkeletonState extends State<BuildGroupsSheetSkeleton> {
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.all(Radius.circular(16.r)),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        height: MediaQuery.of(context).size.height * 0.65,
        child: BulidGroupsView(
        onBack: () {
          Navigator.pop(context);
        },
        isNeedBackButton: false,
      ),
      )
    );
  }
}
