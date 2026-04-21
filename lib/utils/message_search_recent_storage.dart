import 'dart:convert';

import 'package:bilbili_project/constants/index.dart';
import 'package:bilbili_project/viewmodels/Message/index.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 消息页搜索：最近点击过的联系人（本地持久化，条数见 [GlobalConstants.MESSAGE_SEARCH_RECENT_MAX]）。
class MessageSearchRecentStorage {
  MessageSearchRecentStorage._();

  static Future<List<ContactItem>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(GlobalConstants.MESSAGE_SEARCH_RECENT_KEY);
    if (raw == null || raw.isEmpty) return [];
    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      return decoded
          .map((e) => ContactItem.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(growable: false);
    } catch (_) {
      return [];
    }
  }

  static Future<void> _save(List<ContactItem> list) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(list.map((e) => e.toJson()).toList());
    await prefs.setString(GlobalConstants.MESSAGE_SEARCH_RECENT_KEY, encoded);
  }

  /// 新点击的联系人排到最前；与已有项按 name+avatar 去重；最多保留 10 条。
  static Future<void> add(ContactItem contact) async {
    final list = await load();
    final next = <ContactItem>[
      contact,
      ...list.where(
        (e) => e.name != contact.name || e.avatar != contact.avatar,
      ),
    ];
    final max = GlobalConstants.MESSAGE_SEARCH_RECENT_MAX;
    await _save(
      next.length <= max ? next : next.sublist(0, max),
    );
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(GlobalConstants.MESSAGE_SEARCH_RECENT_KEY);
  }
}
