import 'package:flutter/material.dart';

class FriendPage extends StatefulWidget {
  FriendPage({Key? key}) : super(key: key);

  @override
  State<FriendPage> createState() => _FriendPageState();
}

class _FriendPageState extends State<FriendPage> {
  @override
  Widget build(BuildContext context) {
    return Container(
       child: Center(
          child: Text('Friend Page'),
       ),
    );
  }
}


