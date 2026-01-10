import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MessagePage extends StatefulWidget {
  MessagePage({Key? key}) : super(key: key);

  @override
  State<MessagePage> createState() => _MessagePageState();
}

class _MessagePageState extends State<MessagePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('消息'),
      ),
      body: Column(
        children: [
          Container(
            height: 200.0.h,
            color: Colors.red,
          ),
          Container(
            height: 200.0.h,
            color: Colors.blue,
            child: OverflowBox(
              child: Stack(
                clipBehavior: Clip.none,
              children: [
                Positioned(
                  top: -20.0.h,
                  left: 10.0.w,
                  child: Container(
                    width: 40.0.w,
                    height: 40.0.h,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        image: AssetImage('lib/assets/avatar.webp'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            )
          ),
        ],
      )
    );
  }
}
