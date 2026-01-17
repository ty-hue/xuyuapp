import 'package:flutter/material.dart';

class MenuItem {
  final String title;
  final IconData icon;
  Function() cb;
  MenuItem({
    required this.title,
    required this.icon,
    required this.cb,
  });
}

