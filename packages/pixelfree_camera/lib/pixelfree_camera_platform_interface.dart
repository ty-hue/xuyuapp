import 'package:flutter/foundation.dart';
import 'dart:typed_data';

import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'pixelfree_camera_method_channel.dart';

class BeautyCameraConfig {
  const BeautyCameraConfig({
    this.ratio = CameraRatio.ratio9x16,
    this.flashMode = FlashMode.off,
    this.cameraPosition = CameraPosition.front,
    this.enableAudio = true,
    this.previewViewportWidth,
    this.previewViewportHeight,
    this.enableScreenFlashForFront = true,
    this.gifMaxDurationMs = 5000,
    this.recordSpeedProfile = RecordSpeedProfile.normal,
  });

  final CameraRatio ratio;
  final FlashMode flashMode;
  final CameraPosition cameraPosition;
  /// 仍随 [initCamera] 传给原生；**是否录环境音**以 [PixelfreeCameraPlatform.startRecording] 的 [enableAudio] 为准。
  final bool enableAudio;

  /// Logical size of the Flutter preview area (e.g. [LayoutBuilder] constraints). When set, native
  /// picks a camera / GL buffer aspect ratio to match so full-screen [BoxFit.cover] matches TikTok
  /// / Douyin (no letterboxing, minimal aspect crop).
  final double? previewViewportWidth;
  final double? previewViewportHeight;

  /// When true, native may invoke [PixelfreeCameraPlatform.setFrontFlashListener] so Flutter can
  /// show a white overlay for front-camera "flash".
  final bool enableScreenFlashForFront;

  /// Upper bound passed to [captureGif] when duration is omitted.
  final int gifMaxDurationMs;

  /// Recording time-stretch: affects muxed video PTS (slow-mo / timelapse style).
  final RecordSpeedProfile recordSpeedProfile;

  Map<String, Object?> toMap() {
    return {
      'ratio': ratio.value,
      'flashMode': flashMode.value,
      'cameraId': cameraPosition.cameraId,
      'enableAudio': enableAudio,
      'enableScreenFlashForFront': enableScreenFlashForFront,
      'gifMaxDurationMs': gifMaxDurationMs,
      'recordSpeedProfile': recordSpeedProfile.name,
      if (previewViewportWidth != null) 'previewViewportWidth': previewViewportWidth,
      if (previewViewportHeight != null) 'previewViewportHeight': previewViewportHeight,
    };
  }
}

/// Muxed output speed relative to real time (encoder presentation timestamps).
enum RecordSpeedProfile {
  /// 1:1 real-time recording.
  normal,
  /// Stretch timeline so motion appears slower (device must support high-FPS capture where used).
  slow,
  /// Compress timeline (fast motion / timelapse).
  fast,
}

class BeautyCameraSession {
  const BeautyCameraSession({
    required this.previewTextureId,
    this.inputGlTextureId,
    this.previewWidth,
    this.previewHeight,
  });

  final int previewTextureId;
  final int? inputGlTextureId;

  /// Native camera / GL preview buffer size (e.g. 720×1280). Use with [AspectRatio] so [Texture] is not stretched.
  final double? previewWidth;
  final double? previewHeight;
}

/// [takePhoto] result. [pixelWidth]/[pixelHeight] match the JPEG when native provides them (>0).
/// [jpegBytes] — 仍图数据（native 读入内存后删除临时文件）；与 [path] 二选一，优先使用字节。
class TakePhotoResult {
  const TakePhotoResult({
    required this.path,
    this.pixelWidth,
    this.pixelHeight,
    this.jpegBytes,
  });

  final String path;
  final int? pixelWidth;
  final int? pixelHeight;
  final Uint8List? jpegBytes;
}

class BeautySettings {
  const BeautySettings({
    this.smoothing = 0,
    this.whitening = 0,
    this.ruddy = 0,
    this.sharpen = 0,
    this.bigEye = 0,
    /// 亮眼（眼周/虹膜局部提亮），与 [bigEye] 几何大眼不同。
    this.eyeBrighten = 0,
    this.slimFace = 0,
    this.portraitBlur = 0,
    this.faceNarrow = 0,
    this.faceChin = 0,
    this.faceV = 0,
    this.faceNose = 0,
    this.faceForehead = 0,
    this.faceMouth = 0,
    this.facePhiltrum = 0,
    this.faceLongNose = 0,
    this.faceEyeSpace = 0,
    this.faceSmile = 0,
    this.faceCanthus = 0,
  });

  final double smoothing;
  final double whitening;
  final double ruddy;
  final double sharpen;
  final double bigEye;
  final double eyeBrighten;
  final double slimFace;
  /// 0..1 — GPU portrait / background blur (preview + GL photo).
  final double portraitBlur;

  /// 瘦脸之后各项：0..1，由 Android 片元近似形变实现。
  final double faceNarrow;
  final double faceChin;
  final double faceV;
  /// 鼻梁高度（原生片元竖直形变），0..1。
  final double faceNose;
  final double faceForehead;
  final double faceMouth;
  final double facePhiltrum;
  final double faceLongNose;
  final double faceEyeSpace;
  final double faceSmile;
  final double faceCanthus;

