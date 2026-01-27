import 'package:bilbili_project/components/appBar_text_btn.dart';
import 'package:bilbili_project/components/static_app_bar.dart';
import 'package:bilbili_project/components/with_statusBar_color.dart';
import 'package:bilbili_project/pages/Mine/sub/Visitor/comps/close_visitor_view.dart';
import 'package:bilbili_project/pages/Mine/sub/Visitor/comps/open_visitor_view.dart';
import 'package:bilbili_project/pages/Mine/sub/Visitor/comps/visitor_setting_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class VisitorPage extends StatefulWidget {
  VisitorPage({Key? key}) : super(key: key);

  @override
  State<VisitorPage> createState() => _VisitorPageState();
}

class _VisitorPageState extends State<VisitorPage> {
  bool isShowVisitor = false;
  void _openVisitorSettingSheet() async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
      ),
      builder: (BuildContext context) {
        return VisitorSettingSheet(initialValue: isShowVisitor);
      },
    );
    if (result != null) {
      setState(() {
        isShowVisitor = result;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return WithStatusbarColorView(
      statusBarColor: Color.fromRGBO(22, 24, 35, 1),
      child: Scaffold(
        appBar: StaticAppBar(
          title: '主页访客',
          statusBarHeight: MediaQuery.of(context).padding.top,
          backgroundColor: Color.fromRGBO(22, 24, 35, 1),
          actions: [
            AppBarTextBtn(
              onTap: () {
                _openVisitorSettingSheet();
              },
              text: '设置',
            ),
          ],
        ),
        body: Container(
          color: Color.fromRGBO(22, 24, 35, 1),
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: isShowVisitor
              ? OpenVisitorView()
              : CloseVisitorView(
                  onTap: (bool isShow) async {
                    setState(() {
                      isShowVisitor = isShow;
                    });
                  },
                ),
        ),
      ),
    );
  }
}
