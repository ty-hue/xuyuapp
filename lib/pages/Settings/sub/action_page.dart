import 'package:bilbili_project/components/static_app_bar.dart';
import 'package:bilbili_project/components/with_statusBar_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ActionPage extends StatefulWidget {
  final String title;
  final Widget child;
  ActionPage({Key? key, required this.title, required this.child}) : super(key: key);

  @override
  State<ActionPage> createState() => _ActionPageState();
}

class _ActionPageState extends State<ActionPage> {
  @override
  Widget build(BuildContext context) {
    return WithStatusbarColorView(statusBarColor: Color.fromRGBO(22,24,36, 1), child: Scaffold(
      appBar: StaticAppBar(
        backgroundColor: Color.fromRGBO(22,24,36, 1),
        statusBarHeight: MediaQuery.of(context).padding.top,
        title: widget.title,
      ),
      body: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Color.fromRGBO(22,24,36, 1),
        ),
        child: widget.child,
      )
    ));
  }
}