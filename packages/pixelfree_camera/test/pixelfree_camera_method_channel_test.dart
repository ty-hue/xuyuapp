import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pixelfree_camera/pixelfree_camera_method_channel.dart';
import 'package:pixelfree_camera/pixelfree_camera_platform_interface.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final platform = MethodChannelPixelfreeCamera();
  const channel = MethodChannel('com.pixelfree.camera');

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (methodCall) async {
      switch (methodCall.method) {
        case 'getPlatformVersion':
          return '42';
        case 'initCamera':
          return 99;
        case 'getInputGlTextureId':
          return 5;
        default:
          return null;
      }
    });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  test('getPlatformVersion', () async {
    expect(await platform.getPlatformVersion(), '42');
  });

  test('initialize returns camera session', () async {
    final session = await platform.initialize(const BeautyCameraConfig());
    expect(session.previewTextureId, 99);
    expect(session.inputGlTextureId, 5);
  });
}
