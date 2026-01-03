import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CreatePage extends StatefulWidget {
  CreatePage({Key? key}) : super(key: key);

  @override
  State<CreatePage> createState() => _CreatePageState();
}

class _CreatePageState extends State<CreatePage> {
  @override
  Widget build(BuildContext context) {
    return Container(
       child: Center(
         child: Column(
          children: [
            Text('Create page'),
            TextButton(onPressed: (){
              context.go('/');
            }, child: Text('回到首页'))
          ],
         )
       ),
    );
  }
}