// 全局常量
import 'package:bilbili_project/viewmodels/Create/index.dart';

class GlobalConstants {
  static const String BASE_URL = 'http://192.168.1.231:5008'; // 基础地址
  static const int TIME_OUT = 10; // 超时时间
  static const int SUCCESS_CODE = 1; // 成功状态
  static const String TOKEN_KEY = 'csclyf_xuyuapp_token'; // 本地存储的token的key
  static const String MINE_SEARCH_HISTORY_KEY =
      'csclyf_xuyuapp_mine_search_history'; // 本地存储的搜索历史的key
  static const String MUSIC_SEARCH_HISTORY_KEY =
      'csclyf_xuyuapp_music_search_history'; // 本地存储的搜索历史的key

  /// 创作页拍摄偏好（JSON，供 [CreateShootPersistence]）
  static const String CREATE_SHOOT_PREFS_KEY =
      'csclyf_xuyuapp_create_shoot_prefs_v1';

  /// 拍摄页相册缩略图：最近写入相册的资源 id
  static const String LAST_GALLERY_COVER_ASSET_ID_KEY =
      'csclyf_xuyuapp_last_gallery_cover_asset_id';

  /// 拍摄页相册缩略图：封面文件写入本地时间戳（ms）
  static const String LAST_GALLERY_COVER_WRITTEN_MS_KEY =
      'csclyf_xuyuapp_last_gallery_cover_written_ms';
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
  static const String GET_AGREEMENT = '/api/agreement/getByType';
}

/// 协议类型（与后端 `getByType` 等约定一致时请改成真实 type 值）
enum AgreementType {
  privacyPolicy(0),
  userAgreement(1),
  permissionDescription(2),
  declaration(3);

  const AgreementType(this.typeCode);

  /// 接口侧协议类型数值
  final int typeCode;
}

// 搜索状态
enum SearchState {
  idle, // 空闲状态
  searching, // 搜索状态
  searchComplete, // 搜索完成状态
}

// 获取一份新的美颜数据（默认全部为 0，进入拍摄页时不应有美颜；用户调滑杆后再写入 native）
List<BeautyItem> createBeautyList() {
  return [
    BeautyItem(title: '无', icon: '', value: 0.0),
    BeautyItem(
      title: '美白',
      icon: '',
      type: PFBeautyFiterType.faceWhitenStrength,
      value: 0.0,
    ),
    BeautyItem(
      title: '红润',
      icon: '',
      type: PFBeautyFiterType.faceRuddyStrength,
      value: 0.0,
    ),
    BeautyItem(
      title: '磨皮',
      icon: '',
      type: PFBeautyFiterType.faceBlurStrength,
      value: 0.0,
    ),
    BeautyItem(
      title: '亮眼',
      icon: '',
      type: PFBeautyFiterType.faceEyeBrighten,
      value: 0.0,
    ),
    BeautyItem(
      title: '锐化',
      icon: '',
      type: PFBeautyFiterType.faceSharpenStrength,
      value: 0.0,
    ),

    BeautyItem(
      title: '大眼',
      icon: '',
      type: PFBeautyFiterType.eyeStrength,
      value: 0.0,
    ),
    BeautyItem(
      title: '瘦脸',
      icon: '',
      type: PFBeautyFiterType.faceThinning,
      value: 0.0,
    ),
    BeautyItem(
      title: '瘦颧骨',
      icon: '',
      type: PFBeautyFiterType.faceNarrow,
      value: 0.0,
    ),
    BeautyItem(
      title: '下巴',
      icon: '',
      type: PFBeautyFiterType.faceChin,
      value: 0.0,
    ),
    BeautyItem(
      title: '瘦下颔',
      icon: '',
      type: PFBeautyFiterType.faceV,
      value: 0.0,
    ),

    BeautyItem(
      title: '鼻梁',
      icon: '',
      type: PFBeautyFiterType.faceNoseBridge,
      value: 0.0,
    ),
    BeautyItem(
      title: '额头',
      icon: '',
      type: PFBeautyFiterType.faceForehead,
      value: 0.0,
    ),
    BeautyItem(
      title: '嘴巴',
      icon: '',
      type: PFBeautyFiterType.faceMouth,
      value: 0.0,
    ),

    BeautyItem(
      title: '人中',
      icon: '',
      type: PFBeautyFiterType.facePhiltrum,
      value: 0.0,
    ),
    BeautyItem(
      title: '长鼻',
      icon: '',
      type: PFBeautyFiterType.faceLongNose,
      value: 0.0,
    ),
    BeautyItem(
      title: '眼距',
      icon: '',
      type: PFBeautyFiterType.faceEyeSpace,
      value: 0.0,
    ),

    BeautyItem(
      title: '微笑嘴角',
      icon: '',
      type: PFBeautyFiterType.faceSmile,
      value: 0.0,
    ),
    BeautyItem(
      title: '开眼角',
      icon: '',
      type: PFBeautyFiterType.faceCanthus,
      value: 0.0,
    ),
  ];
}

