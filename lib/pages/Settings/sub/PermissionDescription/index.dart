import 'package:bilbili_project/api/Settings/index.dart';
import 'package:bilbili_project/components/static_app_bar.dart';
import 'package:bilbili_project/components/with_statusBar_color.dart';
import 'package:bilbili_project/constants/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class PermissionDescriptionPage extends StatefulWidget {
  PermissionDescriptionPage({Key? key}) : super(key: key);

  @override
  _PermissionDescriptionPageState createState() =>
      _PermissionDescriptionPageState();
}

class _PermissionDescriptionPageState extends State<PermissionDescriptionPage> {
  String permissionDescription = '''''';
  String title = '';
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    getPermissionDescription();
  }

  void getPermissionDescription() async {
    final response = await getAgreementByType(
      AgreementType.permissionDescription.typeCode,
    );
    setState(() {
      permissionDescription = response.content;
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
              '''$permissionDescription''',
              style: TextStyle(color: Colors.white, fontSize: 14.sp),
            ),
          ),
        ),
      ),
    );
  }
}
