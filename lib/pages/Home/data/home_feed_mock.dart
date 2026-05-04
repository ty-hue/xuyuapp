/// 首页推荐流：媒体类型（与后端对齐时可整型枚举）。
enum HomeFeedMediaKind {
  video,
  /// 单张图（竖滑仍是一条作品）。
  imageSingle,
  /// 多图：条内横向滑动浏览。
  imageGallery,
}

/// 单条 Feed 数据模型。当前为本地模拟，接入 API 后由 DTO 映射即可。
class HomeFeedItem {
  HomeFeedItem({
    required this.id,
    required this.kind,
    this.videoUrl,
    this.imageUrls = const [],
    /// 可选。接口未返回时以播放器解码后的 `size` 为准。
    this.videoWidth,
    this.videoHeight,
    required this.author,
    required this.title,
    required this.musicChip,
    required this.musicScroll,
    required this.likeCount,
    required this.commentCount,
    required this.shareCount,
    required this.collectCount,
  }) : assert(
          kind == HomeFeedMediaKind.video
              ? (videoUrl != null && videoUrl.isNotEmpty)
              : imageUrls.isNotEmpty,
          'video 需 videoUrl；图片类需 imageUrls',
        );

  final String id;
  final HomeFeedMediaKind kind;
  final String? videoUrl;
  final int? videoWidth;
  final int? videoHeight;
  final List<String> imageUrls;
  final String author;
  final String title;
  /// 底部左侧小胶囊文案（视频：背景音乐；图：单图/图集）。
  final String musicChip;
  final String musicScroll;
  final int likeCount;
  final int commentCount;
  final int shareCount;
  final int collectCount;
}

/// 模拟推荐流：视频与单图/多图穿插，图片使用 Picsum。
///
/// 视频地址使用 Flutter 文档托管的样片（`flutter.github.io`），一般比境外
/// `*.googleapis.com`、带鉴权参数的 CDN 更易连上；真机仍超时请检查代理/防火墙。
final List<HomeFeedItem> kHomeMockFeed = <HomeFeedItem>[
  HomeFeedItem(
    id: 'v1',
    kind: HomeFeedMediaKind.video,
    videoUrl:
        'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4',
    /// 不设宽高时以解码结果为准（bee 样片多为横屏，竖滑内会留白 + 全屏按钮）。
    author: '@絮语官方',
    title: '官方示例片 bee · 网络稳定可测',
    musicChip: '背景音乐',
    musicScroll: '夜车（demo）- 本地模拟',
    likeCount: 336000,
    commentCount: 5000,
    shareCount: 0,
    collectCount: 50000,
  ),
  HomeFeedItem(
    id: 'img1',
    kind: HomeFeedMediaKind.imageSingle,
    imageUrls: const ['https://picsum.photos/id/1018/1080/1920'],
    author: '@旅行相册',
    title: '单图作品 · 云海日出（模拟）',
    musicChip: '单图',
    musicScroll: '左右无横滑，仅竖滑切下一条',
    likeCount: 12800,
    commentCount: 320,
    shareCount: 12,
    collectCount: 2100,
  ),
  HomeFeedItem(
    id: 'v2',
    kind: HomeFeedMediaKind.video,
    videoUrl:
        'https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4',
    author: '@创作灵感',
    title: '官方示例片 butterfly · 竖滑留白 + 全屏观看',
    musicChip: '背景音乐',
    musicScroll: 'Sample Audio Track',
    likeCount: 8900,
    commentCount: 1200,
    shareCount: 88,
    collectCount: 600,
  ),
  HomeFeedItem(
    id: 'gal1',
    kind: HomeFeedMediaKind.imageGallery,
    imageUrls: const [
      'https://picsum.photos/id/29/1080/1920',
      'https://picsum.photos/id/15/1080/1920',
      'https://picsum.photos/id/28/1080/1920',
    ],
    author: '@图集作者',
    title: '多图图集 · 共 3 张（横滑切换，模拟）',
    musicChip: '图集',
    musicScroll: '横向滑动查看每张 · 竖滑进入下一条',
    likeCount: 45200,
    commentCount: 890,
    shareCount: 45,
    collectCount: 3200,
  ),
  HomeFeedItem(
    id: 'img2',
    kind: HomeFeedMediaKind.imageSingle,
    imageUrls: const ['https://picsum.photos/id/1067/1080/1920'],
    author: '@极简摄影',
    title: '单图 · 远山与雾',
    musicChip: '单图',
    musicScroll: 'Picsum 演示图',
    likeCount: 2100,
    commentCount: 56,
    shareCount: 3,
    collectCount: 180,
  ),
  HomeFeedItem(
    id: 'v3',
    kind: HomeFeedMediaKind.video,
    videoUrl:
        'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4',
    author: '@户外频道',
    title: '旅行 vlog 片段（模拟）',
    musicChip: '背景音乐',
    musicScroll: 'Escape - demo',
    likeCount: 156000,
    commentCount: 4200,
    shareCount: 210,
    collectCount: 12000,
  ),
  HomeFeedItem(
    id: 'gal2',
    kind: HomeFeedMediaKind.imageGallery,
    imageUrls: const [
      'https://picsum.photos/id/1076/1080/1920',
      'https://picsum.photos/id/1023/1080/1920',
    ],
    author: '@城市漫步',
    title: '双图街拍（模拟）',
    musicChip: '图集',
    musicScroll: '2 张 · 横滑',
    likeCount: 6700,
    commentCount: 200,
    shareCount: 18,
    collectCount: 400,
  ),
];

/// 「朋友」流模拟：互关作者发布的动态（结构与 [kHomeMockFeed] 一致，接入 API 后可替换）。
final List<HomeFeedItem> kFriendMutualFollowMockFeed = <HomeFeedItem>[
  HomeFeedItem(
    id: 'f_v1',
    kind: HomeFeedMediaKind.video,
    videoUrl:
        'https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4',
    author: '@互关小林',
    title: '早安 · butterfly 短片（好友流模拟）',
    musicChip: '好友作品',
    musicScroll: '互关专属可见 · demo',
    likeCount: 1280,
    commentCount: 86,
    shareCount: 12,
    collectCount: 340,
  ),
  HomeFeedItem(
    id: 'f_img1',
    kind: HomeFeedMediaKind.imageSingle,
    imageUrls: const ['https://picsum.photos/id/1003/1080/1920'],
    author: '@互关阿周',
    title: '今日随拍一张（模拟互关图文）',
    musicChip: '单图',
    musicScroll: '好友动态',
    likeCount: 520,
    commentCount: 28,
    shareCount: 2,
    collectCount: 90,
  ),
  HomeFeedItem(
    id: 'f_v2',
    kind: HomeFeedMediaKind.video,
    videoUrl:
        'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4',
    author: '@互关 Mina',
    title: '周末 bee 合集 · 等你来赞',
    musicChip: '好友作品',
    musicScroll: 'Track · friend feed',
    likeCount: 5600,
    commentCount: 410,
    shareCount: 33,
    collectCount: 890,
  ),
  HomeFeedItem(
    id: 'f_v3',
    kind: HomeFeedMediaKind.video,
    videoUrl:
        'https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4',
    author: '@互关大江',
    title: '攀岩记录 #好友可见',
    musicChip: '运动',
    musicScroll: 'Climb mix',
    likeCount: 3400,
    commentCount: 156,
    shareCount: 8,
    collectCount: 412,
  ),
];
