import 'dart:io';

import 'package:bilbili_project/components/loading.dart';
import 'package:bilbili_project/components/select_dots.dart';
import 'package:bilbili_project/constants/index.dart';
import 'package:bilbili_project/pages/Create/comps/auto_center_scroll_tabbar.dart';
import 'package:bilbili_project/pages/Create/comps/beautyfiter_sheet_sekeleton.dart';
import 'package:bilbili_project/pages/Create/comps/record_video_btn.dart';
import 'package:bilbili_project/pages/Create/comps/sticker_sheet_sekeleton.dart';
import 'package:bilbili_project/pages/Create/comps/take_photo_btn.dart';
import 'package:bilbili_project/pages/Create/comps/tool_bar.dart';
import 'package:bilbili_project/utils/PermissionUtils.dart';
import 'package:bilbili_project/utils/SheetUtils.dart';
import 'package:bilbili_project/viewmodels/Create/index.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:popover/popover.dart';

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
  final ValueChanged<RecordStatus> onRecordStatusChanged;
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
    required this.onRecordStatusChanged,
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

  File? latestImage; // 最近拍摄的最新的照片

  // 获取相册中最近拍摄的一张照片
  Future<File?> getLatestImage() async {
    // 1 获取“全部照片”相册
    final albums = await PhotoManager.getAssetPathList(
      type: RequestType.image,
      onlyAll: true,
    );

    if (albums.isEmpty) return null;

    // 3 获取最近照片相册
    final recentAlbum = albums.first;

    // 4 获取最新的一张
    final assets = await recentAlbum.getAssetListPaged(page: 0, size: 1);

    if (assets.isEmpty) return null;

    // 5 获取原图
    final file = await assets.first.originFile;

    return file;
  }

  @override
  void initState() {
    super.initState();
    () async {
      // 检查相册读写权限
      PermissionStatus photoValue =
          await Permissionutils.checkPhotoPermission();
          // 如果有权限，获取最近拍摄的照片
      if (photoValue == PermissionStatus.granted) {
        latestImage = await getLatestImage();
        if (latestImage != null) {
          setState(() {});
        }
      }
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
      if (isCompleteAllow) {
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

  // 滤镜数据
  List<BeautyItem> filterOptions = createFilterList();

  // 美颜数据
  List<BeautyItem> beautyOptions = createBeautyList();
  // 修改美颜数据
  void setBeautyOptions(BeautyItem item, double value, bool flag) {
    if (item.type != null) {
      int index = -1;
      if (flag) {
        index = beautyOptions.indexWhere(
          (element) => element.type == item.type,
        );
      } else {
        index = filterOptions.indexWhere(
          (element) => element.filterType == item.filterType,
        );
      }
      if (index != -1) {
        beautyOptions[index].value = value;
      }
      setState(() {});
    } else {
      // 将所有value设置为0
      setState(() {
        if (flag) {
          for (var element in beautyOptions) {
            element.value = 0.0;
          }
        } else {
          for (var element in filterOptions) {
            element.value = 0.0;
          }
        }
      });
    }
  }

  // 重置美颜数据
  void resetBeautyOptions(bool flag) {
    setState(() {
      final originalData = flag ? createBeautyList() : createFilterList();
      if (flag) {
        beautyOptions.forEach((element) {
          element.value = originalData
              .firstWhere((item) => item.type == element.type)
              .value;
        });
      } else {
        filterOptions.forEach((element) {
          element.value = originalData
              .firstWhere((item) => item.filterType == element.filterType)
              .value;
        });
      }
    });
  }

  int selectedBeautyIndex = -1;
  void onBeautySelectedIndexChanged(int index) {
    setState(() {
      selectedBeautyIndex = index;
    });
  }

  // 打开美颜sheet
  void openBeautyfiterSheet() {
    SheetUtils(
      BeautyfiterSheetSekeleton(
        title: '美颜',
        beautyItems: beautyOptions,
        setBeautyOptions: setBeautyOptions,
        resetBeautyOptions: resetBeautyOptions,
        flag: true,
        initSelectedIndex: selectedBeautyIndex,
        onSelectedIndexChanged: onBeautySelectedIndexChanged,
      ),
    ).openAsyncSheet(context: context, barrierColor: Colors.transparent);
  }

  int selectedFilterIndex = -1;
  void onFilterSelectedIndexChanged(int index) {
    setState(() {
      selectedFilterIndex = index;
    });
  }

  // 打开滤镜sheet
  void openFiterSheet() {
    SheetUtils(
      BeautyfiterSheetSekeleton(
        title: '滤镜',
        beautyItems: filterOptions,
        setBeautyOptions: setBeautyOptions,
        resetBeautyOptions: resetBeautyOptions,
        flag: false,
        initSelectedIndex: selectedFilterIndex,
        onSelectedIndexChanged: onFilterSelectedIndexChanged,
      ),
    ).openAsyncSheet(context: context, barrierColor: Colors.transparent);
  }

  // 贴纸数据
  List<StickerItem> stickerOptions = createStickerList();
  int selectedStickerIndex = -1;
  Future<void> onStickerSelectedIndexChanged(int index) async {
    setState(() {
      selectedStickerIndex = index;
    });
    // 后续，这里做真实的特效加载逻辑 （是异步的）
    await Future.delayed(Duration(seconds: 1));
  }

  // 重置特效索引
  void resetStickerIndex() {
    setState(() {
      selectedStickerIndex = -1;
    });
  }

  // 打开贴纸sheet
  void openStickerSheet() {
    SheetUtils(
      StickerSheetSekeleton(
        resetStickerIndex: resetStickerIndex,
        title: '特效',
        stickerItems: stickerOptions,
        onSelectedIndexChanged: onStickerSelectedIndexChanged,
        initSelectedIndex: selectedStickerIndex,
      ),
    ).openAsyncSheet(context: context, barrierColor: Colors.transparent);
  }

  // 按钮状态
  RecordStatus recordStatus = RecordStatus.normal;
  // 录制状态改变
  void onRecordStatusChanged(RecordStatus status) {
    setState(() {
      recordStatus = status;
    });
  }

  // 变动ui函数
  void changeUI(RecordStatus status) {
    widget.onRecordStatusChanged(status);
    setState(() {
      recordStatus = status;
    });
  }

  // 开始录制
  void startRecording() {
    changeUI(RecordStatus.recording);
  }

  // 停止录制
  void stopRecording() {
    changeUI(RecordStatus.end);
  }

  // 拍照
  void takePhoto() {
    changeUI(RecordStatus.end);
  }

  Widget backUI(BuildContext contextBtn) {
    switch (recordStatus) {
      case RecordStatus.normal:
        return GestureDetector(
          onTap: () {
            if (widget.fromUrl != null) {
              context.pop(widget.fromUrl);
            } else {
              context.pop();
            }
          },
          child: Icon(Icons.close, color: Colors.white, size: 26.0.sp),
        );
      case RecordStatus.recording:
        return Container();
      case RecordStatus.end:
        return GestureDetector(
          onTap: () {
            showPopover(
              context: contextBtn,
              bodyBuilder: (context) => Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          changeUI(RecordStatus.normal);
                          context.pop();
                        },
                        splashColor: Color.fromRGBO(207, 72, 53, 0.2),
                        highlightColor: Color.fromRGBO(207, 72, 53, 0.1),
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20.w),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            spacing: 4.0.w,
                            children: [
                              Icon(
                                Icons.arrow_back_ios,
                                size: 26.0.sp,
                                color: Color.fromRGBO(207, 72, 53, 1),
                              ),
                              Text(
                                '不保存返回',
                                style: TextStyle(
                                  color: Color.fromRGBO(207, 72, 53, 1),
                                  fontSize: 16.0.sp,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  Divider(height: 1.0.h),
                  Expanded(
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          changeUI(RecordStatus.normal);
                          context.pop();
                        },
                        splashColor: Color.fromRGBO(207, 72, 53, 0.2),
                        highlightColor: Color.fromRGBO(207, 72, 53, 0.1),
                        child: Padding(
                          padding: EdgeInsetsGeometry.symmetric(
                            horizontal: 20.w,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            spacing: 4.0.w,
                            children: [
                              Icon(
                                Icons.save,
                                size: 26.0.sp,
                                color: Color.fromRGBO(31, 30, 37, 1),
                              ),
                              Text(
                                '存草稿',
                                style: TextStyle(
                                  color: Color.fromRGBO(31, 30, 37, 1),
                                  fontSize: 16.0.sp,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              onPop: () => print('Popover was popped!'),
              direction: PopoverDirection.bottom,
              backgroundColor: Colors.white,
              width: 180.w,
              height: 100.h,
              arrowHeight: 15.h,
              arrowWidth: 30.w,
              allowClicksOnBackground: false,
              barrierColor: Colors.transparent,
            );
          },
          child: Icon(Icons.arrow_back_ios, color: Colors.white, size: 26.0.sp),
        );
    }
  }

  Widget get ButtonUI {
    switch (widget.cameraSelectedIndex) {
      case 0:
        return recordStatus != RecordStatus.end
            ? Align(
                alignment: Alignment.center,
                child: TakePhotoButton(
                  takePhoto: takePhoto,
                  recordStatus: recordStatus,
                ),
              )
            : Container();
      default:
        return recordStatus != RecordStatus.end
            ? Align(
                alignment: Alignment.center,
                child: RecordVideoButton(
                  startRecording: startRecording,
                  stopRecording: stopRecording,
                  recordStatus: recordStatus,
                ),
              )
            : Container();
    }
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
          recordStatus != RecordStatus.recording
              ? Positioned(
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
                )
              : Container(),
          // 侧边操作栏
          recordStatus != RecordStatus.end
              ? Positioned(
                  right: 0.w,
                  top: widget.topVal + 10.h,
                  child: ToolBar(
                    recordStatus: recordStatus,
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
                    onBeautyChanged: openBeautyfiterSheet,
                    onFilterChanged: openFiterSheet,
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
                )
              : Container(),
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

                  recordStatus == RecordStatus.normal
                      ? AutoCenterScrollTabBar(
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
                        )
                      : Container(),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 40.0.w),
                    child: Stack(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            recordStatus == RecordStatus.normal
                                ? GestureDetector(
                                    onTap: () {
                                      openStickerSheet();
                                    },
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      spacing: 4.0.h,
                                      children: [
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            8.0.r,
                                          ),
                                          child: selectedStickerIndex != -1
                                              ? Image.asset(
                                                  stickerOptions[selectedStickerIndex]
                                                      .icon,
                                                  fit: BoxFit.cover,
                                                  width: 50.0.w,
                                                  height: 50.0.h,
                                                )
                                              : Icon(
                                                  FontAwesomeIcons.pagelines,
                                                  color: Colors.white,
                                                  size: 50.0.w,
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
                                  )
                                : Container(),

                            recordStatus == RecordStatus.normal
                                ? GestureDetector(
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
                                          borderRadius: BorderRadius.circular(
                                            8.0.r,
                                          ),
                                          child: _isPhotoPermissionGranted
                                              ? Image.file(
                                                  latestImage!,
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
                                  )
                                : Container(),
                          ],
                        ),
                        ButtonUI,
                      ],
                    ),
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
            child: Builder(
              builder: (btnContext) {
                return Container(
                  padding: EdgeInsets.symmetric(vertical: 10.0.h),
                  child: backUI(btnContext), // ⭐ 这里传按钮自己的 context
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
