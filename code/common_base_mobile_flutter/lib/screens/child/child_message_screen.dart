import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';
import '../../models/system_notification.dart';
import '../../models/medication_record.dart';
import '../../models/user.dart';
import '../../services/notification_service.dart';
import '../../services/medication_service.dart';
import '../../services/family_service.dart';
import '../../widgets/notification/notification_helper.dart';

class ChildMessageScreen extends StatefulWidget {
  const ChildMessageScreen({super.key});

  @override
  State<ChildMessageScreen> createState() => _ChildMessageScreenState();
}

class _ChildMessageScreenState extends State<ChildMessageScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<SystemNotification> _notifications = [];
  List<FamilyBinding> _familyMembers = [];
  Map<String, List<MedicationRecord>> _elderlyRecords = {};
  bool _isLoading = true;
  int _unreadCount = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    try {
      final notificationsRes = await NotificationService.getAllNotifications();
      final countRes = await NotificationService.getUnreadCount();
      final relationsRes = await FamilyService.getMyRelations();

      Map<String, List<MedicationRecord>> records = {};
      final relations = relationsRes.data ?? [];
      for (var binding in relations) {
        if (binding.myRole == 'child' && binding.elderlyProfileId != null) {
          try {
            final elderlyRecordsRes =
                await MedicationService.getElderlyRecordsByDate(
                  binding.elderlyProfileId!,
                  DateTime.now(),
                );
            records[binding.elderlyProfileId!] = elderlyRecordsRes.data ?? [];
          } catch (e) {
            records[binding.elderlyProfileId!] = [];
          }
        }
      }

      if (mounted) {
        setState(() {
          _notifications = notificationsRes.data ?? [];
          _unreadCount = countRes.data ?? 0;
          _familyMembers = relations.where((b) => b.myRole == 'child').toList();
          _elderlyRecords = records;
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

  Future<void> _remindElderly(String elderlyProfileId) async {
    try {
      final result = await MedicationService.remindElderly(elderlyProfileId);
      if (result.isSuccess) {
        NotificationHelper.showSuccess(message: '提醒已发送');
      } else {
        NotificationHelper.showError(message: result.message);
      }
    } catch (e) {
      NotificationHelper.showError(message: '发送失败：$e');
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
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: '通知消息'),
            Tab(text: '老人用药'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildNotificationTab(isDark, colorScheme),
                _buildMedicationTab(isDark, colorScheme),
              ],
            ),
    );
  }

  Widget _buildNotificationTab(bool isDark, ColorScheme colorScheme) {
    if (_notifications.isEmpty) {
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

    return RefreshIndicator(
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
    );
  }

  Widget _buildMedicationTab(bool isDark, ColorScheme colorScheme) {
    if (_familyMembers.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              LucideIcons.users,
              size: 80,
              color: isDark ? Colors.white24 : Colors.black12,
            ),
            const SizedBox(height: 16),
            Text(
              '暂无关联老人',
              style: TextStyle(
                fontSize: 18,
                color: isDark ? Colors.white54 : Colors.black45,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _familyMembers.length,
        itemBuilder: (context, index) {
          final binding = _familyMembers[index];
          final records = _elderlyRecords[binding.elderlyProfileId] ?? [];
          return _buildElderlyCard(binding, records, isDark, colorScheme);
        },
      ),
    );
  }

  Widget _buildElderlyCard(
    FamilyBinding binding,
    List<MedicationRecord> records,
    bool isDark,
    ColorScheme colorScheme,
  ) {
    final checkedCount = records.where((r) => r.isCheckedIn).length;
    final totalCount = records.length;
    final allChecked = totalCount > 0 && checkedCount == totalCount;

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
                  backgroundImage: binding.elderlyAvatar != null
                      ? NetworkImage(binding.elderlyAvatar!)
                      : null,
                  child: binding.elderlyAvatar == null
                      ? Text(binding.elderlyName?.substring(0, 1) ?? '老')
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        binding.elderlyName ?? '老人',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        '今日用药：$checkedCount/$totalCount',
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark ? Colors.white54 : Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: allChecked
                        ? Colors.green.withValues(alpha: 0.1)
                        : Colors.orange.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    allChecked ? '已完成' : '待完成',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: allChecked ? Colors.green : Colors.orange,
                    ),
                  ),
                ),
              ],
            ),
            if (records.isNotEmpty) ...[
              const Divider(height: 24),
              ...records
                  .take(3)
                  .map((record) => _buildRecordItem(record, isDark)),
              if (records.length > 3)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    '还有 ${records.length - 3} 条记录...',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.white38 : Colors.black38,
                    ),
                  ),
                ),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _remindElderly(binding.elderlyProfileId!),
                    icon: const Icon(LucideIcons.bell, size: 18),
                    label: const Text('提醒服药'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: colorScheme.primary,
                      side: BorderSide(color: colorScheme.primary),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecordItem(MedicationRecord record, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(
            record.isCheckedIn ? LucideIcons.checkCircle2 : LucideIcons.circle,
            size: 18,
            color: record.isCheckedIn
                ? Colors.green
                : (record.isMissed ? Colors.red : Colors.orange),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              record.drugName ?? '药品',
              style: const TextStyle(fontSize: 14),
            ),
          ),
          Text(
            record.scheduledTime != null
                ? DateFormat('HH:mm').format(record.scheduledTime!)
                : '',
            style: TextStyle(
              fontSize: 12,
              color: isDark ? Colors.white54 : Colors.black54,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: record.isCheckedIn
                  ? Colors.green.withValues(alpha: 0.1)
                  : (record.isMissed
                        ? Colors.red.withValues(alpha: 0.1)
                        : Colors.orange.withValues(alpha: 0.1)),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              record.statusText,
              style: TextStyle(
                fontSize: 11,
                color: record.isCheckedIn
                    ? Colors.green
                    : (record.isMissed ? Colors.red : Colors.orange),
              ),
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
    IconData icon;
    Color iconColor;
    String typeText;

    if (notification.isMedicationReminder) {
      icon = LucideIcons.pill;
      iconColor = Colors.orange;
      typeText = '用药提醒';
    } else if (notification.isRemindFromChild) {
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
