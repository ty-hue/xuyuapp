// 地址类型
import 'package:azlistview/azlistview.dart';

class AddressResult {
  final String country;
  final String province;
  final String city;

  const AddressResult({
    required this.country,
    required this.province,
    required this.city,
  });

  @override
  String toString() => '$country-$province-$city';
}

class AreaItem {
  final String name;
  final String code;
  final String groupCn;
  final bool hasSub;
  const AreaItem({
    required this.name,
    required this.code,
    required this.groupCn,
    required this.hasSub,
  });
  factory AreaItem.fromJson(Map<String, dynamic> json) {
    return AreaItem(
      name: json['name'],
      code: json['code'],
      groupCn: json['groupCn'],
      hasSub: json['hasSub'],
    );
  }
}

class AreaGroup extends ISuspensionBean {
  final String group;
  final List<AreaItem> items;
  AreaGroup({required this.group, required this.items});
  factory AreaGroup.fromJson(Map<String, dynamic> json) {
    return AreaGroup(
      group: json['group'],
      items: (json['items'] as List<dynamic>)
          .map((e) => AreaItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
  @override
  String getSuspensionTag() {
    return group;
  }
  // 可选：确保悬浮头部显示
  @override
  bool get isShowSuspension => true;
}
