import 'package:bilbili_project/components/static_app_bar.dart';
import 'package:bilbili_project/components/with_statusBar_color.dart';
import 'package:flutter/material.dart';

class DeleteAccountPage extends StatefulWidget {
  DeleteAccountPage({Key? key}) : super(key: key);

  @override
  State<DeleteAccountPage> createState() => _DeleteAccountState();
}

class _DeleteAccountState extends State<DeleteAccountPage> {
  @override
  Widget build(BuildContext context) {
    return WithStatusbarColorView(
      statusBarColor: Colors.white,
      child: Scaffold(
        appBar: StaticAppBar(
          titleColor: Colors.black,
          title: '注销账号',
          titleFontWeight: FontWeight.bold,
          backgroundColor: Colors.white,
          statusBarHeight: MediaQuery.of(context).padding.top,
        ),
      ),
    );
  }
}
