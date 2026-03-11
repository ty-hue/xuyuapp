import 'package:bilbili_project/components/my_asset_picker_text_delegate.dart';
import 'package:bilbili_project/pages/Create/comps/music_list_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';

class UploadMusicPane extends StatefulWidget {
  final Function toggleShowPane;
  UploadMusicPane({Key? key, required this.toggleShowPane}) : super(key: key);

  @override
  _UploadMusicPaneState createState() => _UploadMusicPaneState();
}

class _UploadMusicPaneState extends State<UploadMusicPane> {
  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 14.h,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 顶部导航
        SizedBox(
          height: 50.h,
          child: Stack(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: GestureDetector(
                  onTap: () => widget.toggleShowPane(),
                  child: Icon(
                    Icons.arrow_back_ios_new,
                    color: Color.fromRGBO(24, 26, 36, 1),
                    size: 24.sp,
                  ),
                ),
              ),
              Align(
                alignment: Alignment.center,
                child: Text(
                  '导入音频',
                  style: TextStyle(
                    color: Color.fromRGBO(24, 26, 36, 1),
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
        // 提取音频按钮
        SizedBox(
          height: 48.h,
          child: ElevatedButton(
            onPressed: () async {
              // 打开视频选择器
              final List<AssetEntity>? assets = await AssetPicker.pickAssets(
                context,
                pickerConfig: AssetPickerConfig(
                  requestType: RequestType.video,
                  maxAssets: 1,
                  textDelegate: MyAssetPickerTextDelegate(),
                ),
              );
              // 提取音频
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color.fromRGBO(243, 243, 244, 1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
            child: Row(
              spacing: 4.sp,
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.upload_file,
                  color: Color.from(
                    alpha: 1,
                    red: 0.094,
                    green: 0.102,
                    blue: 0.141,
                  ),
                  size: 24.sp,
                ),
                Text(
                  '提取视频中的音频',
                  style: TextStyle(
                    color: Color.fromRGBO(24, 26, 36, 1),
                    fontSize: 14.sp,
                    letterSpacing: 2.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
        // 音乐列表
        Expanded(
          child: ListView.builder(
            itemCount: 10,
            itemBuilder: (context, index) {
              return MusicListItem(isNeedStarIcon: false);
            },
          ),
        ),
      ],
    );
  }
}
