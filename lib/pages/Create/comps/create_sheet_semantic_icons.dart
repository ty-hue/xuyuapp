import 'package:flutter/material.dart';

/// 美颜 / 滤镜 sheet 缩略格使用的语义化矢量图标（不依赖 PNG，避免圆角裁切黑边）。
IconData? semanticIconForBeautyTitle(String title) {
  switch (title) {
    case '美白':
      return Icons.wb_sunny_outlined;
    case '红润':
      return Icons.water_drop_outlined;
    case '磨皮':
      return Icons.blur_on;
    case '亮眼':
      return Icons.remove_red_eye_outlined;
    case '锐化':
      return Icons.auto_fix_high;
    case '大眼':
      return Icons.zoom_in;
    case '瘦脸':
      return Icons.compress;
    case '背景虚化':
      return Icons.blur_circular;
    case '瘦颧骨':
      return Icons.face_outlined;
    case '下巴':
      return Icons.horizontal_rule;
    case '瘦下颔':
      return Icons.change_history;
    case '鼻梁':
      return Icons.swap_vert;
    case '额头':
      return Icons.arrow_circle_up_outlined;
    case '嘴巴':
      return Icons.mood;
    case '人中':
      return Icons.height;
    case '长鼻':
      return Icons.straighten;
    case '眼距':
      return Icons.space_bar;
    case '微笑嘴角':
      return Icons.sentiment_very_satisfied;
    case '开眼角':
      return Icons.open_in_full;
    default:
      return null;
  }
}

IconData? semanticIconForFilterTitle(String title) {
  switch (title) {
    case '初恋':
      return Icons.favorite;
    case '初心':
      return Icons.favorite_border;
    case '粉嫩':
      return Icons.palette_outlined;
    case '冷酷':
      return Icons.ac_unit;
    case '美味':
      return Icons.restaurant;
    case '奶茶':
      return Icons.local_cafe_outlined;
    case '拍立得':
      return Icons.camera_alt_outlined;
    case '清新':
      return Icons.eco_outlined;
    case '日系':
      return Icons.wb_twilight;
    case '日杂':
      return Icons.menu_book_outlined;
    case '唯美':
      return Icons.auto_awesome;
    default:
      return null;
  }
}
