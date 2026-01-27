import 'dart:typed_data';
import 'package:bilbili_project/components/with_statusBar_color.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

class SingleImagePreviewPage extends StatefulWidget {
  final Map<String, Uint8List?> imageMap;
  SingleImagePreviewPage({Key? key, required this.imageMap}) : super(key: key);

  @override
  State<SingleImagePreviewPage> createState() => _SingleImagePreviewPageState();
}

class _SingleImagePreviewPageState extends State<SingleImagePreviewPage> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pop(context),
      child: Hero(
        tag: widget.imageMap.keys.first,
        child: WithStatusbarColorView(
          statusBarColor: Colors.black,
          child: Scaffold(
            backgroundColor: Colors.black,
            body: Center(
              child: PhotoView(
                imageProvider: MemoryImage(widget.imageMap.values.first!),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
