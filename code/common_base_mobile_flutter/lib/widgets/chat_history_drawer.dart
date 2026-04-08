import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../models/chat_message.dart';
import '../services/chat_service.dart';

class ChatHistoryDrawer extends StatelessWidget {
  final ChatService chatService;
  final VoidCallback onNewChat;
  final VoidCallback onClose;
  final VoidCallback onSessionChanged;

  const ChatHistoryDrawer({
    super.key,
    required this.chatService,
    required this.onNewChat,
    required this.onClose,
    required this.onSessionChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Drawer(
      backgroundColor: isDark ? colorScheme.surface : Colors.white,
      child: SafeArea(
        child: Column(
          children: [
            _buildHeader(context, colorScheme),
            const Divider(height: 1),
            Expanded(
              child: chatService.sessions.isEmpty
                  ? _buildEmptyState(colorScheme)
                  : _buildSessionList(context, colorScheme),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(
            LucideIcons.messageSquarePlus,
            color: colorScheme.primary,
            size: 24,
          ),
          const SizedBox(width: 12),
          Text(
            '对话历史',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
          const Spacer(),
          IconButton(
            onPressed: () {
              onClose();
              onNewChat();
            },
            icon: Icon(LucideIcons.plus, color: colorScheme.primary),
            tooltip: '新建对话',
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(ColorScheme colorScheme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            LucideIcons.messageSquareDashed,
            size: 64,
            color: colorScheme.onSurfaceVariant.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            '暂无对话记录',
            style: TextStyle(
              fontSize: 16,
              color: colorScheme.onSurfaceVariant.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '点击右上角 + 开始新对话',
            style: TextStyle(
              fontSize: 14,
              color: colorScheme.onSurfaceVariant.withOpacity(0.4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSessionList(BuildContext context, ColorScheme colorScheme) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: chatService.sessions.length,
      itemBuilder: (context, index) {
        final session = chatService.sessions[index];
        final isSelected = session.id == chatService.currentSessionId;

        return _buildSessionItem(context, session, isSelected, colorScheme);
      },
    );
  }

  Widget _buildSessionItem(
    BuildContext context,
    ChatSession session,
    bool isSelected,
    ColorScheme colorScheme,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dismissible(
      key: Key(session.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: colorScheme.error,
        child: Icon(LucideIcons.trash2, color: colorScheme.onError),
      ),
      onDismissed: (_) {
        chatService.deleteSession(session.id);
      },
      child: InkWell(
        onTap: () async {
          await chatService.switchSession(session.id);
          onClose();
          onSessionChanged();
        },
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isSelected
                ? colorScheme.primaryContainer.withOpacity(0.3)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: isSelected
                ? Border.all(color: colorScheme.primary.withOpacity(0.3))
                : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      session.title,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.w500,
                        color: isSelected
                            ? colorScheme.primary
                            : colorScheme.onSurface,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    _formatDate(session.updatedAt),
                    style: TextStyle(
                      fontSize: 12,
                      color: colorScheme.onSurfaceVariant.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                session.messages.isNotEmpty
                    ? session.messages.last.content
                    : '暂无消息',
                style: TextStyle(
                  fontSize: 13,
                  color: colorScheme.onSurfaceVariant.withOpacity(0.7),
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                '${session.messages.length} 条消息',
                style: TextStyle(
                  fontSize: 12,
                  color: colorScheme.onSurfaceVariant.withOpacity(0.5),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays == 0) {
      return DateFormat('HH:mm').format(date);
    } else if (diff.inDays == 1) {
      return '昨天';
    } else if (diff.inDays < 7) {
      return '${diff.inDays}天前';
    } else {
      return DateFormat('MM-dd').format(date);
    }
  }
}
