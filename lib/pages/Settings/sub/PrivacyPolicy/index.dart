import 'package:bilbili_project/api/Settings/index.dart';
import 'package:bilbili_project/components/loading.dart';
import 'package:bilbili_project/components/static_app_bar.dart';
import 'package:bilbili_project/components/with_statusBar_color.dart';
import 'package:bilbili_project/constants/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class PrivacyPolicyPage extends StatefulWidget {
  PrivacyPolicyPage({Key? key}) : super(key: key);

  @override
  _PrivacyPolicyPageState createState() => _PrivacyPolicyPageState();
}

class _PrivacyPolicyPageState extends State<PrivacyPolicyPage> {
  String privacyPolicy = '''
 ''';
  String title = '';
  bool isLoading = true;
  @override
  void initState() {
    super.initState();
    getPrivacyPolicy();
  }

  void getPrivacyPolicy() async {
    final response = await getAgreementByType(
      AgreementType.privacyPolicy.typeCode,
    );
    isLoading = false;
    setState(() {
      privacyPolicy = response.content;
      title = response.title;
    });
  }

  @override
  Widget build(BuildContext context) {
    return WithStatusbarColorView(
      statusBarColor: Color.fromRGBO(29, 31, 43, 1),
      child: isLoading
          ? Center(child: FetchLoadingView())
          : Scaffold(
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
                    '''$privacyPolicy''',
                    style: TextStyle(color: Colors.white, fontSize: 14.sp),
                  ),
                ),
              ),
            ),
    );
  }
}
