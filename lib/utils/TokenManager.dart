import 'package:bilbili_project/constants/index.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TokenManager {
  String _token = '';
  // 实例化SharedPreferences对象
  Future<SharedPreferences> _getInstance() async {
    return await SharedPreferences.getInstance();
  }
  // 初始化token
 Future<void> init() async{
    final prefs = await _getInstance();
    _token = prefs.getString(GlobalConstants.TOKEN_KEY) ?? '';
  }
  // 设置token
  Future<void> setToken(String val) async {
    final prefs = await _getInstance();
    prefs.setString(GlobalConstants.TOKEN_KEY, val);
    _token = val;
  }
  // 获取token
  String getToken(){
    return _token;
  }
  // 删除token
  Future<void> removeToken() async{
    final prefs = await _getInstance();
    prefs.remove(GlobalConstants.TOKEN_KEY);
    _token = '';
  }
}

final tokenManager = TokenManager();

