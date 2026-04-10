import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pixelfree_camera/pixelfree_camera.dart';
import 'package:pixelfree_camera/pixelfree_camera_method_channel.dart';
import 'package:pixelfree_camera/pixelfree_camera_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockPixelfreeCameraPlatform
    with MockPlatformInterfaceMixin
    implements PixelfreeCameraPlatform {
  @override
  Future<String?> getPlatformVersion() => Future.value('42');

  @override
  Future<BeautyCameraSession> initialize(BeautyCameraConfig config) async {
    return const BeautyCameraSession(previewTextureId: 42, inputGlTextureId: 7);
  }

  @override
  Future<int> getInputGlTextureId() async => 7;

  @override
  Future<void> switchCamera() async {}

  @override
  Future<void> setRatio(CameraRatio ratio) async {}

  @override
  Future<void> setFlashMode(FlashMode mode) async {}

  @override
  Future<void> setBeauty(BeautySettings settings) async {}

  @override
  Future<void> setFilter(FilterSettings settings) async {}

  @override
  Future<void> setSticker(StickerSettings settings) async {}

  @override
  Future<void> setArEffect(String effect) async {}

  @override
  Future<Map<String, double>?> getFaceOverlay() async => null;

  @override
  Future<Map<String, Object?>?> getFaceAlignmentDebug() async => null;

  @override
  void setFaceOverlayListener(ValueChanged<Map<String, double>?>? listener) {}

  @override
  void setFrontFlashListener(ValueChanged<FrontFlashHint?>? listener) {}

  @override
  Future<void> setRecordSpeedProfile(RecordSpeedProfile profile) async {}

  @override
  Future<String> captureGif({int? durationMs, int? fps}) async => '';

  @override
  Future<TakePhotoResult> takePhoto() async => TakePhotoResult(
        path: '',
        pixelWidth: 1920,
        pixelHeight: 1080,
        jpegBytes: Uint8List.fromList(const [0xff, 0xd8, 0xff]),
      );

  @override
  Future<void> startRecording({bool enableAudio = true}) async {}

  @override
  Future<String> stopRecording() async => 'video.mp4';

  @override
  Future<void> dispose() async {}
}

void main() {
  final initialPlatform = PixelfreeCameraPlatform.instance;

  test('$MethodChannelPixelfreeCamera is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelPixelfreeCamera>());
  });

  test('initialize returns a session', () async {
    PixelfreeCameraPlatform.instance = MockPixelfreeCameraPlatform();
    final camera = PixelfreeCamera();
    final session = await camera.initialize();
    expect(session.previewTextureId, 42);
    expect(session.inputGlTextureId, 7);
  });
}
