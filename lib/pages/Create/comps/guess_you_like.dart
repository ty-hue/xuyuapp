import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class GuessYouLike extends StatefulWidget {
  GuessYouLike({Key? key}) : super(key: key);

  @override
  _GuessYouLikeState createState() => _GuessYouLikeState();
}

class _GuessYouLikeState extends State<GuessYouLike> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text.rich(
          style: TextStyle(
            fontSize: 23.sp,
            fontWeight: FontWeight.bold,
            color: Color.fromRGBO(255, 95, 48, 1),
            // 斜体
            fontStyle: FontStyle.italic,
          ),
          TextSpan(
            text: '猜',
            style: TextStyle(color: Color.fromRGBO(255, 95, 48, 1)),
            children: [
              TextSpan(
                text: '你',
                style: TextStyle(color: Color.fromRGBO(254,71,64, 1)),
                children: [
                  TextSpan(
                    text: '喜',
                    style: TextStyle(color: Color.fromRGBO(254,48,78, 1)),
                    children: [
                      TextSpan(
                        text: '欢',
                        style: TextStyle(color: Color.fromRGBO(254,48,78, 1)),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
