import 'package:flutter/material.dart';

class CameraPreviewWidget extends StatelessWidget {
  final int? textureId;
  final double? previewWidth;
  final double? previewHeight;

  const CameraPreviewWidget({
    Key? key,
    required this.textureId,
    required this.previewWidth,
    required this.previewHeight,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (textureId == null || previewWidth == null || previewHeight == null) {
      return Container(color: Colors.black);
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          width: constraints.maxWidth,
          height: constraints.maxHeight,
          color: Colors.black,
          child: FittedBox(
            fit: BoxFit.cover,
            alignment: Alignment.center,
            child: AspectRatio(
              aspectRatio: previewWidth! / previewHeight!,
              child: Texture(textureId: textureId!),
            ),
          ),
        );
      },
    );
  }
}