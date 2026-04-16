import 'package:bilbili_project/components/static_app_bar.dart';
import 'package:bilbili_project/components/with_statusBar_color.dart';
import 'package:flutter/material.dart';

class OtherHomePage extends StatefulWidget {
  OtherHomePage({Key? key}) : super(key: key);

  @override
  _OtherHomePageState createState() => _OtherHomePageState();
}

class _OtherHomePageState extends State<OtherHomePage> {
  @override
  Widget build(BuildContext context) {
    return WithStatusbarColorView(
      statusBarColor: Colors.white,
      child: Scaffold(
        appBar: StaticAppBar(
          title: '他人主页',
          statusBarHeight: MediaQuery.of(context).padding.top,
          backgroundColor: Colors.black,
        ),
        body: Container(
          child: Text('他人主页'),
        ),
      )
    );
  }
}