import 'package:bilbili_project/components/static_app_bar.dart';
import 'package:bilbili_project/components/with_statusBar_color.dart';
import 'package:flutter/material.dart';

class GlobalSearchPage extends StatefulWidget {
  GlobalSearchPage({Key? key}) : super(key: key);

  @override
  _GlobalSearchPageState createState() => _GlobalSearchPageState();
}

class _GlobalSearchPageState extends State<GlobalSearchPage> {
  @override
  Widget build(BuildContext context) {
    return WithStatusbarColorView(
      statusBarColor: Colors.white,
      child: Scaffold(
        appBar: StaticAppBar(
          title: '搜索',
          statusBarHeight: MediaQuery.of(context).padding.top,
          backgroundColor: Colors.black,
        ),
        body: Container(
          child: Text('搜索'),
        ),
      ),
      
    );
  }
}