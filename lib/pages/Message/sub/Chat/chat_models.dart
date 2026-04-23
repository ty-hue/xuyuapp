/// 聊天列表项类型（对接后端时可与接口字段对齐）
enum ChatItemKind {
  /// 居中时间分割线，例如「周二 16:34」「刚刚」
  timeDivider,

  /// 居中系统提示，例如「你撤回了一条消息」
  systemNotice,

  /// 文本气泡
  text,

  /// 视频卡片气泡（展示缩略图 + 播放按钮）
  video,

  /// 收藏表情（静态图 / GIF 缩略）
  sticker,
}

/// 单条会话消息 / 分割线模型，便于 `ListView` 渲染与接口反序列化。
class ChatListItem {
  const ChatListItem({
    required this.id,
    required this.kind,
    this.isSelf,
    this.text,
    this.timeLabel,
    this.systemText,
    this.videoThumbUrl,
    this.videoTag,
    this.stickerThumbUrl,
    this.stickerIsGif,
  });

  final String id;
  final ChatItemKind kind;

  /// 仅 [text] / [video] 使用：`true` 己方，对方为 `false`
  final bool? isSelf;
  final String? text;

  /// [kind] == [ChatItemKind.timeDivider]
  final String? timeLabel;

  /// [kind] == [ChatItemKind.systemNotice]
  final String? systemText;

  /// [kind] == [ChatItemKind.video]，可为网络图；`null` 时用占位渐变
  final String? videoThumbUrl;

  /// 视频卡片左下角标签，例如「红果免费短剧」
  final String? videoTag;

  /// [kind] == [ChatItemKind.sticker]
  final String? stickerThumbUrl;
  final bool? stickerIsGif;

  /// 从 JSON 构建（字段名按你后端约定改名即可）
  factory ChatListItem.fromJson(Map<String, dynamic> json) {
    final kindStr = json['kind'] as String? ?? 'text';
    final kind = ChatItemKind.values.firstWhere(
      (e) => e.name == kindStr,
      orElse: () => ChatItemKind.text,
    );
    return ChatListItem(
      id: json['id'] as String? ?? '',
      kind: kind,
      isSelf: json['isSelf'] as bool?,
      text: json['text'] as String?,
      timeLabel: json['timeLabel'] as String?,
      systemText: json['systemText'] as String?,
      videoThumbUrl: json['videoThumbUrl'] as String?,
      videoTag: json['videoTag'] as String?,
      stickerThumbUrl: json['stickerThumbUrl'] as String?,
      stickerIsGif: json['stickerIsGif'] as bool?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'kind': kind.name,
        'isSelf': isSelf,
        'text': text,
        'timeLabel': timeLabel,
        'systemText': systemText,
        'videoThumbUrl': videoThumbUrl,
        'videoTag': videoTag,
        'stickerThumbUrl': stickerThumbUrl,
        'stickerIsGif': stickerIsGif,
      };
}

/// 快捷回复胶囊（可选，与运营配置或接口下发对齐）
class QuickReactionItem {
  const QuickReactionItem({required this.emoji, required this.label});

  final String emoji;
  final String label;
}
