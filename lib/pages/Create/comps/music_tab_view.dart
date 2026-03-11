import 'package:bilbili_project/pages/Create/comps/music_list_item.dart';
import 'package:flutter/material.dart';

class MusicTabView extends StatefulWidget {
  MusicTabView({Key? key}) : super(key: key);

  @override
  _MusicTabViewState createState() => _MusicTabViewState();
}

class _MusicTabViewState extends State<MusicTabView> {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 10,
      itemBuilder: (context, index) {
        return MusicListItem();
      },
    );
  }
}