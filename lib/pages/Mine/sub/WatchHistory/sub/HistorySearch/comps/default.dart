import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class HistorySearchDefault extends StatefulWidget {
  HistorySearchDefault({Key? key}) : super(key: key);

  @override
  _HistorySearchDefaultState createState() => _HistorySearchDefaultState();
}

class _HistorySearchDefaultState extends State<HistorySearchDefault> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          '搜索你最近看过的视频',
          style: TextStyle(fontSize: 16.0.sp, color: Colors.white),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
