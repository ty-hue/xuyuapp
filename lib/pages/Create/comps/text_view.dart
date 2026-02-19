import 'package:flutter/material.dart';

class TextView extends StatefulWidget {
  TextView({Key? key}) : super(key: key);

  @override
  _TextViewState createState() => _TextViewState();
}

class _TextViewState extends State<TextView> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Colors.pink,
       child: Text('文本视图'),
    );
  }
}