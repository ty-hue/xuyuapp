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
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_player/video_player.dart';
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
import 'package:bilbili_project/pages/Create/comps/work_preview_skeleton.dart';
import 'package:bilbili_project/pages/Create/sub/ReleasePreparation/release_preparation_args.dart';
import 'package:bilbili_project/utils/PermissionUtils.dart';
import 'package:bilbili_project/utils/SaveImageUtils.dart';
import 'package:bilbili_project/utils/SheetUtils.dart';
import 'package:bilbili_project/store/create/create_shoot_notifier.dart';
import 'package:bilbili_project/store/create/create_shoot_state.dart';
import 'package:bilbili_project/utils/app_messenger.dart';
import 'package:bilbili_project/viewmodels/Create/index.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// [showModalBottomSheet] 返回的 Future 往往早于退场动画结束；切回实时预览前多等一拍，避免 sheet 未滑完就抢画面。
const Duration _kAfterBottomSheetExitVisual = Duration(milliseconds: 360);

/// 系统相册「全部图片」按创建时间倒序，第一页第一张即为最新仍图。
final FilterOptionGroup _kLatestAlbumImageOrder = FilterOptionGroup(
  orders: <OrderOption>[
    OrderOption(type: OrderOptionType.createDate, asc: false),
  ],
);

Future<void> _removeAllGalleryCoverPrefs(SharedPreferences p) async {
  await p.remove(GlobalConstants.LAST_GALLERY_COVER_ASSET_ID_KEY);
  await p.remove(GlobalConstants.LAST_GALLERY_COVER_WRITTEN_MS_KEY);
}

/// 底部「特效 / 相册」槽与图标相对原设计放大倍数（与拍照按钮 1.4 一致）。
const double _kBottomSideIconScale = 1.4;

/// 半透明块内图标相对块宽的比例（略小于 1，留白更舒服）。
const double _kBottomIconInTileRatio = 0.75;

class CameraView extends ConsumerStatefulWidget {
  final double topVal;
  final String? fromUrl;
  final VoidCallback onCountdownFinished;
  final VoidCallback openCountDownSheet;
  final VoidCallback openSettingSheet;
  /// 父级算好的**整段预览槽**宽高（含上下黑边区域）。用于 [LayoutBuilder] 约束，使 UI 相对整槽定位。
  final double? previewSlotWidth;
  final double? previewSlotHeight;
  /// 实际拍摄画面区域高度（与比例一致，不含上下黑边）。传给 native 视口；若未传则按设置里的比例由槽宽推算。
  final double? previewContentHeight;

  const CameraView({
    super.key,
    required this.topVal,
    this.fromUrl,
    required this.onCountdownFinished,
    required this.openCountDownSheet,
    required this.openSettingSheet,
    this.previewSlotWidth,
    this.previewSlotHeight,
    this.previewContentHeight,
  });

  @override
  ConsumerState<CameraView> createState() => CameraViewState();
}

class CameraViewState extends ConsumerState<CameraView> with WidgetsBindingObserver {
  /// 供音量键等读取；与 [createShootProvider] 同步。
  RecordStatus get recordStatus => ref.read(createShootProvider).recordStatus;

