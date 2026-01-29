import 'package:bilbili_project/components/static_app_bar.dart';
import 'package:bilbili_project/components/with_statusBar_color.dart';
import 'package:bilbili_project/routes/app_router.dart';
import 'package:bilbili_project/routes/settings_routes/delete_account_second_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class DeleteAccountPage extends StatefulWidget {
  DeleteAccountPage({Key? key}) : super(key: key);

  @override
  State<DeleteAccountPage> createState() => _DeleteAccountState();
}

class _DeleteAccountState extends State<DeleteAccountPage> {
  bool isRead = false;
  @override
  Widget build(BuildContext context) {
    return WithStatusbarColorView(
      statusBarColor: Colors.white,
      child: Scaffold(
        appBar: StaticAppBar(
          titleColor: Colors.white,
          title: '申请注销账号',
          titleFontWeight: FontWeight.bold,
          backgroundColor: Color.fromRGBO(22, 24, 36, 1),
          statusBarHeight: MediaQuery.of(context).padding.top,
        ),
        body: Container(
          padding: EdgeInsets.only(top: 24.h, bottom: 12.h),
          height: MediaQuery.of(context).size.height,
          color: Color.fromRGBO(22, 24, 36, 1),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    spacing: 12.h,
                    children: [
                      // 圆型头像
                      GestureDetector(
                        onTap: () {
                          // 跳转修改头像页
                        },
                        child: ClipOval(
                          child: Image.network(
                            'https://q1.itc.cn/q_70/images03/20250701/afddfb3d5fcf459594cfa880445c9b2c.jpeg',
                            width: 60.w,
                            height: 60.h,
                          ),
                        ),
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        spacing: 4.w,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'llg',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 20.h),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20.w),
                        child: Container(
                          padding: EdgeInsets.all(20.w),
                          decoration: BoxDecoration(
                            color: Color.fromRGBO(35, 37, 48, 1),
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            mainAxisSize: MainAxisSize.min,
                            spacing: 8.h,
                            children: [
                              Text(
                                '为保证账号安全，你提交的注销申请生效前需满足以下条件：',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.left,
                              ),
                              SizedBox(height: 6.h),
                              Text(
                                '1.通过账号安全验证',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.left,
                              ),
                              SizedBox(height: 6.h),

                              Text(
                                '2.账号财产已结清，交易已完成',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.left,
                              ),

                              Text(
                                '账号下所有关联业务的资产及预期收益（包括 DOU+、抖币、现金、金币、卡券等）和权益（包括会员身份）均已结清、退款、清空或自愿放弃，所有交易已完成或已自愿放弃，絮语支付账户已注销。',
                                style: TextStyle(
                                  color: Color.fromRGBO(144, 145, 150, 1),
                                  fontSize: 14.sp,
                                ),
                                textAlign: TextAlign.left,
                              ),
                              SizedBox(height: 6.h),

                              Text(
                                '3.账号的授权和绑定关系已解除',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.left,
                              ),
                              Text(
                                '账号已解除与其他账号（包括絮语企业号、员工号等）及第三方产品、平台的授权或绑定关系，通过本账号接入的絮语相关服务（包括絮语火山版、絮语极速版、絮语商城版、多闪、絮语旗下生活社区 - 可颂、絮语旗下中长视频版本 - 絮语精选（曾用名 “青桃视频”）、絮语音乐版 - 汽水音乐、简化版等关联版本）中没有未完成或存在争议的内容。',
                                style: TextStyle(
                                  color: Color.fromRGBO(144, 145, 150, 1),
                                  fontSize: 14.sp,
                                ),
                                textAlign: TextAlign.left,
                              ),
                              SizedBox(height: 6.h),
                              Text(
                                '4.允许管理并使用账号违规信息',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.left,
                              ),
                              Text(
                                '允许注销的违规账号注销后，我们可留存手机号、实名信息用于同一手机号、实名认证信息重新注册、实名认证账号的管理（包括但不限于限制频次等）。原账号下的违规行为及 / 或相应处置措施会延续至你注册的新账号，在新账号发生违法违规行为时，我们可按照法律法规、平台规则，对你的违规行为进行合并处理，对你或新账号采取限制全部或部分功能等处置措施。',
                                style: TextStyle(
                                  color: Color.fromRGBO(144, 145, 150, 1),
                                  fontSize: 14.sp,
                                ),
                                textAlign: TextAlign.left,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(20.w),
                child: Column(
                  spacing: 8.h,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Checkbox(
                          activeColor: Color.fromRGBO(249, 45, 87, 1),
                          shape: CircleBorder(),
                          value: isRead,
                          onChanged: (value) {
                            setState(() {
                              isRead = value!;
                            });
                          },
                        ),
                        Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: '已阅读并同意',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14.sp,
                                ),
                              ),
                              TextSpan(
                                text: '《絮语注销须知》',
                                style: TextStyle(
                                  color: Color.fromRGBO(124, 176, 227, 1),
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 56.h,
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          disabledBackgroundColor: Color.fromRGBO(
                            254,
                            43,
                            84,
                            1,
                          ).withOpacity(0.2),

                          backgroundColor: Color.fromRGBO(254, 43, 84, 1),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                        ),
                        onPressed: !isRead ? null : () {
                          DeleteAccountSecondRoute().push(context);
                        },
                        child: Text(
                          '申请注销',
                          style: TextStyle(
                            color: !isRead
                                ? Colors.white.withOpacity(0.8)
                                : Colors.white,
                            fontSize: 18.sp,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
