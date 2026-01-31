import 'package:bilbili_project/components/static_app_bar.dart';
import 'package:bilbili_project/components/with_statusBar_color.dart';
import 'package:flutter/material.dart';

class ActionPage extends StatefulWidget {
  ActionPage({Key? key}) : super(key: key);

  @override
  _ActionPageState createState() => _ActionPageState();
}

class _ActionPageState extends State<ActionPage> {
  @override
  Widget build(BuildContext context) {
    return WithStatusbarColorView(statusBarColor: Colors.white, child: Scaffold(
      appBar: StaticAppBar(
        statusBarHeight: MediaQuery.of(context).padding.top,
        title: '操作',
      ),
    ));
  }
}