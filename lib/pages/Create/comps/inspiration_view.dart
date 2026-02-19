import 'package:flutter/material.dart';

class InspirationView extends StatefulWidget {
  InspirationView({Key? key}) : super(key: key);

  @override
  _InspirationViewState createState() => _InspirationViewState();
}

class _InspirationViewState extends State<InspirationView> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Colors.pink,
       child: Text('创作灵感'),
    );
  }
}