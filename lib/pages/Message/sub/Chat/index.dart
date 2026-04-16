import 'package:bilbili_project/components/static_app_bar.dart';
import 'package:bilbili_project/components/with_statusBar_color.dart';
import 'package:flutter/material.dart';

class ChatPage extends StatefulWidget {
  ChatPage({Key? key}) : super(key: key);

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  @override
  Widget build(BuildContext context) {
    return WithStatusbarColorView(
      statusBarColor: Colors.white,
      child: Scaffold(
        appBar: StaticAppBar(
          title: '聊天',
          statusBarHeight: MediaQuery.of(context).padding.top,
          backgroundColor: Colors.black,
        ),
        body: Container(
          child: Text('聊天'),
        ),
      ),
    
    );
  }
}