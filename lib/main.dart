import 'package:bilbili_project/routes/index.dart';
import 'package:bilbili_project/utils/app_messenger.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // 全应用默认竖屏；仅横屏全屏播放入口内会临时改为仅横屏。
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(
    ProviderScope(
      child: ScreenUtilInit(
        designSize: const Size(426.7, 952.0), // ⚡设计稿尺寸，iPhone X 尺寸行业标准
        minTextAdapt: true, // ⚡文字自适应，防止小屏文字溢出
        splitScreenMode: true, // ⚡支持折叠屏 / 分屏
        builder: (context, child) => MaterialApp.router(
          scaffoldMessengerKey: AppMessenger.scaffoldMessengerKey,
          routerConfig: router,
          // 🌍 全局主题
          theme: ThemeData(
            useMaterial3: false, 
            switchTheme: SwitchThemeData(
              trackColor: MaterialStateProperty.resolveWith((states) {
                if (states.contains(MaterialState.selected)) {
                  return Color.fromRGBO(53, 223, 135, 1);
                }
                return Colors.grey.shade300;
              }),
              thumbColor: MaterialStateProperty.all(Colors.white),
              trackOutlineColor: MaterialStateProperty.all(Colors.transparent),
            ),

            // 字体 / 文本
            textTheme: const TextTheme(bodyMedium: TextStyle(fontSize: 14)),
            // Scaffold 统一背景色
            scaffoldBackgroundColor: Colors.white,
            bottomSheetTheme: const BottomSheetThemeData(
              elevation: 0,
              modalElevation: 0,
              shadowColor: Colors.transparent,
            ),
          ),
          // 🌙 暗黑模式（可选）
          // darkTheme: ThemeData.dark(),
          // themeMode: ThemeMode.light, // system / dark / light
        ),
      ),
    ),
  );
}
