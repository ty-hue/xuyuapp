import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class EditProfilePage extends StatefulWidget {
  EditProfilePage({Key? key}) : super(key: key);

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  @override
  Widget build(BuildContext context) {
    return WillPopScope(child:  Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () {
            context.pop();
          },
        ),
        title: const Text('编辑个人信息'),
      ),
    ), onWillPop: () async {
      context.pop();
      return true;
    });
  }
}