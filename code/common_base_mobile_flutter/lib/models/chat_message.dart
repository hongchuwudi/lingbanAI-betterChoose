import 'package:uuid/uuid.dart';

class ChatMessage {
  final String id;
  final String content;
  final List<String>? imageUrls;
  final String? audioUrl;
  final String? ttsAudioUrl;
  final bool isUser;
  final DateTime timestamp;
  final bool isStreaming;

  ChatMessage({
    String? id,
    required this.content,
    this.imageUrls,
    this.audioUrl,
    this.ttsAudioUrl,
    required this.isUser,
    DateTime? timestamp,
    this.isStreaming = false,
  })  : id = id ?? const Uuid().v4(),
        timestamp = timestamp ?? DateTime.now();

  ChatMessage copyWith({
    String? id,
    String? content,
    List<String>? imageUrls,
    String? audioUrl,
    String? ttsAudioUrl,
    bool? isUser,
    DateTime? timestamp,
    bool? isStreaming,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      content: content ?? this.content,
      imageUrls: imageUrls ?? this.imageUrls,
      audioUrl: audioUrl ?? this.audioUrl,
      ttsAudioUrl: ttsAudioUrl ?? this.ttsAudioUrl,
      isUser: isUser ?? this.isUser,
      timestamp: timestamp ?? this.timestamp,
      isStreaming: isStreaming ?? this.isStreaming,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'imageUrls': imageUrls,
      'audioUrl': audioUrl,
      'ttsAudioUrl': ttsAudioUrl,
      'isUser': isUser,
      'timestamp': timestamp.toIso8601String(),
      'isStreaming': isStreaming,
    };
  }

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'],
      content: json['content'],
      imageUrls: json['imageUrls'] != null
          ? List<String>.from(json['imageUrls'])
          : null,
      audioUrl: json['audioUrl'],
      ttsAudioUrl: json['ttsAudioUrl'],
      isUser: json['isUser'],
      timestamp: DateTime.parse(json['timestamp']),
      isStreaming: json['isStreaming'] ?? false,
    );
  }
}

class ChatSession {
  final String id;
  final String title;
  final List<ChatMessage> messages;
  final DateTime createdAt;
  final DateTime updatedAt;

  ChatSession({
    String? id,
    this.title = '新对话',
    List<ChatMessage>? messages,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : id = id ?? const Uuid().v4(),
        messages = messages ?? [],
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  ChatSession copyWith({
    String? id,
    String? title,
    List<ChatMessage>? messages,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ChatSession(
      id: id ?? this.id,
      title: title ?? this.title,
      messages: messages ?? this.messages,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'messages': messages.map((m) => m.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory ChatSession.fromJson(Map<String, dynamic> json) {
    return ChatSession(
      id: json['id'],
      title: json['title'],
      messages: json['messages'] != null
          ? (json['messages'] as List)
              .map((m) => ChatMessage.fromJson(m))
              .toList()
          : [],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
}
