import 'package:bilbili_project/components/select_sheet_skeleton.dart';
import 'package:bilbili_project/components/static_app_bar.dart';
import 'package:bilbili_project/components/with_statusBar_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ThemePage extends StatefulWidget {
  ThemePage({Key? key}) : super(key: key);

  @override
  State<ThemePage> createState() => _ThemePageState();
}

class _ThemePageState extends State<ThemePage> {
  String themeValue = '0';
  final List<Map<String, String>> themeOptions = [
    {'value': '0', 'title': '浅色', 'subTitle': ''},
    {'value': '1', 'title': '经典', 'subTitle': ''},
    {'value': '2', 'title': '跟随系统', 'subTitle': ''},
  ];
  @override
  Widget build(BuildContext context) {
    return WithStatusbarColorView(
      statusBarColor: Color.fromRGBO(22, 24, 36, 1),
      child: Scaffold(
        appBar: StaticAppBar(
          backgroundColor: Color.fromRGBO(22, 24, 36, 1),
          statusBarHeight: MediaQuery.of(context).padding.top,
          title: '背景设置',
        ),
        body: Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(color: Color.fromRGBO(22, 24, 36, 1)),
          child: Column(
            children: [
              SelectSheetSkeleton(
                itemTitleColor: Colors.white,
                itemIconColor: Color.fromRGBO(244, 52, 106, 1),
                innerBoxColor: Color.fromRGBO(29, 31, 43, 1),
                itemHeight: 54.h,
                borderRadius: Radius.circular(0.r),
                backgroundColor: Colors.transparent,
                outBoxPadding: EdgeInsets.zero,
                immediatelyClose: false,
                label: '背景设置',
                value: themeValue,
                onChanged: (value) {
                  setState(() {
                    themeValue = value;
                  });
                },
                items: themeOptions,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
