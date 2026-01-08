import 'dart:typed_data';

class Album{
  final String name;
  final int count;
  final Uint8List? thumbnail;
  Album({
    required this.name,
    required this.count,
    this.thumbnail,
  });
}