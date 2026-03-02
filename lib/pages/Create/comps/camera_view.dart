import 'package:bilbili_project/components/loading.dart';
import 'package:bilbili_project/components/select_dots.dart';
import 'package:bilbili_project/pages/Create/comps/auto_center_scroll_tabbar.dart';
import 'package:bilbili_project/pages/Create/comps/tool_bar.dart';
import 'package:bilbili_project/utils/PermissionUtils.dart';
import 'package:bilbili_project/viewmodels/Create/index.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';

class CameraView extends StatefulWidget {
  final double topVal;
  final String? fromUrl;
  final GifStatus gifStatus;
  final ValueChanged<GifStatus> onGifStatusChanged;
  final MicrophoneStatus microphoneStatus;
  final ValueChanged<MicrophoneStatus> onMicrophoneStatusChanged;
  final VoidCallback openCountDownSheet;
  final VoidCallback openSettingSheet;
  final bool speedMode;
  final ValueChanged<bool> onSpeedModeChanged;
  final FlashStatus flashStatus;
  final ValueChanged<FlashStatus> onFlashStatusChanged;
  final RecordDuration recordDuration;
  final ValueChanged<RecordDuration> onRecordDurationChanged;
  final int cameraSelectedIndex;
  final ValueChanged<int> onInSelectedIndexChanged;
  final List<String> cameraOptions;
  final List<String> speedOptions;
  final int speedSelectedIndex;
  final ValueChanged<int> onSpeedSelectedIndexChanged;
  CameraView({
    Key? key,
    required this.topVal,
    this.fromUrl,
    required this.gifStatus,
    required this.onGifStatusChanged,
    required this.microphoneStatus,
    required this.onMicrophoneStatusChanged,
    required this.openCountDownSheet,
    required this.openSettingSheet,
    required this.speedMode,
    required this.onSpeedModeChanged,
    required this.flashStatus,
    required this.onFlashStatusChanged,
    required this.recordDuration,
    required this.onRecordDurationChanged,
    required this.cameraSelectedIndex,
    required this.onInSelectedIndexChanged,
    required this.cameraOptions,
    required this.speedOptions,
    required this.speedSelectedIndex,
    required this.onSpeedSelectedIndexChanged,
  }) : super(key: key);

  @override
  _CameraViewState createState() => _CameraViewState();
}

