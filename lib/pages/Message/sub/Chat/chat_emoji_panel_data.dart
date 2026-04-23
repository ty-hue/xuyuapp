// 表情键盘数据：全部 emoji 字符 + 演示用「收藏表情」（静态/GIF URL 可替换为接口返回）

/// 用户收藏的静态图 / GIF（对接接口后用接口列表替换 [mockCollectedStickers]）
class CollectedSticker {
  const CollectedSticker({
    required this.id,
    required this.isGif,
    required this.thumbnailUrl,
  });

  final String id;
  final bool isGif;

  /// 静态图或 GIF 预览地址
  final String thumbnailUrl;
}

/// 演示数据；真实环境由接口拉取收藏列表
const List<CollectedSticker> mockCollectedStickers = [
  CollectedSticker(
    id: 'c1',
    isGif: false,
    thumbnailUrl: 'https://picsum.photos/seed/chatstk1/120/120',
  ),
  CollectedSticker(
    id: 'c2',
    isGif: true,
    thumbnailUrl:
        'https://media.giphy.com/media/l0HlNQ03JzpJ0FLAO/giphy.gif',
  ),
  CollectedSticker(
    id: 'c3',
    isGif: false,
    thumbnailUrl: 'https://picsum.photos/seed/chatstk2/120/120',
  ),
  CollectedSticker(
    id: 'c4',
    isGif: true,
    thumbnailUrl:
        'https://media.giphy.com/media/3o7TKSjRrfIPjeiVQk/giphy.gif',
  ),
  CollectedSticker(
    id: 'c5',
    isGif: false,
    thumbnailUrl: 'https://picsum.photos/seed/chatstk3/120/120',
  ),
  CollectedSticker(
    id: 'c6',
    isGif: false,
    thumbnailUrl: 'https://picsum.photos/seed/chatstk4/120/120',
  ),
  CollectedSticker(
    id: 'c7',
    isGif: true,
    thumbnailUrl:
        'https://media.giphy.com/media/26BRuo6sLetdllPAQ/giphy.gif',
  ),
  CollectedSticker(
    id: 'c8',
    isGif: false,
    thumbnailUrl: 'https://picsum.photos/seed/chatstk5/120/120',
  ),
];

/// 「全部表情」网格数据（节选常见黄脸与手势，可按产品扩展）
const List<String> kEmojiGridChars = [
  '😀', '😃', '😄', '😁', '😆', '😅', '🤣', '😂',
  '🙂', '🙃', '😉', '😊', '😇', '🥰', '😍', '🤩',
  '😘', '😗', '☺️', '😚', '😙', '😋', '😛', '😜',
  '🤪', '😝', '🤑', '🤗', '🤭', '🤫', '🤔', '🤐',
  '🤨', '😐', '😑', '😶', '😏', '😒', '🙄', '😬',
  '🤥', '😌', '😔', '😪', '🤤', '😴', '😷', '🤒',
  '🤕', '🤢', '🤮', '🤧', '🥵', '🥶', '😵', '🤯',
  '🥳', '😎', '🤓', '🧐', '😕', '😟', '🙁', '☹️',
  '😮', '😯', '😲', '😳', '🥺', '😦', '😧', '😨',
  '😰', '😥', '😢', '😭', '😱', '😖', '😣', '😞',
  '😓', '😩', '😫', '🥱', '😤', '😡', '😠', '🤬',
  '👍', '👎', '👏', '🙌', '👐', '🤝', '🙏', '✍️',
  '💪', '🦾', '🦿', '🦵', '🦶', '👂', '🦻', '👃',
  '❤️', '🧡', '💛', '💚', '💙', '💜', '🖤', '🤍',
];
