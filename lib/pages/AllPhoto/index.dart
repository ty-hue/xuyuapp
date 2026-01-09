import 'dart:typed_data';

import 'package:bilbili_project/viewmodels/AllPhoto/index.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:image_editor/image_editor.dart';
import 'package:photo_manager/photo_manager.dart';

class AllPhotoPage extends StatefulWidget {
  final EditorConfig editorConfig;
  const AllPhotoPage({Key? key, required this.editorConfig}) : super(key: key);
  @override
  State<AllPhotoPage> createState() => _AllPhotoPageState();
}

class _AllPhotoPageState extends State<AllPhotoPage> {
  @override
  void initState() {
    super.initState();
    _init();
  }

  List<AssetEntity> images = [];
  List<AssetPathEntity> albums = [];
  bool isExpanded = false; // 是否显示相册列表
  List<Album> albumsWithThumbnail = []; // 相册列表（单个相册数据进行了封装）
  String title = '';
  bool isShowClipSpace = false; // 是否显示裁剪空间
  Uint8List? selectedImage; // 当前需要裁剪的图片
  final GlobalKey<ExtendedImageEditorState> _editorKey =
      GlobalKey<ExtendedImageEditorState>();
  // 请求相册权限
  Future<bool> requestPermission() async {
    final result = await PhotoManager.requestPermissionExtend();
    if (!result.hasAccess) {
      PhotoManager.openSetting(); // 引导用户去设置
      return false;
    }
    return true;
  }

  // 获取所有相册
  Future<void> loadAlbums() async {
    final hasPermission = await requestPermission();
    if (!hasPermission) return;
    albums = await PhotoManager.getAssetPathList(type: RequestType.image);
    if (albums.isEmpty) return;
    if (!mounted) return;
    setState(() {
      albums.length > 0 ? title = albums[0].name : title = '所有照片';
      albums = albums;
    });
  }

  // 获取指定相册里面的所有图片
  Future<void> loadPhotos({int index = 0}) async {
    bool hasPermission = await requestPermission();
    if (!hasPermission) return;
    if (albums.isEmpty) return;
    // 获取主相册的所有图片，分页获取，最多1000张
    List<AssetEntity> photos = await albums[index].getAssetListPaged(
      page: 0,
      size: 1000,
    );
    if (!mounted) return;
    setState(() {
      images = photos;
    });
  }

  // 初始化方法
  Future<void> _init() async {
    // 1. 获取相册列表
    await loadAlbums();

    //2. 遍历相册列表，对单个相册的数据进行封装,得到新的相册列表
    List.generate(albums.length, (index) => _getAlbumThumbnail(albums[index]));

    // 3.获取第一个相册内的所有照片
    await loadPhotos();
  }

  /// 将单个相册数据添加到相册列表中
  Future<void> _getAlbumThumbnail(AssetPathEntity album) async {
    final count = await album.assetCountAsync;
    if (count == 0) return;
    final AssetEntity? last = (await album.getAssetListRange(
      start: 0,
      end: 1,
    )).firstOrNull;
    if (last == null) return;
    albumsWithThumbnail.add(
      Album(
        name: album.name,
        count: count,
        thumbnail: await last.thumbnailDataWithSize(ThumbnailSize(200, 200)),
      ),
    );
    if (!mounted) return;
    setState(() {
      albumsWithThumbnail = albumsWithThumbnail;
    });
  }

