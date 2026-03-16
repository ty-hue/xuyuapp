import 'package:flutter/material.dart';

class CameraGridOverlay extends StatelessWidget {
  final Color lineColor;
  final double lineWidth;

  const CameraGridOverlay({
    Key? key,
    this.lineColor = Colors.white54,
    this.lineWidth = 1.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.infinite,
      painter: _GridPainter(lineColor: lineColor, lineWidth: lineWidth),
    );
  }
}

class _GridPainter extends CustomPainter {
  final Color lineColor;
  final double lineWidth;

  _GridPainter({required this.lineColor, required this.lineWidth});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = lineColor
      ..strokeWidth = lineWidth;

    // 计算分割位置
    final thirdWidth = size.width / 3;
    final thirdHeight = size.height / 3;

    // 画竖线
    canvas.drawLine(Offset(thirdWidth, 0), Offset(thirdWidth, size.height), paint);
    canvas.drawLine(Offset(thirdWidth * 2, 0), Offset(thirdWidth * 2, size.height), paint);

    // 画横线
    canvas.drawLine(Offset(0, thirdHeight), Offset(size.width, thirdHeight), paint);
    canvas.drawLine(Offset(0, thirdHeight * 2), Offset(size.width, thirdHeight * 2), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}