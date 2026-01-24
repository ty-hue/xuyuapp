import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ReportLastPage extends StatefulWidget {
  final String firstReportTypeCode;
  final String secondReportTypeCode;
  ReportLastPage({
    Key? key,
    required this.firstReportTypeCode,
    required this.secondReportTypeCode,
  }) : super(key: key);

  @override
  State<ReportLastPage> createState() => _ReportLastPageState();
}

class _ReportLastPageState extends State<ReportLastPage> {
  final TextEditingController _reportReasonController = TextEditingController();
  String _reportReason = '';
  List<String> _reportImages = [];
  bool get _isSubmitEnabled =>
      _reportReason.isNotEmpty || _reportImages.isNotEmpty;
  void _submitReport() async {
    print('发怂提交举报请求');
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
          body: Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
            decoration: BoxDecoration(color: Color.fromRGBO(14, 16, 23, 1)),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Column(
                      spacing: 4.h,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '举报理由',
                          style: TextStyle(
                            color: Color.fromRGBO(127, 129, 134, 1),
                            fontSize: 14.sp,
                          ),
                        ),
                        Text(
                          '网暴他人',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16.sp,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20.h),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 20.w,
                        vertical: 20.h,
                      ),
                      decoration: BoxDecoration(
                        color: Color.fromRGBO(22, 22, 22, 1),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Column(
                        spacing: 4.h,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '举报描述',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14.sp,
                            ),
                          ),
                          SizedBox(height: 12.h),
                          Form(
                            child: TextFormField(
                              onChanged: (value) {
                                setState(() {
                                  _reportReason = value;
                                });
                              },
                              controller: _reportReasonController,
                              maxLines: 5,
                              maxLength: 200,
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: Colors.white,
                              ),
                              decoration: InputDecoration(
                                hintText: '请详细填写，以提高举报成功率',
                                counterText: '0/200',
                                hintStyle: TextStyle(
                                  fontSize: 12.sp,
                                  color: Colors.grey[500],
                                ),
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 12.w, // 左右内边距
                                  vertical: 12.h, // 上下内边距
                                ),
                                fillColor: Color.fromRGBO(29, 29, 29, 1),
                                filled: true,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(
                                    10.r,
                                  ), // ✅ 圆角
                                  borderSide: BorderSide.none, // ✅ 无边框
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.r),
                                  borderSide: BorderSide.none,
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.r),
                                  borderSide: BorderSide.none,
                                ),
                                errorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.r),
                                  borderSide: BorderSide.none,
                                ),
                                disabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.r),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 20.h),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 20.w,
                        vertical: 20.h,
                      ),
                      decoration: BoxDecoration(
                        color: Color.fromRGBO(22, 22, 22, 1),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Column(
                        spacing: 4.h,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '图片材料提交',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14.sp,
                            ),
                          ),
                          SizedBox(height: 12.h),
                          GestureDetector(
                            onTap: () {
                              // 打开图片选择器
                              print('打开图片选择器');
                            },
                            child: Container(
                              alignment: Alignment.center,
                              height: 80.h,
                              width: 80.w,
                              decoration: BoxDecoration(
                                color: Color.fromRGBO(29, 29, 29, 1),
                                borderRadius: BorderRadius.circular(6.r),
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                spacing: 4.h,
                                children: [
                                  Icon(
                                    Icons.add,
                                    color: Color.fromRGBO(106, 106, 106, 1),
                                    size: 30.sp,
                                  ),
                                  Text(
                                    '0/4',
                                    style: TextStyle(
                                      color: Color.fromRGBO(106, 106, 106, 1),
                                      fontSize: 12.sp,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  width: double.infinity,
                  height: 48.h,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isSubmitEnabled
                          ? Color.fromRGBO(31, 94, 253, 1)
                          : Color.fromRGBO(10, 32, 86, 1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                    ),
                    onPressed: _isSubmitEnabled ? () => _submitReport() : null,
                    child: Text(
                      '提交',
                      style: TextStyle(
                        color: _isSubmitEnabled
                            ? Colors.white
                            : Colors.white.withOpacity(0.5),
                        fontSize: 16.sp,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
