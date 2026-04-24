import 'package:bilbili_project/pages/Mine/sub/EditProfile/comps/age_picker_sheet_skeleton.dart';
import 'package:bilbili_project/pages/Mine/sub/EditProfile/comps/sex_sheet_skeleton.dart';
import 'package:bilbili_project/pages/Mine/sub/EditProfile/sub/UpdateUserInfoField/params/params.dart';
import 'package:bilbili_project/routes/app_router.dart';
import 'package:bilbili_project/routes/mine_routes/select_country_route.dart';
import 'package:bilbili_project/utils/SheetUtils.dart';
import 'package:bilbili_project/viewmodels/EditProfile/index.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';

class EditProfilePage extends StatefulWidget {
  final AddressResult? address;
  final bool? dontSettingAddress;
  EditProfilePage({Key? key, this.address, this.dontSettingAddress})
    : super(key: key);

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage>
    with TickerProviderStateMixin {
  double _extraPicHeight = 0.0;
  late double prevDy;
  AnimationController? _animationController;
  Animation<double>? _anim;
  @override
  void initState() {
    super.initState();
    if (widget.address != null) {
      print('选择的地址编号集合是：${widget.address?.toString()},请发请求更新地址信息');
    } else {
      if (widget.dontSettingAddress == true) {
        print('选择了‘暂不设置’，请发请求通知后端服务器将该用户的地址信息设置为空');
      }
    }
    prevDy = 0.0;
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );
    _anim = Tween<double>(begin: 0.0, end: 0).animate(_animationController!);
  }

  DateTime? selectedBirthday; // 选中的出生日期
  Future<void> _updateBirthday(DateTime date) async {
    // 在此处发送请求更新数据
    print('更新用户出生日期为：$date');
    setState(() {
      selectedBirthday = date;
    });
  }

  Future<void> _showAgePickerSheet() async {
    await SheetUtils(
      AgePickerSheetSkeleton(onConfirm: _updateBirthday),
    ).openAsyncSheet<bool>(context: context);
  }

  bool? selectedGender; // 选中的性别
  Future<void> _openSexSheet() async {
    final bool? isMale = await SheetUtils(
      SexSheetSkeleton(),
    ).openAsyncSheet<bool>(context: context);
    print('选中的性别是：$isMale');
    setState(() {
      selectedGender = isMale;
    });
  }

  void _updatePicHeight(double changed) {
    if (_extraPicHeight > 200.h) {
      return;
    }
    if (prevDy == 0.0) {
      prevDy = changed;
    }
    _extraPicHeight += changed - prevDy;
    prevDy = changed;

    setState(() {});
  }

  void _runAnimate() {
    setState(() {
      _anim =
          Tween(begin: _extraPicHeight, end: 0.0).animate(_animationController!)
            ..addListener(() {
              setState(() {
                _extraPicHeight = _anim!.value;
              });
            });
      prevDy = 0.0;
    });
  }

