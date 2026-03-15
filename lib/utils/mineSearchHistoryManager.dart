import 'package:shared_preferences/shared_preferences.dart';

class MineSearchHistoryManager {
  final String searchKey;
  MineSearchHistoryManager({required this.searchKey});
  List<String> _searchHistory = [];
  // 实例化SharedPreferences对象
  Future<SharedPreferences> _getInstance() async {
    return await SharedPreferences.getInstance();
  }
  // 初始化搜索历史
 Future<void> init() async{
    final prefs = await _getInstance();
    _searchHistory = prefs.getStringList(searchKey) ?? [];
  }
  // 添加搜索记录
  Future<void> setSearchHistory(List<String> val) async {
    final prefs = await _getInstance();
    prefs.setStringList(searchKey, val);
    _searchHistory = val;
  }
  // 获取搜索历史
  List<String> getSearchHistory(){
    return _searchHistory;
  }
  // 删除搜索历史
  Future<void> removeSearchHistory() async{
    final prefs = await _getInstance();
    prefs.remove(searchKey);
    _searchHistory = [];
  }
}


