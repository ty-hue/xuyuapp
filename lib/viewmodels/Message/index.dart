import 'package:flutter/material.dart';

class ContactItem {
  final String name;
  final String avatar;
  final String lastMessage;
  final String lastMessageTime;
  final String unreadCount;

  ContactItem({
    required this.name,
    required this.avatar,
    required this.lastMessage,
    required this.lastMessageTime,
    required this.unreadCount,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'avatar': avatar,
    'lastMessage': lastMessage,
    'lastMessageTime': lastMessageTime,
    'unreadCount': unreadCount,
  };

  factory ContactItem.fromJson(Map<String, dynamic> json) {
    return ContactItem(
      name: json['name'] as String? ?? '',
      avatar: json['avatar'] as String? ?? '',
      lastMessage: json['lastMessage'] as String? ?? '',
      lastMessageTime: json['lastMessageTime'] as String? ?? '',
      unreadCount: json['unreadCount'] as String? ?? '',
    );
  }
}

// 在线状态设置选项类型
enum StatusSettingsItemType {
  online("在线"),
  notToWho("不给谁看"),
  partVisible("部分可见"),
  closeOnline("关闭在线状态");

  final String label;
  const StatusSettingsItemType(this.label);
}

// 消息页的状态设置sheet选项模型
class StatusSettingsItem {
  final String title;
  final IconData icon;
  final bool isSelected;
  final StatusSettingsItemType type;

  StatusSettingsItem({
    required this.title,
    required this.icon,
    required this.isSelected,
    required this.type,
  });
}
