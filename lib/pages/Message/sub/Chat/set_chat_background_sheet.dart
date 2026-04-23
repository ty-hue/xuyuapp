import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';

/// 打开「自定义背景」底部面板（圆角顶栏 + 从相册选择 + 精选背景九宫格）。
Future<void> showSetChatBackgroundSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    barrierColor: Colors.black.withValues(alpha: 0.45),
    backgroundColor: Colors.transparent,
    builder: (ctx) => const _SetChatBackgroundSheet(),
  );
}

class _SetChatBackgroundSheet extends StatefulWidget {
  const _SetChatBackgroundSheet();

  @override
  State<_SetChatBackgroundSheet> createState() => _SetChatBackgroundSheetState();
}

class _SetChatBackgroundSheetState extends State<_SetChatBackgroundSheet> {
  static final List<String?> _presetUrls = [
    null,
    ...List.generate(8, (i) => 'https://picsum.photos/seed/chatbg${i + 1}/400/720'),
  ];

  static const Color _albumRowBg = Color(0xFFF2F2F7);
  static const Color _closeCircle = Color(0xFFF2F2F7);

  int _selectedIndex = 0;

  Future<void> _pickFromAlbum() async {
    final picker = ImagePicker();
    final x = await picker.pickImage(source: ImageSource.gallery);
    if (!mounted) return;
    if (x != null) {
      ScaffoldMessenger.maybeOf(context)?.showSnackBar(
        SnackBar(content: Text('已选择相册图片（演示）：${x.name}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    final sheetH = MediaQuery.sizeOf(context).height * 0.92;

    return ClipRRect(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
      child: Container(
        height: sheetH,
        color: Colors.white,
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeader(context),
              Padding(
                padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 12.h),
                child: Material(
                  color: _albumRowBg,
                  borderRadius: BorderRadius.circular(12.r),
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: _pickFromAlbum,
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                      child: Row(
                        children: [
                          Text(
                            '从相册选择',
                            style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w500, color: Colors.black87),
                          ),
                          const Spacer(),
                          Icon(Icons.photo_outlined, size: 22.r, color: Colors.black54),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 10.h),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '精选背景',
                    style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w600, color: Colors.black87),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, bottomInset + 12.h),
                  child: GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      mainAxisSpacing: 10.w,
                      crossAxisSpacing: 10.w,
                      childAspectRatio: 0.68,
                    ),
                    itemCount: _presetUrls.length,
                    itemBuilder: (context, index) => _PresetTile(
                      imageUrl: _presetUrls[index],
                      selected: _selectedIndex == index,
                      onTap: () => setState(() => _selectedIndex = index),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return SizedBox(
      height: 52.h,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Text(
            '自定义背景',
            style: TextStyle(fontSize: 17.sp, fontWeight: FontWeight.w600, color: Colors.black87),
          ),
          Positioned(
            right: 12.w,
            top: 0,
            bottom: 0,
            child: Center(
              child: Material(
                color: _closeCircle,
                shape: const CircleBorder(),
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: () => Navigator.of(context).maybePop(),
                  child: SizedBox(
                    width: 30.r,
                    height: 30.r,
                    child: Icon(Icons.close_rounded, size: 18.r, color: Colors.black54),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PresetTile extends StatelessWidget {
  const _PresetTile({
    required this.imageUrl,
    required this.selected,
    required this.onTap,
  });

  final String? imageUrl;
  final bool selected;
  final VoidCallback onTap;

  static const Color _accentCheck = Color(0xFFFF2C55);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10.r),
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (imageUrl == null)
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10.r),
                  border: Border.all(color: const Color(0xFFE8E8ED)),
                ),
              )
            else
              SizedBox.expand(
                child: ExtendedImage.network(
                  imageUrl!,
                  fit: BoxFit.cover,
                loadStateChanged: (state) {
                  if (state.extendedImageLoadState == LoadState.failed) {
                    return ColoredBox(
                      color: const Color(0xFFE5E5EA),
                      child: Icon(Icons.image_not_supported_outlined, color: Colors.white54, size: 28.r),
                    );
                  }
                  return null;
                },
              ),
              ),
            if (selected)
              Positioned(
                left: 0,
                right: 0,
                bottom: 8.h,
                child: Center(
                  child: Icon(Icons.check_circle_rounded, size: 24.r, color: _accentCheck),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