  Map<String, Object?> toMap() {
    return {
      'smoothing': smoothing,
      'whitening': whitening,
      'ruddy': ruddy,
      'sharpen': sharpen,
      'bigEye': bigEye,
      'eyeBrighten': eyeBrighten,
      'slimFace': slimFace,
      'portraitBlur': portraitBlur,
      'faceNarrow': faceNarrow,
      'faceChin': faceChin,
      'faceV': faceV,
      'faceNose': faceNose,
      'faceForehead': faceForehead,
      'faceMouth': faceMouth,
      'facePhiltrum': facePhiltrum,
      'faceLongNose': faceLongNose,
      'faceEyeSpace': faceEyeSpace,
      'faceSmile': faceSmile,
      'faceCanthus': faceCanthus,
    };
  }
}

class FilterSettings {
  const FilterSettings({
    this.filterId,
    this.intensity = 0,
  });

  final String? filterId;
  final double intensity;

  Map<String, Object?> toMap() {
    return {
      'filterId': filterId,
      'intensity': intensity,
    };
  }
}

class StickerSettings {
  const StickerSettings({
    this.stickerId,
    this.assetPath,
    this.bundleName,
    this.bundleAssetPath,
    this.previewImageAssetPath,
    this.anchorType,
    this.scale = 1,
    this.offsetX = 0,
    this.offsetY = 0,
  });

  final String? stickerId;
  final String? assetPath;
  final String? bundleName;
  final String? bundleAssetPath;
  final String? previewImageAssetPath;
  final String? anchorType;
  final double scale;
  final double offsetX;
  final double offsetY;

  Map<String, Object?> toMap() {
    return {
      'stickerId': stickerId,
      'assetPath': assetPath,
      'bundleName': bundleName,
      'bundleAssetPath': bundleAssetPath,
      'previewImageAssetPath': previewImageAssetPath,
      'anchorType': anchorType,
      'scale': scale,
      'offsetX': offsetX,
      'offsetY': offsetY,
    };
  }
}

enum CameraRatio {
  ratio9x16('9:16'),
  ratio3x4('3:4');

  const CameraRatio(this.value);
  final String value;
}

enum FlashMode {
  off('off'),
  on('on'),
  auto('auto');

  const FlashMode(this.value);
  final String value;
}

enum CameraPosition {
  back(0),
  front(1);

  const CameraPosition(this.cameraId);
  final int cameraId;
}

/// Native hint for front-camera screen fill-light (no hardware torch).
class FrontFlashHint {
  const FrontFlashHint({required this.active, this.intensity = 0.92});

  final bool active;
  final double intensity;
}

abstract class PixelfreeCameraPlatform extends PlatformInterface {
  PixelfreeCameraPlatform() : super(token: _token);

  static final Object _token = Object();

  static PixelfreeCameraPlatform _instance = MethodChannelPixelfreeCamera();

  static PixelfreeCameraPlatform get instance => _instance;

  static set instance(PixelfreeCameraPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('getPlatformVersion() has not been implemented.');
  }

  Future<BeautyCameraSession> initialize(BeautyCameraConfig config) {
    throw UnimplementedError('initialize() has not been implemented.');
  }

  Future<int> getInputGlTextureId() {
    throw UnimplementedError('getInputGlTextureId() has not been implemented.');
  }

  Future<void> switchCamera() {
    throw UnimplementedError('switchCamera() has not been implemented.');
  }

  Future<void> setRatio(CameraRatio ratio) {
    throw UnimplementedError('setRatio() has not been implemented.');
  }

  Future<void> setFlashMode(FlashMode mode) {
    throw UnimplementedError('setFlashMode() has not been implemented.');
  }

  Future<void> setBeauty(BeautySettings settings) {
    throw UnimplementedError('setBeauty() has not been implemented.');
  }

  Future<void> setFilter(FilterSettings settings) {
    throw UnimplementedError('setFilter() has not been implemented.');
  }

  Future<void> setSticker(StickerSettings settings) {
    throw UnimplementedError('setSticker() has not been implemented.');
  }

  Future<void> setArEffect(String effect) {
    throw UnimplementedError('setArEffect() has not been implemented.');
  }

  Future<Map<String, double>?> getFaceOverlay() {
    throw UnimplementedError('getFaceOverlay() has not been implemented.');
  }

  /// Android: buffer / upright geometry, mlPath (mediapipe|remapped|prepared|…), Kalman nose, AR effect id.
  Future<Map<String, Object?>?> getFaceAlignmentDebug() {
    throw UnimplementedError('getFaceAlignmentDebug() has not been implemented.');
  }

  void setFaceOverlayListener(ValueChanged<Map<String, double>?>? listener) {
    throw UnimplementedError('setFaceOverlayListener() has not been implemented.');
  }

  void setFrontFlashListener(ValueChanged<FrontFlashHint?>? listener) {
    throw UnimplementedError('setFrontFlashListener() has not been implemented.');
  }

  Future<void> setRecordSpeedProfile(RecordSpeedProfile profile) {
    throw UnimplementedError('setRecordSpeedProfile() has not been implemented.');
  }

  /// Encodes a short animated GIF from preview frames (WYSIWYG with current beauty/AR).
  Future<String> captureGif({int? durationMs, int? fps}) {
    throw UnimplementedError('captureGif() has not been implemented.');
  }

  Future<TakePhotoResult> takePhoto() {
    throw UnimplementedError('takePhoto() has not been implemented.');
  }

  /// [enableAudio]：本段录像是否采集麦克风（与 [BeautyCameraConfig.enableAudio] 解耦，避免改开关即重启相机）。
  Future<void> startRecording({bool enableAudio = true}) {
    throw UnimplementedError('startRecording() has not been implemented.');
  }

  Future<String> stopRecording() {
    throw UnimplementedError('stopRecording() has not been implemented.');
  }

  Future<void> dispose() {
    throw UnimplementedError('dispose() has not been implemented.');
  }
}
