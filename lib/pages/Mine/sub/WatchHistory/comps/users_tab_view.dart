import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class UsersTabView extends StatefulWidget {
  UsersTabView({Key? key}) : super(key: key);

  @override
  _UsersTabViewState createState() => _UsersTabViewState();
}

class _UsersTabViewState extends State<UsersTabView> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          color: Color.fromRGBO(35,37,48, 1),
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
          child: Text('我访问过的用户（仅自己可见）',style: TextStyle(
            color: Colors.grey,
            fontSize: 12.sp,
          ),textAlign: TextAlign.left,),
        ),
        Expanded(
          child: CustomScrollView(
            slivers: [
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => Container(
                    padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                    child: Text('用户 $index',style: TextStyle(
                      color: Colors.white,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                    ),),
                  ),
                  childCount: 20,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
