import 'dart:typed_data';

import 'package:bilbili_project/components/loading.dart';
import 'package:bilbili_project/routes/app_router.dart';
import 'package:bilbili_project/routes/report_routes/single_image_preview_route.dart';
import 'package:bilbili_project/viewmodels/AllPhoto/index.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:image_editor/image_editor.dart';
import 'package:photo_manager/photo_manager.dart';

class AllPhotoPage extends StatefulWidget {
  final bool isMultiple; // 是否多选
  final EditorConfig editorConfig;
  const AllPhotoPage({
    Key? key,
    required this.editorConfig,
    required this.isMultiple,
  }) : super(key: key);
  @override
  State<AllPhotoPage> createState() => _AllPhotoPageState();
}

class _AllPhotoPageState extends State<AllPhotoPage> {
  @override
  void initState() {
    super.initState();
    _init();
  }

  // 分页相关配置
  static const int _pageSize = 50; // 每页加载50张（可根据性能调整）
  int _currentPage = 0; // 当前页码
  bool _isLoading = false; // 是否正在加载
  bool _hasMoreData = true; // 是否还有更多数据

  List<AssetEntity> currentAlbumImages = []; // 当前相册已加载的图片
  List<AssetPathEntity> albums = [];
  bool isExpanded = false; // 是否显示相册列表
  List<Album> albumsWithThumbnail = []; // 相册列表（单个相册数据进行了封装）
  String title = '';
  bool isShowClipSpace = false; // 是否显示裁剪空间
  Uint8List? selectedImage; // 当前需要裁剪的图片（原图）
  bool _isLoadingOriginalImage = false; // 原图加载状态标记
  List<AssetEntity> selectedImages = []; // 选中的图片（全局保留，跨相册）
  bool get isAllowNext => selectedImages.isNotEmpty; // 是否允许下一步

  // 全局缓存：所有加载过的图片缩略图（跨相册保留）
  final Map<String, Uint8List?> _globalThumbnailCache = {};

  // 当前选中的相册索引
  int _currentAlbumIndex = 0;

  final GlobalKey<ExtendedImageEditorState> _editorKey =
      GlobalKey<ExtendedImageEditorState>();
  final ScrollController _scrollController = ScrollController(); // 滚动控制器

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

  // 初始化分页加载（切换相册时调用）
  Future<void> initPagination({int albumIndex = 0}) async {
    // 只重置当前相册的分页状态，不影响选中的图片
    _currentPage = 0;
    _isLoading = false;
    _hasMoreData = true;
    _currentAlbumIndex = albumIndex;

    // 只清空当前相册的图片列表，保留全局缓存和选中状态
    currentAlbumImages.clear();

    // 加载当前相册的第一页
    await _loadMorePhotos();
  }

  // 加载更多图片（分页加载核心方法）
  Future<void> _loadMorePhotos() async {
    // 边界检查
    if (_isLoading || !_hasMoreData || albums.isEmpty) return;

    _isLoading = true;

    try {
      // 分页获取当前相册的图片
      List<AssetEntity> newPhotos = await albums[_currentAlbumIndex]
          .getAssetListPaged(page: _currentPage, size: _pageSize);

      // 判断是否还有更多数据
      if (newPhotos.isEmpty || newPhotos.length < _pageSize) {
        _hasMoreData = false;
      }

      // 缓存当前页的缩略图（全局缓存，跨相册保留）
      _cacheThumbnails(newPhotos);

      // 添加新数据到当前相册列表
      if (mounted) {
        setState(() {
          currentAlbumImages.addAll(newPhotos);
          _currentPage++;
        });
      }
    } catch (e) {
      debugPrint('加载图片失败: $e');
      _hasMoreData = false;
    } finally {
      _isLoading = false;
    }
  }

  // 缓存图片缩略图（全局缓存，异步执行）
  Future<void> _cacheThumbnails(List<AssetEntity> photos) async {
    for (final photo in photos) {
      // 已缓存的图片跳过，避免重复加载
      if (_globalThumbnailCache.containsKey(photo.id)) continue;

      try {
        final thumbnailData = await photo.thumbnailDataWithSize(
          ThumbnailSize(200.0.w.toInt(), 200.0.h.toInt()),
        );
        if (mounted) {
          setState(() {
            _globalThumbnailCache[photo.id] = thumbnailData;
          });
        }
      } catch (e) {
        _globalThumbnailCache[photo.id] = null;
        debugPrint('缓存图片${photo.id}缩略图失败: $e');
      }
    }
  }

