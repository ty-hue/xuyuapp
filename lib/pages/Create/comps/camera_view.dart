import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pixelfree_camera/pixelfree_camera.dart';
import 'package:popover/popover.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';
import 'package:bilbili_project/components/loading.dart';
import 'package:bilbili_project/pages/Create/comps/camera_grid_overlay.dart';
import 'package:bilbili_project/pages/Create/comps/countdown_show.dart';
import 'package:bilbili_project/pages/Create/comps/mini_music_sheet_skeleton.dart';
import 'package:bilbili_project/components/my_asset_picker_text_delegate.dart';
import 'package:bilbili_project/components/select_dots.dart';
import 'package:bilbili_project/constants/index.dart';
import 'package:bilbili_project/pages/Create/comps/auto_center_scroll_tabbar.dart';
import 'package:bilbili_project/pages/Create/comps/beautyfiter_sheet_sekeleton.dart';
import 'package:bilbili_project/pages/Create/comps/photo_preview.dart';
import 'package:bilbili_project/pages/Create/comps/record_video_btn.dart';
import 'package:bilbili_project/pages/Create/comps/sticker_sheet_sekeleton.dart';
import 'package:bilbili_project/pages/Create/comps/take_photo_btn.dart';
import 'package:bilbili_project/pages/Create/comps/timekeeping.dart';
import 'package:bilbili_project/pages/Create/comps/tool_bar.dart';
import 'package:bilbili_project/pages/Create/comps/video_preview.dart';
import 'package:bilbili_project/utils/PermissionUtils.dart';
import 'package:bilbili_project/utils/SheetUtils.dart';
import 'package:bilbili_project/viewmodels/Create/index.dart';

/// 底部「特效 / 相册」槽与图标相对原设计放大倍数（与拍照按钮 1.4 一致）。
const double _kBottomSideIconScale = 1.4;

/// 半透明块内图标相对块宽的比例（略小于 1，留白更舒服）。
const double _kBottomIconInTileRatio = 0.75;

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
  final int countdown;
  final bool isStartCountDown;
  final ValueChanged<bool> onIsStartCountDownChanged;
  final VoidCallback onCountdownFinished;
  final SettingSheetType settingSheetType;
  /// 父级算好的**整段预览槽**宽高（含上下黑边区域）。用于 [LayoutBuilder] 约束，使 UI 相对整槽定位。
  final double? previewSlotWidth;
  final double? previewSlotHeight;
  /// 实际拍摄画面区域高度（与比例一致，不含上下黑边）。传给 native 视口；若未传则按 [settingSheetType.aspectRatio] 由槽宽推算。
  final double? previewContentHeight;
  /// 预览区是否已有可展示的成片（含相册选片）；为 false 时父级可禁用「下一步」等。
  final ValueChanged<bool>? onPreviewReadyForNext;
  const CameraView({
    super.key,
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
    required this.countdown,
    required this.isStartCountDown,
    required this.onIsStartCountDownChanged,
    required this.onCountdownFinished,
    required this.settingSheetType,
    this.previewSlotWidth,
    this.previewSlotHeight,
    this.previewContentHeight,
    this.onPreviewReadyForNext,
  });

  @override
  CameraViewState createState() => CameraViewState();
}

class CameraViewState extends State<CameraView> with WidgetsBindingObserver {
  PermissionStatus _cameraPermissionStatus = PermissionStatus.granted;
  PermissionStatus _microphonePermissionStatus = PermissionStatus.granted;
  bool _isInitialized = false;
  /// 是否已成功打开过相机（本 State 生命周期内）。切换分辨率等重启时不再显示 [FetchLoadingView]。
  bool _hasEverInitializedCamera = false;
  bool _isRestartingCamera = false;
  /// 本机拍照成片 JPEG（内存）；与 [_pendingPhotoPath] 互斥，优先用内存预览。
  Uint8List? _pendingPhotoBytes;
  /// 相册选片等仍用路径；本机直拍见 [_pendingPhotoBytes]。
  String? _pendingPhotoPath;
  /// 录像成片本地路径，用 [VideoPreview] 直读文件预览，不写入系统相册。
  String? _pendingVideoPath;
  /// 停止录制后已进入「本机录像预览」流程（含路径未到、解码中）；loading 由 [VideoPreview] 内部负责。
  bool _cameraRecordedVideoPreview = false;
  /// [VideoPreview] 已解码并可展示播放器（相册/本机录像均走此标记）。
  bool _videoPlaybackReady = false;
  int? textureId;
  /// Native GL buffer size (portrait-normalized on Android). Used with [FittedBox] so the texture
  /// scales **uniformly** — [SizedBox.expand] on [Texture] stretches and elongates faces.
  double? _nativeBufferW;
  double? _nativeBufferH;
  final _cameraSdk = const PixelfreeCamera();
  final Map<String, String> _stickerAssetCache = {};
  CameraPosition _cameraPosition = CameraPosition.front;
  /// 前置无物理闪光灯时，由 native [onFrontFlashHint] 驱动全屏补光。
  bool _frontScreenFlashOverlay = false;
  double _frontFlashAlpha = 0.88;

  /// Last [LayoutBuilder] max width — fallback when [previewSlotWidth] is null.
  double? _layoutViewportW;
  bool _cameraOpenScheduled = false;

  /// 拍摄比例变更后略延后重启相机（设置 sheet 已延迟通知父级，此处只需短缓冲）。
  Timer? _cameraRestartAfterAspectTimer;

