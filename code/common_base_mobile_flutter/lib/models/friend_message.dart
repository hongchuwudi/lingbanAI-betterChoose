class FriendMessage {
  final String id;
  final String fromUserId;
  final String toUserId;
  final String content;
  final String messageType;
  final int status;
  final DateTime? createdAt;
  final bool isMine;

  FriendMessage({
    required this.id,
    required this.fromUserId,
    required this.toUserId,
    required this.content,
    required this.messageType,
    required this.status,
    this.createdAt,
    required this.isMine,
  });

  factory FriendMessage.fromJson(Map<String, dynamic> json) {
    return FriendMessage(
      id: json['id']?.toString() ?? '',
      fromUserId: json['fromUserId']?.toString() ?? '',
      toUserId: json['toUserId']?.toString() ?? '',
      content: json['content'] ?? '',
      messageType: json['messageType'] ?? 'text',
      status: json['status'] ?? 0,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
      isMine: json['isMine'] ?? false,
    );
  }
}

class ConversationItem {
  final String friendUserId;
  final String friendNickname;
  final String? friendAvatar;
  final String? lastMessage;
  final DateTime? lastMessageTime;
  final int unreadCount;

  ConversationItem({
    required this.friendUserId,
    required this.friendNickname,
    this.friendAvatar,
    this.lastMessage,
    this.lastMessageTime,
    required this.unreadCount,
  });

  factory ConversationItem.fromJson(Map<String, dynamic> json) {
    return ConversationItem(
      friendUserId: json['friendUserId']?.toString() ?? '',
      friendNickname: json['friendNickname'] ?? '',
      friendAvatar: json['friendAvatar'],
      lastMessage: json['lastMessage'],
      lastMessageTime: json['lastMessageTime'] != null
          ? DateTime.tryParse(json['lastMessageTime'].toString())
          : null,
      unreadCount: json['unreadCount'] ?? 0,
    );
  }
}
