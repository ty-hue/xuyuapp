import 'package:bilbili_project/pages/Mine/sub/EditProfile/sub/UpdateUserInfoField/params/params.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class UpdateUserInfoFieldPage extends StatefulWidget {
  final UpdateUserInfoFieldParams extra;
  
  UpdateUserInfoFieldPage({Key? key, required this.extra})
    : super(key: key);

  @override
  State<UpdateUserInfoFieldPage> createState() => _UpdateUserInfoFieldState();
}

class _UpdateUserInfoFieldState extends State<UpdateUserInfoFieldPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(22, 22, 22, 1),
        leading: TextButton(
          onPressed: () {
            context.pop();
          },
          child: Text(
            '取消',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16.sp,
            ),
          ),
        ),
        title: Text(
          '修改${widget.extra.title}',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: () {
              print('保存');
            },
            child: Text(
              '保存',
              style: TextStyle(
                color: const Color.fromARGB(255, 212, 38, 47),
                fontSize: 16.sp,
              ),
            ),
          ),
        ],
      ),

      body: CustomScrollView(
        slivers: [
          SliverFillRemaining(
            child: Container(
              decoration: BoxDecoration(
                color: Color.fromRGBO(22, 22, 22, 1),
                border: Border(
                  top: BorderSide(color: Colors.grey[800]!, width: 1.0.w),
                ),
              ),
              padding: EdgeInsets.all(16.0.r),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
            
                  Form(
                    child: TextFormField(
                      maxLines: widget.extra.title == '简介' ? 5 : 1,
                      initialValue: widget.extra.initialValue,
                      maxLength: widget.extra.maxLength,
                      autofocus: true,
                      style: TextStyle(
                        fontSize: 14.0.sp, // 设置输入文字的大小
                        color: Colors.white, // 设置输入文字的颜色
                      ),
                      decoration: InputDecoration(
                        counterText: '0/${widget.extra.maxLength}',
                        label: Text(
                          widget.extra.title == '简介' ? '' : '你的${widget.extra.title}',
                          style: TextStyle(
                            fontSize: 14.0.sp, // 设置标签文字的大小
                            color: Colors.white, // 设置标签文字的颜色
                          ),
                        ),
                        helperText: widget.extra.tip,
                        // 2. 设置提示文字的样式
                        hintStyle: TextStyle(
                          fontSize: 12.0.sp, // 设置提示文字的大小
                          color: Colors.grey[500], // 设置提示文字的颜色
                        ),
                        contentPadding: EdgeInsets.only(left: 0), // 内容内边距
                        hintText: "填写${widget.extra.title}",
                        fillColor: Colors.transparent,
                        filled: true,
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.grey[800]!,
                            width: 1.0.w,
                          ),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.grey[800]!,
                            width: 1.0.w,
                          ),
                        ),
                      
                      ),
                    ),
                  ),
          
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
