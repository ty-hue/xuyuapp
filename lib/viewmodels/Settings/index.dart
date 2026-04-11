import 'package:flutter/material.dart';

class ActionPageParams {
  final String title;
  final Widget child;
  ActionPageParams({
    required this.title,
    required this.child,
  });
}

// 协议通用模型
class AgreementModel {
  final String title;
  final String content;
  AgreementModel({
    required this.title,
    required this.content,
  });
  factory AgreementModel.fromJson(Map<String, dynamic> json) {
    return AgreementModel(
      title: json['title'],
      content: json['content'],
    );
  }
}