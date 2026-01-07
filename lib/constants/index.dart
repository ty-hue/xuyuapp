// 全局常量
class GlobalConstants {
  static const String BASE_URL = 'http://192.168.1.231:5008'; // 基础地址
  static const int TIME_OUT = 10; // 超时时间
  static const int SUCCESS_CODE = 1; // 成功状态
  static const String TOKEN_KEY = 'csclyf_xuyuapp_token'; // 本地存储的token的key
}

// 请求地址接口的的常量
class HttpConstants {
  static const String GET_COUNTRY_LIST = '/api/area/getCountryList';
  static const String GET_PROVINCE_LIST = '/api/area/getProvinceByCountry';
  static const String GET_CITY_LIST = '/api/area/getCityByProvince';
}