import 'package:bilbili_project/routes/app_router.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    print('宽高${MediaQuery.of(context).size}');
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Home Page'),
          ElevatedButton(
            onPressed: () {
               LoginRoute().push(context);
            },
            child: Text('去登录1'),
          ),
        ],
      ),
    );
  }
}