  // 顶部操作栏
  Widget _buildTopBar({required double height}) {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      alignment: Alignment.centerLeft,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: IgnorePointer(
              ignoring: isExpanded, // 展开时不可点
              child: AnimatedOpacity(
                opacity: isExpanded ? 0.0 : 1.0,
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOut,
                child: const Icon(Icons.close, color: Colors.black54),
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              // 展开所有相册
              setState(() {
                isExpanded = !isExpanded;
              });
            },
            child: Row(
              children: [
                Text(
                  title,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(width: 4),
                AnimatedRotation(
                  turns: isExpanded ? 0.5 : 0.0, // 0.5 = 180°
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOut,
                  child: const Icon(FontAwesomeIcons.angleDown, size: 16),
                ),
              ],
            ),
          ),
          const SizedBox(width: 24), // 占位
        ],
      ),
    );
  }

  // 相片 Grid
  Widget _buildPhotoGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(2),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: 2,
        crossAxisSpacing: 2,
      ),
      itemCount: images.length,
      itemBuilder: (_, index) {
        final photo = images[index];

        return FutureBuilder<Uint8List?>(
          future: photo.thumbnailDataWithSize(ThumbnailSize(200, 200)),
          builder: (_, snapshot) {
            if (snapshot.connectionState == ConnectionState.done &&
                snapshot.hasData) {
              return GestureDetector(
                onTap: () async {
                  isShowClipSpace = true;
                  selectedImage = await photo.originBytes;
                  setState(() {});
                },
                child: Image.memory(snapshot.data!, fit: BoxFit.cover),
              );
            }
            return Container(color: Colors.grey.shade300);
          },
        );
      },
    );
  }

  // 相册列表
  Widget _buildAlbumList({required double height}) {
    return Positioned(
      top: 57,
      left: 0,
      right: 0,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        height: isExpanded ? height - 57 : 0,
        padding: EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: ListView.builder(
          itemCount: albumsWithThumbnail.length,
          itemBuilder: (_, index) {
            final album = albumsWithThumbnail[index];
            return ListTile(
              leading: album.thumbnail == null
                  ? SizedBox(
                      width: 40,
                      height: 40,
                      child: Image.asset(
                        'assets/album_placeholder.svg',
                        fit: BoxFit.cover,
                      ),
                    )
                  : Image.memory(album.thumbnail!, fit: BoxFit.cover),
              title: Text(album.name),
              subtitle: Text('${album.count} 张照片'),
              onTap: () async {
                // 获取对应相册的所有照片
                await loadPhotos(index: index);
                // 重置标题和isExpanded
                setState(() {
                  isExpanded = false;
                  title = album.name;
                });
              },
            );
          },
        ),
      ),
    );
  }

  Future<void> _cropAndSaveImage() async {
    final editorState = _editorKey.currentState;
    if (editorState == null || selectedImage == null) return;

    // 获取裁剪矩形
    final cropRect = editorState.getCropRect();
    if (cropRect == null) return;

    final option = ImageEditorOption();

    // 添加裁剪
    option.addOption(
      ClipOption(
        x: cropRect.left.toInt(),
        y: cropRect.top.toInt(),
        width: cropRect.width.toInt(),
        height: cropRect.height.toInt(),
      ),
    );

    // 注意：旋转/翻转等操作在 ExtendedImage 内部已经处理，ImageEditor 不需要再手动处理

    // 执行裁剪
    final result = await ImageEditor.editImage(
      image: selectedImage!,
      imageEditorOption: option,
    );

    if (result != null) {
      print('裁剪成功请发送请求更新用户头像: $result');
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    // 屏幕高度
    final height = MediaQuery.of(context).size.height;

    return Scaffold(
      extendBody: true,
      backgroundColor: Colors.black54, // 背景半透明遮罩
      body: SafeArea(
        top: !isShowClipSpace, // 顶部留空
        child: Align(
          alignment: Alignment.bottomCenter,
          child: ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: Stack(
              children: [
                Container(
                  height: height, // 底部弹出高度，可调
                  color: Colors.white,
                  child: Column(
                    children: [
                      // 顶部操作栏
                      _buildTopBar(height: height),

                      const Divider(height: 1),

                      // 相片 Grid
                      Expanded(child: _buildPhotoGrid()),
                    ],
                  ),
                ),
                _buildAlbumList(height: height),
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: isShowClipSpace
                      ? Container(
                          color: Color.fromRGBO(30, 30, 30, 1),
                          child: SafeArea(
                            top: false,
                            child: Stack(
                              children: [
                                Positioned.fill(
                                  child: ExtendedImage.memory(
                                    selectedImage!,
                                    fit: BoxFit.contain,

                                    mode: ExtendedImageMode.editor, // ⭐ 核心

                                    extendedImageEditorKey: _editorKey,

                                    initEditorConfigHandler: (state) {
                                      return widget.editorConfig;
                                    },
                                  ),
                                ),

                                // top值为状态栏高度 + 56
                                Positioned(
                                  left: 0,
                                  right: 0,
                                  top: 0,
                                  child: Container(
                                    padding: EdgeInsets.only(
                                      top: MediaQuery.of(context).padding.top,
                                    ),
                                    height:
                                        MediaQuery.of(context).padding.top + 56,
                                    color: Colors.black,
                                    child: Center(
                                      child: IconButton(
                                        icon: Transform.rotate(
                                          angle: 90 * 3.1415926 / 50,
                                          child: Icon(
                                            FontAwesomeIcons.rotateLeft,
                                            color: Colors.white,
                                            size: 20,
                                          ),
                                        ),
                                        onPressed: () {
                                          _editorKey.currentState?.reset();
                                          setState(() {});
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  left: 0,
                                  right: 0,
                                  bottom: 0,
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 16,
                                    ),
                                    height: 100,
                                    color: Colors.black,
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: SizedBox(
                                            height: 42,
                                            child: ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Color.fromRGBO(
                                                  64,
                                                  64,
                                                  64,
                                                  1,
                                                ),
                                              ),
                                              onPressed: () {
                                                isShowClipSpace = false;
                                                setState(() {});
                                              },
                                              child: Text(
                                                '取消',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: 16),
                                        Expanded(
                                          child: SizedBox(
                                            height: 42,
                                            child: ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Color.fromRGBO(
                                                  254,
                                                  44,
                                                  85,
                                                  1,
                                                ),
                                              ),
                                              onPressed: () {
                                                // 裁剪图片
                                                _cropAndSaveImage();
                                              },
                                              child: Text(
                                                '保存',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
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
                          ),
                        )
                      : Container(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
