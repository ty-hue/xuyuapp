import 'package:flutter/foundation.dart';
import 'pixelfree_camera_platform_interface.dart';

export 'pixelfree_camera_platform_interface.dart'
    show
        BeautyCameraConfig,
        BeautyCameraSession,
        TakePhotoResult,
        BeautySettings,
        FilterSettings,
        StickerSettings,
        CameraRatio,
        FlashMode,
        CameraPosition,
        FrontFlashHint,
        RecordSpeedProfile;

class PixelfreeCamera {
  const PixelfreeCamera();

  Future<String?> getPlatformVersion() {
    return PixelfreeCameraPlatform.instance.getPlatformVersion();
  }

  Future<BeautyCameraSession> initialize({
    BeautyCameraConfig config = const BeautyCameraConfig(),
  }) {
    return PixelfreeCameraPlatform.instance.initialize(config);
  }

  Future<void> switchCamera() {
    return PixelfreeCameraPlatform.instance.switchCamera();
  }

  Future<void> setRatio(CameraRatio ratio) {
    return PixelfreeCameraPlatform.instance.setRatio(ratio);
  }

  Future<void> setFlashMode(FlashMode mode) {
    return PixelfreeCameraPlatform.instance.setFlashMode(mode);
  }

  Future<void> setBeauty(BeautySettings settings) {
    return PixelfreeCameraPlatform.instance.setBeauty(settings);
  }

  Future<void> setFilter(FilterSettings settings) {
    return PixelfreeCameraPlatform.instance.setFilter(settings);
  }

  Future<void> setSticker(StickerSettings settings) {
    return PixelfreeCameraPlatform.instance.setSticker(settings);
  }

  Future<void> setArEffect(String effect) {
    return PixelfreeCameraPlatform.instance.setArEffect(effect);
  }

  Future<Map<String, double>?> getFaceOverlay() {
    return PixelfreeCameraPlatform.instance.getFaceOverlay();
  }

  /// Debug: sensor vs preview buffer sizes, detection path, Kalman nose (Android). See native tag `PixelfreeFaceAlign`.
  Future<Map<String, Object?>?> getFaceAlignmentDebug() {
    return PixelfreeCameraPlatform.instance.getFaceAlignmentDebug();
  }

  void setFaceOverlayListener(ValueChanged<Map<String, double>?>? listener) {
    PixelfreeCameraPlatform.instance.setFaceOverlayListener(listener);
  }

  void setFrontFlashListener(ValueChanged<FrontFlashHint?>? listener) {
    PixelfreeCameraPlatform.instance.setFrontFlashListener(listener);
  }

  Future<void> setRecordSpeedProfile(RecordSpeedProfile profile) {
    return PixelfreeCameraPlatform.instance.setRecordSpeedProfile(profile);
  }

  Future<String> captureGif({int? durationMs, int? fps}) {
    return PixelfreeCameraPlatform.instance.captureGif(durationMs: durationMs, fps: fps);
  }

  Future<TakePhotoResult> takePhoto() {
    return PixelfreeCameraPlatform.instance.takePhoto();
  }

  Future<void> startRecording({bool enableAudio = true}) {
    return PixelfreeCameraPlatform.instance.startRecording(enableAudio: enableAudio);
  }

  Future<String> stopRecording() {
    return PixelfreeCameraPlatform.instance.stopRecording();
  }

  Future<void> dispose() {
    return PixelfreeCameraPlatform.instance.dispose();
  }
}

class PixelfreeCameraPlugin {
  static const PixelfreeCamera instance = PixelfreeCamera();

  static const String flashModeOff = 'off';
  static const String flashModeOn = 'on';
  static const String flashModeAuto = 'auto';

  static const String ratio9_16 = '9:16';
  static const String ratio3_4 = '3:4';

  static const int cameraBack = 0;
  static const int cameraFront = 1;

  static Future<int> initCamera({
    String ratio = ratio9_16,
    String flashMode = flashModeOff,
    int cameraId = cameraFront,
    bool enableAudio = true,
  }) async {
    final session = await instance.initialize(
      config: BeautyCameraConfig(
        ratio: ratio == ratio3_4 ? CameraRatio.ratio3x4 : CameraRatio.ratio9x16,
        flashMode: switch (flashMode) {
          flashModeOn => FlashMode.on,
          flashModeAuto => FlashMode.auto,
          _ => FlashMode.off,
        },
        cameraPosition: cameraId == cameraFront
            ? CameraPosition.front
            : CameraPosition.back,
        enableAudio: enableAudio,
      ),
    );
    return session.previewTextureId; // dimensions: session.previewWidth / previewHeight
  }

  static Future<int> getInputGlTextureId() {
    return PixelfreeCameraPlatform.instance.getInputGlTextureId();
  }

  static Future<void> setRatio(String ratio) async {
    await instance.setRatio(ratio == ratio3_4 ? CameraRatio.ratio3x4 : CameraRatio.ratio9x16);
  }

  static Future<void> setFlashMode(String mode) async {
    await instance.setFlashMode(switch (mode) {
      flashModeOn => FlashMode.on,
      flashModeAuto => FlashMode.auto,
      _ => FlashMode.off,
    });
  }

  static Future<void> flipCamera() async {
    await instance.switchCamera();
  }

  static Future<TakePhotoResult> takePhoto() {
    return instance.takePhoto();
  }

  static Future<void> startRecord({bool enableAudio = true}) {
    return instance.startRecording(enableAudio: enableAudio);
  }

  static Future<String> stopRecord() {
    return instance.stopRecording();
  }

  static Future<void> releaseCamera() {
    return instance.dispose();
  }
}
