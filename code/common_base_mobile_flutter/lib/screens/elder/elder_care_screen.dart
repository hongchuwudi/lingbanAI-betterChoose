import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import '../../models/user.dart';
import '../../models/system_notification.dart';
import '../../providers/auth_provider.dart';
import '../../services/family_service.dart';
import '../../services/notification_service.dart';
import '../../services/medication_service.dart';
import '../../services/websocket_service.dart';
import '../../widgets/notification/notification_helper.dart';
import 'components/family_member_card.dart';
import 'components/pending_request_card.dart';
import 'components/family_member_detail_sheet.dart';
import 'add_family_screen.dart';

class ElderCareScreen extends StatefulWidget {
  const ElderCareScreen({super.key});

  @override
  State<ElderCareScreen> createState() => _ElderCareScreenState();
}

class _ElderCareScreenState extends State<ElderCareScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<FamilyBinding> _familyMembers = [];
  List<FamilyBinding> _pendingRequests = [];
  List<SystemNotification> _notifications = [];
  int _unreadCount = 0;
  bool _isLoading = true;
  bool _isLoadingMessages = false;
  StreamSubscription<String>? _wsSubscription;
  StreamSubscription<Map<String, dynamic>>? _notificationSubscription;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_onTabChanged);
    _loadData();
    _loadMessages();
    _wsSubscription = WebSocketService().familyBindingStream.listen((event) {
      _loadData();
      _loadMessages();
    });
    _notificationSubscription = WebSocketService().notificationStream.listen((
      data,
    ) {
      _loadMessages();
    });
  }

  void _onTabChanged() {
    if (_tabController.index == 1 && !_isLoadingMessages) {
      _loadMessages();
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    _wsSubscription?.cancel();
    _notificationSubscription?.cancel();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    final relationsResponse = await FamilyService.getMyRelations();
    final pendingResponse = await FamilyService.getPendingBindings();

    if (mounted) {
      setState(() {
        _familyMembers = relationsResponse.data ?? [];
        _pendingRequests = pendingResponse.data ?? [];
        _isLoading = false;
      });
    }
  }

  Future<void> _loadMessages() async {
    if (_isLoadingMessages) return;
    setState(() => _isLoadingMessages = true);

    try {
      final notificationsRes = await NotificationService.getAllNotifications();
      final countRes = await NotificationService.getUnreadCount();
      if (mounted) {
        setState(() {
          _notifications = notificationsRes.data ?? [];
          _unreadCount = countRes.data ?? 0;
          _isLoadingMessages = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingMessages = false);
        NotificationHelper.showError(message: '加载消息失败：$e');
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
          setState(() {
            final index = _notifications.indexWhere(
              (n) => n.id == notification.id,
            );
            if (index != -1) {
              _notifications[index] = SystemNotification(
                id: notification.id,
                type: notification.type,
                title: notification.title,
                content: notification.content,
                level: notification.level,
                relatedId: notification.relatedId,
                relatedType: notification.relatedType,
                status: 1,
                createdAt: notification.createdAt,
                canCheckIn: false,
              );
              _unreadCount = _notifications.where((n) => n.status == 0).length;
            }
          });
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
      _loadMessages();
    } catch (e) {
      NotificationHelper.showError(message: '操作失败');
    }
  }

  Future<void> _confirmBinding(FamilyBinding binding) async {
    final response = await FamilyService.confirmBinding(binding.id!);
    if (mounted) {
      if (response.isSuccess) {
        NotificationHelper.showSuccess(message: '绑定成功');
        _loadData();
      } else {
        NotificationHelper.showError(message: response.message);
      }
    }
  }

  Future<void> _rejectBinding(FamilyBinding binding) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认拒绝'),
        content: Text(
          '确定要拒绝 ${binding.getDisplayName(binding.myRole ?? 'elderly')} 的绑定请求吗？',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('拒绝'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final response = await FamilyService.deleteBinding(binding.id!);
      if (mounted) {
        if (response.isSuccess) {
          NotificationHelper.showSuccess(message: '已拒绝');
          _loadData();
        } else {
          NotificationHelper.showError(message: response.message);
        }
      }
    }
  }

  Future<void> _deleteBinding(FamilyBinding binding) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: Text(
          '确定要删除与 ${binding.getDisplayName(binding.myRole ?? 'elderly')} 的关系吗？',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('删除'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final response = await FamilyService.deleteBinding(binding.id!);
      if (mounted) {
        if (response.isSuccess) {
          NotificationHelper.showSuccess(message: '删除成功');
          _loadData();
        } else {
          NotificationHelper.showError(message: response.message);
        }
      }
    }
  }

  void _showAddFamilyDialog() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddFamilyScreen(onAdded: _loadData),
      ),
    );
  }

  void _showMemberDetail(FamilyBinding binding, String? currentRole) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => FamilyMemberDetailSheet(
        binding: binding,
        currentRole: currentRole,
        onDelete: () {
          Navigator.pop(context);
          _deleteBinding(binding);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF1A1A2E) : const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('关怀', style: TextStyle(fontWeight: FontWeight.w600)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: isDark ? Colors.white : Colors.black87,
        actions: [
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                LucideIcons.userPlus,
                size: 20,
                color: colorScheme.primary,
              ),
            ),
            onPressed: _showAddFamilyDialog,
            tooltip: '添加家人',
          ),
          const SizedBox(width: 8),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Container(
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF252542) : Colors.white,
              boxShadow: [
                if (!isDark)
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
              ],
            ),
            child: TabBar(
              controller: _tabController,
              labelColor: colorScheme.primary,
              unselectedLabelColor: isDark ? Colors.white54 : Colors.black45,
              indicatorColor: colorScheme.primary,
              indicatorWeight: 3,
              labelStyle: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
              tabs: [
                Tab(text: '家人 (${_familyMembers.length})'),
                Tab(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('消息'),
                      if (_unreadCount > 0) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '$_unreadCount',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildFamilyTab(isDark), _buildMessageTab(isDark)],
      ),
    );
  }

  Widget _buildFamilyTab(bool isDark) {
    final authStore = context.watch<AuthStore>();
    final currentRole = authStore.user?.roleCode;

    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              '加载中...',
              style: TextStyle(color: isDark ? Colors.white54 : Colors.black45),
            ),
          ],
        ),
      );
    }

    if (_familyMembers.isEmpty && _pendingRequests.isEmpty) {
      return _buildEmptyState(
        icon: LucideIcons.users,
        title: '暂无家人',
        subtitle: '点击右上角添加家人',
        actionText: '添加家人',
        onAction: _showAddFamilyDialog,
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (_pendingRequests.isNotEmpty) ...[
            Text(
              '待确认请求',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white70 : Colors.black54,
              ),
            ),
            const SizedBox(height: 12),
            ..._pendingRequests.map(
              (binding) => PendingRequestCard(
                binding: binding,
                onConfirm: () => _confirmBinding(binding),
                onReject: () => _rejectBinding(binding),
              ),
            ),
            const SizedBox(height: 24),
          ],
          if (_familyMembers.isNotEmpty) ...[
            Text(
              '我的家人',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white70 : Colors.black54,
              ),
            ),
            const SizedBox(height: 12),
            ..._familyMembers.map(
              (binding) => FamilyMemberCard(
                binding: binding,
                currentRole: currentRole,
                onTap: () => _showMemberDetail(binding, currentRole),
              ),
            ),
          ],
          const SizedBox(height: 24),
          _buildMapEntryCard(isDark),
        ],
      ),
    );
  }

  Widget _buildMessageTab(bool isDark) {
    if (_isLoadingMessages) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_notifications.isEmpty) {
      return _buildEmptyState(
        icon: LucideIcons.bell,
        title: '消息中心',
        subtitle: '暂无新消息',
      );
    }

    return RefreshIndicator(
      onRefresh: _loadMessages,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _notifications.length,
        itemBuilder: (context, index) {
          return _buildNotificationCard(_notifications[index], isDark);
        },
      ),
    );
  }

  Widget _buildNotificationCard(SystemNotification notification, bool isDark) {
    final colorScheme = Theme.of(context).colorScheme;
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

  Widget _buildMapEntryCard(bool isDark) {
    final colorScheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, '/care-map'),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              colorScheme.primary.withValues(alpha: 0.08),
              colorScheme.tertiary.withValues(alpha: 0.06),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: colorScheme.primary.withValues(alpha: 0.15),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colorScheme.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                LucideIcons.mapPin,
                color: colorScheme.primary,
                size: 24,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '家园定位',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '设置家园位置，查找周边医院',
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? Colors.white54 : Colors.black45,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                LucideIcons.chevronRight,
                color: colorScheme.primary,
                size: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
    String? actionText,
    VoidCallback? onAction,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.05)
                  : Colors.black.withValues(alpha: 0.03),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 40,
              color: isDark ? Colors.white24 : Colors.black26,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            title,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w500,
              color: isDark ? Colors.white54 : Colors.black45,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.white24 : Colors.black26,
            ),
          ),
          if (actionText != null && onAction != null) ...[
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onAction,
              icon: const Icon(LucideIcons.userPlus, size: 18),
              label: Text(actionText),
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
