import 'dart:typed_data';

import 'package:bilbili_project/viewmodels/AllPhoto/index.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:photo_manager/photo_manager.dart';

class AllPhotoPage extends StatefulWidget {
  const AllPhotoPage({Key? key}) : super(key: key);

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
  bool isExpanded = false; // 是否展开相册
  List<Album> albumsWithThumbnail = []; // 相册列表（单个相册数据进行了封装）
  String title = '';
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
      albums = albums;
    });
  }

  // 分页获取指定相册里面的图片
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

  @override
  Widget build(BuildContext context) {
    // 屏幕高度
    final height = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.black54, // 背景半透明遮罩
      body: SafeArea(
        top: true, // 顶部留空
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
                      Container(
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
                                  child: const Icon(
                                    Icons.close,
                                    color: Colors.black54,
                                  ),
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
                                    title == ''
                                        ? albumsWithThumbnail[0].name
                                        : title,
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(width: 4),
                                  AnimatedRotation(
                                    turns: isExpanded ? 0.5 : 0.0, // 0.5 = 180°
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.easeOut,
                                    child: const Icon(
                                      FontAwesomeIcons.angleDown,
                                      size: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 24), // 占位
                          ],
                        ),
                      ),

                      const Divider(height: 1),

                      // 相册 Grid
                      Expanded(
                        child: GridView.builder(
                          padding: const EdgeInsets.all(2),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 4,
                                mainAxisSpacing: 2,
                                crossAxisSpacing: 2,
                              ),
                          itemCount: images.length,
                          itemBuilder: (_, index) {
                            final photo = images[index];

                            return FutureBuilder<Uint8List?>(
                              future: photo.thumbnailDataWithSize(
                                ThumbnailSize(200, 200),
                              ),
                              builder: (_, snapshot) {
                                if (snapshot.connectionState ==
                                        ConnectionState.done &&
                                    snapshot.hasData) {
                                  return GestureDetector(
                                    onTap: () {
                                      Navigator.pop(context, photo); // 返回选中的照片
                                    },
                                    child: Image.memory(
                                      snapshot.data!,
                                      fit: BoxFit.cover,
                                    ),
                                  );
                                }
                                return Container(color: Colors.grey.shade300);
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  top: 57,
                  left: 0,
                  right: 0,
                  child: AnimatedContainer(
                    duration: Duration(milliseconds: 300),
                    height: isExpanded ? height - 57 : 0,
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(16),
                      ),
                    ),
                    child: ListView.builder(
                      itemCount: albumsWithThumbnail.length,
                      itemBuilder: (_, index) {
                        final album = albumsWithThumbnail[index];
                        return ListTile(
                          leading: album.thumbnail == null
                              ? Container(
                                  width: 40,
                                  height: 40,
                                  color: Colors.grey.shade300,
                                )
                              : Image.memory(
                                  album.thumbnail!,
                                  fit: BoxFit.cover,
                                ),
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
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
