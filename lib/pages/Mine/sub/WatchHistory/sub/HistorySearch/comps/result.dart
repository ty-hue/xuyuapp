import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class HistorySearchResult extends StatefulWidget {
  HistorySearchResult({Key? key}) : super(key: key);

  @override
  _HistorySearchResultState createState() => _HistorySearchResultState();
}

class _HistorySearchResultState extends State<HistorySearchResult> {
  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
       child: Text(
        '结果',
        style: TextStyle(fontSize: 16.0.sp, color: Colors.white),
        textAlign: TextAlign.center,
      ),
    );
  }
}