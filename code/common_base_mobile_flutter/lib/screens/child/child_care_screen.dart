import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import '../../models/user.dart';
import '../../models/system_notification.dart';
import '../../models/medication_record.dart';
import '../../providers/auth_provider.dart';
import '../../models/friend_message.dart';
import '../../services/family_service.dart';
import '../../services/message_service.dart';
import '../../services/notification_service.dart';
import '../../services/medication_service.dart';
import '../../services/websocket_service.dart';
import '../../widgets/notification/notification_helper.dart';
import '../chat/chat_detail_screen.dart';
import '../elder/components/family_member_card.dart';
import '../elder/components/pending_request_card.dart';
import '../elder/components/family_member_detail_sheet.dart';
import '../elder/add_family_screen.dart';

class ChildCareScreen extends StatefulWidget {
  const ChildCareScreen({super.key});

  @override
  State<ChildCareScreen> createState() => _ChildCareScreenState();
}

class _ChildCareScreenState extends State<ChildCareScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<FamilyBinding> _familyMembers = [];
  List<FamilyBinding> _pendingRequests = [];
  List<SystemNotification> _notifications = [];
  List<ConversationItem> _conversations = [];
  Map<String, List<MedicationRecord>> _elderlyRecords = {};
  int _unreadCount = 0;
  int _chatUnread = 0;
  bool _isLoading = true;
  bool _isLoadingMessages = false;
  StreamSubscription<String>? _wsSubscription;
  StreamSubscription<Map<String, dynamic>>? _notificationSubscription;
  StreamSubscription<Map<String, dynamic>>? _chatSubscription;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_onTabChanged);
    _loadData();
    _loadMessages();
    _loadConversations();
    _wsSubscription = WebSocketService().familyBindingStream.listen((event) {
      _loadData();
      _loadMessages();
    });
    _notificationSubscription = WebSocketService().notificationStream.listen((
      data,
    ) {
      _loadMessages();
    });
    _chatSubscription = WebSocketService().chatMessageStream.listen((_) {
      _loadConversations();
    });
  }

  void _onTabChanged() {
    if (_tabController.index == 1 && !_isLoadingMessages) {
      _loadMessages();
    } else if (_tabController.index == 2) {
      _loadConversations();
    }
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

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    _wsSubscription?.cancel();
    _notificationSubscription?.cancel();
    _chatSubscription?.cancel();
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
          _elderlyRecords = records;
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
          '确定要拒绝 ${binding.getDisplayName(binding.myRole ?? 'child')} 的绑定请求吗？',
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
          '确定要删除与 ${binding.getDisplayName(binding.myRole ?? 'child')} 的关系吗？',
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
                      const Text('通知'),
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
                Tab(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('好友消息'),
                      if (_chatUnread > 0) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '$_chatUnread',
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
        children: [
          _buildFamilyTab(isDark),
          _buildMessageTab(isDark),
          _buildChatTab(isDark),
        ],
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

    final elderlyMembers =
        _familyMembers.where((b) => b.myRole == 'child').toList();

    if (_notifications.isEmpty && elderlyMembers.isEmpty) {
      return _buildEmptyState(
        icon: LucideIcons.bell,
        title: '消息中心',
        subtitle: '暂无新消息',
      );
    }

    return RefreshIndicator(
      onRefresh: _loadMessages,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (elderlyMembers.isNotEmpty) ...[
            Text(
              '老人用药情况',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white70 : Colors.black54,
              ),
            ),
            const SizedBox(height: 12),
            ...elderlyMembers.map(
              (binding) => _buildElderlyMedicationCard(binding, isDark),
            ),
            const SizedBox(height: 24),
          ],
          if (_notifications.isNotEmpty) ...[
            Text(
              '通知消息',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white70 : Colors.black54,
              ),
            ),
            const SizedBox(height: 12),
            ..._notifications.map((n) => _buildNotificationCard(n, isDark)),
          ],
        ],
      ),
    );
  }

  Widget _buildElderlyMedicationCard(FamilyBinding binding, bool isDark) {
    final colorScheme = Theme.of(context).colorScheme;
    final records = _elderlyRecords[binding.elderlyProfileId] ?? [];
    final checkedCount = records.where((r) => r.isCheckedIn).length;
    final totalCount = records.length;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  child: ClipOval(
                    child: binding.elderlyAvatar != null &&
                            binding.elderlyAvatar!.isNotEmpty
                        ? Image.network(
                            binding.elderlyAvatar!,
                            width: 40,
                            height: 40,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Text(
                              binding.elderlyName?.substring(0, 1) ?? '老',
                              style: const TextStyle(fontSize: 16),
                            ),
                          )
                        : Text(
                            binding.elderlyName?.substring(0, 1) ?? '老',
                            style: const TextStyle(fontSize: 16),
                          ),
                  ),
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
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '今日用药：$checkedCount/$totalCount 已打卡',
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark ? Colors.white54 : Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () => _remindElderly(binding.elderlyProfileId!),
                  icon: const Icon(LucideIcons.bell, size: 16),
                  label: const Text('提醒'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
            if (records.isNotEmpty) ...[
              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 12),
              ...records.take(3).map(
                    (record) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          Icon(
                            record.isCheckedIn
                                ? LucideIcons.checkCircle
                                : LucideIcons.circle,
                            size: 18,
                            color: record.isCheckedIn
                                ? Colors.green
                                : (record.isMissed
                                    ? Colors.red
                                    : Colors.orange),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              record.drugName ?? '药品',
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                          Text(
                            record.statusText,
                            style: TextStyle(
                              fontSize: 12,
                              color: record.isCheckedIn
                                  ? Colors.green
                                  : (record.isMissed
                                      ? Colors.red
                                      : Colors.orange),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              if (records.length > 3)
                Text(
                  '还有 ${records.length - 3} 条记录...',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.white38 : Colors.black38,
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationCard(SystemNotification notification, bool isDark) {
    final colorScheme = Theme.of(context).colorScheme;

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
          child: Row(
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
                    if (notification.title != null)
                      Text(
                        notification.title!,
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark ? Colors.white54 : Colors.black54,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
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

  void _showNewChatSheet() {
    final currentRole =
        Provider.of<AuthStore>(context, listen: false).user?.roleCode;
    final effectiveRole = currentRole == 'oldMan' ? 'elderly' : 'child';

    final available = _familyMembers.where((b) {
      return b.getOtherUserId(effectiveRole) != null;
    }).toList();

    if (available.isEmpty) {
      NotificationHelper.showError(message: '暂无可发消息的家人，请先添加家人关系');
      return;
    }

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Text(
                  '选择联系人',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
              ),
              const Divider(height: 1),
              ...available.map((b) {
                final name = b.getDisplayName(effectiveRole);
                final avatar = b.getDisplayAvatar(effectiveRole);
                final otherId = b.getOtherUserId(effectiveRole)!;
                return ListTile(
                  leading: _buildAvatar(avatar, name),
                  title: Text(name,
                      style: const TextStyle(fontWeight: FontWeight.w500)),
                  subtitle: Text(b.relationType ?? '家人',
                      style: const TextStyle(fontSize: 13)),
                  onTap: () {
                    Navigator.pop(ctx);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ChatDetailScreen(
                          friendUserId: otherId,
                          friendNickname: name,
                          friendAvatar: avatar,
                        ),
                      ),
                    ).then((_) => _loadConversations());
                  },
                );
              }),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  Widget _buildChatTab(bool isDark) {
    final colorScheme = Theme.of(context).colorScheme;

    final fab = FloatingActionButton(
      heroTag: 'chat_fab_child',
      onPressed: _showNewChatSheet,
      backgroundColor: colorScheme.primary,
      foregroundColor: colorScheme.onPrimary,
      child: const Icon(LucideIcons.messageSquarePlus),
    );

    if (_conversations.isEmpty) {
      return Stack(
        children: [
          _buildEmptyState(
            icon: LucideIcons.messageSquare,
            title: '暂无好友消息',
            subtitle: '点击右下角发起新对话',
          ),
          Positioned(bottom: 24, right: 24, child: fab),
        ],
      );
    }

    return Stack(
      children: [
        RefreshIndicator(
          onRefresh: _loadConversations,
          child: ListView.separated(
            padding: const EdgeInsets.only(bottom: 96, top: 0),
            itemCount: _conversations.length,
            separatorBuilder: (_, __) => const Divider(height: 1, indent: 72),
            itemBuilder: (_, i) {
              final item = _conversations[i];
              return ListTile(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                leading: _buildAvatar(item.friendAvatar, item.friendNickname),
                title: Row(
                  children: [
                    Expanded(
                      child: Text(
                        item.friendNickname,
                        style: const TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 16),
                      ),
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
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: colorScheme.error,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          item.unreadCount > 99
                              ? '99+'
                              : '${item.unreadCount}',
                          style: TextStyle(
                              fontSize: 11, color: colorScheme.onError),
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
            },
          ),
        ),
        Positioned(bottom: 24, right: 24, child: fab),
      ],
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
            errorBuilder: (_, __, ___) => Text(
              name.isNotEmpty ? name.substring(0, 1) : '?',
              style: const TextStyle(fontSize: 18),
            ),
          ),
        ),
      );
    }
    return CircleAvatar(
      radius: 24,
      child: Text(
        name.isNotEmpty ? name.substring(0, 1) : '?',
        style: const TextStyle(fontSize: 18),
      ),
    );
  }

  String _formatTime(DateTime t) {
    final now = DateTime.now();
    final diff = now.difference(t);
    if (diff.inMinutes < 60) return '${diff.inMinutes}分钟前';
    if (diff.inHours < 24) return '${diff.inHours}小时前';
    if (diff.inDays < 7) return '${diff.inDays}天前';
    return '${t.month}-${t.day} ${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
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
