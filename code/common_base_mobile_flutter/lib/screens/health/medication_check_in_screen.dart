import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/health_data.dart';
import '../../services/health_service.dart';
import '../../widgets/notification/notification_helper.dart';

class MedicationCheckInScreen extends StatefulWidget {
  final bool isChildView;
  final String? elderlyProfileId;

  const MedicationCheckInScreen({
    super.key,
    this.isChildView = false,
    this.elderlyProfileId,
  });

  @override
  State<MedicationCheckInScreen> createState() =>
      _MedicationCheckInScreenState();
}

class _MedicationCheckInScreenState extends State<MedicationCheckInScreen>
    with AutomaticKeepAliveClientMixin {
  List<MedicationData> _medications = [];
  bool _isLoading = true;
  Set<int> _pendingIds = {};

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _loadMedications(initial: true);
  }

  @override
  void didUpdateWidget(covariant MedicationCheckInScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.elderlyProfileId != oldWidget.elderlyProfileId) {
      _loadMedications(initial: true);
    }
  }

  Future<void> _loadMedications({bool initial = false}) async {
    if (initial) {
      setState(() => _isLoading = true);
    }
    try {
      final response = widget.isChildView && widget.elderlyProfileId != null
          ? await HealthService.getChildElderlyDashboard(
              widget.elderlyProfileId!,
            )
          : await HealthService.getDashboard();
      if (response.isSuccess && response.data != null) {
        final dashboard = HealthDashboard.fromJson(
          response.data as Map<String, dynamic>,
        );
        if (mounted) {
          setState(() {
            _medications = dashboard.medications;
            _isLoading = false;
          });
        }
      } else {
        if (initial && mounted) {
          setState(() => _isLoading = false);
        }
      }
    } catch (e) {
      if (initial && mounted) {
        setState(() => _isLoading = false);
      }
      if (mounted) {
        NotificationHelper.showError(message: '加载用药数据失败');
      }
    }
  }

  Future<void> _handleCheckIn(int recordId) async {
    if (_pendingIds.contains(recordId)) return;

    setState(() => _pendingIds.add(recordId));

    try {
      final response = await HealthService.recordMedication(recordId);
      if (response.isSuccess) {
        NotificationHelper.showSuccess(message: '打卡成功');
        await Future.delayed(const Duration(milliseconds: 300));
        await _loadMedications();
      } else {
        NotificationHelper.showError(message: response.message);
      }
    } catch (e) {
      NotificationHelper.showError(message: '打卡失败');
    } finally {
      if (mounted) {
        setState(() => _pendingIds.remove(recordId));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (widget.isChildView) {
      return _buildChildView(isDark, colorScheme);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('用药打卡'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: colorScheme.surface,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _medications.isEmpty
              ? _buildEmptyState(isDark, colorScheme)
              : _buildMedicationList(isDark, colorScheme),
    );
  }

  Widget _buildChildView(bool isDark, ColorScheme colorScheme) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('用药提醒'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: colorScheme.surface,
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.bellPlus, size: 20),
            onPressed: () => _showAddReminderDialog(),
            tooltip: '添加提醒',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildChildMedicationContent(isDark, colorScheme),
    );
  }

  Widget _buildChildMedicationContent(bool isDark, ColorScheme colorScheme) {
    final takenCount = _medications.where((m) => m.taken == true).length;
    final totalCount = _medications.length;
    final missedCount = _medications.where((m) {
      if (m.taken == true) return false;
      return true;
    }).length;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildChildSummaryCard(
            takenCount,
            totalCount,
            missedCount,
            isDark,
            colorScheme,
          ),
          const SizedBox(height: 20),
          _buildSectionTitle('今日用药安排', LucideIcons.calendarCheck, colorScheme),
          const SizedBox(height: 12),
          if (_medications.isEmpty)
            _buildEmptyState(isDark, colorScheme)
          else
            ..._medications.map(
              (med) => _buildChildMedicationCard(med, isDark, colorScheme),
            ),
          const SizedBox(height: 20),
          _buildSectionTitle('快捷操作', LucideIcons.zap, colorScheme),
          const SizedBox(height: 12),
          _buildQuickActions(isDark, colorScheme),
        ],
      ),
    );
  }

  Widget _buildChildSummaryCard(
    int taken,
    int total,
    int missed,
    bool isDark,
    ColorScheme colorScheme,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colorScheme.primary.withValues(alpha: 0.15),
            colorScheme.primaryContainer.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colorScheme.primary.withValues(alpha: 0.1)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(
                '已服用',
                taken,
                const Color(0xFF00B894),
                LucideIcons.checkCircle,
              ),
              Container(
                width: 1,
                height: 40,
                color: isDark ? Colors.white10 : Colors.black12,
              ),
              _buildStatItem(
                '待服用',
                total - taken,
                colorScheme.primary,
                LucideIcons.clock,
              ),
              Container(
                width: 1,
                height: 40,
                color: isDark ? Colors.white10 : Colors.black12,
              ),
              _buildStatItem(
                '总计划',
                total,
                colorScheme.tertiary,
                LucideIcons.pill,
              ),
            ],
          ),
          if (missed > 0) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFE74C3C).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    LucideIcons.alertTriangle,
                    size: 16,
                    color: const Color(0xFFE74C3C),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '有 $missed 项用药待确认',
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFFE74C3C),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, int value, Color color, IconData icon) {
    return Column(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(height: 8),
        Text(
          '$value',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: color.withValues(alpha: 0.8)),
        ),
      ],
    );
  }

  Widget _buildChildMedicationCard(
    MedicationData med,
    bool isDark,
    ColorScheme colorScheme,
  ) {
    final isTaken = med.taken == true;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isTaken
              ? const Color(0xFF00B894).withValues(alpha: 0.3)
              : isDark
                  ? Colors.white10
                  : Colors.black.withValues(alpha: 0.05),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: isTaken
                  ? const Color(0xFF00B894).withValues(alpha: 0.12)
                  : colorScheme.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isTaken ? LucideIcons.check : LucideIcons.pill,
              color: isTaken ? const Color(0xFF00B894) : colorScheme.primary,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  med.drugName ?? '',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      LucideIcons.clock,
                      size: 13,
                      color: isDark ? Colors.white54 : Colors.black45,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      med.scheduledTime ?? '',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.white54 : Colors.black45,
                      ),
                    ),
                    if (med.dosage != null && med.dosage!.isNotEmpty) ...[
                      const SizedBox(width: 8),
                      Icon(
                        LucideIcons.beaker,
                        size: 13,
                        color: isDark ? Colors.white54 : Colors.black45,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        med.dosage!,
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? Colors.white54 : Colors.black45,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: isTaken
                  ? const Color(0xFF00B894).withValues(alpha: 0.12)
                  : Colors.orange.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              isTaken ? '已服用' : '待服用',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: isTaken ? const Color(0xFF00B894) : Colors.orange,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(bool isDark, ColorScheme colorScheme) {
    return Row(
      children: [
        Expanded(
          child: _buildActionCard(
            icon: LucideIcons.bellRing,
            title: '发送提醒',
            subtitle: '提醒老人用药',
            color: const Color(0xFFE74C3C),
            isDark: isDark,
            onTap: () => _sendMedicationReminder(),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildActionCard(
            icon: LucideIcons.phone,
            title: '电话提醒',
            subtitle: '直接致电老人',
            color: const Color(0xFF42A5F5),
            isDark: isDark,
            onTap: () => _callElderly(),
          ),
        ),
      ],
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 10),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 11,
                color: isDark ? Colors.white54 : Colors.black45,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(
    String title,
    IconData icon,
    ColorScheme colorScheme,
  ) {
    return Row(
      children: [
        Icon(icon, size: 18, color: colorScheme.primary),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
      ],
    );
  }

  void _showAddReminderDialog() {
    NotificationHelper.showInfo(message: '添加用药提醒功能开发中');
  }

  void _sendMedicationReminder() {
    NotificationHelper.showInfo(message: '已发送用药提醒');
  }

  void _callElderly() {
    NotificationHelper.showInfo(message: '正在拨打老人电话...');
  }

  Widget _buildEmptyState(bool isDark, ColorScheme colorScheme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            LucideIcons.pill,
            size: 64,
            color: isDark ? Colors.white24 : Colors.black12,
          ),
          const SizedBox(height: 16),
          Text(
            '暂无用药计划',
            style: TextStyle(
              fontSize: 16,
              color: isDark ? Colors.white54 : Colors.black45,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '请先添加用药计划',
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.white38 : Colors.black26,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMedicationList(bool isDark, ColorScheme colorScheme) {
    final takenCount = _medications.where((m) => m.taken == true).length;
    final totalCount = _medications.length;
    final progress = totalCount > 0 ? takenCount / totalCount : 0.0;

    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: colorScheme.primary.withValues(alpha: 0.08),
            border: Border(
              bottom: BorderSide(
                color: isDark
                    ? Colors.white10
                    : Colors.black.withValues(alpha: 0.05),
              ),
            ),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '今日进度',
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? Colors.white70 : Colors.black54,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '$takenCount/$totalCount',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: progress,
                  backgroundColor: isDark
                      ? Colors.white10
                      : Colors.black.withValues(alpha: 0.05),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    colorScheme.primary,
                  ),
                  minHeight: 8,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _medications.length,
            itemBuilder: (context, index) {
              final med = _medications[index];
              return _buildMedicationCard(med, isDark, colorScheme);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildMedicationCard(
    MedicationData med,
    bool isDark,
    ColorScheme colorScheme,
  ) {
    final isTaken = med.taken == true;
    final isPending = _pendingIds.contains(med.id);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isTaken
              ? const Color(0xFF00B894).withValues(alpha: 0.3)
              : isDark
                  ? Colors.white10
                  : Colors.black.withValues(alpha: 0.05),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: isTaken
                  ? const Color(0xFF00B894).withValues(alpha: 0.12)
                  : colorScheme.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isTaken ? LucideIcons.check : LucideIcons.pill,
              color: isTaken ? const Color(0xFF00B894) : colorScheme.primary,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  med.drugName ?? '',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : Colors.black87,
                    decoration: isTaken ? TextDecoration.lineThrough : null,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      LucideIcons.clock,
                      size: 14,
                      color: isDark ? Colors.white54 : Colors.black45,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      med.scheduledTime ?? '',
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark ? Colors.white54 : Colors.black45,
                      ),
                    ),
                    if (med.dosage != null && med.dosage!.isNotEmpty) ...[
                      const SizedBox(width: 12),
                      Icon(
                        LucideIcons.beaker,
                        size: 14,
                        color: isDark ? Colors.white54 : Colors.black45,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        med.dosage!,
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark ? Colors.white54 : Colors.black45,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          if (isTaken)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF00B894).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                '已打卡',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF00B894),
                ),
              ),
            )
          else
            GestureDetector(
              onTap: isPending || med.id == null
                  ? null
                  : () => _handleCheckIn(med.id!),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: colorScheme.primary,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: isPending
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    : const Text(
                        '打卡',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
        ],
      ),
    );
  }
}
