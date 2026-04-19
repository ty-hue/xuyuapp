import 'package:bilbili_project/components/dim_tap_Icon_button.dart';
import 'package:bilbili_project/components/static_app_bar.dart';
import 'package:bilbili_project/components/with_statusBar_color.dart';
import 'package:bilbili_project/pages/Home/comps/video_share_sheet_skeleton.dart';
import 'package:bilbili_project/utils/SheetUtils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';

class MusicDetailPage extends StatefulWidget {
  MusicDetailPage({Key? key}) : super(key: key);

  @override
  _MusicDetailPageState createState() => _MusicDetailPageState();
}

class _MusicDetailPageState extends State<MusicDetailPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _avatarRotationController;

  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _avatarRotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 18),
    )..stop();
  }

  @override
  void dispose() {
    _avatarRotationController.dispose();
    super.dispose();
  }

  // 播放 / 暂停方法
  void _playOrPause() {
    setState(() {
      _isPlaying = !_isPlaying;
      if (_isPlaying) {
        _avatarRotationController.repeat();
      } else {
        _avatarRotationController.stop();
      }
    });
  }

  // 收藏
  void _collect() {
    print('收藏');
  }

  // 分享
  void _share() {
    SheetUtils(
      VideoShareSheetSkeleton(),
    ).openAsyncSheet(context: context);
  }

  @override
  Widget build(BuildContext context) {
    return WithStatusbarColorView(
      statusBarColor: Colors.white,
      child: Scaffold(
        appBar: StaticAppBar(
          statusBarHeight: MediaQuery.of(context).padding.top,
          backgroundColor: Colors.white,
          leadingChild: DimTapIconButton(
            color: Colors.black,
            size: 24.0.sp,
            icon: FontAwesomeIcons.chevronLeft,
            onPressed: () {
              context.pop();
            },
          ),
          actions: [
            // 转发
            DimTapIconButton(
              color: Colors.black,
              size: 24.0.sp,
              icon: FontAwesomeIcons.share,
              onPressed: () {
                _share();
              },
            ),
          ],
        ),
        body: Container(
          color: Colors.white,
          child: Column(
            spacing: 10.h,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 220.0.r,
                    height: 220.0.r,
                    child: Image.asset(
                      'lib/assets/record_bg.jpg',
                      fit: BoxFit.fill,
                    ),
                  ),
                  RotationTransition(
                    turns: _avatarRotationController,
                    child: CircleAvatar(
                      radius: 56.0.r,
                      backgroundImage: NetworkImage(
                        'https://q1.itc.cn/q_70/images03/20250701/afddfb3d5fcf459594cfa880445c9b2c.jpeg',
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      _playOrPause();
                    },
                    child: Icon(
                      _isPlaying ? FontAwesomeIcons.pause : FontAwesomeIcons.play,
                      size: 40.0.r,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              Text(
                '@Tan-Hoo Hoo创作的原声',
                style: TextStyle(
                  fontSize: 20.sp,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              Text(
                'Tan-Hoo Hoo | 7人使用',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Color.fromRGBO(140, 140, 140, 1),
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
              Container(
                alignment: Alignment.center,
                height: 42.h,
                child: Row(
                  spacing: 20.w,
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color.fromRGBO(244, 244, 244, 1),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                      ),
                      onPressed: () {
                        _share();
                      },
                      label: Text(
                        '音乐分享',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Color.fromRGBO(32, 32, 33, 1),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      icon: Icon(
                        FontAwesomeIcons.share,
                        size: 14.0.r,
                        color: Color.fromRGBO(32, 32, 33, 1),
                      ),
                    ),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color.fromRGBO(244, 244, 244, 1),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                      ),
                      onPressed: () {
                        _collect();
                      },
                      label: Text(
                        '收藏',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Color.fromRGBO(32, 32, 33, 1),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      icon: Icon(
                        FontAwesomeIcons.star,
                        size: 14.0.r,
                        color: Color.fromRGBO(32, 32, 33, 1),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing: 1.w,
                    crossAxisSpacing: 1.w,
                    childAspectRatio: 0.8,
                  ),
                  itemBuilder: (context, index) {
                    return Container(color: Colors.red);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