class _CameraViewState extends State<CameraView> {
  // 图片读写权限
  bool _isPhotoPermissionGranted = false;
  // 相机权限 默认为永久拒绝
  PermissionStatus _cameraPermissionStatus = PermissionStatus.permanentlyDenied;
  // 麦克风权限 默认为永久拒绝
  PermissionStatus _microphonePermissionStatus =
      PermissionStatus.permanentlyDenied;
  CameraController? _cameraController; // 相机控制器
  late List<CameraDescription> _cameras; // 相机列表
  bool _isInitialized = false; // 相机是否初始化完成
  // 初始化相机
  Future<void> _initializeCamera() async {
    // 获取设备上的所有相机
    _cameras = await availableCameras();
    if (_cameras.isNotEmpty) {
      // 选择后置相机
      _cameraController = CameraController(
        _cameras[0], // 选择第一个相机，通常是后置相机
        ResolutionPreset.veryHigh, // 设置分辨率 1080p
        fps: 30, // 设置帧率为 30fps
        enableAudio: true, // 开启音频
      );

      // 初始化相机
      await _cameraController?.initialize();

      if (!mounted) return;

      setState(() {
        _isInitialized = true;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    () async {
      // 检查相册读写权限
      PermissionStatus photoValue =
          await Permissionutils.checkPhotoPermission();
      setState(() {
        _isPhotoPermissionGranted = photoValue == PermissionStatus.granted;
      });
      // 检查相机权限
      PermissionStatus cameraValue =
          await Permissionutils.checkCameraPermission();
      // 如果不是永久拒绝状态，那么就需要询问用户是否允许相机权限
      if (cameraValue != PermissionStatus.permanentlyDenied) {
        PermissionStatus _cameraValue =
            await Permissionutils.requestCameraPermission();
        setState(() {
          _cameraPermissionStatus = _cameraValue;
        });
      }
      // 检查麦克风权限
      PermissionStatus microphoneValue =
          await Permissionutils.checkMicrophonePermission();
      // 如果不是永久拒绝状态，那么就需要询问用户是否允许麦克风权限
      if (microphoneValue != PermissionStatus.permanentlyDenied) {
        PermissionStatus _microphoneValue =
            await Permissionutils.requestMicrophonePermission();
        setState(() {
          _microphonePermissionStatus = _microphoneValue;
        });
      }
      // 初始化相机
      if(isCompleteAllow){
        await _initializeCamera();
      }
    }();
  }

  // 是否完全允许相机和麦克风
  bool get isCompleteAllow {
    if (_cameraPermissionStatus == PermissionStatus.granted &&
        _microphonePermissionStatus == PermissionStatus.granted) {
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Stack(
        children: [
          // 视频流预览
          Positioned.fill(
            child: _isInitialized && isCompleteAllow
                ? CameraPreview(_cameraController!)
                : Container(),
          ),

          // 选择音乐
          Positioned(
            top: widget.topVal,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () {
                    print('选择音乐');
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      vertical: 10.0.h,
                      horizontal: 12.0.w,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8.0.r),
                      color: Colors.black.withOpacity(0.4),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      spacing: 2.0.w,
                      children: [
                        Icon(
                          Icons.music_note,
                          color: Colors.white,
                          size: 20.0.sp,
                        ),
                        Text(
                          '选择音乐',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14.0.sp,
                            decoration: TextDecoration.none, // ⭐关键
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          // 侧边操作栏
          Positioned(
            right: 0.w,
            top: widget.topVal + 10.h,
            child: ToolBar(
              cameraSelectedIndex: widget.cameraSelectedIndex,
              gifStatus: widget.gifStatus,
              onGifStatusChanged: (status) {
                widget.onGifStatusChanged(status);
              },
              microphoneStatus: widget.microphoneStatus,
              onMicrophoneStatusChanged: (status) {
                widget.onMicrophoneStatusChanged(status);
              },
              onCountDownChanged: () {
                widget.openCountDownSheet();
              },
              onSettingChanged: widget.openSettingSheet,
              onBeautyChanged: () {
                print('美颜');
              },
              onFilterChanged: () {
                print('滤镜');
              },
              onRotateChanged: () {
                print('旋转');
              },
              speedMode: widget.speedMode,
              onSpeedModeChanged: (mode) {
                widget.onSpeedModeChanged(mode);
              },
              flashStatus: widget.flashStatus,
              recordDuration: widget.recordDuration,
              onFlashStatusChanged: (status) {
                widget.onFlashStatusChanged(status);
              },
              onRecordDurationChanged: (duration) {
                widget.onRecordDurationChanged(duration);
              },
            ),
          ),
          // 底部操作栏
          Positioned(
            bottom: 20.0.h,
            left: 0,
            right: 0,
            child: Container(
              child: Column(
                spacing: 24.0.h,
                mainAxisSize: MainAxisSize.min,
                children: [
                  widget.speedMode
                      ? Container(
                          alignment: Alignment.center,
                          height: 40.h,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SelectDots(
                                width: MediaQuery.of(context).size.width * 0.7,
                                height: 40.h,
                                bgColor: Colors.black.withOpacity(0.3),
                                labels: widget.speedOptions,
                                selectedIndex: widget.speedSelectedIndex,
                                onChanged: widget.onSpeedSelectedIndexChanged,
                                borderRadius: 4.0.r,
                              ),
                            ],
                          ),
                        )
                      : Container(),
                  AutoCenterScrollTabBar(
                    itemSpacing: 20.0.w,
                    highlightHeight: 22.0.h,
                    highlightColor: Colors.white,
                    itemPadding: EdgeInsets.symmetric(horizontal: 2.0.w),
                    activeStyle: TextStyle(
                      fontSize: 14.0.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      decoration: TextDecoration.none,
                    ),
                    inactiveStyle: TextStyle(
                      fontSize: 14.0.sp,
                      color: Colors.white,
                      decoration: TextDecoration.none,
                    ),
                    initialIndex: widget.cameraSelectedIndex,
                    tabs: widget.cameraOptions,
                    onChanged: widget.onInSelectedIndexChanged,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: () {
                          print('选择特效');
                        },
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          spacing: 4.0.h,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8.0.r),
                              child: Image.asset(
                                'lib/assets/app_logo.png',
                                width: 50.0.w,
                                height: 50.0.h,
                              ),
                            ),
                            Text(
                              '特效',
                              style: TextStyle(
                                fontSize: 14.0.sp,
                                color: Colors.white,
                                decoration: TextDecoration.none,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        alignment: Alignment.topCenter,
                        child: GestureDetector(
                          onTap: () {
                            print('开始录制');
                          },
                          child: Container(
                            alignment: Alignment.center,
                            width: 64.0.w,
                            height: 64.0.h,
                            decoration: BoxDecoration(
                              color: Colors.transparent,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white,
                                width: 3.0.w,
                              ),
                            ),
                            child: Container(
                              width: 48.0.w,
                              height: 48.0.h,
                              decoration: BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          if (_isPhotoPermissionGranted) {
                            // 打开相册
                            print('打开相册');
                          } else {
                            openAppSettings();
                          }
                        },
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          spacing: 4.0.h,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8.0.r),
                              child: _isPhotoPermissionGranted
                                  ? Image.asset(
                                      'lib/assets/app_logo.png',
                                      width: 50.0.w,
                                      height: 50.0.h,
                                    )
                                  : Icon(
                                      Icons.photo_library,
                                      size: 50.0.w,
                                      color: Colors.white,
                                    ),
                            ),
                            Text(
                              '相册',
                              style: TextStyle(
                                fontSize: 14.0.sp,
                                color: Colors.white,
                                decoration: TextDecoration.none,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          !isCompleteAllow
              ? Positioned.fill(
                  child: Container(
                    alignment: Alignment.center,
                    color: Colors.black.withOpacity(0.9),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '在絮语APP拍摄',
                          style: TextStyle(
                            fontSize: 22.0.sp,
                            color: Colors.white,
                            decoration: TextDecoration.none,
                            letterSpacing: 2.0.w,
                          ),
                        ),
                        SizedBox(height: 6.0.h),
                        Text(
                          '开启以下权限即可进入拍摄',
                          style: TextStyle(
                            fontSize: 13.0.sp,
                            color: Colors.grey,
                            decoration: TextDecoration.none,
                          ),
                        ),
                        SizedBox(height: 20.0.h),
                        Column(
                          spacing: 20.0.h,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _cameraPermissionStatus != PermissionStatus.granted
                                ? SizedBox(
                                    width:
                                        MediaQuery.of(context).size.width * 0.6,
                                    height: 50.0.h,
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Color.fromRGBO(
                                          41,
                                          41,
                                          41,
                                          1,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            8.0.r,
                                          ),
                                        ),
                                      ),
                                      onPressed: () {
                                        openAppSettings();
                                      },
                                      child: Row(
                                        spacing: 8.0.w,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.camera_alt,
                                            color: Colors.white,
                                            size: 24.0.sp,
                                          ),
                                          SizedBox(width: 8.0.w),
                                          Text(
                                            '开启相机',
                                            style: TextStyle(
                                              fontSize: 14.0.sp,
                                              color: Colors.white,
                                              decoration: TextDecoration.none,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  )
                                : Container(),
                            _microphonePermissionStatus !=
                                    PermissionStatus.granted
                                ? SizedBox(
                                    width:
                                        MediaQuery.of(context).size.width * 0.6,
                                    height: 50.0.h,
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Color.fromRGBO(
                                          41,
                                          41,
                                          41,
                                          1,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            8.0.r,
                                          ),
                                        ),
                                      ),
                                      onPressed: () {
                                        openAppSettings();
                                      },
                                      child: Row(
                                        spacing: 8.0.w,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.mic,
                                            color: Colors.white,
                                            size: 24.0.sp,
                                          ),
                                          SizedBox(width: 8.0.w),
                                          Text(
                                            '开启麦克风',
                                            style: TextStyle(
                                              fontSize: 14.0.sp,
                                              color: Colors.white,
                                              decoration: TextDecoration.none,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  )
                                : Container(),
                          ],
                        ),
                      ],
                    ),
                  ),
                )
              : Container(),
          Positioned.fill(
            child: !_isInitialized && isCompleteAllow
                ? Container(
                    color: Colors.black.withOpacity(0.9),
                    child: FetchLoadingView(),
                  )
                : Container(),
          ),
          // 返回按钮
          Positioned(
            left: 20.0.w,
            top: widget.topVal,
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 10.0.h),
              child: GestureDetector(
                onTap: () {
                  if (widget.fromUrl != null) {
                    context.pop(widget.fromUrl);
                  } else {
                    context.pop();
                  }
                },
                child: Icon(Icons.close, color: Colors.white, size: 26.0.sp),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