  Future<void> _syncPreviewSettings() async {
    if (!_isInitialized) return;
    await _cameraSdk.setFlashMode(_currentFlashMode);
    await _applyBeautyAndFilterAndSticker();
  }

  Future<void> _refreshPermissionsAndMaybeInit() async {
    final cameraStatus = await Permissionutils.checkCameraPermission();
    final microphoneStatus = await Permissionutils.checkMicrophonePermission();
    if (!mounted) return;
    setState(() {
      _cameraPermissionStatus = cameraStatus;
      _microphonePermissionStatus = microphoneStatus;
    });
  }

  double _previewContentHeightOrInfer(double width) {
    final ph = widget.previewContentHeight;
    if (ph != null && ph > 0) return ph;
    final wh = widget.settingSheetType.aspectRatio == '3:4' ? 3 / 4 : 9 / 16;
    return width > 0 ? width / wh : 0;
  }

  Future<void> _initializeCamera() async {
    final vw = widget.previewSlotWidth ?? _layoutViewportW;
    final wNum = (vw != null && vw > 0) ? vw : 0.0;
    final vh = _previewContentHeightOrInfer(wNum);
    final session = await _cameraSdk.initialize(
      config: BeautyCameraConfig(
        ratio: _currentRatio,
        flashMode: _currentFlashMode,
        cameraPosition: _cameraPosition,
        // 麦克风开关在 [startRecording] → [PixelfreeCameraPlugin.startRecord] 传入，避免改开关即重启相机。
        enableAudio: false,
        previewViewportWidth: (vw != null && vw > 0) ? vw : null,
        previewViewportHeight: vh > 0 ? vh : null,
        enableScreenFlashForFront: true,
      ),
    );
    _cameraSdk.setFrontFlashListener((FrontFlashHint? hint) {
      if (!mounted) return;
      setState(() {
        _frontScreenFlashOverlay = hint?.active ?? false;
        _frontFlashAlpha = hint?.intensity ?? 0.92;
      });
    });
    textureId = session.previewTextureId;
    _nativeBufferW = session.previewWidth;
    _nativeBufferH = session.previewHeight;
    if (!mounted) return;
    setState(() {
      _isInitialized = true;
      _hasEverInitializedCamera = true;
    });
  }

  CameraRatio get _currentRatio =>
      widget.settingSheetType.aspectRatio == '3:4'
          ? CameraRatio.ratio3x4
          : CameraRatio.ratio9x16;

  FlashMode get _currentFlashMode {
    switch (widget.flashStatus) {
      case FlashStatus.on:
        return FlashMode.on;
      case FlashStatus.auto:
        return FlashMode.auto;
      case FlashStatus.off:
        return FlashMode.off;
    }
  }


  Future<String> _extractAssetToTemp(String assetPath) async {
    if (_stickerAssetCache.containsKey(assetPath)) {
      return _stickerAssetCache[assetPath]!;
    }
    final byteData = await rootBundle.load(assetPath);
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/${assetPath.split('/').last}');
    await file.writeAsBytes(byteData.buffer.asUint8List(), flush: true);
    _stickerAssetCache[assetPath] = file.path;
    return file.path;
  }

  double _beautyValue(List<BeautyItem> source, String title, {double fallback = 0}) {
    final item = source.where((element) => element.title == title).firstOrNull;
    return item?.value ?? fallback;
  }

  Future<void> _applyBeautyAndFilterAndSticker() async {
    await _cameraSdk.setBeauty(
      BeautySettings(
        smoothing: _beautyValue(beautyOptions, '磨皮'),
        whitening: _beautyValue(beautyOptions, '美白'),
        ruddy: _beautyValue(beautyOptions, '红润'),
        sharpen: _beautyValue(beautyOptions, '锐化'),
        bigEye: _beautyValue(beautyOptions, '大眼'),
        eyeBrighten: _beautyValue(beautyOptions, '亮眼'),
        slimFace: _beautyValue(beautyOptions, '瘦脸'),
        portraitBlur: _beautyValue(beautyOptions, '背景虚化'),
        faceNarrow: _beautyValue(beautyOptions, '瘦颧骨'),
        faceChin: _beautyValue(beautyOptions, '下巴'),
        faceV: _beautyValue(beautyOptions, '瘦下颔'),
        faceNose: _beautyValue(beautyOptions, '鼻梁'),
        faceForehead: _beautyValue(beautyOptions, '额头'),
        faceMouth: _beautyValue(beautyOptions, '嘴巴'),
        facePhiltrum: _beautyValue(beautyOptions, '人中'),
        faceLongNose: _beautyValue(beautyOptions, '长鼻'),
        faceEyeSpace: _beautyValue(beautyOptions, '眼距'),
        faceSmile: _beautyValue(beautyOptions, '微笑嘴角'),
        faceCanthus: _beautyValue(beautyOptions, '开眼角'),
      ),
    );

    if (selectedFilterIndex > 0 && selectedFilterIndex < filterOptions.length) {
      final filter = filterOptions[selectedFilterIndex];
      await _cameraSdk.setFilter(
        FilterSettings(
          filterId: filter.filterType,
          intensity: filter.value,
        ),
      );
    } else {
      await _cameraSdk.setFilter(const FilterSettings(filterId: null, intensity: 0));
    }

    if (selectedStickerIndex >= 0 && selectedStickerIndex < stickerOptions.length) {
      final sticker = stickerOptions[selectedStickerIndex];
      await _cameraSdk.setArEffect(sticker.name);
    } else {
      await _cameraSdk.setArEffect('none');
    }
  }

