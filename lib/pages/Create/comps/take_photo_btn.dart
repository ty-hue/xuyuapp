import 'package:bilbili_project/viewmodels/Create/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class TakePhotoButton extends StatefulWidget {
  final VoidCallback takePhoto;
  final RecordStatus recordStatus;
  TakePhotoButton({
    Key? key,
    required this.takePhoto,
    required this.recordStatus,
  });

  @override
  _TakePhotoButtonState createState() => _TakePhotoButtonState();
}

class _TakePhotoButtonState extends State<TakePhotoButton> {
  @override
  void initState() {
    super.initState();
  }

  // 开始拍照
  void _takePhoto() {
    widget.takePhoto();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _takePhoto();
      },
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 72.0.w,
            height: 72.0.h,
            decoration: BoxDecoration(
              color: Colors.transparent,
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white,
                width: 6.0.w,
              ),
            ),
          ),
          Container(
            width: 54.0.w,
            height: 54.0.h,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
    );
  }
}
