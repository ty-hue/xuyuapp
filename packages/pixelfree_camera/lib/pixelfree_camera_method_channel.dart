import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'pixelfree_camera_platform_interface.dart';
import 'pixelfree_gif_encoder.dart';

class MethodChannelPixelfreeCamera extends PixelfreeCameraPlatform {
  MethodChannelPixelfreeCamera() {
    methodChannel.setMethodCallHandler(_handleCallback);
  }

  @visibleForTesting
  final methodChannel = const MethodChannel('com.pixelfree.camera');

  ValueChanged<Map<String, double>?>? _faceOverlayListener;
  ValueChanged<FrontFlashHint?>? _frontFlashListener;

  @override
  Future<String?> getPlatformVersion() async {
    return methodChannel.invokeMethod<String>('getPlatformVersion');
  }

  @override
  Future<BeautyCameraSession> initialize(BeautyCameraConfig config) async {
    final rawId = await methodChannel.invokeMethod<dynamic>(
      'initCamera',
      config.toMap(),
    );
    final int previewTextureId = switch (rawId) {
      null => throw PlatformException(
          code: 'NULL_TEXTURE_ID',
          message: 'Native camera did not return a preview texture id.',
        ),
      int i => i,
      num n => n.toInt(),
      String s when int.tryParse(s) != null => int.parse(s),
      _ => throw PlatformException(
          code: 'NULL_TEXTURE_ID',
          message: 'Native camera did not return a preview texture id: $rawId',
        ),
    };
    if (previewTextureId <= 0) {
      throw PlatformException(
        code: 'INVALID_TEXTURE_ID',
        message: 'Preview texture id must be positive, got $previewTextureId',
      );
    }

    double? previewWidth;
    double? previewHeight;
    try {
      final size = await methodChannel
          .invokeMapMethod<String, dynamic>('getPreviewBufferSize');
      if (size != null) {
        final w = size['width'];
        final h = size['height'];
        if (w is num && h is num && w > 0 && h > 0) {
          previewWidth = w.toDouble();
          previewHeight = h.toDouble();
        }
      }
    } catch (_) {
      // Older native or iOS stub — preview still works without aspect metadata.
    }

    final inputGlTextureId = await getInputGlTextureId();

    return BeautyCameraSession(
      previewTextureId: previewTextureId,
      inputGlTextureId: inputGlTextureId > 0 ? inputGlTextureId : null,
      previewWidth: previewWidth,
      previewHeight: previewHeight,
    );
  }

  @override
  Future<int> getInputGlTextureId() async {
    return (await methodChannel.invokeMethod<int>('getInputGlTextureId')) ?? -1;
  }

  @override
  Future<void> switchCamera() async {
    await methodChannel.invokeMethod<void>('flipCamera');
  }

  @override
  Future<void> setRatio(CameraRatio ratio) async {
    await methodChannel.invokeMethod<void>('setRatio', {'ratio': ratio.value});
  }

  @override
  Future<void> setFlashMode(FlashMode mode) async {
    await methodChannel.invokeMethod<void>('setFlashMode', {'mode': mode.value});
  }

  @override
  Future<void> setBeauty(BeautySettings settings) async {
    await methodChannel.invokeMethod<void>('setBeauty', settings.toMap());
  }

  @override
  Future<void> setFilter(FilterSettings settings) async {
    await methodChannel.invokeMethod<void>('setFilter', settings.toMap());
  }

  @override
  Future<void> setSticker(StickerSettings settings) async {
    await methodChannel.invokeMethod<void>('setSticker', settings.toMap());
  }

  @override
  Future<void> setArEffect(String effect) async {
    await methodChannel.invokeMethod<void>('setArEffect', {'effect': effect});
  }

  @override
  Future<Map<String, double>?> getFaceOverlay() async {
    final map = await methodChannel.invokeMapMethod<String, dynamic>('getFaceOverlay');
    if (map == null) return null;
    return {
      'centerX': (map['centerX'] as num).toDouble(),
      'centerY': (map['centerY'] as num).toDouble(),
      'faceWidth': (map['faceWidth'] as num).toDouble(),
      'faceHeight': (map['faceHeight'] as num).toDouble(),
      'eyeCenterX': (map['eyeCenterX'] as num?)?.toDouble() ?? (map['centerX'] as num).toDouble(),
      'eyeCenterY': (map['eyeCenterY'] as num?)?.toDouble() ?? (map['centerY'] as num).toDouble(),
      'headTopX': (map['headTopX'] as num?)?.toDouble() ?? (map['centerX'] as num).toDouble(),
      'headTopY': (map['headTopY'] as num?)?.toDouble() ?? ((map['centerY'] as num).toDouble() - (map['faceHeight'] as num).toDouble() * 0.6),
    };
  }