  File? latestImage;
  Future<File?> getLatestImage() async {
    final albums = await PhotoManager.getAssetPathList(type: RequestType.image, onlyAll: true);
    if (albums.isEmpty) return null;
    final assets = await albums.first.getAssetListPaged(page: 0, size: 1);
    if (assets.isEmpty) return null;
    return assets.first.originFile;
  }

  bool _photoPermissionGranted = false;
  Future<bool> requestPermission() async {
    final result = await PhotoManager.requestPermissionExtend();
    return result.hasAccess;
  }

  Future<void> getLatestPhoto() async {
    _photoPermissionGranted = await requestPermission();
    if (!mounted) return;
    if (_photoPermissionGranted) {
      latestImage = await getLatestImage();
      if (!mounted) return;
    }
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    () async {
      await getLatestPhoto();
      PermissionStatus cameraValue = await Permissionutils.checkCameraPermission();
      if (cameraValue != PermissionStatus.permanentlyDenied) {
        cameraValue = await Permissionutils.requestCameraPermission();
      }
      PermissionStatus microphoneValue = await Permissionutils.checkMicrophonePermission();
      if (microphoneValue != PermissionStatus.permanentlyDenied) {
        microphoneValue = await Permissionutils.requestMicrophonePermission();
      }
      if (!mounted) return;
      setState(() {
        _cameraPermissionStatus = cameraValue;
        _microphonePermissionStatus = microphoneValue;
      });
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

  Future<void> _restartCamera({bool forceDispose = true}) async {
    if (_isRestartingCamera) return;
    _isRestartingCamera = true;
    if (forceDispose) {
      await _cameraSdk.dispose();
    }
    if (!mounted) {
      _isRestartingCamera = false;
      return;
    }
    setState(() {
      _isInitialized = false;
      textureId = null;
      _nativeBufferW = null;
      _nativeBufferH = null;
    });
    try {
      await _initializeCamera();
      await _syncPreviewSettings();
    } finally {
      _isRestartingCamera = false;
    }
  }

  @override
  void didUpdateWidget(covariant CameraView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!isCompleteAllow) return;

    final aspectChanged =
        oldWidget.settingSheetType.aspectRatio != widget.settingSheetType.aspectRatio;
    final slotChanged = oldWidget.previewSlotWidth != widget.previewSlotWidth ||
        oldWidget.previewSlotHeight != widget.previewSlotHeight ||
        oldWidget.previewContentHeight != widget.previewContentHeight;

    if (aspectChanged) {
      _cameraRestartAfterAspectTimer?.cancel();
      _cameraRestartAfterAspectTimer = Timer(const Duration(milliseconds: 200), () {
        _cameraRestartAfterAspectTimer = null;
        if (!mounted) return;
        _restartCamera();
      });
      return;
    }

    if (slotChanged) {
      _restartCamera();
      return;
    }

    if (oldWidget.flashStatus != widget.flashStatus && _isInitialized) {
      unawaited(_cameraSdk.setFlashMode(_currentFlashMode));
    }

    if (oldWidget.cameraSelectedIndex != widget.cameraSelectedIndex &&
        recordStatus == RecordStatus.end) {
      setState(() {
        _videoPlaybackReady = false;
      });
      _notifyPreviewReadyForNext();
    }

    if (oldWidget.onPreviewReadyForNext != widget.onPreviewReadyForNext) {
      _notifyPreviewReadyForNext();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _refreshPermissionsAndMaybeInit();
    }
    if (state == AppLifecycleState.paused && _isInitialized) {
      _cameraSdk.dispose();
      if (mounted) {
        setState(() {
          _isInitialized = false;
          textureId = null;
          _nativeBufferW = null;
          _nativeBufferH = null;
        });
      }
    }
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
        if (flag) {
          beautyOptions[index].value = value;
        } else {
          filterOptions[index].value = value;
        }
      }
      setState(() {});
      _applyBeautyAndFilterAndSticker();
    } else {
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
      _applyBeautyAndFilterAndSticker();
    }
  }

  void resetBeautyOptions(bool flag) {
    setState(() {
      if (flag) {
        selectedBeautyIndex = 0;
      } else {
        selectedFilterIndex = 0;
      }
      final originalData = flag ? createBeautyList() : createFilterList();
      if (flag) {
        for (final element in beautyOptions) {
          element.value = originalData
              .firstWhere((item) => item.type == element.type)
              .value;
        }
      } else {
        for (final element in filterOptions) {
          element.value = originalData
              .firstWhere((item) => item.filterType == element.filterType)
              .value;
        }
      }
    });
    _applyBeautyAndFilterAndSticker();
  }

  /// 与列表首项「无」对应，首次进入拍摄页不应用美颜/滤镜时 sheet 应高亮「无」。
  int selectedBeautyIndex = 0;
  void onBeautySelectedIndexChanged(int index) {
    setState(() {
      selectedBeautyIndex = index;
    });
    _applyBeautyAndFilterAndSticker();
  }

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

  int selectedFilterIndex = 0;
  void onFilterSelectedIndexChanged(int index) {
    setState(() {
      selectedFilterIndex = index;
    });
    _applyBeautyAndFilterAndSticker();
  }

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

  List<StickerItem> stickerOptions = createStickerList();
  /// -1 = 未选/无特效；≥0 为 [createStickerList] 中对应项（如 `face_mesh`、`glasses_3d`）。
  int selectedStickerIndex = -1;
  Future<void> onStickerSelectedIndexChanged(int index) async {
    setState(() {
      selectedStickerIndex = index;
    });
    await _applyBeautyAndFilterAndSticker();
  }

  void resetStickerIndex() {
    setState(() {
      selectedStickerIndex = -1;
    });
    _applyBeautyAndFilterAndSticker();
  }

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

  RecordStatus recordStatus = RecordStatus.normal;
  void onRecordStatusChanged(RecordStatus status) {
    setState(() {
      recordStatus = status;
    });
  }

  bool _computePreviewReadyForNext() {
    if (recordStatus != RecordStatus.end) return false;
    if (widget.cameraSelectedIndex == 0) {
      if (_pendingPhotoBytes != null && _pendingPhotoBytes!.isNotEmpty) return true;
      if (_pendingPhotoPath != null && _pendingPhotoPath!.isNotEmpty) return true;
      if (imagePreviewAssets.isNotEmpty) return true;
      return false;
    }
    if (videoPreviewAssets.isNotEmpty) {
      return _videoPlaybackReady;
    }
    if (_cameraRecordedVideoPreview) {
      if (_pendingVideoPath == null || _pendingVideoPath!.isEmpty) return false;
      return _videoPlaybackReady;
    }
    return false;
  }

  void _notifyPreviewReadyForNext() {
    widget.onPreviewReadyForNext?.call(_computePreviewReadyForNext());
  }

  void _onVideoPreviewPlaybackReady() {
    if (!mounted) return;
    setState(() {
      _videoPlaybackReady = true;
    });
    _notifyPreviewReadyForNext();
  }

  void changeUI(RecordStatus status) {
    widget.onRecordStatusChanged(status);
    setState(() {
      recordStatus = status;
      if (status == RecordStatus.normal) {
        _videoPlaybackReady = false;
      }
    });
    _notifyPreviewReadyForNext();
  }

  void startRecording() async {
    await PixelfreeCameraPlugin.startRecord(
      enableAudio: widget.microphoneStatus == MicrophoneStatus.on,
    );
    changeUI(RecordStatus.recording);
  }

  void stopRecording() {
    changeUI(RecordStatus.end);
    setState(() {
      _cameraRecordedVideoPreview = true;
      _pendingVideoPath = null;
      _videoPlaybackReady = false;
      videoPreviewAssets.clear();
      imagePreviewAssets.clear();
      _pendingPhotoPath = null;
      _pendingPhotoBytes = null;
    });
    _notifyPreviewReadyForNext();
    unawaited(_completeStopRecording());
  }

  Future<void> _completeStopRecording() async {
    try {
      final path = await PixelfreeCameraPlugin.stopRecord();
      if (!mounted) return;
      if (path.isEmpty) {
        setState(() {
          _cameraRecordedVideoPreview = false;
        });
        changeUI(RecordStatus.normal);
        return;
      }
      setState(() {
        _pendingVideoPath = path;
        _videoPlaybackReady = false;
      });
      _notifyPreviewReadyForNext();
      await _cameraSdk.dispose();
      if (!mounted) return;
      setState(() {
        _isInitialized = false;
        textureId = null;
        _nativeBufferW = null;
        _nativeBufferH = null;
      });
    } catch (_) {
      if (mounted) {
        setState(() {
          _cameraRecordedVideoPreview = false;
        });
        changeUI(RecordStatus.normal);
      }
    }
  }

  void takePhoto() {
    unawaited(_completeTakePhoto());
  }

  /// 先 await 仍图（内存 JPEG）→ 再 [changeUI] 进入成片预览 → 帧结束后异步 [dispose] 释放相机。
  /// 按下快门后仍保持实时 [Texture]，用户可看到闪光灯点亮过程。
  Future<void> _completeTakePhoto() async {
    try {
      final shot = await PixelfreeCameraPlugin.takePhoto();
      if (!mounted) return;
      Uint8List? bytes = shot.jpegBytes;
      if ((bytes == null || bytes.isEmpty) && shot.path.isNotEmpty) {
        try {
          final f = File(shot.path);
          bytes = await f.readAsBytes();
          if (await f.exists()) await f.delete();
        } catch (_) {}
      }
      if (bytes == null || bytes.isEmpty) {
        if (mounted) changeUI(RecordStatus.normal);
        return;
      }
      setState(() {
        _pendingPhotoBytes = bytes;
        _pendingPhotoPath = null;
        _pendingVideoPath = null;
        _cameraRecordedVideoPreview = false;
        _videoPlaybackReady = false;
        imagePreviewAssets.clear();
        videoPreviewAssets.clear();
      });
      changeUI(RecordStatus.end);
      _notifyPreviewReadyForNext();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        unawaited(_releaseCameraAfterStillShown());
      });
    } catch (_) {
      if (mounted) changeUI(RecordStatus.normal);
    }
  }

  Future<void> _releaseCameraAfterStillShown() async {
    if (!_isInitialized) return;
    await _cameraSdk.dispose();
    if (!mounted) return;
    setState(() {
      _isInitialized = false;
      textureId = null;
    });
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
        return const SizedBox.shrink();
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
                          _pendingPhotoPath = null;
                          _pendingPhotoBytes = null;
                          _pendingVideoPath = null;
                          _cameraRecordedVideoPreview = false;
                          imagePreviewAssets.clear();
                          videoPreviewAssets.clear();
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
                              Icon(Icons.arrow_back_ios, size: 26.0.sp, color: Color.fromRGBO(207, 72, 53, 1)),
                              Text('不保存返回', style: TextStyle(color: Color.fromRGBO(207, 72, 53, 1), fontSize: 16.0.sp, fontWeight: FontWeight.w500)),
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
                          _pendingPhotoPath = null;
                          _pendingPhotoBytes = null;
                          _pendingVideoPath = null;
                          _cameraRecordedVideoPreview = false;
                          imagePreviewAssets.clear();
                          videoPreviewAssets.clear();
                          context.pop();
                        },
                        splashColor: Color.fromRGBO(207, 72, 53, 0.2),
                        highlightColor: Color.fromRGBO(207, 72, 53, 0.1),
                        child: Padding(
                          padding: EdgeInsetsGeometry.symmetric(horizontal: 20.w),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            spacing: 4.0.w,
                            children: [
                              Icon(Icons.save, size: 26.0.sp, color: Color.fromRGBO(31, 30, 37, 1)),
                              Text('存草稿', style: TextStyle(color: Color.fromRGBO(31, 30, 37, 1), fontSize: 16.0.sp, fontWeight: FontWeight.w500)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              onPop: () {},
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

  Widget get buttonUI {
    switch (widget.cameraSelectedIndex) {
      case 0:
        return recordStatus != RecordStatus.end && !widget.isStartCountDown
            ? Align(
                alignment: Alignment.center,
                child: TakePhotoButton(takePhoto: takePhoto, recordStatus: recordStatus),
              )
            : Container();
      default:
        return recordStatus != RecordStatus.end && !widget.isStartCountDown
            ? Align(
                alignment: Alignment.center,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    spacing: recordStatus == RecordStatus.recording ? 12.0.h : 0.0.h,
                    children: [
                      recordStatus == RecordStatus.recording
                          ? Timekeeping(recordDuration: widget.recordDuration, stopRecording: stopRecording)
                          : Container(),
                      RecordVideoButton(
                        recordDuration: widget.recordDuration,
                        startRecording: startRecording,
                        stopRecording: stopRecording,
                        recordStatus: recordStatus,
                      ),
                    ],
                  ),
                ),
              )
            : Container();
    }
  }

  List<AssetEntity> imagePreviewAssets = [];
  List<AssetEntity> videoPreviewAssets = [];
  bool get isShowPreview =>
      videoPreviewAssets.isNotEmpty ||
      (_pendingVideoPath != null && _pendingVideoPath!.isNotEmpty) ||
      imagePreviewAssets.isNotEmpty ||
      (_pendingPhotoBytes != null && _pendingPhotoBytes!.isNotEmpty) ||
      (_pendingPhotoPath != null && _pendingPhotoPath!.isNotEmpty) ||
      _cameraRecordedVideoPreview;
  Widget get perviewUI {
    if (videoPreviewAssets.isNotEmpty) {
      return VideoPreview(
        videoData: videoPreviewAssets.first,
        onPlaybackReady: _onVideoPreviewPlaybackReady,
      );
    }
    // 本机录像预览：路径未到或解码中时的 loading 均在 [VideoPreview] 内；路径就绪后 [ValueKey] 变化会重新挂载并开始解码。
    if (widget.cameraSelectedIndex != 0 &&
        recordStatus == RecordStatus.end &&
        _cameraRecordedVideoPreview) {
      return VideoPreview(
        key: ValueKey(_pendingVideoPath ?? 'waiting'),
        videoFilePath: _pendingVideoPath,
        onPlaybackReady: _onVideoPreviewPlaybackReady,
      );
    }
    if (widget.cameraSelectedIndex == 0 &&
        _pendingPhotoBytes != null &&
        _pendingPhotoBytes!.isNotEmpty) {
      return ColoredBox(
        color: Colors.black,
        child: LayoutBuilder(
          builder: (context, c) {
            final cw = c.maxWidth;
            final ch = _previewContentHeightOrInfer(cw);
            return Center(
              child: SizedBox(
                width: cw,
                height: ch,
                child: KeyedSubtree(
                  key: ValueKey(_pendingPhotoBytes!.length),
                  child: _buildAspectCorrectStillMemory(_pendingPhotoBytes!),
                ),
              ),
            );
          },
        ),
      );
    }
    final pending = _pendingPhotoPath;
    if (pending != null && pending.isNotEmpty) {
      // 与 live 同一 content 槽；仍图 [SizedBox] 用 readPixels 真实像素宽高（非 Texture 的 pw×ph），避免朝向差 90°。
      return ColoredBox(
        color: Colors.black,
        child: LayoutBuilder(
          builder: (context, c) {
            final cw = c.maxWidth;
            final ch = _previewContentHeightOrInfer(cw);
            return Center(
              child: SizedBox(
                width: cw,
                height: ch,
                child: KeyedSubtree(
                  key: ValueKey(pending),
                  child: _buildAspectCorrectStillFile(File(pending)),
                ),
              ),
            );
          },
        ),
      );
    }
    if (imagePreviewAssets.isNotEmpty) return PhotoPreview(assets: imagePreviewAssets);
    return const SizedBox.shrink();
  }

  Future<void> _pickFromAlbum() async {
    if (!_photoPermissionGranted) {
      await getLatestPhoto();
      return;
    }

    final isPhotoMode = widget.cameraSelectedIndex == 0;
    final assets = await AssetPicker.pickAssets(
      context,
      pickerConfig: AssetPickerConfig(
        requestType: isPhotoMode ? RequestType.image : RequestType.video,
        maxAssets: isPhotoMode ? 20 : 1,
        textDelegate: MyAssetPickerTextDelegate(),
      ),
    );
    if (!mounted || assets == null) return;

    setState(() {
      _pendingPhotoPath = null;
      _pendingPhotoBytes = null;
      _pendingVideoPath = null;
      _cameraRecordedVideoPreview = false;
      _videoPlaybackReady = false;
      if (isPhotoMode) {
        imagePreviewAssets = assets;
        videoPreviewAssets.clear();
      } else {
        videoPreviewAssets = assets;
        imagePreviewAssets.clear();
      }
    });
    changeUI(RecordStatus.end);
  }

  void openMiniMusicSheet() {
    SheetUtils(MiniMusicSheetSkeleton()).openAsyncSheet(context: context);
  }

  void onCountdownFinished() {
    widget.onCountdownFinished();
  }

  @override
  void dispose() {
    _cameraRestartAfterAspectTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    _cameraSdk.setFrontFlashListener(null);
    PixelfreeCameraPlugin.releaseCamera();
    super.dispose();
  }

  /// 仍图与 [_buildAspectCorrectPreview] 同一套 [FittedBox]/fitWidth + 归一化 pw×ph，与 GL 全屏 readPixels 一致。
  Widget _buildAspectCorrectStillFile(File file) {
    final rawW = _nativeBufferW;
    final rawH = _nativeBufferH;
    if (rawW != null && rawH != null && rawW > 0 && rawH > 0) {
      var pw = rawW;
      var ph = rawH;
      if (pw > ph) {
        final t = pw;
        pw = ph;
        ph = t;
      }
      return LayoutBuilder(
        builder: (context, constraints) {
          if (!constraints.hasBoundedWidth ||
              !constraints.hasBoundedHeight ||
              constraints.maxWidth <= 0 ||
              constraints.maxHeight <= 0) {
            return ColoredBox(
              color: Colors.black,
              child: SizedBox.expand(
                child: Image.file(
                  file,
                  fit: BoxFit.fill,
                  gaplessPlayback: true,
                  filterQuality: FilterQuality.high,
                ),
              ),
            );
          }
          return ColoredBox(
            color: Colors.black,
            child: ClipRect(
              child: FittedBox(
                fit: BoxFit.fitWidth,
                alignment: Alignment.center,
                child: SizedBox(
                  width: pw,
                  height: ph,
                  child: Image.file(
                    file,
                    fit: BoxFit.fill,
                    gaplessPlayback: true,
                    filterQuality: FilterQuality.high,
                  ),
                ),
              ),
            ),
          );
        },
      );
    }
    final ar = _currentRatio == CameraRatio.ratio3x4 ? 3 / 4 : 9 / 16;
    return LayoutBuilder(
      builder: (context, constraints) {
        if (!constraints.hasBoundedWidth ||
            !constraints.hasBoundedHeight ||
            constraints.maxWidth <= 0 ||
            constraints.maxHeight <= 0) {
          return ColoredBox(
            color: Colors.black,
            child: SizedBox.expand(
              child: Image.file(
                file,
                fit: BoxFit.fill,
                gaplessPlayback: true,
                filterQuality: FilterQuality.high,
              ),
            ),
          );
        }
        return ColoredBox(
          color: Colors.black,
          child: ClipRect(
            child: FittedBox(
              fit: BoxFit.fitWidth,
              alignment: Alignment.center,
              child: AspectRatio(
                aspectRatio: ar,
                child: Image.file(
                  file,
                  fit: BoxFit.fill,
                  gaplessPlayback: true,
                  filterQuality: FilterQuality.high,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// 与 [_buildAspectCorrectStillFile] 相同布局，数据源为内存 JPEG。
  Widget _buildAspectCorrectStillMemory(Uint8List bytes) {
    final rawW = _nativeBufferW;
    final rawH = _nativeBufferH;
    if (rawW != null && rawH != null && rawW > 0 && rawH > 0) {
      var pw = rawW;
      var ph = rawH;
      if (pw > ph) {
        final t = pw;
        pw = ph;
        ph = t;
      }
      return LayoutBuilder(
        builder: (context, constraints) {
          if (!constraints.hasBoundedWidth ||
              !constraints.hasBoundedHeight ||
              constraints.maxWidth <= 0 ||
              constraints.maxHeight <= 0) {
            return ColoredBox(
              color: Colors.black,
              child: SizedBox.expand(
                child: Image.memory(
                  bytes,
                  fit: BoxFit.fill,
                  gaplessPlayback: true,
                  filterQuality: FilterQuality.high,
                ),
              ),
            );
          }
          return ColoredBox(
            color: Colors.black,
            child: ClipRect(
              child: FittedBox(
                fit: BoxFit.fitWidth,
                alignment: Alignment.center,
                child: SizedBox(
                  width: pw,
                  height: ph,
                  child: Image.memory(
                    bytes,
                    fit: BoxFit.fill,
                    gaplessPlayback: true,
                    filterQuality: FilterQuality.high,
                  ),
                ),
              ),
            ),
          );
        },
      );
    }
    final ar = _currentRatio == CameraRatio.ratio3x4 ? 3 / 4 : 9 / 16;
    return LayoutBuilder(
      builder: (context, constraints) {
        if (!constraints.hasBoundedWidth ||
            !constraints.hasBoundedHeight ||
            constraints.maxWidth <= 0 ||
            constraints.maxHeight <= 0) {
          return ColoredBox(
            color: Colors.black,
            child: SizedBox.expand(
              child: Image.memory(
                bytes,
                fit: BoxFit.fill,
                gaplessPlayback: true,
                filterQuality: FilterQuality.high,
              ),
            ),
          );
        }
        return ColoredBox(
          color: Colors.black,
          child: ClipRect(
            child: FittedBox(
              fit: BoxFit.fitWidth,
              alignment: Alignment.center,
              child: AspectRatio(
                aspectRatio: ar,
                child: Image.memory(
                  bytes,
                  fit: BoxFit.fill,
                  gaplessPlayback: true,
                  filterQuality: FilterQuality.high,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// 宽铺满父约束（= 屏宽），纵向按比例缩放；[BoxFit.fitWidth] 避免出现左右黑边，多余只在上下 [ClipRect] 裁切。
  /// 外层 Create 页已负责上下黑边与 9:16 / 3:4 槽位。
  Widget _buildAspectCorrectPreview(int tid) {
    final rawW = _nativeBufferW;
    final rawH = _nativeBufferH;
    if (rawW != null && rawH != null && rawW > 0 && rawH > 0) {
      var pw = rawW;
      var ph = rawH;
      if (pw > ph) {
        final t = pw;
        pw = ph;
        ph = t;
      }
      return LayoutBuilder(
        builder: (context, constraints) {
          if (!constraints.hasBoundedWidth ||
              !constraints.hasBoundedHeight ||
              constraints.maxWidth <= 0 ||
              constraints.maxHeight <= 0) {
            return ColoredBox(
              color: Colors.black,
              child: SizedBox.expand(
                child: Texture(textureId: tid, filterQuality: FilterQuality.high),
              ),
            );
          }
          return ColoredBox(
            color: Colors.black,
            child: ClipRect(
              child: FittedBox(
                fit: BoxFit.fitWidth,
                alignment: Alignment.center,
                child: SizedBox(
                  width: pw,
                  height: ph,
                  child: Texture(textureId: tid, filterQuality: FilterQuality.high),
                ),
              ),
            ),
          );
        },
      );
    }
    final ar = _currentRatio == CameraRatio.ratio3x4 ? 3 / 4 : 9 / 16;
    return LayoutBuilder(
      builder: (context, constraints) {
        if (!constraints.hasBoundedWidth ||
            !constraints.hasBoundedHeight ||
            constraints.maxWidth <= 0 ||
            constraints.maxHeight <= 0) {
          return ColoredBox(
            color: Colors.black,
            child: SizedBox.expand(
              child: Texture(textureId: tid, filterQuality: FilterQuality.high),
            ),
          );
        }
        return ColoredBox(
          color: Colors.black,
          child: ClipRect(
            child: FittedBox(
              fit: BoxFit.fitWidth,
              alignment: Alignment.center,
              child: AspectRatio(
                aspectRatio: ar,
                child: Texture(textureId: tid, filterQuality: FilterQuality.high),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        _layoutViewportW = constraints.maxWidth;
        final canLayout = constraints.hasBoundedWidth &&
            constraints.hasBoundedHeight &&
            constraints.maxWidth > 0 &&
            constraints.maxHeight > 0;
        if (isCompleteAllow &&
            recordStatus == RecordStatus.normal &&
            !_isInitialized &&
            !_isRestartingCamera &&
            !_cameraOpenScheduled &&
            canLayout) {
          _cameraOpenScheduled = true;
          WidgetsBinding.instance.addPostFrameCallback((_) async {
            _cameraOpenScheduled = false;
            if (!mounted || _isInitialized || _isRestartingCamera || recordStatus != RecordStatus.normal) return;
            await _restartCamera(forceDispose: false);
          });
        }
        final contentH = _previewContentHeightOrInfer(constraints.maxWidth);
        return Container(
          child: Stack(
        children: [
          Positioned.fill(
            child: ColoredBox(
              color: Colors.black,
              child: Center(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 320),
                  curve: Curves.easeInOutCubic,
                  width: constraints.maxWidth,
                  height: contentH,
                  child: _isInitialized && isCompleteAllow && !isShowPreview && textureId != null
                      ? _buildAspectCorrectPreview(textureId!)
                      : const ColoredBox(color: Colors.black),
                ),
              ),
            ),
          ),
          widget.isStartCountDown ? Positioned.fill(child: CountdownShow(countdown: widget.countdown, onCountdownFinished: onCountdownFinished)) : Container(),
          widget.settingSheetType.grid ? Positioned.fill(child: CameraGridOverlay()) : Container(),
          Positioned.fill(child: perviewUI),
          if (_frontScreenFlashOverlay)
            Positioned.fill(
              child: IgnorePointer(
                child: ColoredBox(
                  color: Colors.white.withValues(alpha: _frontFlashAlpha.clamp(0.0, 1.0)),
                ),
              ),
            ),
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
                          openMiniMusicSheet();
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: 14.0.h, horizontal: 14.0.w),
                          decoration: BoxDecoration(borderRadius: BorderRadius.circular(8.0.r), color: Colors.black.withValues(alpha: 0.4)),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            spacing: 2.0.w,
                            children: [
                              Icon(Icons.music_note, color: Colors.white, size: 20.0.sp),
                              Text('选择音乐', style: TextStyle(color: Colors.white, fontSize: 14.0.sp, decoration: TextDecoration.none, fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              : Container(),
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
                    onRotateChanged: () async {
                      _cameraPosition = _cameraPosition == CameraPosition.front
                          ? CameraPosition.back
                          : CameraPosition.front;
                      await _restartCamera();
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
                    isStartCountDown: widget.isStartCountDown,
                  ),
                )
              : Container(),
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
                                bgColor: Colors.black.withValues(alpha: 0.3),
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
                          highlightHeight: 30.0.h,
                          highlightColor: Colors.white,
                          itemPadding: EdgeInsets.symmetric(horizontal: 2.0.w,vertical: 4.0.h),
                          activeStyle: TextStyle(fontSize: 15.0.sp, fontWeight: FontWeight.bold, color: Colors.black, decoration: TextDecoration.none),
                          inactiveStyle: TextStyle(fontSize: 15.0.sp, color: Colors.white, decoration: TextDecoration.none),
                          initialIndex: widget.cameraSelectedIndex,
                          tabs: widget.cameraOptions,
                          onChanged: widget.onInSelectedIndexChanged,
                        )
                      : Container(),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 40.0.w),
                    child: Builder(
                      builder: (context) {
                        // 与特效同一套尺寸；相册占位也用 Font Awesome，避免与 Material Icon 混用导致同数值却视觉大小不一。
                        final sideW = 50.0.w * _kBottomSideIconScale - 4.0.w;
                        final sideH = 50.0.h * _kBottomSideIconScale - 4.0.w;
                        final iconSize = sideW * _kBottomIconInTileRatio;
                        // 三等分列 + 垂直居中：左右槽与中间拍照/录制在同一行对齐，避免 Stack 叠放时仅按整列高度居中导致与圆钮错位。
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: recordStatus == RecordStatus.normal
                                    ? GestureDetector(
                                        onTap: openStickerSheet,
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          spacing: 4.0.h,
                                          children: [
                                            Container(
                                              width: sideW,
                                              height: sideH,
                                              decoration: BoxDecoration(
                                                color: Colors.black.withValues(alpha: 0.35),
                                                borderRadius: BorderRadius.circular(8.0.r),
                                              ),
                                              alignment: Alignment.center,
                                              child: Icon(
                                                Icons.auto_awesome,
                                                color: Colors.white,
                                                size: iconSize,
                                              ),
                                            ),
                                            Text('特效', style: TextStyle(fontSize: 14.0.sp, color: Colors.white, decoration: TextDecoration.none)),
                                          ],
                                        ),
                                      )
                                    : const SizedBox.shrink(),
                              ),
                            ),
                            Expanded(
                              child: Center(child: buttonUI),
                            ),
                            Expanded(
                              child: Align(
                                alignment: Alignment.centerRight,
                                child: recordStatus == RecordStatus.normal
                                    ? GestureDetector(
                                        onTap: _pickFromAlbum,
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          spacing: 4.0.h,
                                          children: [
                                            Container(
                                              width: sideW,
                                              height: sideH,
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.circular(8.0.r),
                                                color: _photoPermissionGranted && latestImage != null
                                                    ? Colors.transparent
                                                    : Colors.black.withValues(alpha: 0.35),
                                              ),
                                              clipBehavior: Clip.antiAlias,
                                              alignment: Alignment.center,
                                              child: _photoPermissionGranted && latestImage != null
                                                  ? Image.file(
                                                      latestImage!,
                                                      width: sideW,
                                                      height: sideH,
                                                      fit: BoxFit.cover,
                                                    )
                                                  : Icon(
                                                      FontAwesomeIcons.images,
                                                      color: Colors.white,
                                                      size: iconSize,
                                                    ),
                                            ),
                                            Text('相册', style: TextStyle(fontSize: 14.0.sp, color: Colors.white, decoration: TextDecoration.none)),
                                          ],
                                        ),
                                      )
                                    : const SizedBox.shrink(),
                              ),
                            ),
                          ],
                        );
                      },
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
                    color: Colors.black.withValues(alpha: 0.9),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('在絮语APP拍摄', style: TextStyle(fontSize: 22.0.sp, color: Colors.white, decoration: TextDecoration.none, letterSpacing: 2.0.w)),
                        SizedBox(height: 6.0.h),
                        Text('开启以下权限即可进入拍摄', style: TextStyle(fontSize: 13.0.sp, color: Colors.grey, decoration: TextDecoration.none)),
                        SizedBox(height: 20.0.h),
                        Column(
                          spacing: 20.0.h,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _cameraPermissionStatus != PermissionStatus.granted
                                ? SizedBox(
                                    width: MediaQuery.of(context).size.width * 0.6,
                                    height: 50.0.h,
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Color.fromRGBO(41, 41, 41, 1),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0.r)),
                                      ),
                                      onPressed: () {
                                        openAppSettings();
                                      },
                                      child: Row(
                                        spacing: 8.0.w,
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.camera_alt, color: Colors.white, size: 24.0.sp),
                                          SizedBox(width: 8.0.w),
                                          Text('开启相机', style: TextStyle(fontSize: 14.0.sp, color: Colors.white, decoration: TextDecoration.none)),
                                        ],
                                      ),
                                    ),
                                  )
                                : Container(),
                            _microphonePermissionStatus != PermissionStatus.granted
                                ? SizedBox(
                                    width: MediaQuery.of(context).size.width * 0.6,
                                    height: 50.0.h,
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Color.fromRGBO(41, 41, 41, 1),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0.r)),
                                      ),
                                      onPressed: () {
                                        openAppSettings();
                                      },
                                      child: Row(
                                        spacing: 8.0.w,
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.mic, color: Colors.white, size: 24.0.sp),
                                          SizedBox(width: 8.0.w),
                                          Text('开启麦克风', style: TextStyle(fontSize: 14.0.sp, color: Colors.white, decoration: TextDecoration.none)),
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
          !_isInitialized && isCompleteAllow && !_hasEverInitializedCamera
              ? const FetchLoadingView()
              : Container(),
        ],
      ),
        );
      },
    );
  }
}