// 获取一份新的滤镜数据
List<BeautyItem> createFilterList() {
  return [
    BeautyItem(title: '无', icon: '', value: 0.0),
    BeautyItem(
      title: '初恋',
      icon: '',
      filterType: "chulian",
      value: 0.5,
      type: PFBeautyFiterType.faceWhitenStrength,
    ),
    BeautyItem(
      title: '初心',
      icon: '',
      filterType: "chuxin",
      value: 0.5,
      type: PFBeautyFiterType.faceWhitenStrength,
    ),
    BeautyItem(
      title: '粉嫩',
      icon: '',
      filterType: "fennen",
      value: 0.5,
      type: PFBeautyFiterType.faceWhitenStrength,
    ),
    BeautyItem(
      title: '冷酷',
      icon: '',
      filterType: "lengku",
      value: 0.5,
      type: PFBeautyFiterType.faceWhitenStrength,
    ),
    BeautyItem(
      title: '美味',
      icon: '',
      filterType: "meiwei",
      value: 0.5,
      type: PFBeautyFiterType.faceWhitenStrength,
    ),
    BeautyItem(
      title: '奶茶',
      icon: '',
      filterType: "naicha",
      value: 0.5,
      type: PFBeautyFiterType.faceWhitenStrength,
    ),
    BeautyItem(
      title: '奶茶',
      icon: '',
      filterType: "naicha",
      value: 0.5,
      type: PFBeautyFiterType.faceWhitenStrength,
    ),
    BeautyItem(
      title: '拍立得',
      icon: '',
      filterType: "pailide",
      value: 0.3,
      type: PFBeautyFiterType.faceWhitenStrength,
    ),
    BeautyItem(
      title: '清新',
      icon: '',
      filterType: "qingxin",
      value: 0.3,
      type: PFBeautyFiterType.faceWhitenStrength,
    ),
    BeautyItem(
      title: '日系',
      icon: '',
      filterType: "rixi",
      value: 0.3,
      type: PFBeautyFiterType.faceWhitenStrength,
    ),
    BeautyItem(
      title: '日杂',
      icon: '',
      filterType: "riza",
      value: 0.3,
      type: PFBeautyFiterType.faceWhitenStrength,
    ),
    BeautyItem(
      title: '唯美',
      icon: '',
      filterType: "weimei",
      value: 0.3,
      type: PFBeautyFiterType.faceWhitenStrength,
    ),
  ];
}

/// AR 特效；`name` 与原生 `setArEffect` 一致（`face_mesh` 为脸部线框网，当前以 Android 实现为准）。
List<StickerItem> createStickerList() {
  return [
    StickerItem(
      name: 'face_mesh',
      bundleName: '',
      icon: '',
      label: '3D脸部点(线框)',
    ),
    StickerItem(name: 'lip_color', bundleName: '', icon: '', label: '玫瑰唇色'),
  ];
}

/// 创作页美颜/滤镜/贴纸等 bottom sheet 用到的本地图路径（去重），供 [scheduleCreateSheetImagePrecache] 预解码。
List<String> createSheetPrecacheAssetPaths() {
  final paths = <String>{};
  for (final item in createBeautyList()) {
    if (item.icon.isNotEmpty) paths.add(item.icon);
  }
  for (final item in createFilterList()) {
    if (item.icon.isNotEmpty) paths.add(item.icon);
  }
  for (final item in createStickerList()) {
    if (item.icon.isNotEmpty) paths.add(item.icon);
  }
  return paths.toList();
}
