import 'package:bilbili_project/components/static_app_bar.dart';
import 'package:bilbili_project/components/with_statusBar_color.dart';
import 'package:flutter/material.dart';

class NoticePage extends StatefulWidget {
  NoticePage({Key? key}) : super(key: key);

  @override
  _NoticePageState createState() => _NoticePageState();
}

class _NoticePageState extends State<NoticePage> {
  @override
  Widget build(BuildContext context) {
    return WithStatusbarColorView(statusBarColor: Color.fromRGBO(29, 31, 43, 1), child: Scaffold(
      appBar: StaticAppBar(
        statusBarHeight: MediaQuery.of(context).padding.top,
        backgroundColor: Color.fromRGBO(29, 31, 43, 1),
        title: '通知设置',
      ),
    ));
  }
}