import 'package:bilbili_project/routes/login_route.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Home Page'),
          ElevatedButton(
            onPressed: () {
               LoginRoute().go(context);
            },
            child: Text('去登录1'),
          ),
        ],
      ),
    );
  }
}