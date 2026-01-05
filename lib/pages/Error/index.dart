import 'package:flutter/material.dart';

class ErrorPage extends StatefulWidget {
  final Exception error;
  ErrorPage({Key? key, required this.error}) : super(key: key);

  @override
  State<ErrorPage> createState() => _ErrorPageState();
}

class _ErrorPageState extends State<ErrorPage> {
  @override
  Widget build(BuildContext context) {
    return Container(
       child: null,
    );
  }
}