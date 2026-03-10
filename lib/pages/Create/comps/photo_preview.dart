import 'package:flutter/material.dart';

class PhotoPreview extends StatefulWidget {
  PhotoPreview({Key? key}) : super(key: key);

  @override
  _PhotoPreviewState createState() => _PhotoPreviewState();
}

class _PhotoPreviewState extends State<PhotoPreview> {
  @override
  Widget build(BuildContext context) {
    return Container(
       child: Center(child: Text('图片预览'),),
    );
  }
}