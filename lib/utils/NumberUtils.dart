class NumberUtils {
  // 格式化 （大于10000 时，保留1位小数，‘万’为单位）
  static String formatLikeCount(int count) {
    if (count < 10000) {
      return count.toString();
    } else {
      double value = count / 10000;
      return "${value.toStringAsFixed(1)}万";
    }
  }
}