  // 加载原图（核心修复：裁剪用原图）
  Future<void> _loadOriginalImage(AssetEntity photo) async {
    if (_isLoadingOriginalImage) return; // 防止重复加载

    setState(() {
      _isLoadingOriginalImage = true;
      isShowClipSpace = true; // 先显示裁剪界面，避免无响应
    });

    try {
      // 加载原图（关键：使用originBytes而非thumbnailData）
      final originalBytes = await photo.originBytes;
      if (mounted && originalBytes != null) {
        setState(() {
          selectedImage = originalBytes; // 赋值原图
        });
      }
    } catch (e) {
      debugPrint('加载原图失败: $e');
      if (mounted) {
        setState(() {
          selectedImage = null; // 加载失败置空
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingOriginalImage = false; // 结束加载状态
        });
      }
    }
  }

  // 封装相册数据
  Future<void> _handleAlbums() async {
    for (final album in albums) {
      await _getAlbumThumbnail(album);
    }
  }

  // 初始化方法
  Future<void> _init() async {
    // 1. 获取相册列表
    await loadAlbums();

    // 2. 遍历相册列表，封装相册数据
    await _handleAlbums();

    // 3. 初始化滚动监听
    _scrollController.addListener(() {
      // 滚动到列表底部80%时加载更多
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent * 0.8) {
        _loadMorePhotos();
      }
    });

    // 4. 初始化分页加载第一个相册
    if (albums.isNotEmpty) {
      await initPagination(albumIndex: 0);
    }
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

    // 使用全局缓存，避免重复加载相册缩略图
    Uint8List? thumbnail;
    if (_globalThumbnailCache.containsKey(last.id)) {
      thumbnail = _globalThumbnailCache[last.id];
    } else {
      thumbnail = await last.thumbnailDataWithSize(
        ThumbnailSize(200.0.w.toInt(), 200.0.h.toInt()),
      );
      _globalThumbnailCache[last.id] = thumbnail;
    }

