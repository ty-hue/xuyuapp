import 'package:bilbili_project/api/EditProfile/index.dart';
import 'package:bilbili_project/pages/Mine/comps/custom_azlistview.dart';
import 'package:bilbili_project/routes/app_router.dart';
import 'package:bilbili_project/routes/mine_routes/select_city_route.dart';
import 'package:bilbili_project/viewmodels/EditProfile/index.dart';
import 'package:flutter/material.dart';

class SelectProvince extends StatefulWidget {
  final String countryCode;
  SelectProvince({Key? key, required this.countryCode}) : super(key: key);

  @override
  State<SelectProvince> createState() => _SelectProvinceState();
}

class _SelectProvinceState extends State<SelectProvince> {
  List<AreaGroup> _areaList = [];

  @override
  void initState() {
    super.initState();
    _getAreaList();
  }

  Future<void> _getAreaList() async {
    final areaList = await getProvinceList({'countryCode': widget.countryCode});
    setState(() {
      _areaList = areaList;
    });
  }

  void _onSelect(AreaItem item) {
    // 直接进入城市页进行最后的选择
    SelectCityRoute(
      countryCode: widget.countryCode,
      provinceCode: item.code,
    ).push(context);
  }

  @override
  Widget build(BuildContext context) {
    return CustomAzlistview(areaList: _areaList, onSelect: _onSelect);
  }
}
