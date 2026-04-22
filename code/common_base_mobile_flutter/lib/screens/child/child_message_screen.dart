import 'dart:async';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';
import '../../models/friend_message.dart';
import '../../models/system_notification.dart';
import '../../models/medication_record.dart';
import '../../models/user.dart';
import '../../services/message_service.dart';
import '../../services/notification_service.dart';
import '../../services/medication_service.dart';
import '../../services/family_service.dart';
import '../../services/websocket_service.dart';
import '../../widgets/notification/notification_helper.dart';
import '../chat/chat_detail_screen.dart';

class ChildMessageScreen extends StatefulWidget {
  const ChildMessageScreen({super.key});

  @override
  State<ChildMessageScreen> createState() => _ChildMessageScreenState();
}

class _ChildMessageScreenState extends State<ChildMessageScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // 消息 tab
  List<ConversationItem> _conversations = [];
  int _chatUnread = 0;

  // 通知 tab
  List<SystemNotification> _notifications = [];
  int _notifUnread = 0;

  // 老人用药 tab
  List<FamilyBinding> _familyMembers = [];
  Map<String, List<MedicationRecord>> _elderlyRecords = {};

  bool _isLoading = true;
  StreamSubscription? _wsSub;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
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
    await Future.wait([
      _loadConversations(),
      _loadNotifications(),
      _loadMedicationData(),
    ]);
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
      final res = await NotificationService.getAllNotifications();
      final countRes = await NotificationService.getUnreadCount();
      if (mounted) {
        setState(() {
          _notifications = res.data ?? [];
          _notifUnread = countRes.data ?? 0;
        });
      }
    } catch (_) {}
  }

  Future<void> _loadMedicationData() async {
    try {
      final relRes = await FamilyService.getMyRelations();
      final relations = relRes.data ?? [];
      final members =
          relations.where((b) => b.myRole == 'child').toList();

      final Map<String, List<MedicationRecord>> records = {};
      for (final b in members) {
        if (b.elderlyProfileId != null) {
          try {
            final r = await MedicationService.getElderlyRecordsByDate(
              b.elderlyProfileId!,
              DateTime.now(),
            );
            records[b.elderlyProfileId!] = r.data ?? [];
          } catch (_) {
            records[b.elderlyProfileId!] = [];
          }
        }
      }
      if (mounted) {
        setState(() {
          _familyMembers = members;
          _elderlyRecords = records;
        });
      }
    } catch (_) {}
  }

  Future<void> _markAllNotifRead() async {
    try {
      await NotificationService.markAllAsRead();
      NotificationHelper.showSuccess(message: '已全部标记为已读');
      _loadNotifications();
    } catch (_) {
      NotificationHelper.showError(message: '操作失败');
    }
  }

  Future<void> _remindElderly(String elderlyProfileId) async {
    try {
      final res = await MedicationService.remindElderly(elderlyProfileId);
      if (res.isSuccess) {
        NotificationHelper.showSuccess(message: '提醒已发送');
      } else {
        NotificationHelper.showError(message: res.message);
      }
    } catch (e) {
      NotificationHelper.showError(message: '发送失败：$e');
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
            const Tab(text: '老人用药'),
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
                _buildMedTab(colorScheme),
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
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMedTab(ColorScheme colorScheme) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (_familyMembers.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(LucideIcons.users,
                size: 80,
                color: isDark ? Colors.white24 : Colors.black12),
            const SizedBox(height: 16),
            Text('暂无关联老人',
                style: TextStyle(
                    fontSize: 18,
                    color: isDark ? Colors.white54 : Colors.black45)),
          ],
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: _loadMedicationData,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _familyMembers.length,
        itemBuilder: (_, i) {
          final b = _familyMembers[i];
          final recs = _elderlyRecords[b.elderlyProfileId] ?? [];
          return _buildElderlyCard(b, recs, isDark, colorScheme);
        },
      ),
    );
  }

  Widget _buildElderlyCard(
    FamilyBinding b,
    List<MedicationRecord> recs,
    bool isDark,
    ColorScheme cs,
  ) {
    final checked = recs.where((r) => r.isCheckedIn).length;
    final total = recs.length;
    final allDone = total > 0 && checked == total;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  child: ClipOval(
                    child: b.elderlyAvatar != null &&
                            b.elderlyAvatar!.isNotEmpty
                        ? Image.network(
                            b.elderlyAvatar!,
                            width: 48,
                            height: 48,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Text(
                              b.elderlyName?.substring(0, 1) ?? '老',
                              style: const TextStyle(fontSize: 18),
                            ),
                          )
                        : Text(
                            b.elderlyName?.substring(0, 1) ?? '老',
                            style: const TextStyle(fontSize: 18),
                          ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(b.elderlyName ?? '老人',
                          style: const TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 16)),
                      Text('今日用药：$checked/$total',
                          style: TextStyle(
                              fontSize: 13,
                              color:
                                  isDark ? Colors.white54 : Colors.black54)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: allDone
                        ? Colors.green.withValues(alpha: 0.1)
                        : Colors.orange.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(allDone ? '已完成' : '待完成',
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: allDone ? Colors.green : Colors.orange)),
                ),
              ],
            ),
            if (recs.isNotEmpty) ...[
              const Divider(height: 24),
              ...recs.take(3).map((r) => _buildRecordItem(r, isDark)),
              if (recs.length > 3)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text('还有 ${recs.length - 3} 条记录...',
                      style: TextStyle(
                          fontSize: 12,
                          color: isDark
                              ? Colors.white38
                              : Colors.black38)),
                ),
            ],
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () =>
                    _remindElderly(b.elderlyProfileId!),
                icon: const Icon(LucideIcons.bell, size: 18),
                label: const Text('提醒服药'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: cs.primary,
                  side: BorderSide(color: cs.primary),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecordItem(MedicationRecord r, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(
            r.isCheckedIn ? LucideIcons.checkCircle2 : LucideIcons.circle,
            size: 18,
            color: r.isCheckedIn
                ? Colors.green
                : (r.isMissed ? Colors.red : Colors.orange),
          ),
          const SizedBox(width: 8),
          Expanded(
              child: Text(r.drugName ?? '药品',
                  style: const TextStyle(fontSize: 14))),
          Text(
            r.scheduledTime != null
                ? DateFormat('HH:mm').format(r.scheduledTime!)
                : '',
            style: TextStyle(
                fontSize: 12,
                color: isDark ? Colors.white54 : Colors.black54),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: r.isCheckedIn
                  ? Colors.green.withValues(alpha: 0.1)
                  : (r.isMissed
                      ? Colors.red.withValues(alpha: 0.1)
                      : Colors.orange.withValues(alpha: 0.1)),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              r.statusText,
              style: TextStyle(
                  fontSize: 11,
                  color: r.isCheckedIn
                      ? Colors.green
                      : (r.isMissed ? Colors.red : Colors.orange)),
            ),
          ),
        ],
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
