import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/friend_message.dart';
import '../../services/message_service.dart';
import '../../services/websocket_service.dart';
import '../../widgets/notification/notification_helper.dart';

class ChatDetailScreen extends StatefulWidget {
  final String friendUserId;
  final String friendNickname;
  final String? friendAvatar;

  const ChatDetailScreen({
    super.key,
    required this.friendUserId,
    required this.friendNickname,
    this.friendAvatar,
  });

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final List<FriendMessage> _messages = [];
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = true;
  bool _isSending = false;
  StreamSubscription? _wsSub;

  @override
  void initState() {
    super.initState();
    WebSocketService().activeChatUserId = widget.friendUserId;
    _loadHistory();
    _wsSub = WebSocketService().chatMessageStream.listen(_onIncomingMessage);
  }

  @override
  void dispose() {
    WebSocketService().activeChatUserId = null;
    _wsSub?.cancel();
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadHistory() async {
    try {
      final res = await MessageService.getHistory(
        friendUserId: widget.friendUserId,
      );
      if (mounted) {
        setState(() {
          _messages.clear();
          _messages.addAll(res.data ?? []);
          _isLoading = false;
        });
        _scrollToBottom();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _onIncomingMessage(Map<String, dynamic> data) {
    if (data['fromUserId'] != widget.friendUserId) return;
    final msg = FriendMessage(
      id: data['messageId'] ?? '',
      fromUserId: data['fromUserId'] ?? '',
      toUserId: '',
      content: data['content'] ?? '',
      messageType: 'text',
      status: 0,
      createdAt: DateTime.tryParse(data['createdAt'] ?? ''),
      isMine: false,
    );
    if (mounted) {
      setState(() => _messages.add(msg));
      _scrollToBottom();
    }
    MessageService.markRead(widget.friendUserId);
  }

  Future<void> _sendMessage() async {
    final content = _inputController.text.trim();
    if (content.isEmpty || _isSending) return;
    setState(() => _isSending = true);
    _inputController.clear();
    try {
      final res = await MessageService.sendMessage(
        toUserId: widget.friendUserId,
        content: content,
      );
      if (res.isSuccess && res.data != null) {
        if (mounted) {
          setState(() => _messages.add(res.data!));
          _scrollToBottom();
        }
      } else {
        NotificationHelper.showError(message: res.message);
        _inputController.text = content;
      }
    } catch (e) {
      NotificationHelper.showError(message: '发送失败');
      _inputController.text = content;
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            _buildAvatar(widget.friendAvatar, widget.friendNickname, 18),
            const SizedBox(width: 10),
            Text(widget.friendNickname, style: const TextStyle(fontSize: 17)),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _messages.isEmpty
                    ? Center(
                        child: Text(
                          '暂无消息，发送第一条消息吧',
                          style: TextStyle(
                            color: isDark ? Colors.white38 : Colors.black38,
                          ),
                        ),
                      )
                    : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        itemCount: _messages.length,
                        itemBuilder: (context, index) {
                          return _buildMessageBubble(
                            _messages[index],
                            colorScheme,
                            isDark,
                          );
                        },
                      ),
          ),
          _buildInputBar(colorScheme),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(
    FriendMessage msg,
    ColorScheme colorScheme,
    bool isDark,
  ) {
    final isMine = msg.isMine;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment:
            isMine ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMine) ...[
            _buildAvatar(widget.friendAvatar, widget.friendNickname, 16),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment:
                  isMine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Container(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.65,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: isMine
                        ? colorScheme.primary
                        : (isDark ? Colors.grey[800] : Colors.grey[200]),
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(16),
                      topRight: const Radius.circular(16),
                      bottomLeft: Radius.circular(isMine ? 16 : 4),
                      bottomRight: Radius.circular(isMine ? 4 : 16),
                    ),
                  ),
                  child: Text(
                    msg.content,
                    style: TextStyle(
                      fontSize: 15,
                      color: isMine
                          ? colorScheme.onPrimary
                          : colorScheme.onSurface,
                    ),
                  ),
                ),
                if (msg.createdAt != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 3),
                    child: Text(
                      _formatTime(msg.createdAt!),
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark ? Colors.white38 : Colors.black38,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          if (isMine) const SizedBox(width: 8),
        ],
      ),
    );
  }

  Widget _buildAvatar(String? avatar, String name, double radius) {
    if (avatar != null && avatar.isNotEmpty) {
      return CircleAvatar(
        radius: radius,
        child: ClipOval(
          child: Image.network(
            avatar,
            width: radius * 2,
            height: radius * 2,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => _textAvatar(name, radius),
          ),
        ),
      );
    }
    return CircleAvatar(
      radius: radius,
      child: _textAvatar(name, radius),
    );
  }

  Widget _textAvatar(String name, double radius) {
    return Text(
      name.isNotEmpty ? name.substring(0, 1) : '?',
      style: TextStyle(fontSize: radius * 0.8),
    );
  }

  Widget _buildInputBar(ColorScheme colorScheme) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          border: Border(
            top: BorderSide(
              color: colorScheme.outlineVariant.withValues(alpha: 0.3),
            ),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _inputController,
                decoration: InputDecoration(
                  hintText: '输入消息...',
                  filled: true,
                  fillColor:
                      colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                ),
                maxLines: 4,
                minLines: 1,
                textInputAction: TextInputAction.newline,
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
            const SizedBox(width: 8),
            _isSending
                ? const SizedBox(
                    width: 40,
                    height: 40,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : IconButton(
                    onPressed: _sendMessage,
                    icon: Icon(Icons.send_rounded, color: colorScheme.primary),
                    style: IconButton.styleFrom(
                      backgroundColor:
                          colorScheme.primary.withValues(alpha: 0.1),
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime t) {
    final now = DateTime.now();
    if (now.difference(t).inDays == 0) {
      return DateFormat('HH:mm').format(t);
    } else if (now.difference(t).inDays < 7) {
      return DateFormat('MM-dd HH:mm').format(t);
    }
    return DateFormat('yyyy-MM-dd HH:mm').format(t);
  }
}
