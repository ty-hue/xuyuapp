import 'dart:io';

import 'package:image/image.dart' as img;

/// Assembles JPEG frames written by native [captureGifFrames] into a single GIF file.
Future<String> encodeJpegDirectoryToGifFile(String jpegDirPath) async {
  final dir = Directory(jpegDirPath);
  if (!dir.existsSync()) return '';
  final files = dir
      .listSync()
      .whereType<File>()
      .where((f) => f.path.toLowerCase().endsWith('.jpg'))
      .toList()
    ..sort((a, b) => a.path.compareTo(b.path));
  if (files.isEmpty) return '';

  final encoder = img.GifEncoder(repeat: 0, samplingFactor: 12);
  for (final f in files) {
    final bytes = f.readAsBytesSync();
    final image = img.decodeImage(bytes);
    if (image != null) {
      encoder.addFrame(image, duration: 8);
    }
  }
  final gifBytes = encoder.finish()!;
  final out = File(
    '${dir.parent.path}/gif_${DateTime.now().millisecondsSinceEpoch}.gif',
  );
  out.writeAsBytesSync(gifBytes);
  try {
    dir.deleteSync(recursive: true);
  } catch (_) {}
  return out.path;
}
