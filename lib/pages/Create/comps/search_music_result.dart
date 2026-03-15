import 'package:bilbili_project/pages/Create/comps/search_music_list_item.dart';
import 'package:bilbili_project/viewmodels/Create/index.dart';
import 'package:flutter/material.dart';

class SearchMusicResult extends StatefulWidget {
  final List<String> searchResult;
  final Future<void> Function() search;
  SearchMusicResult({
    Key? key,
    required this.searchResult,
    required this.search,
  }) : super(key: key);

  @override
  _SearchMusicResultState createState() => _SearchMusicResultState();
}

class _SearchMusicResultState extends State<SearchMusicResult> {
  bool isLoading = false;
  // 请求方法
  Future<void> _search() async {
    setState(() {
      isLoading = true;
    });
    await widget.search();
    setState(() {
      isLoading = false;
    });
  }

  int selectIndex = -1;
  // 改变选中项
  Future<void> changeSelectIndex(int index) async {
    setState(() {
      selectIndex = index;
    });
  }

  PlayStatus playStatus = PlayStatus.normal;
  // 改变播放状态
  Future<void> changePlayStatus(PlayStatus status) async {
    setState(() {
      playStatus = status;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.zero,
      shrinkWrap: true,
      itemCount: 10,
      itemBuilder: (context, index) {
        return SearchMusicListItem(
          selectIndex: selectIndex,
          playStatus: playStatus,
          changeSelectIndex: changeSelectIndex,
          changePlayStatus: changePlayStatus,
          selfIndex: index,
        );
      },
    );
  }
}
