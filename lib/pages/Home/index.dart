import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
class HomePage extends StatefulWidget {
  HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
       child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
         children: [
           Text('Home Page'),
           ElevatedButton(onPressed: (){
            context.push('/login');
           }, child: Text('登录'))
         ],
       ),
    );
  }
}