import 'package:bilbili_project/api/EditProfile/index.dart';
import 'package:bilbili_project/components/custom_azlistview.dart';
import 'package:bilbili_project/viewmodels/EditProfile/index.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ChoosePhonePrefixPage extends StatefulWidget {
  ChoosePhonePrefixPage({Key? key}) : super(key: key);

  @override
  State<ChoosePhonePrefixPage> createState() => _ChoosePhonePrefixPageState();
}

class _ChoosePhonePrefixPageState extends State<ChoosePhonePrefixPage> {
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
    context.pop(item);
  }
  @override
  Widget build(BuildContext context) {
    return CustomAzlistview(areaList: _areaList, onSelect: _onSelect,isCountry: true,isSelectPhoneMode: true);
  }
}