import 'package:bilbili_project/api/Report/index.dart';
import 'package:bilbili_project/pages/Report/comps/report_type.dart';
import 'package:bilbili_project/routes/app_router.dart';
import 'package:bilbili_project/routes/report_routes/report_last_route.dart';
import 'package:bilbili_project/viewmodels/Report/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

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
      ).push(context);
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
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Color.fromRGBO(14, 16, 23, 1), // Android
        statusBarIconBrightness: Brightness.light, // Android 图标白色
        statusBarBrightness: Brightness.dark, // iOS 白字
      ),
      child: SafeArea(
        top: false,
        child: Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios_new, color: Colors.white),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            title: Text(
              '账号举报',
              style: TextStyle(color: Colors.white, fontSize: 18.sp),
            ),
            centerTitle: true,
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
      ),
    );
  }
}
