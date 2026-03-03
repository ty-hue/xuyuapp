// 全局常量
import 'package:bilbili_project/viewmodels/Create/index.dart';
import 'package:pixelfree/pixelfree_platform_interface.dart';

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

// 获取一份新的美颜数据
List<BeautyItem> createBeautyList() {
  return [
    BeautyItem(title: '无', icon: '', value: 0.0),
    BeautyItem(
      title: '美白',
      icon: 'assets/icons/meibai.png',
      type: PFBeautyFiterType.faceWhitenStrength,
      value: 0.5,
    ),
    BeautyItem(
      title: '红润',
      icon: 'assets/icons/hongrun.png',
      type: PFBeautyFiterType.faceRuddyStrength,
      value: 0.5,
    ),
    BeautyItem(
      title: '磨皮',
      icon: 'assets/icons/mopi.png',
      type: PFBeautyFiterType.faceBlurStrength,
      value: 0.8,
    ),
    BeautyItem(
      title: '亮眼',
      icon: 'assets/icons/liangyan.png',
      type: PFBeautyFiterType.faceEyeBrighten,
      value: 0.5,
    ),
    BeautyItem(
      title: '锐化',
      icon: 'assets/icons/ruihua.png',
      type: PFBeautyFiterType.faceSharpenStrength,
      value: 0.5,
    ),
    BeautyItem(
      title: '增强画质',
      icon: 'assets/icons/huazhizengqiang.png',
      type: PFBeautyFiterType.faceQualityStrength,
      value: 0.5,
    ),

    BeautyItem(
      title: '大眼',
      icon: 'assets/icons/dayan.png',
      type: PFBeautyFiterType.eyeStrength,
      value: 0.3,
    ),
    BeautyItem(
      title: '瘦脸',
      icon: 'assets/icons/shoulian.png',
      type: PFBeautyFiterType.faceThinning,
      value: 0.5,
    ),
    BeautyItem(
      title: '瘦颧骨',
      icon: 'assets/icons/zhailian.png',
      type: PFBeautyFiterType.faceNarrow,
      value: 0.5,
    ),
    BeautyItem(
      title: '下巴',
      icon: 'assets/icons/xiaba.png',
      type: PFBeautyFiterType.faceChin,
      value: 0.5,
    ),
    BeautyItem(
      title: '瘦下颔',
      icon: 'assets/icons/vlian.png',
      type: PFBeautyFiterType.faceV,
      value: 0.5,
    ),
    BeautyItem(
      title: '小脸',
      icon: 'assets/icons/xianlian.png',
      type: PFBeautyFiterType.faceSmall,
      value: 0.5,
    ),

    BeautyItem(
      title: '鼻子',
      icon: 'assets/icons/bizhi.png',
      type: PFBeautyFiterType.faceNose,
      value: 0.5,
    ),
    BeautyItem(
      title: '额头',
      icon: 'assets/icons/etou.png',
      type: PFBeautyFiterType.faceForehead,
      value: 0.5,
    ),
    BeautyItem(
      title: '嘴巴',
      icon: 'assets/icons/zuiba.png',
      type: PFBeautyFiterType.faceMouth,
      value: 0.5,
    ),

    BeautyItem(
      title: '人中',
      icon: 'assets/icons/renzhong.png',
      type: PFBeautyFiterType.facePhiltrum,
      value: 0.5,
    ),
    BeautyItem(
      title: '长鼻',
      icon: 'assets/icons/changbi.png',
      type: PFBeautyFiterType.faceLongNose,
      value: 0.5,
    ),
    BeautyItem(
      title: '眼距',
      icon: 'assets/icons/yanju.png',
      type: PFBeautyFiterType.faceEyeSpace,
      value: 0.5,
    ),

    BeautyItem(
      title: '微笑嘴角',
      icon: 'assets/icons/weixiaozuijiao.png',
      type: PFBeautyFiterType.faceSmile,
      value: 0.5,
    ),
    BeautyItem(
      title: '旋转眼睛',
      icon: 'assets/icons/yanjingjiaodu.png',
      type: PFBeautyFiterType.faceEyeRotate,
      value: 0.5,
    ),
    BeautyItem(
      title: '开眼角',
      icon: 'assets/icons/kaiyanjiao.png',
      type: PFBeautyFiterType.faceCanthus,
      value: 0.5,
    ),
  ];
}

// 获取一份新的滤镜数据
List<BeautyItem> createFilterList() {
  return [
    BeautyItem(title: '无', icon: '', value: 0.0),
    BeautyItem(
      title: '初恋',
      icon: 'assets/icons/chulian.png',
      filterType: "chulian",
      value: 0.5,
      type: PFBeautyFiterType.faceWhitenStrength,
    ),
    BeautyItem(
      title: '初心',
      icon: 'assets/icons/chuxin.png',
      filterType: "chuxin",
      value: 0.5,
      type: PFBeautyFiterType.faceWhitenStrength,
    ),
    BeautyItem(
      title: '粉嫩',
      icon: 'assets/icons/f_fennen1.png',
      filterType: "fennen",
      value: 0.5,
      type: PFBeautyFiterType.faceWhitenStrength,
    ),
    BeautyItem(
      title: '冷酷',
      icon: 'assets/icons/lengku.png',
      filterType: "lengku",
      value: 0.5,
      type: PFBeautyFiterType.faceWhitenStrength,
    ),
    BeautyItem(
      title: '美味',
      icon: 'assets/icons/meiwei.png',
      filterType: "meiwei",
      value: 0.5,
      type: PFBeautyFiterType.faceWhitenStrength,
    ),
    BeautyItem(
      title: '奶茶',
      icon: 'assets/icons/naicha.png',
      filterType: "naicha",
      value: 0.5,
      type: PFBeautyFiterType.faceWhitenStrength,
    ),
    BeautyItem(
      title: '奶茶',
      icon: 'assets/icons/naicha.png',
      filterType: "naicha",
      value: 0.5,
      type: PFBeautyFiterType.faceWhitenStrength,
    ),
    BeautyItem(
      title: '拍立得',
      icon: 'assets/icons/pailide.png',
      filterType: "pailide",
      value: 0.3,
      type: PFBeautyFiterType.faceWhitenStrength,
    ),
    BeautyItem(
      title: '清新',
      icon: 'assets/icons/qingxin.png',
      filterType: "qingxin",
      value: 0.3,
      type: PFBeautyFiterType.faceWhitenStrength,
    ),
    BeautyItem(
      title: '日系',
      icon: 'assets/icons/rixi.png',
      filterType: "rixi",
      value: 0.3,
      type: PFBeautyFiterType.faceWhitenStrength,
    ),
    BeautyItem(
      title: '日杂',
      icon: 'assets/icons/riza.png',
      filterType: "riza",
      value: 0.3,
      type: PFBeautyFiterType.faceWhitenStrength,
    ),
    BeautyItem(
      title: '唯美',
      icon: 'assets/icons/weimei.png',
      filterType: "weimei",
      value: 0.3,
      type: PFBeautyFiterType.faceWhitenStrength,
    ),
  ];
}