    albumsWithThumbnail.add(
      Album(name: album.name, count: count, thumbnail: thumbnail),
    );
    if (!mounted) return;
    setState(() {
      albumsWithThumbnail = albumsWithThumbnail;
    });
  }

  // 顶部操作栏
  Widget _buildTopBar({required double height}) {
    return Container(
      height: 56.0.h,
      padding: EdgeInsets.symmetric(horizontal: 16.0.w),
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
                SizedBox(width: 4.0.w),
                AnimatedRotation(
                  turns: isExpanded ? 0.5 : 0.0, // 0.5 = 180°
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOut,
                  child: Icon(FontAwesomeIcons.angleDown, size: 16.0.r),
                ),
              ],
            ),
          ),
          // 显示已选中的图片数量
          Container(
            width: 24.0.w,
            alignment: Alignment.center,
            child: selectedImages.isNotEmpty
                ? Text(
                    '${selectedImages.length}/4',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Color.fromRGBO(253, 44, 85, 1),
                      fontWeight: FontWeight.bold,
                    ),
                  )
                : null,
          ),
        ],
      ),
    );
  }

  // 获取相片在选中相片列表里面的索引编号
  String getPhotoIndexInSelected(AssetEntity photo) {
    if (!selectedImages.contains(photo)) return '';
    return (selectedImages.indexOf(photo) + 1).toString();
  }

  // 优化后的相片 Grid（分页加载）
  Widget _buildPhotoGrid() {
    return GridView.builder(
      controller: _scrollController,
      padding: EdgeInsets.all(2.r),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: 2.r,
        crossAxisSpacing: 2.r,
      ),
      itemCount: currentAlbumImages.length,
      itemBuilder: (_, index) {
        final photo = currentAlbumImages[index];
        return _buildPhotoItem(photo);
      },
    );
  }

  // 单独的图片Item构建方法
  Widget _buildPhotoItem(AssetEntity photo) {
    final hasThumbnail = _globalThumbnailCache.containsKey(photo.id);
    final thumbnailData = _globalThumbnailCache[photo.id];
    // 判断当前图片是否被选中
    final isSelected = selectedImages.contains(photo);
    // 判断是否达到选中上限且当前图片未被选中
    final isMaxSelected = selectedImages.length >= 4 && !isSelected;

    return GestureDetector(
      key: ValueKey(photo.id), // 使用 photo.id 作为唯一标识符
      onTap: () async {
        if (!widget.isMultiple) {
          // 单选模式：加载原图进行裁剪（核心修复）
          await _loadOriginalImage(photo);
        } else {
          // 多选模式：进行单图预览
          Uint8List? data = await photo.originBytes;
          context.push(
            SingleImagePreviewRoute().location,
            extra: {photo.id: data},
          );
        }
      },
      child: Stack(
        children: [
          Positioned.fill(
            child: hasThumbnail
                ? (thumbnailData != null
                      ? Hero(
                          tag: photo.id,
                          child: Image.memory(thumbnailData, fit: BoxFit.cover),
                        )
                      : Container(color: Colors.grey.shade300))
                : Container(
                    color: Colors.grey.shade200,
                    child: const Center(child: FetchLoadingView()),
                  ),
          ),
          widget.isMultiple
              ? Positioned(
                  right: 4.w,
                  top: 4.h,
                  child: GestureDetector(
                    onTap: () {
                      if (isMaxSelected) return; // 达到4张上限，禁止选择新图片

                      setState(() {
                        if (isSelected) {
                          // 已选中，取消选中
                          selectedImages.remove(photo);
                        } else {
                          // 未选中，添加选中（最多4张）
                          if (selectedImages.length < 4) {
                            selectedImages.add(photo);
                          }
                        }
                      });
                    },
                    child: Container(
                      width: 22.0.w,
                      height: 22.0.h,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isSelected
                            ? Color.fromRGBO(253, 44, 85, 1)
                            : Colors.transparent,
                        border: Border.all(color: Colors.white, width: 2.0.r),
                      ),
                      child: Text(
                        getPhotoIndexInSelected(photo),
                        style: TextStyle(
                          fontSize: 12.0.sp,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                )
              : Container(),
          // 达到选中上限时，未选中的图片添加遮罩
          isMaxSelected
              ? Positioned.fill(
                  child: Container(color: Colors.white.withOpacity(0.5)),
                )
              : Container(),
        ],
      ),
    );
  }

  // 相册列表
  Widget _buildAlbumList({required double height}) {
    return Positioned(
      top: 57.0.h,
      left: 0,
      right: 0,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        height: isExpanded ? height - 57.0.h : 0,
        padding: EdgeInsets.symmetric(horizontal: 16.0.w),
        decoration: BoxDecoration(color: Colors.white),
        child: ListView.builder(
          itemCount: albumsWithThumbnail.length,
          itemBuilder: (_, index) {
            final album = albumsWithThumbnail[index];
            return ListTile(
              leading: album.thumbnail == null
                  ? SizedBox(
                      width: 40.0.w,
                      height: 40.0.h,
                      child: Image.asset(
                        'assets/album_placeholder.svg',
                        fit: BoxFit.cover,
                      ),
                    )
                  : Image.memory(album.thumbnail!, fit: BoxFit.cover),
              title: Text(album.name),
              subtitle: Text('${album.count} 张照片'),
              onTap: () async {
                // 切换相册，重新初始化分页（保留选中状态）
                await initPagination(albumIndex: index);

                // 更新UI状态
                if (mounted) {
                  setState(() {
                    isExpanded = false;
                    title = album.name;
                  });
                }
              },
            );
          },
        ),
      ),
    );
  }

  Future<void> _cropAndSaveImage() async {
    // 安全检查：原图为空直接返回
    if (selectedImage == null) {
      debugPrint('裁剪失败：原图为空');
      return;
    }

    final editorState = _editorKey.currentState;
    if (editorState == null) return;

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

    // 执行裁剪（使用原图裁剪）
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
  void dispose() {
    // 释放资源
    _scrollController.dispose();
    super.dispose();
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
            borderRadius: BorderRadius.vertical(top: Radius.circular(16.0.r)),
            child: Stack(
              children: [
                Container(
                  height: height, // 底部弹出高度，可调
                  color: Colors.white,
                  child: Column(
                    children: [
                      // 顶部操作栏
                      _buildTopBar(height: height),

                      // 分隔线
                      Divider(height: 1.0.h),

                      // 相片 Grid
                      Expanded(child: _buildPhotoGrid()),
                      AnimatedContainer(
                        duration: Duration(milliseconds: 300),
                        height: isAllowNext ? 100.0.h : 0,
                      ),
                    ],
                  ),
                ),

                // 多选模式底部操作栏
                widget.isMultiple
                    ? Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white, // 顶部边框
                            border: isAllowNext
                                ? Border(
                                    top: BorderSide(
                                      color: Colors.grey.shade300,
                                      width: 1.0.r,
                                    ),
                                  )
                                : Border(),
                          ),
                          padding: EdgeInsets.symmetric(
                            horizontal: 12.0.w,
                            vertical: 12.0.h,
                          ),
                          child: Column(
                            children: [
                              AnimatedContainer(
                                duration: Duration(milliseconds: 300),
                                height: isAllowNext ? 80.0.h : 0,
                                child: GridView.builder(
                                  gridDelegate:
                                      SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 6,
                                        crossAxisSpacing: 8.r,
                                      ),
                                  itemCount: selectedImages.length,
                                  itemBuilder: (_, index) {
                                    final photo = selectedImages[index];
                                    final thumbnailData =
                                        _globalThumbnailCache[photo.id];

                                    return GestureDetector(
                                      onTap: () async {
                                        context.push(
                                          SingleImagePreviewRoute().location,
                                          extra: {photo.id: thumbnailData},
                                        );
                                      },
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(
                                          6.0.r,
                                        ),
                                        child: Stack(
                                          children: [
                                            thumbnailData != null
                                                ? Image.memory(
                                                    thumbnailData,
                                                    fit: BoxFit.cover,
                                                    width: 80.0.w,
                                                    height: 80.0.h,
                                                  )
                                                : Container(
                                                    color: Colors.grey.shade300,
                                                  ),
                                            Positioned(
                                              right: 0,
                                              top: 0,
                                              child: GestureDetector(
                                                onTap: () {
                                                  // 删除选中（跨相册生效）
                                                  setState(() {
                                                    selectedImages.remove(
                                                      photo,
                                                    );
                                                  });
                                                },
                                                child: Container(
                                                  width: 18.0.r,
                                                  height: 18.0.r,
                                                  decoration: BoxDecoration(
                                                    color: Color.fromRGBO(
                                                      12,
                                                      9,
                                                      6,
                                                      1,
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.only(
                                                          bottomLeft:
                                                              Radius.circular(
                                                                6.0.r,
                                                              ),
                                                        ),
                                                  ),
                                                  child: Icon(
                                                    FontAwesomeIcons.xmark,
                                                    size: 10.0.r,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              Divider(height: 1.0.h),
                              SizedBox(
                                height: 80.0.h,
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      '已选择 ${selectedImages.length}/4 张',
                                      style: TextStyle(
                                        fontSize: 12.0.sp,
                                        color: Color.fromRGBO(181, 181, 185, 1),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 40.0.h,
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: isAllowNext
                                              ? Color.fromRGBO(253, 44, 85, 1)
                                              : Color.fromRGBO(
                                                  243,
                                                  243,
                                                  244,
                                                  1,
                                                ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              6.0.r,
                                            ),
                                          ),
                                        ),
                                        onPressed: isAllowNext
                                            ? _cropAndSaveImage
                                            : null,
                                        child: Text(
                                          '下一步（${selectedImages.length}/4）',
                                          style: TextStyle(
                                            fontSize: 12.0.sp,
                                            color: isAllowNext
                                                ? Colors.white
                                                : Color.fromRGBO(
                                                    181,
                                                    181,
                                                    185,
                                                    1,
                                                  ),
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
                      )
                    : Container(),
                _buildAlbumList(height: height),

                // 裁剪预览区域（修复模糊+空指针）
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
                                // 加载中显示loading，加载完成显示原图
                                Positioned.fill(
                                  child: _isLoadingOriginalImage
                                      ? const Center(child: FetchLoadingView())
                                      : selectedImage != null
                                      ? ExtendedImage.memory(
                                          selectedImage!, // 原图显示，清晰
                                          fit: BoxFit.contain,
                                          mode: ExtendedImageMode.editor,
                                          extendedImageEditorKey: _editorKey,
                                          initEditorConfigHandler: (state) {
                                            return widget.editorConfig;
                                          },
                                        )
                                      : const Center(
                                          child: Text(
                                            '图片加载失败，请重试',
                                            style: TextStyle(
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                ),
                                Positioned(
                                  left: 0,
                                  right: 0,
                                  top: 0,
                                  child: Container(
                                    padding: EdgeInsets.only(
                                      top: MediaQuery.of(context).padding.top,
                                    ),
                                    height:
                                        MediaQuery.of(context).padding.top +
                                        56.0.h,
                                    color: Colors.black,
                                    child: Center(
                                      child: IconButton(
                                        icon: Transform.rotate(
                                          angle: 90 * 3.1415926 / 50,
                                          child: Icon(
                                            FontAwesomeIcons.rotateLeft,
                                            color: Colors.white,
                                            size: 20.0.r,
                                          ),
                                        ),
                                        onPressed: _isLoadingOriginalImage
                                            ? null // 加载中禁用旋转
                                            : () {
                                                _editorKey.currentState
                                                    ?.reset();
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
                                      horizontal: 16.0.w,
                                    ),
                                    height: 100.0.h,
                                    color: Colors.black,
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: SizedBox(
                                            height: 42.0.h,
                                            child: ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Color.fromRGBO(
                                                  64,
                                                  64,
                                                  64,
                                                  1,
                                                ),
                                              ),
                                              onPressed: _isLoadingOriginalImage
                                                  ? null // 加载中禁用取消
                                                  : () {
                                                      setState(() {
                                                        isShowClipSpace = false;
                                                        selectedImage =
                                                            null; // 清空原图
                                                      });
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
                                        SizedBox(width: 16.0.w),
                                        Expanded(
                                          child: SizedBox(
                                            height: 42.0.h,
                                            child: ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Color.fromRGBO(
                                                  254,
                                                  44,
                                                  85,
                                                  1,
                                                ),
                                              ),
                                              // 加载中或原图为空时禁用保存
                                              onPressed:
                                                  _isLoadingOriginalImage ||
                                                      selectedImage == null
                                                  ? null
                                                  : _cropAndSaveImage,
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
