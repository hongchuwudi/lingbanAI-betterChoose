import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';
import '../../models/system_notification.dart';
import '../../services/notification_service.dart';
import '../../services/medication_service.dart';
import '../../widgets/notification/notification_helper.dart';

class ElderMessageScreen extends StatefulWidget {
  const ElderMessageScreen({super.key});

  @override
  State<ElderMessageScreen> createState() => _ElderMessageScreenState();
}

class _ElderMessageScreenState extends State<ElderMessageScreen> {
  List<SystemNotification> _notifications = [];
  bool _isLoading = true;
  int _unreadCount = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final notificationsRes = await NotificationService.getAllNotifications();
      final countRes = await NotificationService.getUnreadCount();
      if (mounted) {
        setState(() {
          _notifications = notificationsRes.data ?? [];
          _unreadCount = countRes.data ?? 0;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        NotificationHelper.showError(message: '加载失败：$e');
      }
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
          await _loadData();
        } else {
          NotificationHelper.showError(message: result.message);
        }
      }
    } catch (e) {
      NotificationHelper.showError(message: '打卡失败：$e');
    }
  }

  Future<void> _markAsRead(SystemNotification notification) async {
    if (notification.isRead) return;
    try {
      await NotificationService.markAsRead(notification.id!);
      _loadData();
    } catch (e) {
      NotificationHelper.showError(message: '操作失败');
    }
  }

  Future<void> _markAllAsRead() async {
    try {
      await NotificationService.markAllAsRead();
      NotificationHelper.showSuccess(message: '已全部标记为已读');
      _loadData();
    } catch (e) {
      NotificationHelper.showError(message: '操作失败');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('消息'),
        actions: [
          if (_unreadCount > 0)
            TextButton(onPressed: _markAllAsRead, child: const Text('全部已读')),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _notifications.isEmpty
          ? _buildEmptyState(isDark, colorScheme)
          : RefreshIndicator(
              onRefresh: _loadData,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _notifications.length,
                itemBuilder: (context, index) {
                  return _buildNotificationCard(
                    _notifications[index],
                    isDark,
                    colorScheme,
                  );
                },
              ),
            ),
    );
  }

  Widget _buildEmptyState(bool isDark, ColorScheme colorScheme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            LucideIcons.bellOff,
            size: 80,
            color: isDark ? Colors.white24 : Colors.black12,
          ),
          const SizedBox(height: 16),
          Text(
            '暂无消息',
            style: TextStyle(
              fontSize: 18,
              color: isDark ? Colors.white54 : Colors.black45,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(
    SystemNotification notification,
    bool isDark,
    ColorScheme colorScheme,
  ) {
    final bool isMedication = notification.isMedicationReminder;
    final bool isRemind = notification.isRemindFromChild;

    IconData icon;
    Color iconColor;
    String typeText;

    if (isMedication) {
      icon = LucideIcons.pill;
      iconColor = Colors.orange;
      typeText = '用药提醒';
    } else if (isRemind) {
      icon = LucideIcons.heart;
      iconColor = Colors.red;
      typeText = '家人提醒';
    } else {
      icon = LucideIcons.bell;
      iconColor = colorScheme.primary;
      typeText = '系统通知';
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: notification.isRead ? 0 : 2,
      color: notification.isRead
          ? (isDark ? Colors.grey[900] : Colors.grey[100])
          : null,
      child: InkWell(
        onTap: () => _markAsRead(notification),
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
                        Row(
                          children: [
                            Text(
                              typeText,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                              ),
                            ),
                            if (!notification.isRead) ...[
                              const SizedBox(width: 8),
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: colorScheme.primary,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ],
                          ],
                        ),
                        if (notification.createdAt != null)
                          Text(
                            _formatTime(notification.createdAt!),
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark ? Colors.white38 : Colors.black38,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                notification.title ?? '',
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                ),
              ),
              if (notification.content != null) ...[
                const SizedBox(height: 4),
                Text(
                  notification.content!,
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? Colors.white70 : Colors.black54,
                  ),
                ),
              ],
              if (isMedication && notification.canCheckIn == true) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _handleCheckIn(notification),
                        icon: const Icon(LucideIcons.check, size: 18),
                        label: const Text('已服药，点击打卡'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);

    if (diff.inMinutes < 60) {
      return '${diff.inMinutes}分钟前';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}小时前';
    } else if (diff.inDays < 7) {
      return '${diff.inDays}天前';
    } else {
      return DateFormat('MM-dd HH:mm').format(time);
    }
  }
}
