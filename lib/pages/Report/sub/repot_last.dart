import 'package:bilbili_project/pages/Report/sub/report_second.dart';
import 'package:bilbili_project/routes/app_router.dart';
import 'package:bilbili_project/routes/report_routes/report_second_route.dart';
import 'package:bilbili_project/routes/report_routes/single_image_preview_route.dart';
import 'package:bilbili_project/utils/ToastUtils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:photo_manager/photo_manager.dart';

class ReportLastPage extends StatefulWidget {
  final String firstReportTypeCode;
  final String secondReportTypeCode;
  final List<AssetEntity> selectedImages;
  ReportLastPage({
    Key? key,
    required this.firstReportTypeCode,
    required this.secondReportTypeCode,
    required this.selectedImages,
  }) : super(key: key);

  @override
  State<ReportLastPage> createState() => _ReportLastPageState();
}

class _ReportLastPageState extends State<ReportLastPage> {
  final TextEditingController _reportReasonController = TextEditingController();
  String _reportReason = '';
  List<Uint8List> _reportImages = [];
  bool get _isSubmitEnabled =>
      _reportReason.isNotEmpty || _reportImages.isNotEmpty;
  void _submitReport() async {
    print('发怂提交举报请求');
  }

  // 获取缩略图
  Future<void> _getThumbnailData() async {
    for (final photo in widget.selectedImages) {
      final thumbnailData = await photo.thumbnailDataWithSize(
        ThumbnailSize(200.0.w.toInt(), 200.0.h.toInt()),
      );
      if (thumbnailData != null) {
        _reportImages.add(thumbnailData);
      }
    }
    if (!mounted) return;
    setState(() {});
  }

  List<Widget> _buildReportImageWidgets() {
    return _reportImages
        .map(
          (image) => GestureDetector(
            onTap: () {},
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8.r),
              child: Container(
                // margin: EdgeInsets.all(4.0.r),
                child: Stack(
                  children: [
                    Image.memory(
                      image,
                      width: 60.w,
                      height: 60.h,
                      fit: BoxFit.cover,
                    ),
                    Positioned(
                      right: 0,
                      top: 0,
                      child: GestureDetector(
                        onTap: () {
                          // 删除选中（跨相册生效）
                          setState(() {
                            _reportImages.remove(image);
                          });
                        },
                        child: Container(
                          width: 18.0.r,
                          height: 18.0.r,
                          decoration: BoxDecoration(
                            color: Color.fromRGBO(12, 9, 6, 1),
                            borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(6.0.r),
                            ),
                          ),
                          child: Icon(
                            FontAwesomeIcons.xmark,
                            size: 10.0.r,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        )
        .toList();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getThumbnailData();
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
                context.pop(context);
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
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            spacing: 8.w,
                            children: [
                              // 已选择图片列表
                              ..._buildReportImageWidgets(),
                              GestureDetector(
                                onTap: () {
                                  if (_reportImages.length >= 4) {
                                    ToastUtils.showToast(
                                      context,
                                      msg: '最多上传4张图片',
                                    );
                                    return;
                                  }
                                  // 打开图片选择器
                                  AllPhotoRoute(
                                    isMultiple: true,
                                    firstReportTypeCode:
                                        widget.firstReportTypeCode,
                                    secondReportTypeCode:
                                        widget.secondReportTypeCode,
                                    featureCode: 1,
                                  ).push(context);
                                },
                                child: Container(
                                  alignment: Alignment.center,
                                  height: 60.h,
                                  width: 60.w,
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
                                        '${_reportImages.length}/4',
                                        style: TextStyle(
                                          color: Color.fromRGBO(
                                            106,
                                            106,
                                            106,
                                            1,
                                          ),
                                          fontSize: 12.sp,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
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
