import 'dart:math';

import 'package:bilbili_project/pages/Message/sub/Chat/chat_models.dart';

/// 对接真实 API 时实现此类（例如内部使用 `dio` POST/GET）。
abstract class ChatRemoteDataSource {
  /// 拉取历史消息；`cursor`/`beforeId` 用于分页，按后端约定传入。
  Future<List<ChatListItem>> fetchMessages({
    String? conversationId,
    String? cursor,
  });

  /// 发送文本；成功后由上层刷新列表或本地追加。
  Future<void> sendText({
    required String conversationId,
    required String text,
  });

  /// 发送收藏表情（静态/GIF）；对接时用 `stickerId` / URL 传给后端。
  Future<void> sendCollectedSticker({
    required String conversationId,
    required String stickerId,
    required String thumbnailUrl,
    required bool isGif,
  });
}

/// 演示用假数据（含随机生成的多条记录，便于看滚动）；接入接口后可删除或仅用于开发调试。
class MockChatRemoteDataSource implements ChatRemoteDataSource {
  MockChatRemoteDataSource();

  static final Random _rand = Random();

  static const List<String> _peerLines = [
    '在吗',
    '晚上有空吗',
    '这条视频你看过没',
    '哈哈哈哈笑死我了',
    '明天见面聊',
    'OK 等你消息',
    '我先去忙了',
    '记得发我链接',
    '好呢',
    '👌 没问题',
  ];

  static const List<String> _selfLines = [
    '在的',
    '刚看到',
    '好啊',
    '等我十分钟',
    '收到了',
    '牛牛牛牛牛牛牛',
    '等下打给你',
    '😂 这也太巧了',
    '马上到',
    '一会发你',
  ];

  static const List<String> _timeLabels = [
    '周二 16:34',
    '昨天 01:32',
    '昨天 18:05',
    '今天上午 09:12',
    '刚刚',
    '星期一 12:00',
    '星期五 22:18',
  ];

  static const List<String> _systemLines = [
    '你撤回了一条消息',
    '对方撤回了一条消息',
    '以上为历史消息',
  ];

  List<ChatListItem> _randomConversation() {
    final items = <ChatListItem>[];
    var id = 0;
    String nextId() => 'm_${++id}';

    items.add(
      ChatListItem(
        id: nextId(),
        kind: ChatItemKind.timeDivider,
        timeLabel: _timeLabels[0],
      ),
    );

    /// 随机生成约 55～75 条列表项（含时间/系统/文本/视频）
    final target = 55 + _rand.nextInt(21);
    for (var i = 0; i < target; i++) {
      final roll = _rand.nextInt(100);
      if (roll < 8) {
        items.add(
          ChatListItem(
            id: nextId(),
            kind: ChatItemKind.timeDivider,
            timeLabel: _timeLabels[_rand.nextInt(_timeLabels.length)],
          ),
        );
      } else if (roll < 11) {
        items.add(
          ChatListItem(
            id: nextId(),
            kind: ChatItemKind.systemNotice,
            systemText: _systemLines[_rand.nextInt(_systemLines.length)],
          ),
        );
      } else if (roll < 18) {
        items.add(
          ChatListItem(
            id: nextId(),
            kind: ChatItemKind.video,
            isSelf: _rand.nextBool(),
            videoThumbUrl: null,
            videoTag: _rand.nextBool()
                ? ['红果免费短剧', '精选短视频', null, null][_rand.nextInt(4)]
                : null,
          ),
        );
      } else {
        final self = _rand.nextBool();
        items.add(
          ChatListItem(
            id: nextId(),
            kind: ChatItemKind.text,
            isSelf: self,
            text: self
                ? _selfLines[_rand.nextInt(_selfLines.length)]
                : _peerLines[_rand.nextInt(_peerLines.length)],
          ),
        );
      }
    }

    return items;
  }

  @override
  Future<List<ChatListItem>> fetchMessages({
    String? conversationId,
    String? cursor,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 120));
    return _randomConversation();
  }

  @override
  Future<void> sendText({
    required String conversationId,
    required String text,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 80));
  }

  @override
  Future<void> sendCollectedSticker({
    required String conversationId,
    required String stickerId,
    required String thumbnailUrl,
    required bool isGif,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 80));
  }
}