  Widget _buildCompleteProgress() {
    return Container(
      alignment: Alignment.centerRight,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 4.h,
            children: [
              // 进度条
              SizedBox(
                width: 100.w,
                child: LinearProgressIndicator(
                  value: 0.89,
                  backgroundColor: Colors.grey,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    const Color.fromARGB(255, 89, 127, 192),
                  ),
                  minHeight: 5.h,
                  borderRadius: BorderRadius.circular(4.r),
                ),
              ),
              Text.rich(
                TextSpan(
                  text: '资料完成度 ',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10.sp,
                    fontWeight: FontWeight.bold,
                  ),
                  children: [
                    TextSpan(
                      text: '89%',
                      style: TextStyle(
                        color: Colors.blueAccent,
                        fontSize: 10.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 头像
  Widget _buildAvatarInsideStack() {
    return Container(
      alignment: Alignment.center,
      child: Stack(
        children: [
          Container(
            width: 110.w,
            height: 110.h,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white, width: 2.w),
              shape: BoxShape.circle,
              image: DecorationImage(
                image: AssetImage('lib/assets/avatar.webp'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () {
                context.push(AllPhotoRoute().location);
              },
              child: Container(
                width: 110.w,
                height: 110.h,
                decoration: BoxDecoration(shape: BoxShape.circle),
                child: Column(
                  spacing: 4.h,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      FontAwesomeIcons.cameraRetro,
                      color: Colors.white,
                      size: 26.r,
                    ),
                    Text(
                      '更换头像',
                      style: TextStyle(color: Colors.white, fontSize: 18.r),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFlexibleHeader() {
    return Stack(
      children: [
        GestureDetector(
          onTap: () {
            PreviewRoute(
              mode: '1',
              tag: '',
              imageUrl:
                  'https://gips1.baidu.com/it/u=1024042145,2716310167&fm=3028&app=3028&f=JPEG&fmt=auto?w=1440&h=2560',
            ).push(context);
          },
          child: Image.network(
            'https://gips1.baidu.com/it/u=1024042145,2716310167&fm=3028&app=3028&f=JPEG&fmt=auto?w=1440&h=2560',
            width: MediaQuery.of(context).size.width,
            fit: BoxFit.cover,
          ),
        ),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            height: 90.h,
            decoration: BoxDecoration(
              color: Color.fromRGBO(22, 22, 22, 1),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20.r),
                topRight: Radius.circular(20.r),
              ),
              boxShadow: [
                BoxShadow(
                  color: Color.fromRGBO(22, 22, 22, 1),
                  spreadRadius: 0,
                  blurRadius: 0,
                  offset: Offset(0, 2.h),
                ),
              ],
            ),
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
            child: Stack(
              children: [
                Positioned(
                  top: 2.h,
                  right: 0,
                  left: 0,
                  child: _buildCompleteProgress(),
                ),
              ],
            ),
          ),
        ),
        // 头像独立放在最外层 Stack，避免上半部分点击命中到底图手势层。
        Positioned(
          left: 0,
          right: 0,
          bottom: 50.h,
          child: _buildAvatarInsideStack(),
        ),
      ],
    );
  }

  // 构建信息条目
  Widget _buildInfoItem({
    required String label,
    required String content,
    required VoidCallback fn,
  }) {
    return GestureDetector(
      onTap: () {
        fn();
      },
      child: SizedBox(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              flex: 3,
              child: Container(
                alignment: Alignment.centerLeft,
                child: Text(
                  label,
                  style: TextStyle(color: Colors.grey, fontSize: 16.sp),
                ),
              ),
            ),
            Expanded(
              flex: 7,
              child: Text(
                content,
                style: TextStyle(
                  color: label == '简介' ? Colors.grey : Colors.white,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  overflow: TextOverflow.ellipsis,
                ),
                maxLines: 1,
                textAlign: TextAlign.left,
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: Colors.grey,
              size: 16.r,
              fontWeight: FontWeight.bold,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: Scaffold(
        body: Listener(
          onPointerMove: (PointerMoveEvent event) {
            _updatePicHeight(event.position.dy);
          },
          onPointerUp: (PointerUpEvent event) {
            _runAnimate();
            _animationController!.forward(from: 0.0);
          },
          child: CustomScrollView(
            physics: ClampingScrollPhysics(),
            slivers: [
              SliverAppBar(
                leading: Container(
                  margin: EdgeInsets.only(left: 20.w),
                  child: GestureDetector(
                    onTap: () {
                      context.go('/mine');
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          padding: EdgeInsets.all(8.r),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(18.r),
                            color: Colors.black.withOpacity(0.44),
                          ),
                          child: Row(
                            spacing: 8.w,
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.arrow_back_ios_new,
                                color: Colors.white,
                                size: 14.r,
                                fontWeight: FontWeight.bold,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                centerTitle: true,
                pinned: true,
                floating: true,
                snap: true,
                expandedHeight: 260.h + _extraPicHeight,
                backgroundColor: Colors.black,
                flexibleSpace: FlexibleSpaceBar(
                  background: _buildFlexibleHeader(),
                ),
                elevation: 0,
                actions: [
                  Container(
                    margin: EdgeInsets.only(right: 20.w),
                    child: GestureDetector(
                      onTap: () {
                        context.push(
                          AllPhotoRoute().location,
                          extra: EditorConfig(
                            maxScale: 8.0,
                            cropRectPadding: const EdgeInsets.all(0),
                            hitTestSize: 20,

                            // 🔽 裁剪形状（你可以切换）
                            cropAspectRatio: 2.0, // 长方形
                            initCropRectType: InitCropRectType.imageRect,
                            // CropRectType.rect,
                            cornerColor: Colors.white,
                            lineColor: Colors.white,
                          ),
                        );
                      },
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            padding: EdgeInsets.all(8.r),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(18.r),
                              color: Colors.black.withOpacity(0.44),
                            ),
                            child: Row(
                              spacing: 8.w,
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Icon(
                                  FontAwesomeIcons.camera,
                                  color: Colors.white,
                                  size: 14.r,
                                  fontWeight: FontWeight.bold,
                                ),
                                Text(
                                  '更换封面',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12.r,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              SliverFillRemaining(
                hasScrollBody: false,
                child: Container(
                  decoration: BoxDecoration(
                    color: Color.fromRGBO(22, 22, 22, 1),
                    border: Border.all(
                      width: 0,
                      color: Color.fromRGBO(22, 22, 22, 1),
                    ),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: Column(
                    children: [
                      _buildInfoItem(
                        label: '名字',
                        content: 'llg',
                        fn: () {
                          context.push(
                            '/mine/edit_profile/update_user_info_field',
                            extra: UpdateUserInfoFieldParams(
                              title: '名字',
                              tip: '请输入新的名字',
                              maxLength: 20,
                              initialValue: 'llg',
                            ),
                          );
                        },
                      ),
                      SizedBox(height: 28.h),
                      _buildInfoItem(
                        label: '简介',
                        content: '介绍喜好、个性或@你的亲友',
                        fn: () {
                          context.push(
                            '/mine/edit_profile/update_user_info_field',
                            extra: UpdateUserInfoFieldParams(
                              title: '简介',
                              tip: '请输入新的简介',
                              maxLength: 100,
                              initialValue: '',
                            ),
                          );
                        },
                      ),
                      SizedBox(height: 28.h),
                      _buildInfoItem(
                        label: '性别',
                        content: '不展示',
                        fn: () {
                          _openSexSheet();
                        },
                      ),
                      SizedBox(height: 28.h),
                      _buildInfoItem(
                        label: '生日',
                        content: '不展示',
                        fn: () {
                          _showAgePickerSheet();
                        },
                      ),
                      SizedBox(height: 28.h),
                      _buildInfoItem(
                        label: '所在地',
                        content: '不展示',
                        fn: () {
                          SelectCountryRoute().push(context);
                        },
                      ),
                      SizedBox(height: 28.h),
                      _buildInfoItem(
                        label: '抖音号',
                        content: 'sdk199912',
                        fn: () {
                          context.push(
                            '/mine/edit_profile/update_user_info_field',
                            extra: UpdateUserInfoFieldParams(
                              title: '抖音号',
                              tip: '请输入新的抖音号',
                              maxLength: 16,
                              initialValue: 'sdk199912',
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      onWillPop: () async {
        context.pop();
        return true;
      },
    );
  }
}
