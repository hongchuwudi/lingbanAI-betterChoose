import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import '../config/app_config.dart';
import '../models/chat_message.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'auth_service.dart';

class ChatService {
  static final ChatService _instance = ChatService._internal();
  factory ChatService() => _instance;
  ChatService._internal();

  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: AppConfig.apiBaseUrl,
      connectTimeout: const Duration(seconds: 60),
      receiveTimeout: const Duration(minutes: 10),
    ),
  );

  CancelToken? _cancelToken;
  List<ChatSession> _sessions = [];
  String? _currentSessionId;
  bool _isCancelled = false;

  List<ChatSession> get sessions => _sessions;
  String? get currentSessionId => _currentSessionId;
  ChatSession? get currentSession =>
      _sessions.where((s) => s.id == _currentSessionId).firstOrNull;

  Future<void> init() async {
    await _loadSessionsFromServer();
    if (_sessions.isEmpty) {
      await createNewSession();
    } else {
      _currentSessionId = _sessions.first.id;
      await _loadSessionMessages(_currentSessionId!);
    }
  }

  Future<void> _loadSessionsFromServer() async {
    try {
      final token = await AuthService.getToken();
      if (token == null || token.isEmpty) {
        print('Token为空，从本地加载会话');
        await _loadSessions();
        return;
      }

      final response = await _dio.get(
        '/ai/conversation/list',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200 && response.data['code'] == 200) {
        final List<dynamic> data = response.data['data'] ?? [];
        _sessions = data.map((j) {
          return ChatSession(
            id: j['conversationId'],
            title: j['title'] ?? '新对话',
            messages: [],
            createdAt: j['createdAt'] != null
                ? DateTime.parse(j['createdAt'])
                : DateTime.now(),
            updatedAt: j['updatedAt'] != null
                ? DateTime.parse(j['updatedAt'])
                : DateTime.now(),
          );
        }).toList();
        print('从服务器加载会话列表成功，数量: ${_sessions.length}');
      } else {
        print('从服务器加载会话失败: ${response.data['message']}');
        await _loadSessions();
      }
    } catch (e) {
      print('从服务器加载会话异常: $e');
      await _loadSessions();
    }
  }

  Future<void> _loadSessions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final sessionsJson = prefs.getString('chat_sessions');
      if (sessionsJson != null) {
        final List<dynamic> decoded = jsonDecode(sessionsJson);
        _sessions = decoded.map((j) => ChatSession.fromJson(j)).toList();
      }
    } catch (e) {
      print('加载会话失败: $e');
    }
  }

  Future<void> _saveSessions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final sessionsJson = jsonEncode(
        _sessions.map((s) => s.toJson()).toList(),
      );
      await prefs.setString('chat_sessions', sessionsJson);
    } catch (e) {
      print('保存会话失败: $e');
    }
  }

  Future<void> createNewSession() async {
    final session = ChatSession();
    _sessions.insert(0, session);
    _currentSessionId = session.id;
    await _saveSessions();
  }

  Future<void> switchSession(String sessionId) async {
    _currentSessionId = sessionId;
    await _loadSessionMessages(sessionId);
  }

  Future<void> _loadSessionMessages(String sessionId) async {
    try {
      final token = await AuthService.getToken();
      if (token == null || token.isEmpty) {
        print('Token为空，无法加载历史消息');
        return;
      }

      final response = await _dio.get(
        '/chat-memory/history/session/$sessionId',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200 && response.data['code'] == 200) {
        final List<dynamic> data = response.data['data'] ?? [];
        final messages = data.map((item) {
          return ChatMessage(
            id:
                item['id']?.toString() ??
                DateTime.now().millisecondsSinceEpoch.toString(),
            content: item['content'] ?? '',
            imageUrls: item['imageUrls'] != null
                ? List<String>.from(item['imageUrls'])
                : null,
            isUser: item['role']?.toLowerCase() == 'user',
            timestamp: item['createdAt'] != null
                ? DateTime.parse(item['createdAt'])
                : DateTime.now(),
            isStreaming: false,
          );
        }).toList();

        final sessionIndex = _sessions.indexWhere((s) => s.id == sessionId);
        if (sessionIndex != -1) {
          _sessions[sessionIndex] = _sessions[sessionIndex].copyWith(
            messages: messages,
          );
          print('加载会话历史消息成功，会话ID: $sessionId, 消息数: ${messages.length}');
        }
      } else {
        print('加载会话历史消息失败: ${response.data['message']}');
      }
    } catch (e) {
      print('加载会话历史消息异常: $e');
    }
  }

  Future<void> deleteSession(String sessionId) async {
    try {
      final token = await AuthService.getToken();
      if (token != null && token.isNotEmpty) {
        await _dio.delete(
          '/ai/conversation/$sessionId',
          options: Options(headers: {'Authorization': 'Bearer $token'}),
        );
        print('从服务器删除会话成功: $sessionId');
      }
    } catch (e) {
      print('从服务器删除会话失败: $e');
    }

    _sessions.removeWhere((s) => s.id == sessionId);
    if (_currentSessionId == sessionId) {
      if (_sessions.isNotEmpty) {
        _currentSessionId = _sessions.first.id;
      } else {
        await createNewSession();
      }
    }
    await _saveSessions();
  }

  Future<void> clearCurrentSession() async {
    final index = _sessions.indexWhere((s) => s.id == _currentSessionId);
    if (index != -1) {
      _sessions[index] = _sessions[index].copyWith(
        messages: [],
        title: '新对话',
        updatedAt: DateTime.now(),
      );
      await _saveSessions();
    }
  }

  void addMessage(ChatMessage message) {
    final index = _sessions.indexWhere((s) => s.id == _currentSessionId);
    if (index != -1) {
      _sessions[index] = _sessions[index].copyWith(
        messages: [..._sessions[index].messages, message],
        updatedAt: DateTime.now(),
      );
      if (_sessions[index].messages.length == 1 && message.isUser) {
        final title = message.content.length > 20
            ? '${message.content.substring(0, 20)}...'
            : message.content;
        _sessions[index] = _sessions[index].copyWith(title: title);
      }
    }
  }

  void updateMessage(String messageId, String newContent, {bool? isStreaming}) {
    final sessionIndex = _sessions.indexWhere((s) => s.id == _currentSessionId);
    if (sessionIndex != -1) {
      final messages = List<ChatMessage>.from(_sessions[sessionIndex].messages);
      final msgIndex = messages.indexWhere((m) => m.id == messageId);
      if (msgIndex != -1) {
        messages[msgIndex] = messages[msgIndex].copyWith(
          content: newContent,
          isStreaming: isStreaming,
        );
        _sessions[sessionIndex] = _sessions[sessionIndex].copyWith(
          messages: messages,
          updatedAt: DateTime.now(),
        );
      }
    }
  }

  void updateSessionMessages(int sessionIndex, List<ChatMessage> messages) {
    if (sessionIndex >= 0 && sessionIndex < _sessions.length) {
      _sessions[sessionIndex] = _sessions[sessionIndex].copyWith(
        messages: messages,
        updatedAt: DateTime.now(),
      );
    }
  }

  void stopStreaming() {
    _isCancelled = true;
    _cancelToken?.cancel('用户取消');
    _cancelToken = null;
  }

  Stream<String> sendMessage({
    required String prompt,
    required String chatId,
    List<XFile>? images,
  }) async* {
    _isCancelled = false;
    _cancelToken = CancelToken();

    List<String> ossImageUrls = [];

    if (images != null && images.isNotEmpty) {
      for (final image in images) {
        try {
          final result = await AuthService.uploadFile(image, bizType: 'chat');
          if (result['success'] == true && result['data'] != null) {
            final fileUrl = result['data']['fileUrl'] as String;
            ossImageUrls.add(fileUrl);
            print('上传聊天图片成功: $fileUrl');
          } else {
            print('上传聊天图片失败: ${result['message']}');
          }
        } catch (e) {
          print('上传聊天图片异常: $e');
        }
      }
    }

    _lastUploadedImageUrls = ossImageUrls;

    try {
      final token = await AuthService.getToken();
      final uri = Uri.parse('${AppConfig.apiBaseUrl}/ai/chat');
      final request = http.StreamedRequest('POST', uri);

      final boundary =
          '----FlutterFormBoundary${DateTime.now().millisecondsSinceEpoch}';
      request.headers['Content-Type'] =
          'multipart/form-data; boundary=$boundary';
      request.headers['Accept'] = 'text/event-stream';
      if (token != null && token.isNotEmpty) {
        request.headers['Authorization'] = 'Bearer $token';
      }

      final body = <Uint8List>[];

      void addField(String name, String value) {
        body.add(utf8.encode('--$boundary\r\n'));
        body.add(
          utf8.encode('Content-Disposition: form-data; name="$name"\r\n\r\n'),
        );
        body.add(utf8.encode('$value\r\n'));
      }

      void addFile(
        String name,
        String filename,
        Uint8List bytes,
        String contentType,
      ) {
        body.add(utf8.encode('--$boundary\r\n'));
        body.add(
          utf8.encode(
            'Content-Disposition: form-data; name="$name"; filename="$filename"\r\n',
          ),
        );
        body.add(utf8.encode('Content-Type: $contentType\r\n\r\n'));
        body.add(bytes);
        body.add(utf8.encode('\r\n'));
      }

      addField('prompt', prompt);
      addField('chatId', chatId);

      if (images != null && images.isNotEmpty) {
        for (final image in images) {
          final bytes = await image.readAsBytes();
          final contentType = image.mimeType ?? 'image/jpeg';
          addFile('files', image.name, bytes, contentType);
        }
      }

      body.add(utf8.encode('--$boundary--\r\n'));

      final fullBody = Uint8List.fromList(body.expand((e) => e).toList());
      request.contentLength = fullBody.length;

      request.sink.add(fullBody);
      request.sink.close();

      final response = await http.Client().send(request);

      if (response.statusCode != 200) {
        yield '[ERROR: HTTP ${response.statusCode}]';
        return;
      }

      String buffer = '';

      await for (final chunk in response.stream) {
        if (_isCancelled) {
          yield '[CANCELLED]';
          return;
        }

        buffer += utf8.decode(chunk);

        while (buffer.contains('\n')) {
          final index = buffer.indexOf('\n');
          final line = buffer.substring(0, index).trim();
          buffer = buffer.substring(index + 1);

          if (line.isEmpty) continue;

          String content;
          if (line.startsWith('data:')) {
            content = line.substring(5).trim();
          } else {
            content = line.trim();
          }

          if (content.isNotEmpty) {
            yield content;
          }
        }
      }

      if (buffer.trim().isNotEmpty) {
        final line = buffer.trim();
        if (line.startsWith('data:')) {
          final content = line.substring(5).trim();
          if (content.isNotEmpty) {
            yield content;
          }
        } else if (line.isNotEmpty) {
          yield line;
        }
      }
    } catch (e) {
      if (_isCancelled) {
        yield '[CANCELLED]';
      } else {
        yield '[ERROR: $e]';
      }
    } finally {
      _cancelToken = null;
    }
  }

  List<String> get lastUploadedImageUrls => _lastUploadedImageUrls;
  static List<String> _lastUploadedImageUrls = [];

  Future<void> saveSessions() async {
    await _saveSessions();
  }

  Future<void> refreshSessions() async {
    await _loadSessionsFromServer();
  }

  void dispose() {
    _cancelToken?.cancel('dispose');
    _cancelToken = null;
    _isCancelled = true;
  }
}
