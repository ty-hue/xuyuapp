import 'package:bilbili_project/components/appBar_text_btn.dart';
import 'package:bilbili_project/components/static_app_bar.dart';
import 'package:bilbili_project/components/switch_sheet_skeleton.dart';
import 'package:bilbili_project/components/with_statusBar_color.dart';
import 'package:bilbili_project/pages/Mine/sub/Visitor/comps/close_visitor_view.dart';
import 'package:bilbili_project/pages/Mine/sub/Visitor/comps/open_visitor_view.dart';
import 'package:bilbili_project/utils/SheetUtils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class VisitorPage extends StatefulWidget {
  VisitorPage({Key? key}) : super(key: key);

  @override
  State<VisitorPage> createState() => _VisitorPageState();
}

class _VisitorPageState extends State<VisitorPage> {
  bool isShowVisitor = false;
  Future<void> _openSwitchSheet({
    required String title,
    required String subTitle,
    required String label,
    required bool value,
    bool immediatelyClose = true,
    bool isNeedCloseIcon = true,
  }) async {
    final result = await SheetUtils(
      SwitchSheetSkeleton(
        immediatelyClose: immediatelyClose,
        title: title,
        subTitle: subTitle,
        label: label,
        value: value,
        isNeedCloseIcon: isNeedCloseIcon,
      ),
    ).openAsyncSheet<bool>(context: context);
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
                _openSwitchSheet(
                  title: '主页访客',
                  subTitle: '关闭后，你查看他人主页时不会留下记录，同时，你也无法查看谁访问了你的主页。',
                  label: '展示主页访客',
                  value: isShowVisitor,
                );
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
