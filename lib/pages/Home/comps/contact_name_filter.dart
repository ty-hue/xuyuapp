import 'dart:collection';

import 'package:bilbili_project/viewmodels/Message/index.dart';
import 'package:lpinyin/lpinyin.dart';

class _NameSearchIndex {
  /// 全拼连续串（小写、无空格），用于「zhangsan」「zhangs」等匹配
  final String fullPinyin;

  /// 拼音首字母连续串（小写），用于「zs」等匹配
  final String initials;

  const _NameSearchIndex({
    required this.fullPinyin,
    required this.initials,
  });
}

/// 联系人名称 → 拼音索引，避免每次输入都全量转拼音
final LinkedHashMap<String, _NameSearchIndex> _nameIndexCache =
    LinkedHashMap<String, _NameSearchIndex>();

const int _maxNameIndexCacheEntries = 2000;

_NameSearchIndex _indexForName(String name) {
  final cached = _nameIndexCache.remove(name);
  if (cached != null) {
    _nameIndexCache[name] = cached;
    return cached;
  }

  String full = '';
  String initials = '';
  try {
    full = PinyinHelper.getPinyinE(
      name,
      separator: '',
      defPinyin: '',
      format: PinyinFormat.WITHOUT_TONE,
    ).toLowerCase();
    full = full.replaceAll(RegExp(r'\s+'), '');
    initials =
        PinyinHelper.getShortPinyin(name).toLowerCase().replaceAll(
              RegExp(r'\s+'),
              '',
            );
  } catch (_) {
    // 含无法转拼音字符时仅依赖展示名匹配
  }

  final built = _NameSearchIndex(fullPinyin: full, initials: initials);
  _nameIndexCache[name] = built;
  while (_nameIndexCache.length > _maxNameIndexCacheEntries) {
    _nameIndexCache.remove(_nameIndexCache.keys.first);
  }
  return built;
}

bool _contactMatchesNameQuery(ContactItem c, String needleLower) {
  final needleCompact = needleLower.replaceAll(RegExp(r'\s+'), '');
  final nameLower = c.name.toLowerCase();
  if (nameLower.contains(needleLower)) return true;
  if (needleCompact.isEmpty) return false;

  final idx = _indexForName(c.name);
  if (idx.fullPinyin.contains(needleCompact)) return true;
  if (idx.initials.contains(needleCompact)) return true;
  return false;
}

/// 按联系人名称模糊匹配：原文子串、全拼子串、拼音首字母子串（忽略大小写，忽略查询中的空格）。
/// 查询为空时返回原列表引用。
List<ContactItem> filterContactsByName(
  List<ContactItem> source,
  String query,
) {
  final trimmed = query.trim();
  if (trimmed.isEmpty) return source;
  final needle = trimmed.toLowerCase();
  return source
      .where((c) => _contactMatchesNameQuery(c, needle))
      .toList(growable: false);
}
