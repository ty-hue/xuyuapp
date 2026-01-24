// 全局常量
class GlobalConstants {
  static const String BASE_URL = 'http://192.168.1.231:5008'; // 基础地址
  static const int TIME_OUT = 10; // 超时时间
  static const int SUCCESS_CODE = 1; // 成功状态
  static const String TOKEN_KEY = 'csclyf_xuyuapp_token'; // 本地存储的token的key
  static const String MINE_SEARCH_HISTORY_KEY =
      'csclyf_xuyuapp_mine_search_history'; // 本地存储的搜索历史的key
}

// 请求地址接口的的常量
class HttpConstants {
  static const String GET_COUNTRY_LIST = '/api/area/getCountryList';
  static const String GET_PROVINCE_LIST = '/api/area/getProvinceByCountry';
  static const String GET_CITY_LIST = '/api/area/getCityByProvince';
  static const String GET_FIRST_REPORT_TYPE_LIST =
      '/api/report/getFirstReportLevels';
  static const String GET_SECOND_REPORT_TYPE_LIST =
      '/api/report/getSecondReportLevelsByFirstCode';
}

// 搜索状态
enum SearchState {
  idle, // 空闲状态
  searching, // 搜索状态
  searchComplete, // 搜索完成状态
}
