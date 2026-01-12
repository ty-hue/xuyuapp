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
  void _openVisitorSettingSheet() async{
  final result =  await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
      ),
      builder: (BuildContext context) {
        return VisitorSettingSheet(
          initialValue: isShowVisitor,
        );
      },
    );
    if(result != null){
      setState(() {
        isShowVisitor = result;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(22, 24, 35, 1),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          '主页访客',
          style: TextStyle(fontSize: 18.sp, color: Colors.white),
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: () {
              _openVisitorSettingSheet();
            },
            child: Text('设置', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: Container(
        color: Color.fromRGBO(22, 24, 35, 1),
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        child: isShowVisitor ? OpenVisitorView() : CloseVisitorView(onTap: (bool isShow) async{
          setState(() {
            isShowVisitor = isShow;
          });
        },),
      )
    );
  }
}
