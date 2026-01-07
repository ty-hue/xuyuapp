import 'package:azlistview/azlistview.dart';
import 'package:bilbili_project/viewmodels/EditProfile/index.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CustomAzlistview extends StatefulWidget {
  final List<AreaGroup> areaList;
  final Function(AreaItem) onSelect;
  CustomAzlistview({required this.areaList, required this.onSelect, Key? key}) : super(key: key);

  @override
  State<CustomAzlistview> createState() => _CustomAzlistviewState();
}

class _CustomAzlistviewState extends State<CustomAzlistview> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(leading: IconButton(icon: Icon(Icons.arrow_back_ios_new, color: Colors.white,size: 18,),onPressed: (){
        context.pop();
      },),title: Text('选择地区',style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white,),),centerTitle: true,backgroundColor: Color.fromRGBO(22, 22, 22, 1),scrolledUnderElevation: 0,
),
      body: Container(
            color: Color.fromRGBO(22, 22, 22, 1),
            child: AzListView(
              hapticFeedback:true,
              susItemHeight: 40,
              padding: EdgeInsets.zero,
              data: widget.areaList, // 每个 item 需要实现 ISuspensionBean
              susItemBuilder: (context, index) {
              
                final item = widget.areaList[index];
                return Container(
                  color: Color.fromRGBO(22, 22, 22, 1),
                  width: MediaQuery.of(context).size.width,
                  alignment: Alignment.centerLeft,
                  padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  child: Text(item.group, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white,),),
                );
              },
              itemCount: widget.areaList.length,
              itemBuilder: (context, index) {
                final item = widget.areaList[index].items;
                return Container(
                  padding: EdgeInsets.only(bottom: 30),
              
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: List.generate(item.length, (index) {
                      return Container(
                        padding: index == item.length - 1
                            ? EdgeInsets.only(bottom: 20)
                            : EdgeInsets.only(bottom: 0),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: index != item.length - 1
                                ? BorderSide.none
                                : BorderSide(
                                    color: Colors.white.withOpacity(0.1),
                                    width: 0.5,
                                  ),
                          ),
                        ),
                        child: ListTile(title: Text(item[index].name, style: TextStyle(fontSize: 14, color: Colors.white,),),onTap: (){
                          widget.onSelect(item[index]);
                        },),
                      );
                    }),
                  ),
                );
              },
              indexBarData: widget.areaList.map((e) => e.group).toList(), // A-Z 索引
              indexBarOptions: IndexBarOptions(
                needRebuild: true,
                selectTextStyle: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
                selectItemDecoration: BoxDecoration(
                  shape: BoxShape.circle,
                ),
              ),
            ),
          )
    );
  }
}