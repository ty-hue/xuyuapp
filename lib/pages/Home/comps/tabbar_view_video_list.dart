import 'package:bilbili_project/pages/Home/comps/video_list_item.dart';
import 'package:flutter/material.dart';

class TabbarViewVideoList extends StatefulWidget {
  TabbarViewVideoList({Key? key}) : super(key: key);

  @override
  _TabbarViewVideoListState createState() => _TabbarViewVideoListState();
}

class _TabbarViewVideoListState extends State<TabbarViewVideoList> {
  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      scrollDirection: Axis.vertical,
      itemCount: 2,
      itemBuilder: (context, index) {
        return VideoListItem();
      },
    );
  }
}