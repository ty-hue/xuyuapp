import 'package:bilbili_project/components/static_app_bar.dart';
import 'package:bilbili_project/components/with_statusBar_color.dart';
import 'package:flutter/material.dart';

class CachePage extends StatefulWidget {
  CachePage({Key? key}) : super(key: key);

  @override
  _CachePageState createState() => _CachePageState();
}

class _CachePageState extends State<CachePage> {
  @override
  Widget build(BuildContext context) {
    return WithStatusbarColorView(
      statusBarColor: Color.fromRGBO(29, 31, 43, 1),
      child: Scaffold(
        appBar: StaticAppBar(
          statusBarHeight: MediaQuery.of(context).padding.top,
          backgroundColor: Color.fromRGBO(29, 31, 43, 1),
          title: '清理缓存',
        ),
      ),
    );
  }
}
