import 'package:bilbili_project/components/static_app_bar.dart';
import 'package:bilbili_project/components/with_statusBar_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class PermissionDescriptionPage extends StatefulWidget {
  PermissionDescriptionPage({Key? key}) : super(key: key);

  @override
  _PermissionDescriptionPageState createState() => _PermissionDescriptionPageState();
}

class _PermissionDescriptionPageState extends State<PermissionDescriptionPage> {
  final String permissionDescription =
      '''
1.为保障絮语能实现与安全稳定运行之目的，我们可能会申请或使用操作系统的相关权限；

2.为保障你的知情权，我们通过下列列表将产品可能申请、使用的相关操作系统权限进行展示，你可以根据实际需要对相关权限进行管理；

3.根据产品的升级，申请、使用权限的类型与目的可能会有变动，我们将及时根据这些变动对列表进行调整，以确保你及时获悉权限的申请与使用情况；

4.请你知悉，我们为业务与产品的功能与安全需要，我们可能也会使用第三方SDK，这些第三方也可能会申请或使用相关操作系统权限；

5.在使用产品的过程中，你可能会使用第三方开发的H5页面或小程序，这些第三方开发开发的插件或小程序也可能因业务功能所必需而申请或使用相关操作系统权限;

6.本说明适用于絮语、絮语极速版、絮语火山版，具体的适用范围将在以下列表中说明。

安卓操作系统应用权限列表

1.读取外置存储器 android.permission.READ_EXTERNAL_STORAGE

权限功能说明：提供读取手机储存空间内数据的功能

使用场景与目的：允许App或小程序读取存储中的图片、文件等内容，主要用于帮助你发布信息，上传头像等图片、文件、在本地记录崩溃日志信息等功能

备注：共同适用絮语、絮语极速版、絮语火山版

2.读取图片 android.permission.READ_MEDIA_IMAGES

权限功能说明：允许App从外部存储读取图片数据

使用场景与目的：允许App或小程序读取存储中的图片文件，主要用于帮助你发布信息，上传头像等需要读取图片的功能

备注：共同适用絮语、絮语极速版、絮语火山版

3.读取视频 android.permission.READ_MEDIA_VIDEO

权限功能说明：允许App从外部存储读取视频数据

使用场景与目的：允许App或小程序读取存储中的视频文件，主要用于帮助你发布信息等需要读取视频的功能

备注：共同适用絮语、絮语极速版、絮语火山版

4.读取音频 android.permission.READ_MEDIA_AUDIO

权限功能说明：允许App从外部存储读取音频数据

使用场景与目的：允许App或小程序读取存储中的音频文件，主要用于帮助你添加本地音频、在发布内容时添加本地配乐等需要读取音频的功能

备注：共同适用絮语、絮语极速版、絮语火山版

5.读取用户选取的媒体文件 android.permission.READ_MEDIA_VISUAL_USER_SELECTED

权限功能说明：允许App从外部存储读取用户选取的媒体文件

使用场景与目的：用于在添加、上传图片等场景中读取和访问您选中的图片/照片

备注：共同适用絮语、絮语极速版、絮语火山版

6.写入外置存储器 android.permission.WRITE_EXTERNAL_STORAGE

权限功能说明：提供写入外部储存功能

使用场景与目的：允许App或小程序写入/下载/保存/缓存/修改/删除图片、文件等信息

备注：共同适用絮语、絮语极速版、絮语火山版

7.访问大致地理位置信息 android.permission.ACCESS_COARSE_LOCATION

权限功能说明：通过网络位置信息（例如基站和WLAN）获取大致地理位置信息

使用场景与目的：用于完成安全保障服务及基于地理位置的服务（LBS）如：同城信息、发布作品坐标定位以及小程序需使用相关位置服务等相关功能

备注：共同适用絮语、絮语极速版、絮语火山版

8.访问精确地理位置信息 android.permission.ACCESS_FINE_LOCATION

权限功能说明：通过全球定位系统（GPS）和网络位置信息（例如基站和WLAN）获取精准地理位置信息

使用场景与目的：用于完成安全保障服务及基于地理位置的服务（LBS）如：同城信息、发布作品坐标定位以及小程序需使用相关位置服务等相关功能

备注：共同适用絮语、絮语极速版、絮语火山版

9.录音 android.permission.RECORD_AUDIO

权限功能说明：使用麦克风录制音频

使用场景与目的：用于帮助你完成音视频信息发布、进行直播、语音输入、完成搜索（如有）等需要使用该权限的相关功能

备注：共同适用絮语、絮语极速版、絮语火山版

10.拍摄照片和视频 android.permission.CAMERA

权限功能说明：使用拍摄照片和视频、完成扫描二维码

使用场景与目的：用于帮助你拍摄发布音视频、进行直播、完成扫描二维码、识别图片和搜索、更换头像和完成实名认证等需要使用该权限的相关功能

备注：共同适用絮语、絮语极速版、絮语火山版

11.写入日历 android.permission.WRITE_CALENDAR

权限功能说明：添加或修改系统中的日历活动

使用场景与目的：用于帮助你在系统日历中添加或修改活动、直播等预约提醒

备注：共同适用絮语、絮语极速版、絮语火山版

12.读取通讯录 android.permission.READ_CONTACTS

权限功能说明：获取系统中的通讯录信息

使用场景与目的： 用于帮助你实现推荐好友等功能

备注：共同适用絮语、絮语极速版、絮语火山版

13.身体活动识别 ACTIVITY_RECOGNITION

权限功能说明：访问运动与身体数据

使用场景与目的： 用于访问你的行走数据，帮忙你正常使用走路赚金币功能

备注：适用絮语极速版

14.读取媒体文件位置信息 ACCESS_MEDIA_LOCATION

权限功能说明：从照片中读取位置信息

使用场景和目的：用于帮助你完成足迹打卡、模版/话题/标签的智能推荐、公益项目等场景中的相关功能

备注：共同适用絮语、絮语极速版、絮语火山版

15.NFC识别 android.permission.NFC

权限功能说明：访问NFC硬件

使用场景和目的：帮助你通过NFC功能识别证件信息进行实名认证

备注：共同适用絮语、絮语极速版、絮语火山版

16.访问所有应用软件列表 android.permission.QUERY_ALL_PACKAGES

权限功能说明：读取您的应用软件列表

使用场景与目的：用于预防恶意程序、维护服务正常运行、保障您的帐号安全，并为您提供推荐等更优质的服务体验

备注：共同适用絮语、絮语极速版、絮语火山版

17.蓝牙扫描 android.permission.BLUETOOTH_SCAN

权限功能说明：查找蓝牙设备

使用场景与目的：用于观看视频/直播时扫描蓝牙设备

备注：共同适用絮语、絮语极速版、絮语火山版

18.蓝牙通信 android.permission.BLUETOOTH_CONNECT

权限功能说明：与已配对的蓝牙设备通信

使用场景与目的：用于观看视频/直播时连接蓝牙设备

备注：共同适用絮语、絮语极速版、絮语火山版

19. 使用设备指纹识别功能 android.permission.USE_FINGERPRINT

权限功能说明：使用设备的指纹识别功能，用于快速验证身份

使用场景与目的：支付等场景使用设备指纹验证功能实现快速支付。本功能不会获取您任何指纹信息，仅能获取您的验证是否通过的结果。

备注：共同适用絮语、絮语极速版、絮语火山版

20. 使用设备的生物识别功能 android.permission.USE_BIOMETRIC

权限功能说明：使用设备的生物识别功能，用于快速验证身份

使用场景和目的：支付等场景使用设备生物验证功能实现快速支付，本功能不会获取您任何生物识别信息，仅能获取您的验证是否通过的结果。

备注：共同适用絮语、絮语极速版、絮语火山版

iOS操作系统应用权限列表

1.NSPhotoLibraryAddUsageDescription

权限功能说明：向相册中添加内容

使用场景和目的：允许App写入/下载/保存/修改/删除图片、视频、文件、崩溃日志等信息

备注：共同适用絮语、絮语极速版、絮语火山版

2.NSPhotoLibraryUsageDescription

权限功能说明：读取相册中内容

使用场景和目的：允许App读取存储中的图片、文件等内容，主要用于帮助你发布信息、用户资料设置、识别图片和搜索等功能

备注：共同适用絮语、絮语极速版、絮语火山版

3.NSCameraUsageDescription

权限功能说明：使用摄像头

使用场景和目的：用于帮助你完成音视频信息发布、完成扫描二维码、用户资料设置、识别图片和搜索等需要使用该权限的相关功能

备注：共同适用絮语、絮语极速版、絮语火山版

4.NSLocationWhenInUseUsageDescription

权限功能说明：仅App被使用时获取地理位置

使用场景和目的：用于完成安全保障、推荐信息以及基于地理位置的服务（LBS）等相关功能

备注：共同适用絮语、絮语极速版、絮语火山版

5.NSContactsUsageDescription

权限功能说明：读取用户通讯录

使用场景和目的：用于好友推荐、拨打紧急联系人电话等功能

备注：共同适用絮语、絮语极速版、絮语火山版

6.NSAppleMusicUsageDescription

权限功能说明：访问媒体资料库

使用场景和目的：用于选取手机内的本地音乐

备注：共同适用絮语、絮语极速版、絮语火山版

7.NSMicrophoneUsageDescription

权限功能说明：使用麦克风

使用场景和目的：用于帮助你完成音视频信息发布、开直播、语音输入、完成搜索（语音转语义）等需要使用该权限的相关功能

备注：共同适用絮语、絮语极速版、絮语火山版

8.NSCalendarsUsageDescription

权限功能说明：访问系统中的日历活动

使用场景和目的：用于帮助你设置、完成或修改直播或活动等预约提醒功能

备注：共同适用絮语、絮语极速版、絮语火山版

9.NSFaceIDUsageDescription

权限功能说明：使用面容ID

使用场景和目的：用于你的支付功能

备注：共同适用絮语、絮语极速版、絮语火山版

10.NSUserTrackingUsageDescription

权限功能说明：获取设备标识，以识别设备信息

使用场景和目的：仅用于标识设备并保障服务安全与提升浏览体验

备注：共同适用絮语、絮语极速版、絮语火山版

11.NSLocalNetworkUsageDescription

权限功能说明：获取您的本地网络权限

使用场景和目的：为了保障并优化视频播放；查找并连接到本地网络上的设备，以使用投屏功能

备注：共同适用絮语、絮语极速版、絮语火山版

12.NSLocationTemporaryUsageDescriptionDictionary

权限功能说明：允许临时访问精确地理位置信息

使用场景和目的：用于完成安全保障、推荐信息、用户资料设置、以及基于地理位置服务（LBS）等相关功能

备注：共同适用絮语、絮语火山版

13.NSMotionUsageDescription

权限功能说明：访问运动与健身数据

使用场景和目的：用于访问你的行走数据，帮助你正常使用走路赚金币功能

备注：共同适用絮语、絮语极速版、絮语火山版

14.NSBluetoothPeripheralUsageDescription

权限功能说明：用于连接其他蓝牙设备

使用场景和目的：用于发现和连接到附近的蓝牙设备进行投屏等

备注：共同适用于絮语、絮语极速版、絮语火山版

15.NSBluetoothAlwaysUsageDescription

权限功能说明：持续使用蓝牙

使用场景和目的：用于发现和连接到附近的蓝牙设备进行投屏等

备注：共同适用于絮语、絮语极速版、絮语火山版

16.NFCReaderUsageDescription

权限功能说明：访问NFC硬件

使用场景和目的：帮助你通过NFC功能识别证件信息进行实名认证

备注：共同适用絮语、絮语极速版、絮语火山版

17.NSCalendarsFullAccessUsageDescription

权限功能说明：读写日历

使用场景和目的：用于帮助你创建提醒、修改活动、创建和修改直播预约等相关功能功能

备注：共同适用絮语、絮语极速版、絮语火山版

18.NSCalendarsWriteOnlyAccessUsageDescription

权限功能说明：写入日历

使用场景和目的：用于帮助你创建提醒、修改活动、创建和修改直播预约等相关功能功能

备注：共同适用絮语、絮语极速版、絮语火山版
 ''';
  @override
  Widget build(BuildContext context) {
    return WithStatusbarColorView(
      statusBarColor: Color.fromRGBO(29, 31, 43, 1),
      child: Scaffold(
        appBar: StaticAppBar(
          statusBarHeight: MediaQuery.of(context).padding.top,
          backgroundColor: Color.fromRGBO(29, 31, 43, 1),
          title: '絮语权限申请与使用情况说明',
        ),
        body: Container(
          color: Color.fromRGBO(29, 31, 43, 1),
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
          child: SingleChildScrollView(
            child: Text(
              permissionDescription,
              style: TextStyle(color: Colors.white, fontSize: 14.sp),
            ),
          ),
        ),
      ),
    );
  }
}
