import 'package:flutter/foundation.dart';

/// 评论用户，字段可与后端对齐（如 `id`、`nickname`、`avatar`、`is_author`）。
@immutable
class VideoCommentUser {
  const VideoCommentUser({
    required this.id,
    required this.nickname,
    this.avatarUrl,
    this.isVideoAuthor = false,
  });

  final String id;
  final String nickname;
  final String? avatarUrl;
  final bool isVideoAuthor;

  factory VideoCommentUser.fromJson(Map<String, dynamic> j) {
    return VideoCommentUser(
      id: (j['id'] ?? j['user_id'] ?? '').toString(),
      nickname: (j['name'] ?? j['nickname'] ?? j['user_name'] ?? '') as String,
      avatarUrl: (j['avatar'] ?? j['avatar_url'] ?? j['face']) as String?,
      isVideoAuthor:
          j['is_author'] == true ||
          j['is_video_author'] == true ||
          j['isAuthor'] == true,
    );
  }
}

@immutable
class VideoCommentNode {
  const VideoCommentNode({
    required this.id,
    this.parentId,
    this.rootCommentId,
    required this.user,
    this.replyToUser,
    required this.content,
    required this.timeAgo,
    this.location,
    this.likeCount = 0,
    this.replies = const [],
  });

  final String id;
  final String? parentId;
  final String? rootCommentId;
  final VideoCommentUser user;
  final VideoCommentUser? replyToUser;
  final String content;
  final String timeAgo;
  final String? location;
  final int likeCount;
  final List<VideoCommentNode> replies;

  /// 接口返回嵌套 `replies` / `sub_comments` / `children` 时直接使用。
  factory VideoCommentNode.fromJson(Map<String, dynamic> j) {
    final u = j['user'] ?? j['author'] ?? j['from_user'];
    if (u is! Map) {
      throw ArgumentError('comment: missing user/author object');
    }
    final uMap = Map<String, dynamic>.from(u);

    VideoCommentUser? replyTo;
    final rt = j['reply_to_user'] ?? j['reply_to'] ?? j['at_user'];
    if (rt is Map) {
      replyTo = VideoCommentUser.fromJson(Map<String, dynamic>.from(rt));
    }

    final rawReplies = j['replies'] ?? j['sub_comments'] ?? j['children'];
    final List<VideoCommentNode> children;
    if (rawReplies is List) {
      children = [
        for (final e in rawReplies)
          if (e is Map) VideoCommentNode.fromJson(Map<String, dynamic>.from(e)),
      ];
    } else {
      children = const [];
    }
    return VideoCommentNode(
      id: (j['comment_id'] ?? j['id'] ?? j['cid'] ?? '').toString(),
      parentId: j['parent_id']?.toString(),
      rootCommentId: j['root_id']?.toString(),
      user: VideoCommentUser.fromJson(uMap),
      replyToUser: replyTo,
      content: (j['content'] ?? j['message'] ?? j['text'] ?? '') as String,
      timeAgo:
          (j['time_ago'] ?? j['timeAgo'] ?? j['time_text'] ?? '') as String,
      location: (j['location'] ?? j['ip_location'] ?? j['region']) as String?,
      likeCount: (j['likes'] is int)
          ? j['likes'] as int
          : int.tryParse('${j['like_count'] ?? 0}') ?? 0,
      replies: children,
    );
  }
}

/// 从扁平表（含 `parent_id` / `root_id`）组出多根楼。顺序为接口列表顺序在兄弟间保持。
List<VideoCommentNode> buildVideoCommentForest(
  List<Map<String, dynamic>> flat,
) {
  if (flat.isEmpty) return const [];

  final byId = <String, _MutableC>{};
  for (final m in flat) {
    final id = (m['id'] ?? m['comment_id'])?.toString() ?? '';
    if (id.isEmpty) continue;
    byId[id] = _MutableC(
      VideoCommentNode(
        id: id,
        parentId: m['parent_id']?.toString(),
        rootCommentId: m['root_id']?.toString(),
        user: _parseUser(m),
        replyToUser: _parseReplyTo(m),
        content: (m['content'] ?? m['message'] ?? '') as String? ?? '',
        timeAgo: (m['time_ago'] ?? m['time_text'] ?? '') as String? ?? '',
        location: m['location'] as String? ?? m['ip_location'] as String?,
        likeCount: (m['likes'] is int)
            ? m['likes'] as int
            : int.tryParse('${m['like_count'] ?? 0}') ?? 0,
      ),
    );
  }

  final childLists = <String, List<VideoCommentNode>>{};
  final rootOrder = <String>[];

  for (final m in flat) {
    final id = (m['id'] ?? m['comment_id'])?.toString() ?? '';
    if (id.isEmpty) continue;
    final node = byId[id]!.base;
    final p = node.parentId;
    if (p == null || p.isEmpty || !byId.containsKey(p)) {
      if (!rootOrder.contains(id)) rootOrder.add(id);
    } else {
      childLists.putIfAbsent(p, () => []);
      if (!childLists[p]!.any((e) => e.id == id)) {
        childLists[p]!.add(node);
      }
    }
  }

  VideoCommentNode freezeNode(String id) {
    final mut = byId[id]!;
    if (mut.done != null) return mut.done!;
    final ch = childLists[id] ?? const <VideoCommentNode>[];
    final outChildren = <VideoCommentNode>[];
    for (final c in ch) {
      outChildren.add(freezeNode(c.id));
    }
    final n0 = mut.base;
    final done = VideoCommentNode(
      id: n0.id,
      parentId: n0.parentId,
      rootCommentId: n0.rootCommentId,
      user: n0.user,
      replyToUser: n0.replyToUser,
      content: n0.content,
      timeAgo: n0.timeAgo,
      location: n0.location,
      likeCount: n0.likeCount,
      replies: outChildren,
    );
    mut.done = done;
    return done;
  }

  for (final id in byId.keys) {
    final n = byId[id]!.base;
    final p = n.parentId;
    if (p == null || p.isEmpty || !byId.containsKey(p)) {
      freezeNode(id);
    }
  }

  return [for (final id in rootOrder) freezeNode(id)];
}

class _MutableC {
  _MutableC(this.base);
  final VideoCommentNode base;
  VideoCommentNode? done;
}

VideoCommentUser _parseUser(Map<String, dynamic> m) {
  final u = m['user'] ?? m['from_user'] ?? m['author'];
  if (u is Map) {
    return VideoCommentUser.fromJson(Map<String, dynamic>.from(u));
  }
  return const VideoCommentUser(id: '', nickname: '');
}

VideoCommentUser? _parseReplyTo(Map<String, dynamic> m) {
  final rt = m['reply_to_user'] ?? m['reply_to'] ?? m['at_user'];
  if (rt is! Map) return null;
  return VideoCommentUser.fromJson(Map<String, dynamic>.from(rt));
}
