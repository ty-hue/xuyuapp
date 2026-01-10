import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class SettingsPage extends StatefulWidget {
  SettingsPage({Key? key}) : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsState();
}

class _SettingsState extends State<SettingsPage> {
  Widget _buildGroupName(String groupName) {
    return Container(
      padding: EdgeInsets.only(left: 16.w),
      child: Text(
        groupName,
        style: TextStyle(
          color: Colors.grey,
          fontSize: 14.sp,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

 Widget _buildGroupItem({
  required String itemName,
  required IconData icon,
  bool needUnderline = true,
  bool needTrailingIcon = true,
  required Function()? cb,
}) {
  return Material(
    color: const Color.fromRGBO(35, 35, 35, 1), // 默认背景
    child: InkWell(
      onTap: cb,
      splashColor: Colors.white.withOpacity(0.08), // 水波纹
      highlightColor: Colors.white.withOpacity(0.05), // 按下态 ⭐
      child: SizedBox(
        height: 54.h,
        child: Padding(
          padding:  EdgeInsets.only(left: 16.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Icon(icon, color: Colors.grey, size: 20.r),
               SizedBox(width: 10.w),
              Expanded(
                child: Container(
                  padding:  EdgeInsets.only(right: 16.w),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: needUnderline
                          ?  BorderSide(color: Colors.grey, width: 0.5.w)
                          : BorderSide.none,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        itemName,
                        style:  TextStyle(
                          color: Colors.white,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      needTrailingIcon
                          ?  Icon(
                              Icons.arrow_forward_ios,
                              color: Colors.grey,
                              size: 14.r,
                            )
                          : const SizedBox.shrink(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new,color: Colors.white,size: 20.r,),
          onPressed: () {
            context.pop();
          },
        ),
        backgroundColor: Color.fromRGBO(11, 11, 11, 1),
        title: Text('设置',style: TextStyle(color: Colors.white,fontSize: 16.sp,fontWeight: FontWeight.bold),),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.only(left: 16.w, right: 16.w,top: 16.h,bottom: 60.h),
          color: Color.fromRGBO(11, 11, 11, 1),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildGroupName('账号'),
              SizedBox(height: 10.h),
              ClipRRect(
                borderRadius: BorderRadius.circular(8.r),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Column(
                    children: [
                      _buildGroupItem(itemName: '账号与安全', icon: Icons.person,cb: (){
                      }),
                      _buildGroupItem(itemName: '隐私设置', icon: Icons.lock,cb: (){
                      }),
                      _buildGroupItem(
                        itemName: '支付设置',
                        icon: Icons.payment,
                        needUnderline: false,
                        cb: (){
                        },
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20.h),
              _buildGroupName('通用'),
              SizedBox(height: 10.h),
              ClipRRect(
                borderRadius: BorderRadius.circular(8.r),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Column(
                    children: [
                      _buildGroupItem(itemName: '通用设置', icon: Icons.settings,cb: (){
                      }),
                      _buildGroupItem(
                        itemName: '通知设置',
                        icon: Icons.notifications,
                        cb: (){
                        },
                      ),
                      _buildGroupItem(
                        itemName: '通知消息管理',
                        icon: Icons.notifications_active,
                        cb: (){
                        },
                      ),
                      _buildGroupItem(itemName: '聊天与通话设置', icon: Icons.phone,cb: (){
                      }),
                      _buildGroupItem(itemName: '播放设置', icon: Icons.play_arrow,cb: (){
                      }),
                      _buildGroupItem(itemName: '背景设置', icon: Icons.wallpaper,cb: (){
                      }),
                      _buildGroupItem(itemName: '长辈模式', icon: Icons.people_alt,cb: (){
                      }),
                      _buildGroupItem(
                        itemName: '字体大小',
                        icon: Icons.text_fields,
                        cb: (){
                        },
                      ),
                      _buildGroupItem(
                        itemName: '清理缓存',
                        icon: Icons.cleaning_services,
                        cb: (){
                        },
                      ),
                      _buildGroupItem(
                        itemName: '系统权限',
                        icon: Icons.system_update_alt,
                        needUnderline: false,
                        cb: (){
                        },
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20.h),
              _buildGroupName('关于'),
              SizedBox(height: 10.h),
              ClipRRect(
                borderRadius: BorderRadius.circular(8.r),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Column(
                    children: [
                      _buildGroupItem(itemName: '关于絮语', icon: Icons.info,cb: (){
                      }),
                      _buildGroupItem(
                        itemName: '了解与管理广告推送',
                        icon: Icons.ad_units_sharp,
                        cb: (){
                        },
                      ),
                      _buildGroupItem(itemName: '反馈与帮助', icon: Icons.help,cb: (){
                      }),
                      _buildGroupItem(itemName: '絮语规则中心', icon: Icons.rule,cb: (){
                      }),
                      _buildGroupItem(
                        itemName: '资质证照',
                        icon: Icons.verified_user,
                        cb: (){
                        },
                      ),
                      _buildGroupItem(
                        itemName: '用户协议',
                        icon: Icons.description,
                        cb: (){
                        },
                      ),
                      _buildGroupItem(
                        itemName: '隐私政策及简明版',
                        icon: Icons.privacy_tip,
                        cb: (){
                        },
                      ),
                      _buildGroupItem(
                        itemName: '应用权限',
                        icon: Icons.perm_identity,
                        cb: (){
                        },
                      ),
                      _buildGroupItem(itemName: '个人信息收集清单', icon: Icons.info,cb: (){
                      }),
                      _buildGroupItem(itemName: '第三方信息共享清单', icon: Icons.info,cb: (){
                      }),

                      _buildGroupItem(itemName: '个人信息管理', icon: Icons.info,cb: (){
                      }),
                      _buildGroupItem(
                        itemName: '开源软件声明',
                        icon: Icons.code,
                        cb: (){
                        },
                        needUnderline: false,
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20.h),
              ClipRRect(
                borderRadius: BorderRadius.circular(8.r),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Column(
                    children: [
                      _buildGroupItem(
                        itemName: '切换账号',
                        icon: Icons.switch_account,
                        cb: (){
                        },
                      ),
                      _buildGroupItem(
                        itemName: '退出登录',
                        icon: Icons.exit_to_app,
                        needUnderline: false,
                        needTrailingIcon: false,
                        cb: (){
                        },
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 60.h),
              Text('絮语 version 1.0.0',style: TextStyle(color: Colors.grey,fontSize: 14.sp,fontWeight: FontWeight.bold),textAlign: TextAlign.center,),
            ],
          ),
        ),
      ),
    );
  }
}
