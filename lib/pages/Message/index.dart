import 'package:flutter/material.dart';

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
            height: 200,
            color: Colors.red,
          ),
          Container(
            height: 200,
            color: Colors.blue,
            child: OverflowBox(
              child: Stack(
                clipBehavior: Clip.none,
              children: [
                Positioned(
                  top: -20,
                  left: 10,
                  child: Container(
                    width: 40,
                    height: 40,
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
