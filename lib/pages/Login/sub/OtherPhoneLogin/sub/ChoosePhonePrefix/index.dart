import 'dart:collection';

import 'package:bilbili_project/data/country_phone_prefix.dart';
import 'package:bilbili_project/pages/Login/sub/OtherPhoneLogin/params/params.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ChoosePhonePrefixPage extends StatefulWidget {
  ChoosePhonePrefixPage({Key? key}) : super(key: key);

  @override
  State<ChoosePhonePrefixPage> createState() => _ChoosePhonePrefixPageState();
}

class _ChoosePhonePrefixPageState extends State<ChoosePhonePrefixPage> {
  
  final List<OtherPhoneLoginParams> countryPhonePrefixList = rawData.map((e) => OtherPhoneLoginParams.fromJson(e)).toList();
  // 2. 用于存储处理后的数据
  late Map<String, List<OtherPhoneLoginParams>> groupedData;
  late List<String> sortedGroupKeys;
  @override
  initState() {
    super.initState();
    _processData();
  }

  void _processData() {
    // 使用 SplayTreeMap，它会自动根据 key (字母) 进行排序
    final map = SplayTreeMap<String, List<OtherPhoneLoginParams>>();

    // 遍历原始数据
    for (final country in countryPhonePrefixList) {
      final group = country.groupCn;
      // 如果 map 中还没有这个字母的 key，就创建一个空列表
      if (!map.containsKey(group)) {
        map[group] = [];
      }
      // 将当前国家添加到对应字母的列表中
      map[group]!.add(country);
    }
    // 将处理好的数据赋值给 state 变量
    setState(() {
      groupedData = map;
      // 提取已排序的字母列表，用于后续渲染
      sortedGroupKeys = map.keys.toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios),
          onPressed: () {
            context.pop();
          },
        ),
        title: Text('选择国家和地区'),
        centerTitle: true,
      ),
      body: ListView.builder(
        // 外层列表的 itemCount 是字母分组的数量
        itemCount: sortedGroupKeys.length,
        itemBuilder: (context, groupIndex) {
          // 获取当前字母分组的 key (如 'A')
          final groupKey = sortedGroupKeys[groupIndex];
          // 根据 key 从 groupedData 中获取对应的国家列表
          final countriesInGroup = groupedData[groupKey]!;

          // 返回一个 Column，包含字母标题和国家列表
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. 渲染字母标题
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8.0,
                ),
                child: Text(
                  groupKey,
                  style: const TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
              ),
              // 2. 渲染该字母下的所有国家
              ListView.builder(
                // 关键属性 1: shrinkWrap: true
                // 这告诉内部的 ListView 不要无限延伸，而是根据其内容的高度来调整自身大小。
                shrinkWrap: true,
                // 关键属性 2: physics: NeverScrollableScrollPhysics()
                // 这禁用了内部 ListView 的滚动功能，因为我们希望整个页面由外层 ListView 统一滚动。
                physics: const NeverScrollableScrollPhysics(),
                itemCount: countriesInGroup.length,
                itemBuilder: (context, countryIndex) {
                  final country = countriesInGroup[countryIndex];
                  return ListTile(
                    title: Text(country.name),
                    trailing: Text(
                      country.code,
                      style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onTap: () {
                      // 点击国家后，返回上一页并携带数据
                      context.push(
                        '/login/other_phone_login',
                        extra: country,
                      );
                    },
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