  @override
  Future<Map<String, Object?>?> getFaceAlignmentDebug() async {
    return methodChannel.invokeMapMethod<String, dynamic>('getFaceAlignmentDebug');
  }

  @override
  void setFaceOverlayListener(ValueChanged<Map<String, double>?>? listener) {
    _faceOverlayListener = listener;
  }

  @override
  void setFrontFlashListener(ValueChanged<FrontFlashHint?>? listener) {
    _frontFlashListener = listener;
  }

  @override
  Future<void> setRecordSpeedProfile(RecordSpeedProfile profile) async {
    await methodChannel.invokeMethod<void>('setRecordSpeedProfile', {
      'profile': profile.name,
    });
  }

  @override
  Future<String> captureGif({int? durationMs, int? fps}) async {
    final dir = await methodChannel.invokeMethod<String>('captureGifFrames', {
      'durationMs': durationMs ?? 3000,
      'fps': fps ?? 10,
    });
    if (dir == null || dir.isEmpty) return '';
    return encodeJpegDirectoryToGifFile(dir);
  }

  Future<void> _handleCallback(MethodCall call) async {
    if (call.method == 'onFaceOverlay') {
      final map = (call.arguments as Map?)?.cast<String, dynamic>();
      if (_faceOverlayListener == null || map == null) return;
      _faceOverlayListener!.call({
        'centerX': (map['centerX'] as num).toDouble(),
        'centerY': (map['centerY'] as num).toDouble(),
        'faceWidth': (map['faceWidth'] as num).toDouble(),
        'faceHeight': (map['faceHeight'] as num).toDouble(),
        'eyeCenterX': (map['eyeCenterX'] as num?)?.toDouble() ?? (map['centerX'] as num).toDouble(),
        'eyeCenterY': (map['eyeCenterY'] as num?)?.toDouble() ?? (map['centerY'] as num).toDouble(),
        'headTopX': (map['headTopX'] as num?)?.toDouble() ?? (map['centerX'] as num).toDouble(),
        'headTopY': (map['headTopY'] as num?)?.toDouble() ?? ((map['centerY'] as num).toDouble() - (map['faceHeight'] as num).toDouble() * 0.6),
      });
      return;
    }
    if (call.method == 'onFrontFlashHint') {
      final map = (call.arguments as Map?)?.cast<String, dynamic>();
      if (_frontFlashListener == null || map == null) return;
      final active = map['active'] == true;
      final intensity = (map['intensity'] as num?)?.toDouble() ?? 0.92;
      _frontFlashListener!.call(FrontFlashHint(active: active, intensity: intensity));
    }
  }

  @override
  Future<TakePhotoResult> takePhoto() async {
    final raw = await methodChannel.invokeMethod<dynamic>('takePhoto');
    if (raw == null) {
      return const TakePhotoResult(path: '');
    }
    if (raw is String) {
      return TakePhotoResult(path: raw);
    }
    if (raw is Map) {
      final m = raw.cast<String, dynamic>();
      final path = m['path'] as String? ?? '';
      final pw = (m['pixelWidth'] as num?)?.toInt();
      final ph = (m['pixelHeight'] as num?)?.toInt();
      final jb = m['jpegBytes'];
      Uint8List? jpegBytes;
      if (jb is Uint8List) {
        jpegBytes = jb;
      } else if (jb is List) {
        jpegBytes = Uint8List.fromList(jb.cast<int>());
      }
      return TakePhotoResult(
        path: path,
        pixelWidth: pw != null && pw > 0 ? pw : null,
        pixelHeight: ph != null && ph > 0 ? ph : null,
        jpegBytes: jpegBytes,
      );
    }
    return const TakePhotoResult(path: '');
  }

  @override
  Future<void> startRecording({bool enableAudio = true}) async {
    await methodChannel.invokeMethod<void>('startRecord', {
      'enableAudio': enableAudio,
    });
  }

  @override
  Future<String> stopRecording() async {
    final path = await methodChannel.invokeMethod<String>('stopRecord');
    return path ?? '';
  }

  @override
  Future<void> dispose() async {
    _faceOverlayListener = null;
    _frontFlashListener = null;
    await methodChannel.invokeMethod<void>('releaseCamera');
  }
}
