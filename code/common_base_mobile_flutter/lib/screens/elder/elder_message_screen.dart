import 'dart:async';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';
import '../../models/friend_message.dart';
import '../../models/system_notification.dart';
import '../../services/message_service.dart';
import '../../services/notification_service.dart';
import '../../services/medication_service.dart';
import '../../services/websocket_service.dart';
import '../../widgets/notification/notification_helper.dart';
import '../chat/chat_detail_screen.dart';

class ElderMessageScreen extends StatefulWidget {
  const ElderMessageScreen({super.key});

  @override
  State<ElderMessageScreen> createState() => _ElderMessageScreenState();
}

class _ElderMessageScreenState extends State<ElderMessageScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // 消息 tab
  List<ConversationItem> _conversations = [];
  int _chatUnread = 0;

  // 通知 tab
  List<SystemNotification> _notifications = [];
  int _notifUnread = 0;

  bool _isLoading = true;
  StreamSubscription? _wsSub;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
    _wsSub = WebSocketService().chatMessageStream.listen((_) {
      _loadConversations();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _wsSub?.cancel();
    super.dispose();
  }

  Future<void> _loadData() async {
    await Future.wait([_loadConversations(), _loadNotifications()]);
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _loadConversations() async {
    try {
      final res = await MessageService.getConversations();
      final unreadRes = await MessageService.getUnreadCount();
      if (mounted) {
        setState(() {
          _conversations = res.data ?? [];
          _chatUnread = unreadRes.data ?? 0;
        });
      }
    } catch (_) {}
  }

  Future<void> _loadNotifications() async {
    try {
      final notifRes = await NotificationService.getAllNotifications();
      final countRes = await NotificationService.getUnreadCount();
      if (mounted) {
        setState(() {
          _notifications = notifRes.data ?? [];
          _notifUnread = countRes.data ?? 0;
        });
      }
    } catch (_) {}
  }

  Future<void> _markAllNotifRead() async {
    try {
      await NotificationService.markAllAsRead();
      NotificationHelper.showSuccess(message: '已全部标记为已读');
      _loadNotifications();
    } catch (e) {
      NotificationHelper.showError(message: '操作失败');
    }
  }

  Future<void> _handleCheckIn(SystemNotification notification) async {
    try {
      if (notification.relatedId != null) {
        final result = await MedicationService.checkInByNotification(
          notification.id!,
        );
        if (result.isSuccess) {
          NotificationHelper.showSuccess(message: '打卡成功');
          _loadNotifications();
        } else {
          NotificationHelper.showError(message: result.message);
        }
      }
    } catch (e) {
      NotificationHelper.showError(message: '打卡失败：$e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('消息'),
        actions: [
          if (_tabController.index == 1 && _notifUnread > 0)
            TextButton(
              onPressed: _markAllNotifRead,
              child: const Text('全部已读'),
            ),
        ],
        bottom: TabBar(
          controller: _tabController,
          onTap: (_) => setState(() {}),
          tabs: [
            Tab(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('消息'),
                  if (_chatUnread > 0) ...[
                    const SizedBox(width: 6),
                    _badge(_chatUnread, colorScheme),
                  ],
                ],
              ),
            ),
            Tab(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('通知'),
                  if (_notifUnread > 0) ...[
                    const SizedBox(width: 6),
                    _badge(_notifUnread, colorScheme),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildChatsTab(colorScheme),
                _buildNotifTab(colorScheme),
              ],
            ),
    );
  }

  Widget _badge(int count, ColorScheme cs) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: cs.error,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        count > 99 ? '99+' : '$count',
        style: TextStyle(fontSize: 11, color: cs.onError),
      ),
    );
  }

  Widget _buildChatsTab(ColorScheme colorScheme) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (_conversations.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(LucideIcons.messageCircle,
                size: 80,
                color: isDark ? Colors.white24 : Colors.black12),
            const SizedBox(height: 16),
            Text('暂无消息',
                style: TextStyle(
                    fontSize: 18,
                    color: isDark ? Colors.white54 : Colors.black45)),
          ],
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: _loadConversations,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: _conversations.length,
        separatorBuilder: (_, __) => const Divider(height: 1, indent: 72),
        itemBuilder: (_, i) => _buildConversationTile(_conversations[i]),
      ),
    );
  }

  Widget _buildConversationTile(ConversationItem item) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      leading: _buildAvatar(item.friendAvatar, item.friendNickname),
      title: Row(
        children: [
          Expanded(
            child: Text(item.friendNickname,
                style: const TextStyle(
                    fontWeight: FontWeight.w600, fontSize: 16)),
          ),
          if (item.lastMessageTime != null)
            Text(
              _formatTime(item.lastMessageTime!),
              style: TextStyle(
                  fontSize: 12,
                  color: isDark ? Colors.white38 : Colors.black38),
            ),
        ],
      ),
      subtitle: Row(
        children: [
          Expanded(
            child: Text(
              item.lastMessage ?? '',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  fontSize: 13,
                  color: isDark ? Colors.white54 : Colors.black54),
            ),
          ),
          if (item.unreadCount > 0) ...[
            const SizedBox(width: 8),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: colorScheme.error,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                item.unreadCount > 99 ? '99+' : '${item.unreadCount}',
                style: TextStyle(fontSize: 11, color: colorScheme.onError),
              ),
            ),
          ],
        ],
      ),
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ChatDetailScreen(
              friendUserId: item.friendUserId,
              friendNickname: item.friendNickname,
              friendAvatar: item.friendAvatar,
            ),
          ),
        );
        _loadConversations();
      },
    );
  }

  Widget _buildAvatar(String? avatar, String name) {
    if (avatar != null && avatar.isNotEmpty) {
      return CircleAvatar(
        radius: 24,
        child: ClipOval(
          child: Image.network(
            avatar,
            width: 48,
            height: 48,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) =>
                Text(name.isNotEmpty ? name.substring(0, 1) : '?'),
          ),
        ),
      );
    }
    return CircleAvatar(
      radius: 24,
      child: Text(name.isNotEmpty ? name.substring(0, 1) : '?',
          style: const TextStyle(fontSize: 18)),
    );
  }

  Widget _buildNotifTab(ColorScheme colorScheme) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (_notifications.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(LucideIcons.bellOff,
                size: 80,
                color: isDark ? Colors.white24 : Colors.black12),
            const SizedBox(height: 16),
            Text('暂无通知',
                style: TextStyle(
                    fontSize: 18,
                    color: isDark ? Colors.white54 : Colors.black45)),
          ],
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: _loadNotifications,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _notifications.length,
        itemBuilder: (_, i) =>
            _buildNotifCard(_notifications[i], isDark, colorScheme),
      ),
    );
  }

  Widget _buildNotifCard(
      SystemNotification n, bool isDark, ColorScheme cs) {
    IconData icon;
    Color iconColor;
    String typeText;
    if (n.isMedicationReminder) {
      icon = LucideIcons.pill;
      iconColor = Colors.orange;
      typeText = '用药提醒';
    } else if (n.isRemindFromChild) {
      icon = LucideIcons.heart;
      iconColor = Colors.red;
      typeText = '家人提醒';
    } else {
      icon = LucideIcons.bell;
      iconColor = cs.primary;
      typeText = '系统通知';
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: n.isRead ? 0 : 2,
      color: n.isRead ? (isDark ? Colors.grey[900] : Colors.grey[100]) : null,
      child: InkWell(
        onTap: () async {
          if (!n.isRead) {
            await NotificationService.markAsRead(n.id!);
            _loadNotifications();
          }
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: iconColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(icon, color: iconColor, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: [
                          Text(typeText,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w600, fontSize: 15)),
                          if (!n.isRead) ...[
                            const SizedBox(width: 8),
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                  color: cs.primary,
                                  shape: BoxShape.circle),
                            ),
                          ],
                        ]),
                        if (n.createdAt != null)
                          Text(_formatTime(n.createdAt!),
                              style: TextStyle(
                                  fontSize: 12,
                                  color: isDark
                                      ? Colors.white38
                                      : Colors.black38)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(n.title ?? '',
                  style: const TextStyle(
                      fontWeight: FontWeight.w500, fontSize: 16)),
              if (n.content != null) ...[
                const SizedBox(height: 4),
                Text(n.content!,
                    style: TextStyle(
                        fontSize: 14,
                        color: isDark ? Colors.white70 : Colors.black54)),
              ],
              if (n.isMedicationReminder && n.canCheckIn == true) ...[
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _handleCheckIn(n),
                    icon: const Icon(LucideIcons.check, size: 18),
                    label: const Text('已服药，点击打卡'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _formatTime(DateTime t) {
    final now = DateTime.now();
    final diff = now.difference(t);
    if (diff.inMinutes < 60) return '${diff.inMinutes}分钟前';
    if (diff.inHours < 24) return '${diff.inHours}小时前';
    if (diff.inDays < 7) return '${diff.inDays}天前';
    return DateFormat('MM-dd HH:mm').format(t);
  }
}