  /// 真实权限未就绪前必须为「未授权」，否则首帧会误走 openCamera。
  PermissionStatus _cameraPermissionStatus = PermissionStatus.denied;
  PermissionStatus _microphonePermissionStatus = PermissionStatus.denied;
  /// 已完成相机+麦克风的 request（或从后台 [resumed] 时刷新过权限），之后才允许调度初始化。
  bool _permissionsResolved = false;
  bool _isInitialized = false;
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
  /// 当前成片 [VideoPreview] 的 controller；成片操作 sheet 打开时可暂停以省资源。
  VideoPlayerController? _previewVideoPlayer;
  int? textureId;
  /// Native GL buffer size (portrait-normalized on Android). Used with [FittedBox] so the texture
  /// scales **uniformly** — [SizedBox.expand] on [Texture] stretches and elongates faces.
  double? _nativeBufferW;
  double? _nativeBufferH;
  final _cameraSdk = const PixelfreeCamera();
  final Map<String, String> _stickerAssetCache = {};
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
      _permissionsResolved = true;
    });
  }

  /// 权限已齐、且当前应是实时预览时，确保原生相机已打开（用于从后台恢复、或 init 失败后重试）。
  Future<void> _ensureLivePreviewIfNeeded() async {
    if (!_permissionsResolved || !isCompleteAllow) return;
    if (recordStatus != RecordStatus.normal) return;
    if (isShowPreview) return;
    if (_isRestartingCamera || _isInitialized) return;
    try {
      await _restartCamera(forceDispose: true);
    } catch (e, st) {
      debugPrint('CameraView: _ensureLivePreviewIfNeeded failed: $e\n$st');
    }
  }

  Future<void> _onAppResumed() async {
    await _refreshPermissionsAndMaybeInit();
    if (!mounted) return;
    await _ensureLivePreviewIfNeeded();
    if (mounted) unawaited(getLatestPhoto());
  }

  double _previewContentHeightOrInfer(double width) {
    final ph = widget.previewContentHeight;
    if (ph != null && ph > 0) return ph;
    final ar = ref.read(createShootProvider).settingSheetType.aspectRatio;
    final wh = ar == '3:4' ? 3 / 4 : 9 / 16;
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
        cameraPosition: ref.read(createShootProvider).useFrontCamera
            ? CameraPosition.front
            : CameraPosition.back,
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
    });
  }

  CameraRatio get _currentRatio {
    final ar = ref.read(createShootProvider).settingSheetType.aspectRatio;
    return ar == '3:4' ? CameraRatio.ratio3x4 : CameraRatio.ratio9x16;
  }

  FlashMode get _currentFlashMode {
    switch (ref.read(createShootProvider).flashStatus) {
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
    final shoot = ref.read(createShootProvider);
    await _cameraSdk.setBeauty(
      BeautySettings(
        smoothing: _beautyValue(shoot.beautyOptions, '磨皮'),
        whitening: _beautyValue(shoot.beautyOptions, '美白'),
        ruddy: _beautyValue(shoot.beautyOptions, '红润'),
        sharpen: _beautyValue(shoot.beautyOptions, '锐化'),
        bigEye: _beautyValue(shoot.beautyOptions, '大眼'),
        eyeBrighten: _beautyValue(shoot.beautyOptions, '亮眼'),
        slimFace: _beautyValue(shoot.beautyOptions, '瘦脸'),
        portraitBlur: _beautyValue(shoot.beautyOptions, '背景虚化'),
        faceNarrow: _beautyValue(shoot.beautyOptions, '瘦颧骨'),
        faceChin: _beautyValue(shoot.beautyOptions, '下巴'),
        faceV: _beautyValue(shoot.beautyOptions, '瘦下颔'),
        faceNose: _beautyValue(shoot.beautyOptions, '鼻梁'),
        faceForehead: _beautyValue(shoot.beautyOptions, '额头'),
        faceMouth: _beautyValue(shoot.beautyOptions, '嘴巴'),
        facePhiltrum: _beautyValue(shoot.beautyOptions, '人中'),
        faceLongNose: _beautyValue(shoot.beautyOptions, '长鼻'),
        faceEyeSpace: _beautyValue(shoot.beautyOptions, '眼距'),
        faceSmile: _beautyValue(shoot.beautyOptions, '微笑嘴角'),
        faceCanthus: _beautyValue(shoot.beautyOptions, '开眼角'),
      ),
    );

    if (shoot.selectedFilterIndex > 0 &&
        shoot.selectedFilterIndex < shoot.filterOptions.length) {
      final filter = shoot.filterOptions[shoot.selectedFilterIndex];
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

  /// 本机拍照存草稿后的缩略图字节；与磁盘缓存同内容，用于同会话内绕开 [Image.file] 对同路径的解码缓存问题。
  Uint8List? _albumThumbMemoryJpeg;

  /// 取消已过期的 [getLatestPhoto] 异步结果，避免晚到的请求用 [getLatestImage] 盖住刚存的草稿封面。
  int _albumThumbOpSeq = 0;
  /// [Image.file] / [Image.memory] 的 Key，同路径覆盖或替换字节后必须递增否则 Flutter 可能仍显示旧解码。
  int _albumCoverDisplayToken = 0;

  /// 与应用同寿命的封面缓存（非系统临时目录，离开拍摄页再进入仍可读）。
  Future<File> _albumCoverCacheFile() async {
    final d = await getApplicationSupportDirectory();
    return File('${d.path}/xuyu_last_album_cover.jpg');
  }

  /// 读取应用内封面 JPEG；不依赖 [File.exists]（少数环境下与可读性不一致）。
  Future<Uint8List?> _tryReadAlbumCoverBytes(File cache) async {
    try {
      final b = await cache.readAsBytes();
      return b.isEmpty ? null : b;
    } catch (_) {
      return null;
    }
  }

  /// 记录存草稿对应的相册资源，并写入 [latestImage] 用的 JPEG 缓存。
  Future<void> _persistLastGalleryCover(AssetEntity entity, {Uint8List? cameraJpeg}) async {
    _albumThumbOpSeq++;
    try {
      final out = await _albumCoverCacheFile();
      var wrote = false;
      if (cameraJpeg != null && cameraJpeg.isNotEmpty) {
        await out.writeAsBytes(cameraJpeg, flush: true);
        wrote = true;
      } else if (entity.type == AssetType.video) {
        final data = await entity.thumbnailDataWithSize(const ThumbnailSize.square(512));
        if (data != null) {
          await out.writeAsBytes(data, flush: true);
          wrote = true;
        }
      } else {
        final src = await entity.originFile;
        if (src != null && await src.exists()) {
          await out.writeAsBytes(await src.readAsBytes(), flush: true);
          wrote = true;
        }
      }
      if (!wrote) return;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(GlobalConstants.LAST_GALLERY_COVER_ASSET_ID_KEY, entity.id);
      await prefs.setInt(
        GlobalConstants.LAST_GALLERY_COVER_WRITTEN_MS_KEY,
        DateTime.now().millisecondsSinceEpoch,
      );
    } catch (e, st) {
      debugPrint('CameraView: _persistLastGalleryCover failed: $e\n$st');
    }
  }

  /// 当前「全部图片」中创建时间最新的一张（仍图文件，用于底部相册缩略图）。
  Future<File?> getLatestImage() async {
    final albums = await PhotoManager.getAssetPathList(
      type: RequestType.image,
      onlyAll: true,
      filterOption: _kLatestAlbumImageOrder,
    );
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
    final op = ++_albumThumbOpSeq;
    _photoPermissionGranted = await requestPermission();
    if (!mounted || op != _albumThumbOpSeq) return;
    if (!_photoPermissionGranted) {
      latestImage = null;
      if (!mounted || op != _albumThumbOpSeq) return;
      setState(() {});
      return;
    }

    final cache = await _albumCoverCacheFile();
    if (!mounted || op != _albumThumbOpSeq) return;

    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getString(GlobalConstants.LAST_GALLERY_COVER_ASSET_ID_KEY);
    final coverWrittenMs =
        prefs.getInt(GlobalConstants.LAST_GALLERY_COVER_WRITTEN_MS_KEY);
    final coverBytes = await _tryReadAlbumCoverBytes(cache);
    final cacheReadable = coverBytes != null && coverBytes.isNotEmpty;
    final cacheExists = await cache.exists();
    final hasDraftCoverMeta =
        (id != null && id.isNotEmpty) || coverWrittenMs != null;

    if (!mounted || op != _albumThumbOpSeq) return;

    // 以「能读出非空 JPEG」+ 曾有过存草稿记录为准；读入内存用 Image.memory，避免回首页再进时 Image.file 同路径解码缓存仍显示旧图。
    if (cacheReadable && hasDraftCoverMeta) {
      latestImage = cache;
      _albumThumbMemoryJpeg = Uint8List.fromList(coverBytes);
      _albumCoverDisplayToken++;
      if (!mounted || op != _albumThumbOpSeq) return;
      setState(() {});
      return;
    }
    if (!mounted || op != _albumThumbOpSeq) return;

    if (id != null && id.isNotEmpty) {
      try {
        final e = await AssetEntity.fromId(id);
        if (!mounted || op != _albumThumbOpSeq) return;
        if (e != null) {
          if (e.type == AssetType.video) {
            if (cacheExists) {
              latestImage = cache;
              _albumCoverDisplayToken++;
              if (!mounted || op != _albumThumbOpSeq) return;
              setState(() {});
              return;
            }
            final data = await e.thumbnailDataWithSize(const ThumbnailSize.square(512));
            if (!mounted || op != _albumThumbOpSeq) return;
            if (data != null) {
              await cache.writeAsBytes(data, flush: true);
              latestImage = cache;
              _albumCoverDisplayToken++;
              if (!mounted || op != _albumThumbOpSeq) return;
              setState(() {});
              return;
            }
          } else {
            final f = await e.originFile;
            if (!mounted || op != _albumThumbOpSeq) return;
            if (f != null && await f.exists()) {
              latestImage = f;
              _albumThumbMemoryJpeg = null;
              _albumCoverDisplayToken++;
              if (!mounted || op != _albumThumbOpSeq) return;
              setState(() {});
              return;
            }
          }
        }
        if (cacheExists) {
          latestImage = cache;
          _albumCoverDisplayToken++;
          if (!mounted || op != _albumThumbOpSeq) return;
          setState(() {});
          return;
        }
        if (e == null) {
          await _removeAllGalleryCoverPrefs(prefs);
        }
      } catch (e, st) {
        debugPrint('CameraView: fromId cover failed: $e\n$st');
        if (cacheExists) {
          latestImage = cache;
          _albumCoverDisplayToken++;
          if (!mounted || op != _albumThumbOpSeq) return;
          setState(() {});
          return;
        }
        await _removeAllGalleryCoverPrefs(prefs);
      }
    }
    if (!mounted || op != _albumThumbOpSeq) return;

    if (cacheExists) {
      latestImage = cache;
      _albumCoverDisplayToken++;
      if (!mounted || op != _albumThumbOpSeq) return;
      setState(() {});
      return;
    }

    latestImage = await getLatestImage();
    if (!mounted || op != _albumThumbOpSeq) return;
    _albumThumbMemoryJpeg = null;
    _albumCoverDisplayToken++;
    setState(() {});
  }

  /// 写入相册后系统索引往往晚于 [PhotoManager.editor]；仅在不具备「本机成片 JPEG」时用查询对齐。
  void _scheduleAlbumThumbRefreshAfterWrite() {
    for (final ms in [400, 1200, 3000]) {
      Future.delayed(Duration(milliseconds: ms), () {
        if (mounted) unawaited(getLatestPhoto());
      });
    }
  }

  /// 存草稿成功后更新底栏缩略图。
  ///
  /// **拍照直出**：优先用 [cameraJpeg]（与写入相册的是同一份像素），避免 [AssetEntity]/系统相册列表延迟或错乱。
  /// 无字节时再回退 [entity]（相册选片、路径成片、视频等）。
  Future<void> _applyAlbumThumbAfterDraftSave({
    required AssetEntity? entity,
    Uint8List? cameraJpeg,
  }) async {
    if (entity == null) return;
    await _persistLastGalleryCover(entity, cameraJpeg: cameraJpeg);
    final out = await _albumCoverCacheFile();
    if (await out.exists() && mounted) {
      setState(() {
        latestImage = out;
        _photoPermissionGranted = true;
        if (cameraJpeg != null && cameraJpeg.isNotEmpty) {
          _albumThumbMemoryJpeg = Uint8List.fromList(cameraJpeg);
        } else {
          _albumThumbMemoryJpeg = null;
        }
        _albumCoverDisplayToken++;
      });
      return;
    }
    await _applyAlbumThumbFromEntity(entity);
  }

  /// 使用保存接口返回的 [AssetEntity] 立即更新底部缩略图（不依赖相册列表是否已刷新）。
  Future<void> _applyAlbumThumbFromEntity(AssetEntity entity) async {
    try {
      if (entity.type == AssetType.video) {
        final data = await entity.thumbnailDataWithSize(const ThumbnailSize.square(512));
        if (data == null || !mounted) return;
        final dir = await getTemporaryDirectory();
        final f = File('${dir.path}/xuyu_album_thumb_${entity.id}.jpg');
        await f.writeAsBytes(data, flush: true);
        if (!mounted) return;
        setState(() {
          latestImage = f;
          _photoPermissionGranted = true;
          _albumThumbMemoryJpeg = null;
          _albumCoverDisplayToken++;
        });
        return;
      }
      File? f = await entity.originFile;
      if (f == null || !await f.exists()) {
        final data = await entity.thumbnailDataWithSize(const ThumbnailSize.square(512));
        if (data == null || !mounted) return;
        final dir = await getTemporaryDirectory();
        f = File('${dir.path}/xuyu_album_thumb_${entity.id}.jpg');
        await f.writeAsBytes(data, flush: true);
      }
      if (!mounted || !await f.exists()) return;
      setState(() {
        latestImage = f;
        _photoPermissionGranted = true;
        _albumThumbMemoryJpeg = null;
        _albumCoverDisplayToken++;
      });
    } catch (e, st) {
      debugPrint('CameraView: _applyAlbumThumbFromEntity failed: $e\n$st');
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    () async {
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
        _permissionsResolved = true;
      });
      // 放到首帧之后，确保父级 [previewSlotWidth] 与本地 [_layoutViewportW] 已随 layout 写好再 init。
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        unawaited(_ensureLivePreviewIfNeeded());
      });
      // 相册缩略图不阻塞相机预览：避免先弹相册权限导致相机初始化过晚。
      unawaited(getLatestPhoto());
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
    } catch (e, st) {
      debugPrint('CameraView: _restartCamera init failed: $e\n$st');
      if (mounted) setState(() {});
    } finally {
      _isRestartingCamera = false;
    }
  }

  @override
  void didUpdateWidget(covariant CameraView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!isCompleteAllow) return;

    final slotChanged = oldWidget.previewSlotWidth != widget.previewSlotWidth ||
        oldWidget.previewSlotHeight != widget.previewSlotHeight ||
        oldWidget.previewContentHeight != widget.previewContentHeight;

    if (slotChanged) {
      unawaited(_restartCamera());
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      unawaited(_onAppResumed());
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

  void openBeautyfiterSheet() {
    final shoot = ref.read(createShootProvider);
    final n = ref.read(createShootProvider.notifier);
    SheetUtils(
      BeautyfiterSheetSekeleton(
        title: '美颜',
        beautyItems: shoot.beautyOptions,
        setBeautyOptions: (item, value, flag) {
          n.setBeautyOptions(item, value, flag);
          unawaited(_applyBeautyAndFilterAndSticker());
        },
        resetBeautyOptions: (flag) {
          n.resetBeautyOptions(flag);
          unawaited(_applyBeautyAndFilterAndSticker());
        },
        flag: true,
        initSelectedIndex: shoot.selectedBeautyIndex,
        onSelectedIndexChanged: (index) {
          n.setSelectedBeautyIndex(index);
          unawaited(_applyBeautyAndFilterAndSticker());
        },
      ),
    ).openAsyncSheet(context: context, barrierColor: Colors.transparent);
  }

  void openFiterSheet() {
    final shoot = ref.read(createShootProvider);
    final n = ref.read(createShootProvider.notifier);
    SheetUtils(
      BeautyfiterSheetSekeleton(
        title: '滤镜',
        beautyItems: shoot.filterOptions,
        setBeautyOptions: (item, value, flag) {
          n.setBeautyOptions(item, value, flag);
          unawaited(_applyBeautyAndFilterAndSticker());
        },
        resetBeautyOptions: (flag) {
          n.resetBeautyOptions(flag);
          unawaited(_applyBeautyAndFilterAndSticker());
        },
        flag: false,
        initSelectedIndex: shoot.selectedFilterIndex,
        onSelectedIndexChanged: (index) {
          n.setSelectedFilterIndex(index);
          unawaited(_applyBeautyAndFilterAndSticker());
        },
      ),
    ).openAsyncSheet(context: context, barrierColor: Colors.transparent);
  }

  List<StickerItem> stickerOptions = createStickerList();
  /// -1 = 未选/无特效；≥0 为 [createStickerList] 中对应项（如 `face_mesh`、`lip_color`）。
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

  bool _computePreviewReadyForNext() {
    final shoot = ref.read(createShootProvider);
    if (shoot.recordStatus != RecordStatus.end) return false;
    if (shoot.cameraSelectedIndex == 0) {
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
    ref
        .read(createShootProvider.notifier)
        .setPreviewReadyForNext(_computePreviewReadyForNext());
  }

  void _onVideoPreviewPlaybackReady() {
    if (!mounted) return;
    setState(() {
      _videoPlaybackReady = true;
    });
    _notifyPreviewReadyForNext();
  }

  void _onPreviewVideoPlayerBound(VideoPlayerController? c) {
    _previewVideoPlayer = c;
  }

  void changeUI(RecordStatus status) {
    ref.read(createShootProvider.notifier).setRecordStatus(status);
    setState(() {
      if (status == RecordStatus.normal) {
        _videoPlaybackReady = false;
      }
    });
    _notifyPreviewReadyForNext();
  }

  /// 成片预览 → 回到实时相机：单次 [setState] 清空成片数据并触发重新打开相机（与 [changeUI] 分离以免漏清字段）。
  ///
  /// [refreshAlbumThumb] 为 false 时跳过立即 [getLatestPhoto]（例如存草稿后已用 [AssetEntity] 设过缩略图，
  /// 避免相册索引未更新时把缩略图刷成旧图/null）。
  void _exitPreviewToLiveCamera({bool refreshAlbumThumb = true}) {
    ref.read(createShootProvider.notifier).setRecordStatus(RecordStatus.normal);
    if (!mounted) return;
    setState(() {
      _videoPlaybackReady = false;
      _pendingPhotoPath = null;
      _pendingPhotoBytes = null;
      _pendingVideoPath = null;
      _cameraRecordedVideoPreview = false;
      imagePreviewAssets.clear();
      videoPreviewAssets.clear();
    });
    _notifyPreviewReadyForNext();
    if (refreshAlbumThumb) {
      unawaited(getLatestPhoto());
    }
    // 与成片 Video/Texture 卸载错开一拍再开相机，减轻单帧内 jank。
    Future.delayed(const Duration(milliseconds: 48), () {
      if (!mounted) return;
      unawaited(_ensureLivePreviewIfNeeded());
    });
  }

  /// 存草稿写入相册；成功返回新建 [AssetEntity]，供立即更新底部缩略图。
  Future<AssetEntity?> _saveDraftToGallery() async {
    try {
      if (ref.read(createShootProvider).cameraSelectedIndex == 0) {
        final bytes = _pendingPhotoBytes;
        if (bytes != null && bytes.isNotEmpty) {
          return saveImageUtils.saveImageToGallery(bytes);
        }
        final p = _pendingPhotoPath;
        if (p != null && p.isNotEmpty) {
          return saveImageUtils.saveImageFromPathToGallery(p);
        }
        if (imagePreviewAssets.isNotEmpty) {
          return saveImageUtils.saveAssetEntityDraft(imagePreviewAssets.first);
        }
      } else {
        final vp = _pendingVideoPath;
        if (vp != null && vp.isNotEmpty) {
          return saveImageUtils.saveVideoFromPathToGallery(vp);
        }
        if (videoPreviewAssets.isNotEmpty) {
          return saveImageUtils.saveAssetEntityDraft(videoPreviewAssets.first);
        }
      }
    } catch (e, st) {
      debugPrint('CameraView: save draft failed: $e\n$st');
    }
    return null;
  }

  /// 当前成片类型与本地路径，供发布准备页使用。
  Future<ReleasePreparationArgs> prepareReleaseArgs() async {
    final shoot = ref.read(createShootProvider);
    final aspect = shoot.settingSheetType.aspectRatio;
    if (shoot.cameraSelectedIndex == 1) {
      final p = _pendingVideoPath;
      if (p != null && p.isNotEmpty) {
        return ReleasePreparationArgs.video(path: p, shootAspectRatio: aspect);
      }
      if (videoPreviewAssets.isNotEmpty) {
        try {
          final file = await videoPreviewAssets.first.file;
          if (file != null && await file.exists()) {
            return ReleasePreparationArgs.video(
              path: file.path,
              shootAspectRatio: aspect,
            );
          }
        } catch (_) {}
      }
      return ReleasePreparationArgs.video(path: null, shootAspectRatio: aspect);
    }
    final bytes = _pendingPhotoBytes;
    if (bytes != null && bytes.isNotEmpty) {
      return ReleasePreparationArgs.photo(
        path: null,
        bytes: bytes,
        shootAspectRatio: aspect,
      );
    }
    final pp = _pendingPhotoPath;
    if (pp != null && pp.isNotEmpty) {
      return ReleasePreparationArgs.photo(path: pp, shootAspectRatio: aspect);
    }
    if (imagePreviewAssets.isNotEmpty) {
      try {
        final file = await imagePreviewAssets.first.file;
        if (file != null && await file.exists()) {
          return ReleasePreparationArgs.photo(
            path: file.path,
            shootAspectRatio: aspect,
          );
        }
      } catch (_) {}
    }
    return ReleasePreparationArgs.photo(path: null, shootAspectRatio: aspect);
  }

  void startRecording() async {
    await PixelfreeCameraPlugin.startRecord(
      enableAudio:
          ref.read(createShootProvider).microphoneStatus == MicrophoneStatus.on,
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
        unawaited(getLatestPhoto());
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
        unawaited(getLatestPhoto());
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
        unawaited(getLatestPhoto());
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

  Future<void> _openEndPreviewSheet(BuildContext contextBtn) async {
    final vpc = _previewVideoPlayer;
    final wasPlaying = vpc?.value.isPlaying ?? false;
    unawaited(vpc?.pause() ?? Future.value());

    void resumeIfPlaying() {
      if (!mounted) return;
      if (!wasPlaying) return;
      final c = _previewVideoPlayer;
      if (c != null) unawaited(c.play());
    }

    final WorkPreviewSheetResult? result = await SheetUtils(
      const WorkPreviewSheetSkeleton(),
    ).openAsyncSheet<WorkPreviewSheetResult>(context: contextBtn);

    if (!mounted) return;

    // 划掉关闭：仍留在成片预览，恢复播放。
    if (result == null) {
      resumeIfPlaying();
      return;
    }

    // 点了「不保存 / 存草稿」：不要先 resume 成片（会叠在尚未退完的 sheet 下）；等 sheet 视觉退场后再改 UI。
    await Future<void>.delayed(_kAfterBottomSheetExitVisual);
    if (!mounted) return;

    switch (result) {
      case WorkPreviewSheetResult.discardWithoutSave:
        _exitPreviewToLiveCamera();
        break;
      case WorkPreviewSheetResult.saveDraft:
        final saved = await _saveDraftToGallery();
        if (!mounted) return;
        if (saved != null) {
          final pending = _pendingPhotoBytes;
          final Uint8List? jpegForCover =
              (ref.read(createShootProvider).cameraSelectedIndex == 0 &&
                      pending != null &&
                      pending.isNotEmpty)
                  ? Uint8List.fromList(pending)
                  : null;
          await _applyAlbumThumbAfterDraftSave(
            entity: saved,
            cameraJpeg: jpegForCover,
          );
          if (!mounted) return;
          AppMessenger.show(context, '已保存到相册');
          _exitPreviewToLiveCamera(refreshAlbumThumb: false);
          if (jpegForCover == null) {
            _scheduleAlbumThumbRefreshAfterWrite();
          }
        } else {
          AppMessenger.show(context, '保存失败，请检查相册权限');
          resumeIfPlaying();
        }
        break;
    }
  }

  Widget backUI(BuildContext contextBtn, CreateShootState shoot) {
    switch (shoot.recordStatus) {
      case RecordStatus.normal:
        return GestureDetector(
          onTap: () {
            if (widget.fromUrl != null) {
              context.pop(widget.fromUrl);
            } else {
              context.pop();
            }
          },
          child: Padding(padding: EdgeInsets.all(8.w), child: Icon(Icons.close, color: Colors.white, size: 33.0.sp),),
        );
      case RecordStatus.recording:
        return const SizedBox.shrink();
      case RecordStatus.end:
        return GestureDetector(
          onTap: () => unawaited(_openEndPreviewSheet(contextBtn)),
          child: Padding(padding: EdgeInsets.all(8.w), child: Icon(Icons.arrow_back_ios, color: Colors.white, size: 33.0.sp),),
        );
    }
  }

  Widget _buttonUI(CreateShootState shoot) {
    switch (shoot.cameraSelectedIndex) {
      case 0:
        return shoot.recordStatus != RecordStatus.end && !shoot.isStartCountDown
            ? Align(
                alignment: Alignment.center,
                child: TakePhotoButton(
                  takePhoto: takePhoto,
                  recordStatus: shoot.recordStatus,
                ),
              )
            : Container();
      default:
        return shoot.recordStatus != RecordStatus.end && !shoot.isStartCountDown
            ? Align(
                alignment: Alignment.center,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    spacing: shoot.recordStatus == RecordStatus.recording
                        ? 12.0.h
                        : 0.0.h,
                    children: [
                      shoot.recordStatus == RecordStatus.recording
                          ? Timekeeping(
                              recordDuration: shoot.recordDuration,
                              stopRecording: stopRecording,
                            )
                          : Container(),
                      RecordVideoButton(
                        recordDuration: shoot.recordDuration,
                        startRecording: startRecording,
                        stopRecording: stopRecording,
                        recordStatus: shoot.recordStatus,
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
  Widget _perviewUI(CreateShootState shoot) {
    if (videoPreviewAssets.isNotEmpty) {
      return VideoPreview(
        videoData: videoPreviewAssets.first,
        onPlaybackReady: _onVideoPreviewPlaybackReady,
        onVideoPlayerBound: _onPreviewVideoPlayerBound,
      );
    }
    // 本机录像预览：路径未到或解码中时的 loading 均在 [VideoPreview] 内；路径就绪后 [ValueKey] 变化会重新挂载并开始解码。
    if (shoot.cameraSelectedIndex != 0 &&
        shoot.recordStatus == RecordStatus.end &&
        _cameraRecordedVideoPreview) {
      return VideoPreview(
        key: ValueKey(_pendingVideoPath ?? 'waiting'),
        videoFilePath: _pendingVideoPath,
        onPlaybackReady: _onVideoPreviewPlaybackReady,
        onVideoPlayerBound: _onPreviewVideoPlayerBound,
      );
    }
    if (shoot.cameraSelectedIndex == 0 &&
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

    final isPhotoMode = ref.read(createShootProvider).cameraSelectedIndex == 0;
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
    // ref.listen 必须在 ConsumerState.build 顶层调用，不可放在 LayoutBuilder.builder
    //（后者在 layout 子阶段执行，debugDoingBuild 为 false，会触发断言）。
    final shoot = ref.watch(createShootProvider);

    ref.listen(
      createShootProvider.select((s) => s.settingSheetType.aspectRatio),
      (prev, next) {
        if (prev == next) return;
        if (!isCompleteAllow) return;
        _cameraRestartAfterAspectTimer?.cancel();
        _cameraRestartAfterAspectTimer =
            Timer(const Duration(milliseconds: 200), () {
          _cameraRestartAfterAspectTimer = null;
          if (!mounted) return;
          unawaited(_restartCamera());
        });
      },
    );

    ref.listen(
      createShootProvider.select((s) => s.flashStatus),
      (prev, next) {
        if (prev == next || !_isInitialized) return;
        unawaited(_cameraSdk.setFlashMode(_currentFlashMode));
      },
    );

    ref.listen(
      createShootProvider.select((s) => s.cameraSelectedIndex),
      (prev, next) {
        if (prev == next) return;
        if (ref.read(createShootProvider).recordStatus != RecordStatus.end) {
          return;
        }
        setState(() => _videoPlaybackReady = false);
        _notifyPreviewReadyForNext();
      },
    );

    ref.listen(
      createShootProvider.select((s) => s.useFrontCamera),
      (prev, next) {
        if (prev == next || !_isInitialized || _isRestartingCamera) return;
        unawaited(_restartCamera());
      },
    );

    ref.listen(
      createShootProvider.select(
        (s) => Object.hash(
          s.selectedBeautyIndex,
          s.selectedFilterIndex,
          Object.hashAll(s.beautyOptions.map((e) => e.value)),
          Object.hashAll(s.filterOptions.map((e) => e.value)),
        ),
      ),
      (prev, next) {
        if (prev == next || !_isInitialized) return;
        unawaited(_syncPreviewSettings());
      },
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        _layoutViewportW = constraints.maxWidth;
        final canLayout = constraints.hasBoundedWidth &&
            constraints.hasBoundedHeight &&
            constraints.maxWidth > 0 &&
            constraints.maxHeight > 0;
        if (_permissionsResolved &&
            isCompleteAllow &&
            shoot.recordStatus == RecordStatus.normal &&
            !_isInitialized &&
            !_isRestartingCamera &&
            !_cameraOpenScheduled &&
            canLayout) {
          _cameraOpenScheduled = true;
          WidgetsBinding.instance.addPostFrameCallback((_) async {
            _cameraOpenScheduled = false;
            if (!mounted ||
                _isInitialized ||
                _isRestartingCamera ||
                ref.read(createShootProvider).recordStatus !=
                    RecordStatus.normal) {
              return;
            }
            await _restartCamera(forceDispose: false);
          });
        }
        final contentH = _previewContentHeightOrInfer(constraints.maxWidth);
        final countdownSec = int.tryParse(
              shoot.countdownType.countdownDuration.replaceAll('秒', ''),
            ) ??
            3;
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
          shoot.isStartCountDown
              ? Positioned.fill(
                  child: CountdownShow(
                    countdown: countdownSec,
                    onCountdownFinished: onCountdownFinished,
                  ),
                )
              : Container(),
          shoot.settingSheetType.grid
              ? Positioned.fill(child: CameraGridOverlay())
              : Container(),
          Positioned.fill(child: _perviewUI(shoot)),
          if (_frontScreenFlashOverlay)
            Positioned.fill(
              child: IgnorePointer(
                child: ColoredBox(
                  color: Colors.white.withValues(alpha: _frontFlashAlpha.clamp(0.0, 1.0)),
                ),
              ),
            ),
          Positioned(
            left: 12.w,
            top: widget.topVal,
            // Popover 锚点必须用 Builder 的 context，不能用 State.build 的 context，否则弹层在屏幕外
            child: Builder(
              builder: (anchorContext) => backUI(anchorContext, shoot),
            ),
          ),
          shoot.recordStatus != RecordStatus.recording
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
          shoot.recordStatus != RecordStatus.end
              ? Positioned(
                  right: 0.w,
                  top: widget.topVal + 10.h,
                  child: ToolBar(
                    openCountDownSheet: widget.openCountDownSheet,
                    openSettingSheet: widget.openSettingSheet,
                    onBeautyTap: openBeautyfiterSheet,
                    onFilterTap: openFiterSheet,
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
                  shoot.speedMode
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
                                labels: CreateShootLabels.speedLabels,
                                selectedIndex: shoot.speedSelectedIndex,
                                onChanged: (i) => ref
                                    .read(createShootProvider.notifier)
                                    .setSpeedSelectedIndex(i),
                                borderRadius: 4.0.r,
                              ),
                            ],
                          ),
                        )
                      : Container(),
                  shoot.recordStatus == RecordStatus.normal
                      ? AutoCenterScrollTabBar(
                          itemSpacing: 20.0.w,
                          highlightHeight: 30.0.h,
                          highlightColor: Colors.white,
                          itemPadding: EdgeInsets.symmetric(horizontal: 2.0.w,vertical: 4.0.h),
                          activeStyle: TextStyle(fontSize: 15.0.sp, fontWeight: FontWeight.bold, color: Colors.black, decoration: TextDecoration.none),
                          inactiveStyle: TextStyle(fontSize: 15.0.sp, color: Colors.white, decoration: TextDecoration.none),
                          initialIndex: shoot.cameraSelectedIndex,
                          tabs: CreateShootLabels.cameraModeTabs,
                          onChanged: (i) => ref
                              .read(createShootProvider.notifier)
                              .setCameraSelectedIndex(i),
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
                        final stickerIconAsset = selectedStickerIndex >= 0 &&
                                selectedStickerIndex < stickerOptions.length &&
                                stickerOptions[selectedStickerIndex].icon.isNotEmpty
                            ? stickerOptions[selectedStickerIndex].icon
                            : null;
                        // 三等分列 + 垂直居中：左右槽与中间拍照/录制在同一行对齐，避免 Stack 叠放时仅按整列高度居中导致与圆钮错位。
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: shoot.recordStatus == RecordStatus.normal
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
                                                color: stickerIconAsset != null
                                                    ? Colors.transparent
                                                    : Colors.black
                                                        .withValues(alpha: 0.35),
                                                borderRadius:
                                                    BorderRadius.circular(8.0.r),
                                              ),
                                              clipBehavior: Clip.antiAlias,
                                              alignment: Alignment.center,
                                              child: stickerIconAsset != null
                                                  ? Image.asset(
                                                      stickerIconAsset,
                                                      width: sideW,
                                                      height: sideH,
                                                      fit: BoxFit.cover,
                                                      gaplessPlayback: true,
                                                      errorBuilder:
                                                          (c, e, s) => Icon(
                                                        Icons.auto_awesome,
                                                        color: Colors.white,
                                                        size: iconSize,
                                                      ),
                                                    )
                                                  : Icon(
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
                              child: Center(child: _buttonUI(shoot)),
                            ),
                            Expanded(
                              child: Align(
                                alignment: Alignment.centerRight,
                                child: shoot.recordStatus == RecordStatus.normal
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
                                                color: (_albumThumbMemoryJpeg != null &&
                                                        _albumThumbMemoryJpeg!.isNotEmpty) ||
                                                        (_photoPermissionGranted && latestImage != null)
                                                    ? Colors.transparent
                                                    : Colors.black.withValues(alpha: 0.35),
                                              ),
                                              clipBehavior: Clip.antiAlias,
                                              alignment: Alignment.center,
                                              child: (_albumThumbMemoryJpeg != null &&
                                                      _albumThumbMemoryJpeg!.isNotEmpty)
                                                  ? Image.memory(
                                                      _albumThumbMemoryJpeg!,
                                                      key: ValueKey(_albumCoverDisplayToken),
                                                      width: sideW,
                                                      height: sideH,
                                                      fit: BoxFit.cover,
                                                      gaplessPlayback: true,
                                                    )
                                                  : _photoPermissionGranted && latestImage != null
                                                      ? Image.file(
                                                          latestImage!,
                                                          key: ValueKey(_albumCoverDisplayToken),
                                                          width: sideW,
                                                          height: sideH,
                                                          fit: BoxFit.cover,
                                                          gaplessPlayback: true,
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
          !isCompleteAllow && _permissionsResolved
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
          !_isInitialized &&
                  _permissionsResolved &&
                  isCompleteAllow &&
                  !isShowPreview &&
                  shoot.recordStatus == RecordStatus.normal
              ? const FetchLoadingView()
              : Container(),
        ],
      ),
        );
      },
    );
  }
}
