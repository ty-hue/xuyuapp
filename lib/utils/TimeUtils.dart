class Timeutils {
  // 格式化视频时长为 HH:MM:SS 格式
  static String formatDuration(double milliseconds) {
  int seconds = (milliseconds / 1000).floor();
  int minutes = (seconds / 60).floor();
  seconds = seconds % 60;
  int hours = (minutes / 60).floor();
  minutes = minutes % 60;

  // 只有当小时不为零时才显示小时部分
  String hoursStr = hours > 0 ? hours.toString().padLeft(2, '0') + ':' : '';
  String minutesStr = minutes.toString().padLeft(2, '0');
  String secondsStr = seconds.toString().padLeft(2, '0');
  
  return "$hoursStr$minutesStr:$secondsStr";
}
}
