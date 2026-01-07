import 'package:bilbili_project/api/EditProfile/index.dart';
import 'package:bilbili_project/pages/Mine/comps/custom_azlistview.dart';
import 'package:bilbili_project/routes/app_router.dart';
import 'package:bilbili_project/viewmodels/EditProfile/index.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SelectCity extends StatefulWidget {
  final String countryCode;
  final String provinceCode;
  SelectCity({Key? key, required this.countryCode, required this.provinceCode})
    : super(key: key);

  @override
  State<SelectCity> createState() => _SelectCityState();
}

class _SelectCityState extends State<SelectCity> {
  List<AreaGroup> _areaList = [];

  @override
  void initState() {
    super.initState();
    _getAreaList();
  }

  Future<void> _getAreaList() async {
    Map<String, String> queryParameters = {'countryCode': widget.countryCode};
    if (widget.provinceCode != '-1') {
      queryParameters['provinceCode'] = widget.provinceCode;
    }
    final areaList = await getCityList(queryParameters);
    setState(() {
      _areaList = areaList;
    });
  }

  void _onSelect(AreaItem item) {
    // 直接进入城市页进行最后的选择
    context.replace(EditProfileRoute().location,extra: AddressResult(
      country: widget.countryCode,
      province: widget.provinceCode,
      city: item.code,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return CustomAzlistview(areaList: _areaList, onSelect: _onSelect);
  }
}
