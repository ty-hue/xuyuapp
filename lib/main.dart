import 'package:bilbili_project/routes/index.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(
    MaterialApp.router(
      routerConfig: router,
      // 🌍 全局主题
      theme: ThemeData(
        useMaterial3: false, // 👈 关键
        primaryColor: Colors.blue,
        // Switch 全局样式
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
      ),
      // 🌙 暗黑模式（可选）
      darkTheme: ThemeData.dark(),
      themeMode: ThemeMode.light, // system / dark / light
    ),
  );
}
