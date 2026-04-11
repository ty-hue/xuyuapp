import 'package:bilbili_project/api/Settings/index.dart';
import 'package:bilbili_project/components/static_app_bar.dart';
import 'package:bilbili_project/components/with_statusBar_color.dart';
import 'package:bilbili_project/constants/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class UserAgreementPage extends StatefulWidget {
  UserAgreementPage({Key? key}) : super(key: key);

  @override
  _UserAgreementPageState createState() => _UserAgreementPageState();
}

class _UserAgreementPageState extends State<UserAgreementPage> {
  String userAgreement = '''''';
  String title = '';
  bool isLoading = true;
  @override
  void initState() {
    super.initState();
    getUserAgreement();
  }

  void getUserAgreement() async {
    final response = await getAgreementByType(
      AgreementType.userAgreement.typeCode,
    );
    setState(() {
      userAgreement = response.content;
      title = response.title;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return WithStatusbarColorView(
      statusBarColor: Color.fromRGBO(29, 31, 43, 1),
      child: Scaffold(
        appBar: StaticAppBar(
          statusBarHeight: MediaQuery.of(context).padding.top,
          backgroundColor: Color.fromRGBO(29, 31, 43, 1),
          title: title,
        ),
        body: Container(
          color: Color.fromRGBO(29, 31, 43, 1),
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
          child: SingleChildScrollView(
            child: Text(
              '''$userAgreement''',
              style: TextStyle(color: Colors.white, fontSize: 14.sp),
            ),
          ),
        ),
      ),
    );
  }
}
