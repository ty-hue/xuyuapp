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

// 获取一份新的贴纸数据
List<StickerItem> createStickerList() {
  return [
    StickerItem(
      name: '白小猫',
      bundleName: 'baixiaomao.bundle',
      icon: 'assets/icons/baixiaomao.png',
    ),
    StickerItem(
      name: '白小猫胡须',
      bundleName: 'baixiaomaohuxu.bundle',
      icon: 'assets/icons/baixiaomaohuxu.png',
    ),
    StickerItem(
      name: '熊头',
      bundleName: 'bear_headgear.bundle',
      icon: 'assets/icons/bear_headgear.png',
    ),
    StickerItem(
      name: '大眼镜',
      bundleName: 'big_eyes.bundle',
      icon: 'assets/icons/big_eyes.png',
    ),
    StickerItem(
      name: '生日',
      bundleName: 'birthday.bundle',
      icon: 'assets/icons/birthday.png',
    ),
    StickerItem(
      name: '小猫咪',
      bundleName: 'buliaoxiaomao.bundle',
      icon: 'assets/icons/buliaoxiaomao.png',
    ),
    StickerItem(
      name: 'Candy',
      bundleName: 'candy.bundle',
      icon: 'assets/icons/candy.jpg',
    ),
    StickerItem(
      name: '猫爪',
      bundleName: 'cat_claw.bundle',
      icon: 'assets/icons/cat_claw.png',
    ),
    StickerItem(
      name: '呆呆猫',
      bundleName: 'cat_fa_qia.bundle',
      icon: 'assets/icons/cat_fa_qia.png',
    ),
    StickerItem(
      name: '小黑猫',
      bundleName: 'cat_on_the_head.bundle',
      icon: 'assets/icons/cat_on_the_head.png',
    ),
    StickerItem(
      name: '带刺帽子',
      bundleName: 'cidinmaozi.bundle',
      icon: 'assets/icons/cidinmaozi.png',
    ),
    StickerItem(
      name: '蛋糕',
      bundleName: 'cream_cake.bundle',
      icon: 'assets/icons/cream_cake.png',
    ),
    StickerItem(
      name: '理发',
      bundleName: 'cut_hair.bundle',
      icon: 'assets/icons/cut_hair.png',
    ),
    StickerItem(
      name: '可爱猫',
      bundleName: 'cute_cat.bundle',
      icon: 'assets/icons/cute_cat.png',
    ),
    StickerItem(
      name: '蝴蝶结',
      bundleName: 'dahudiejie.bundle',
      icon: 'assets/icons/dahudiejie.png',
    ),
    StickerItem(
      name: '酷酷眼镜',
      bundleName: 'damengyanjing.bundle',
      icon: 'assets/icons/damengyanjing.png',
    ),
    StickerItem(
      name: '大圆耳朵',
      bundleName: 'dayuanerduo.bundle',
      icon: 'assets/icons/dayuanerduo.png',
    ),
    StickerItem(
      name: '狗狗',
      bundleName: 'dog_tongue.bundle',
      icon: 'assets/icons/dog_tongue.png',
    ),
    StickerItem(
      name: '老虎机',
      bundleName: 'duboji.bundle',
      icon: 'assets/icons/duboji.png',
    ),
    StickerItem(
      name: '烦恼',
      bundleName: 'fannao.bundle',
      icon: 'assets/icons/fannao.png',
    ),
    StickerItem(
      name: '时尚Lady',
      bundleName: 'fashion_laddy.bundle',
      icon: 'assets/icons/fashion_laddy.png',
    ),
    StickerItem(
      name: '飞碟',
      bundleName: 'feidie.bundle',
      icon: 'assets/icons/feidie.png',
    ),
    StickerItem(
      name: '封印',
      bundleName: 'fengying.bundle',
      icon: 'assets/icons/fengying.png',
    ),
    StickerItem(
      name: '鲜花',
      bundleName: 'flower.bundle',
      icon: 'assets/icons/flower.png',
    ),
    StickerItem(
      name: '花丛',
      bundleName: 'flowers.bundle',
      icon: 'assets/icons/flowers.jpg',
    ),
    StickerItem(
      name: '绅士帽',
      bundleName: 'gentleman_hat.bundle',
      icon: 'assets/icons/gentleman_hat.png',
    ),
    StickerItem(
      name: '书呆子眼镜',
      bundleName: 'glasses_space.bundle',
      icon: 'assets/icons/glasses_space.png',
    ),
    StickerItem(
      name: '害羞',
      bundleName: 'goux.bundle',
      icon: 'assets/icons/goux.png',
    ),
    StickerItem(
      name: '兔子耳朵',
      bundleName: 'hdj.bundle',
      icon: 'assets/icons/hdj.png',
    ),
    StickerItem(
      name: '爱心桃',
      bundleName: 'heart_explode.bundle',
      icon: 'assets/icons/heart_explode.png',
    ),
    StickerItem(
      name: '打招呼',
      bundleName: 'hello_baby.bundle',
      icon: 'assets/icons/hello_baby.png',
    ),
    StickerItem(
      name: '你好眼镜',
      bundleName: 'hello_glasses.bundle',
      icon: 'assets/icons/hello_glasses.png',
    ),
    StickerItem(
      name: '红眼睛',
      bundleName: 'hongtoushi.bundle',
      icon: 'assets/icons/hongtoushi.png',
    ),
    StickerItem(
      name: '爱心蒸汽',
      bundleName: 'huangm.bundle',
      icon: 'assets/icons/huangm.png',
    ),
    StickerItem(
      name: '小黑猫拳拳',
      bundleName: 'jianbixiaoheimao.bundle',
      icon: 'assets/icons/jianbixiaoheimao.png',
    ),
    StickerItem(
      name: '简单小猫',
      bundleName: 'jiandanxiaomaomi.bundle',
      icon: 'assets/icons/jiandanxiaomaomi.png',
    ),
    StickerItem(
      name: '简单猫',
      bundleName: 'jiandanzhuangshi.bundle',
      icon: 'assets/icons/jiandanzhuangshi.png',
    ),
    StickerItem(
      name: 'kitty眼镜',
      bundleName: 'kitty.bundle',
      icon: 'assets/icons/kitty.png',
    ),
    StickerItem(
      name: 'laser',
      bundleName: 'laser.bundle',
      icon: 'assets/icons/laser.png',
    ),
    StickerItem(
      name: '战斗眼',
      bundleName: 'laugh.bundle',
      icon: 'assets/icons/laugh.png',
    ),
    StickerItem(
      name: '虐心',
      bundleName: 'lecher.bundle',
      icon: 'assets/icons/lecher.png',
    ),
    StickerItem(
      name: '蓝色爱心',
      bundleName: 'liangshanaixinmao.bundle',
      icon: 'assets/icons/liangshanaixinmao.png',
    ),
    StickerItem(
      name: '小浴缸',
      bundleName: 'little_bear.bundle',
      icon: 'assets/icons/little_bear.png',
    ),
    StickerItem(
      name: '小狼狗',
      bundleName: 'long_ear_dog.bundle',
      icon: 'assets/icons/long_ear_dog.png',
    ),
    StickerItem(
      name: '可爱兔子耳朵',
      bundleName: 'long_ear_rabbit.bundle',
      icon: 'assets/icons/long_ear_rabbit.png',
    ),
    StickerItem(
      name: '透明爱心',
      bundleName: 'love_bubbles.bundle',
      icon: 'assets/icons/love_bubbles.png',
    ),
    StickerItem(
      name: '比心',
      bundleName: 'love_gestures.bundle',
      icon: 'assets/icons/love_gestures.png',
    ),
    StickerItem(
      name: '猫和狗',
      bundleName: 'maogou.bundle',
      icon: 'assets/icons/maogou.png',
    ),
    StickerItem(
      name: '毛球',
      bundleName: 'maorong.bundle',
      icon: 'assets/icons/maorong.jpg',
    ),
    StickerItem(
      name: '皇冠',
      bundleName: 'myqueen.bundle',
      icon: 'assets/icons/myqueen.png',
    ),
    StickerItem(
      name: '面条',
      bundleName: 'noodles.bundle',
      icon: 'assets/icons/noodles.png',
    ),
    StickerItem(
      name: '卡拉ok',
      bundleName: 'pop_glasses.bundle',
      icon: 'assets/icons/pop_glasses.png',
    ),
    StickerItem(
      name: '囚禁',
      bundleName: 'prison.bundle',
      icon: 'assets/icons/prison.png',
    ),
    StickerItem(
      name: '晕阙',
      bundleName: 'qifei.bundle',
      icon: 'assets/icons/qifei.png',
    ),
    StickerItem(
      name: '兔子皇冠',
      bundleName: 'rabbit_blush.bundle',
      icon: 'assets/icons/rabbit_blush.png',
    ),
    StickerItem(
      name: '兔子脸红',
      bundleName: 'rabbit_holding_face.bundle',
      icon: 'assets/icons/rabbit_holding_face.png',
    ),
    StickerItem(
      name: '哈巴狗',
      bundleName: 'red_glasses.bundle',
      icon: 'assets/icons/red_glasses.png',
    ),
    StickerItem(
      name: '羊咩咩',
      bundleName: 'sheep.bundle',
      icon: 'assets/icons/sheep.png',
    ),
    StickerItem(
      name: '狮子头',
      bundleName: 'shizitou.bundle',
      icon: 'assets/icons/shizitou.png',
    ),
    StickerItem(
      name: '太阳镜',
      bundleName: 'sunflower_glasses.bundle',
      icon: 'assets/icons/sunflower_glasses.png',
    ),
    StickerItem(
      name: '可怜的眼泪',
      bundleName: 'tears.bundle',
      icon: 'assets/icons/tears.png',
    ),
    StickerItem(
      name: '小窝',
      bundleName: 'touhua.bundle',
      icon: 'assets/icons/touhua.png',
    ),
    StickerItem(
      name: '可怜的小狗',
      bundleName: 'toy_dog.bundle',
      icon: 'assets/icons/toy_dog.png',
    ),
    StickerItem(
      name: '毛茸茸兔耳朵',
      bundleName: 'toy_rabbit_ear_tie.bundle',
      icon: 'assets/icons/toy_rabbit_ear_tie.png',
    ),
    StickerItem(
      name: '潜水',
      bundleName: 'under_water_glasses.bundle',
      icon: 'assets/icons/under_water_glasses.png',
    ),
    StickerItem(
      name: '红领巾',
      bundleName: 'uniform2.bundle',
      icon: 'assets/icons/uniform2.png',
    ),
    StickerItem(
      name: '小熊猫',
      bundleName: 'xiantiaoxiongmao.bundle',
      icon: 'assets/icons/xiantiaoxiongmao.jpg',
    ),
    StickerItem(
      name: '仙子',
      bundleName: 'xianzi.bundle',
      icon: 'assets/icons/xianzi.png',
    ),
    StickerItem(
      name: '星星',
      bundleName: 'xingxing.bundle',
      icon: 'assets/icons/xingxing.png',
    ),
    StickerItem(
      name: '熊耳朵',
      bundleName: 'xiongerduo.bundle',
      icon: 'assets/icons/xiongerduo.jpg',
    ),
  ];
}
