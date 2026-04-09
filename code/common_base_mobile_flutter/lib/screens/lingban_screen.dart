import 'dart:async';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import '../models/chat_message.dart';
import '../services/chat_service.dart';
import '../widgets/chat_bubble.dart';
import '../widgets/chat_history_drawer.dart';
import '../widgets/chat_input_bar.dart';
import 'voice_call_screen.dart';

class LingbanScreen extends StatefulWidget {
  const LingbanScreen({super.key});

  @override
  State<LingbanScreen> createState() => _LingbanScreenState();
}

class _LingbanScreenState extends State<LingbanScreen>
    with TickerProviderStateMixin {
  final ChatService _chatService = ChatService();
  final ScrollController _scrollController = ScrollController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  bool _isStreaming = false;
  String? _streamingMessageId;
  late AnimationController _fadeController;
  StreamSubscription<String>? _streamSubscription;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _initChat();
  }

  Future<void> _initChat() async {
    await _chatService.init();
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _streamSubscription?.cancel();
    _fadeController.dispose();
    _scrollController.dispose();
    _chatService.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _handleSend(String text, List<XFile>? images) async {
    if (text.isEmpty && (images == null || images.isEmpty)) return;

    final userMessage = ChatMessage(
      content: text,
      imageUrls: images?.map((x) => x.path).toList(),
      isUser: true,
    );

    if (!mounted) return;
    setState(() {
      _chatService.addMessage(userMessage);
    });

    _scrollToBottom();

    final aiMessage = ChatMessage(
      content: '',
      isUser: false,
      isStreaming: true,
    );

    if (!mounted) return;
    setState(() {
      _chatService.addMessage(aiMessage);
      _isStreaming = true;
      _streamingMessageId = aiMessage.id;
    });

    _scrollToBottom();

    final stream = _chatService.sendMessage(
      prompt: text,
      chatId: _chatService.currentSessionId!,
      images: images,
    );

    String fullContent = '';

    _streamSubscription = stream.listen(
      (chunk) {
        if (!mounted) return;

        if (chunk == '[CANCELLED]') {
          return;
        } else if (chunk.startsWith('[ERROR:')) {
          fullContent = '抱歉，发生了错误：${chunk.substring(8, chunk.length - 1)}';
          _finishStreaming(aiMessage.id, fullContent);
          return;
        }

        fullContent += chunk;

        setState(() {
          _chatService.updateMessage(
            aiMessage.id,
            fullContent,
            isStreaming: true,
          );
        });
        _scrollToBottom();
      },
      onDone: () {
        if (!mounted) return;
        _finishStreaming(aiMessage.id, fullContent);
      },
      onError: (error) {
        if (!mounted) return;
        _finishStreaming(aiMessage.id, '抱歉，发生了错误：$error');
      },
    );
  }

  void _finishStreaming(String messageId, String content) {
    if (!mounted) return;

    setState(() {
      _chatService.updateMessage(messageId, content, isStreaming: false);
      if (_chatService.lastUploadedImageUrls.isNotEmpty) {
        final userMsgId = _chatService.currentSession?.messages
            .firstWhere(
              (m) => m.id != messageId && m.imageUrls?.isNotEmpty == true,
              orElse: () => ChatMessage(content: '', isUser: true),
            )
            .id;
        if (userMsgId != null && userMsgId.isNotEmpty) {
          _updateUserMessageImageUrls(
            userMsgId,
            _chatService.lastUploadedImageUrls,
          );
        }
      }
      _isStreaming = false;
      _streamingMessageId = null;
    });
    _chatService.saveSessions();
  }

  void _updateUserMessageImageUrls(String messageId, List<String> ossUrls) {
    if (messageId.isEmpty) return;
    final sessionIndex = _chatService.sessions.indexWhere(
      (s) => s.id == _chatService.currentSessionId,
    );
    if (sessionIndex != -1) {
      final messages = List<ChatMessage>.from(
        _chatService.sessions[sessionIndex].messages,
      );
      final msgIndex = messages.indexWhere((m) => m.id == messageId);
      if (msgIndex != -1) {
        messages[msgIndex] = messages[msgIndex].copyWith(imageUrls: ossUrls);
        _chatService.updateSessionMessages(sessionIndex, messages);
      }
    }
  }

  void _handleStop() {
    _streamSubscription?.cancel();
    _chatService.stopStreaming();
    if (!mounted) return;
    setState(() {
      _isStreaming = false;
      if (_streamingMessageId != null) {
        final currentContent = _chatService.currentSession?.messages
                .firstWhere((m) => m.id == _streamingMessageId)
                .content ??
            '';
        _chatService.updateMessage(
          _streamingMessageId!,
          '$currentContent\n\n[已停止]',
          isStreaming: false,
        );
        _streamingMessageId = null;
      }
    });
  }

  void _handleNewChat() async {
    await _chatService.createNewSession();
    if (mounted) {
      setState(() {});
    }
  }

  void _handleClearChat() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('清空对话'),
        content: const Text('确定要清空当前对话吗？此操作不可撤销。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _chatService.clearCurrentSession();
              if (mounted) {
                setState(() {});
              }
            },
            child: Text(
              '清空',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        ],
      ),
    );
  }

  void _openVoiceCall() async {
    final result = await Navigator.push<List<ChatMessage>>(
      context,
      MaterialPageRoute(
        builder: (context) => VoiceCallScreen(
          sessionId: _chatService.currentSessionId,
          existingMessages: _chatService.currentSession?.messages,
        ),
        fullscreenDialog: true,
      ),
    );

    if (result != null && mounted) {
      await _chatService.refreshCurrentSession();
      if (mounted) setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor:
          isDark ? const Color(0xFF1E1E1E) : const Color(0xFFF5F5F5),
      drawer: ChatHistoryDrawer(
        chatService: _chatService,
        onNewChat: _handleNewChat,
        onClose: () => _scaffoldKey.currentState?.closeDrawer(),
        onSessionChanged: () {
          if (mounted) setState(() {});
        },
      ),
      appBar: _buildAppBar(colorScheme, isDark),
      body: Column(
        children: [
          Expanded(child: _buildMessageList(colorScheme, isDark)),
          ChatInputBar(
            onSend: _handleSend,
            onStop: _handleStop,
            isStreaming: _isStreaming,
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(ColorScheme colorScheme, bool isDark) {
    return AppBar(
      backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: Icon(LucideIcons.panel_left, color: colorScheme.onSurface),
        onPressed: () => _scaffoldKey.currentState?.openDrawer(),
      ),
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(LucideIcons.sparkles, color: colorScheme.primary, size: 24),
          const SizedBox(width: 8),
          Text(
            '灵伴',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
        ],
      ),
      centerTitle: true,
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 4),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                colorScheme.primaryContainer,
                colorScheme.primaryContainer.withOpacity(0.7),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: IconButton(
            icon: Icon(
              LucideIcons.phone,
              color: colorScheme.onPrimaryContainer,
              size: 20,
            ),
            onPressed: _openVoiceCall,
            tooltip: '语音对话',
          ),
        ),
        PopupMenuButton<String>(
          icon: Icon(LucideIcons.ellipsis, color: colorScheme.onSurface),
          onSelected: (value) {
            switch (value) {
              case 'new':
                _handleNewChat();
                break;
              case 'clear':
                _handleClearChat();
                break;
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'new',
              child: Row(
                children: [
                  Icon(LucideIcons.plus, size: 20),
                  SizedBox(width: 12),
                  Text('新建对话'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'clear',
              child: Row(
                children: [
                  Icon(LucideIcons.trash_2, size: 20),
                  SizedBox(width: 12),
                  Text('清空对话'),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMessageList(ColorScheme colorScheme, bool isDark) {
    final messages = _chatService.currentSession?.messages ?? [];

    if (messages.isEmpty) {
      return _buildEmptyState(colorScheme, isDark);
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final message = messages[index];
        final showTimestamp = index == 0 ||
            messages[index - 1]
                    .timestamp
                    .difference(message.timestamp)
                    .inMinutes
                    .abs() >
                5;

        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: 1),
          duration: const Duration(milliseconds: 300),
          builder: (context, value, child) {
            return Opacity(
              opacity: value,
              child: Transform.translate(
                offset: Offset(0, 20 * (1 - value)),
                child: child,
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: ChatBubble(
              message: message,
              showTimestamp: showTimestamp,
              onSynthesizeSpeech: _chatService.synthesizeSpeech,
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(ColorScheme colorScheme, bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer,
              shape: BoxShape.circle,
            ),
            child: ClipOval(
              child: Image.asset('assets/ai_chat_logo.png', fit: BoxFit.cover),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            '你好，我是灵伴',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '有什么可以帮助你的吗？',
            style: TextStyle(fontSize: 16, color: colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: 32),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            alignment: WrapAlignment.center,
            children: [
              _buildSuggestionChip(
                '今天天气怎么样？',
                colorScheme,
                () => _handleSend('今天天气怎么样？', null),
              ),
              _buildSuggestionChip(
                '今日养生建议',
                colorScheme,
                () => _handleSend('今日养生建议', null),
              ),
              _buildSuggestionChip(
                '高血压怎么管理？',
                colorScheme,
                () => _handleSend('高血压怎么管理？', null),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestionChip(
    String text,
    ColorScheme colorScheme,
    VoidCallback onTap,
  ) {
    return ActionChip(
      label: Text(text),
      backgroundColor: colorScheme.surfaceContainerHighest,
      labelStyle: TextStyle(color: colorScheme.onSurface, fontSize: 14),
      side: BorderSide.none,
      onPressed: onTap,
    );
  }
}
