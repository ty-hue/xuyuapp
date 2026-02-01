import 'package:bilbili_project/components/static_app_bar.dart';
import 'package:bilbili_project/components/with_statusBar_color.dart';
import 'package:flutter/material.dart';

class DeclarationPage extends StatefulWidget {
  DeclarationPage({Key? key}) : super(key: key);

  @override
  _DeclarationPageState createState() => _DeclarationPageState();
}

class _DeclarationPageState extends State<DeclarationPage> {
  @override
  Widget build(BuildContext context) {
    return WithStatusbarColorView(
      statusBarColor: Color.fromRGBO(29, 31, 43, 1),
      child: Scaffold(
        appBar: StaticAppBar(
          statusBarHeight: MediaQuery.of(context).padding.top,
          backgroundColor: Color.fromRGBO(29, 31, 43, 1),
          title: '开源软件声明',
        ),
      ),
    );
  }
}
