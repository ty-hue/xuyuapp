import 'package:bilbili_project/api/Report/index.dart';
import 'package:bilbili_project/components/appBar_back_icon_btn.dart';
import 'package:bilbili_project/components/static_app_bar.dart';
import 'package:bilbili_project/components/with_statusBar_color.dart';
import 'package:bilbili_project/pages/Report/comps/report_type.dart';
import 'package:bilbili_project/routes/app_router.dart';
import 'package:bilbili_project/routes/report_routes/report_last_route.dart';
import 'package:bilbili_project/viewmodels/Report/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class ReportSecondPage extends StatefulWidget {
  final String firstReportTypeCode;
  ReportSecondPage({Key? key, required this.firstReportTypeCode})
    : super(key: key);

  @override
  State<ReportSecondPage> createState() => _ReportSecondPageState();
}

class _ReportSecondPageState extends State<ReportSecondPage> {
  int _selectedReport = -1;
  bool get isActive => _selectedReport != -1;
  List<ReportTypeItem> reportTypes = [];
  // 请求一级举报类型列表
  Future<void> _getReportTypeList() async {
    final response = await getSecondReportLevelsByFirstCode({
      'firstReportLevelCode': widget.firstReportTypeCode,
    });
    if (response.isNotEmpty) {
      setState(() {
        reportTypes = response;
      });
    } else {
      ReportLastRoute(
        firstReportTypeCode: widget.firstReportTypeCode,
        secondReportTypeCode: '-1',
      ).replace(context);
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getReportTypeList();
  }

  @override
  Widget build(BuildContext context) {
    return WithStatusbarColorView(
      statusBarColor: Color.fromRGBO(14, 16, 23, 1),
      child: Scaffold(
        appBar: StaticAppBar(
         
          title: '账号举报',
          statusBarHeight: MediaQuery.of(context).padding.top,
          backgroundColor: Color.fromRGBO(14, 16, 23, 1),
        ),
        body: ReportTypeView(
          selectedReport: _selectedReport,
          reportTypes: reportTypes,
          next: (reportTypeCode) {
            ReportLastRoute(
              firstReportTypeCode: widget.firstReportTypeCode,
              secondReportTypeCode: reportTypeCode.toString(),
            ).push(context);
          },
          changeSelectedReport: ({required int selectedReport}) {
            setState(() {
              _selectedReport = selectedReport;
            });
          },
        ),
      ),
    );
  }
}
