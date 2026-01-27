import 'package:bilbili_project/api/EditProfile/index.dart';
import 'package:bilbili_project/components/custom_azlistview.dart';
import 'package:bilbili_project/routes/app_router.dart';
import 'package:bilbili_project/routes/mine_routes/select_city_route.dart';
import 'package:bilbili_project/routes/mine_routes/select_province_route.dart';
import 'package:bilbili_project/viewmodels/EditProfile/index.dart';
import 'package:flutter/material.dart';

class SelectCountry extends StatefulWidget {
  SelectCountry({Key? key}) : super(key: key);

  @override
  State<SelectCountry> createState() => _SelectCountryState();
}

class _SelectCountryState extends State<SelectCountry> {
  List<AreaGroup> _areaList = [];

  @override
  void initState() {
    super.initState();
    _getAreaList();
  }

  Future<void> _getAreaList() async {
    final areaList = await getCountryList(); 
    setState(() {
      final AreaGroup headerGroup = AreaGroup(group: '#', items: []);
      _areaList = areaList..insert(0, headerGroup);
    });
  }

  
  
  void _onSelect(AreaItem item){
    if(item.hasSub) {
      // 进入选择省份页继续选择
      SelectProvinceRoute(countryCode: item.code).push(context);
    } else {
      // 直接进入城市页进行最后的选择
      SelectCityRoute(countryCode: item.code,provinceCode: '-1').push(context);
    }
  }
  @override
  Widget build(BuildContext context) {
    return CustomAzlistview(areaList: _areaList, onSelect: _onSelect,isCountry: true);
  }
}
