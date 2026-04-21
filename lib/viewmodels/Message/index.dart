class ContactItem {
  final String name;
  final String avatar;
  final String lastMessage;
  final String lastMessageTime;
  final String unreadCount;

  ContactItem({
    required this.name,
    required this.avatar,
    required this.lastMessage,
    required this.lastMessageTime,
    required this.unreadCount,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'avatar': avatar,
        'lastMessage': lastMessage,
        'lastMessageTime': lastMessageTime,
        'unreadCount': unreadCount,
      };

  factory ContactItem.fromJson(Map<String, dynamic> json) {
    return ContactItem(
      name: json['name'] as String? ?? '',
      avatar: json['avatar'] as String? ?? '',
      lastMessage: json['lastMessage'] as String? ?? '',
      lastMessageTime: json['lastMessageTime'] as String? ?? '',
      unreadCount: json['unreadCount'] as String? ?? '',
    );
  }
}