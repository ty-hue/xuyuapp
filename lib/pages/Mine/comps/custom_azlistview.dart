import 'package:azlistview/azlistview.dart';
import 'package:bilbili_project/routes/app_router.dart';
import 'package:bilbili_project/viewmodels/EditProfile/index.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CustomAzlistview extends StatefulWidget {
  final List<AreaGroup> areaList;
  final Function(AreaItem) onSelect;
  final bool? isCountry;
  CustomAzlistview({required this.areaList, required this.onSelect,this.isCountry,Key? key})
    : super(key: key);

  @override
  State<CustomAzlistview> createState() => _CustomAzlistviewState();
}

class _CustomAzlistviewState extends State<CustomAzlistview> {
    Widget _buildHeaderItem(){
    return Container(
                width: MediaQuery.of(context).size.width,
                padding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                  GestureDetector(
                    onTap: (){
                      EditProfileRoute(dontSettingAddress: true).push(context);
                    },
                    child:  Container(
                      padding: EdgeInsets.symmetric(
                        vertical: 20,
                        horizontal: 8,
                      ),
                      // 添加底部边框
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: Colors.white.withOpacity(0.1),
                            width: 0.5,
                          ),
                        ),
                      ),
                      child: Text(
                        '暂不设置',
                        style: TextStyle(fontSize: 14, color: Colors.white),
                      ),
                    ),
                  ),
                    Container(
                      padding: EdgeInsets.symmetric(
                        vertical: 20,
                        horizontal: 8,
                      ),
                      // 添加底部边框
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: Colors.white.withOpacity(0.1),
                            width: 0.5,
                          ),
                        ),
                      ),
                      child: Column(
                        spacing: 24,
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            spacing: 4,
                            children: [
                              Icon(
                                Icons.location_on,
                                color: Colors.grey,
                                size: 12,
                              ),
                              Text(
                                '当前位置',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            '湖南·长沙',
                            style: TextStyle(fontSize: 14, color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                        vertical: 20,
                        horizontal: 8,
                      ),
                      // 添加底部边框
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: Colors.white.withOpacity(0.1),
                            width: 0.5,
                          ),
                        ),
                      ),
                      child: Column(
                        spacing: 24,
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            children: [
                              Text(
                                '其他地区',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 4),
                          GestureDetector(
                            onTap: (){
                              widget.onSelect(AreaItem(code: '1', name: '中国', hasSub: true,groupCn: 'Z'));
                            },
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 4),
                              child: Text(
                                '中国',
                                style: TextStyle(fontSize: 14, color: Colors.white),
                              ),
                            ),
                          ),
                          SizedBox(height: 4),
                      
                        ],
                      ),
                    ),
                  ],
                ),
              );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 18),
          onPressed: () {
            context.pop();
          },
        ),
        title: Text(
          '选择地区',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: Color.fromRGBO(22, 22, 22, 1),
        scrolledUnderElevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          color: Color.fromRGBO(22, 22, 22, 1),
          border: Border(
            top: BorderSide(color: Colors.white.withOpacity(0.1), width: 0.5),
          ),
        ),
        child: AzListView(
          hapticFeedback: true,
          susItemHeight: 40,
          padding: EdgeInsets.zero,
          data: widget.areaList, // 每个 item 需要实现 ISuspensionBean
          susItemBuilder: (context, index) {
            if (index == 0 && widget.isCountry == true) {
              return Container();
            }
            final item = widget.areaList[index];
            return Container(
              color: Color.fromRGBO(22, 22, 22, 1),
              width: MediaQuery.of(context).size.width,
              alignment: Alignment.centerLeft,
              padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              child: Text(
                item.group,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            );
          },
          itemCount: widget.areaList.length,
          itemBuilder: (context, index) {
            if (index == 0 && widget.isCountry == true) {
              return _buildHeaderItem();
            }
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
                    child: ListTile(
                      title: Text(
                        item[index].name,
                        style: TextStyle(fontSize: 14, color: Colors.white),
                      ),
                      onTap: () {
                        widget.onSelect(item[index]);
                      },
                    ),
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
            selectItemDecoration: BoxDecoration(shape: BoxShape.circle),
          ),
        ),
      ),
    );
  }
}
