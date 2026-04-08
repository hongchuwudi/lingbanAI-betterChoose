import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/health_data.dart';
import '../../services/health_service.dart';
import '../../widgets/notification/notification_helper.dart';

class MedicationCheckInScreen extends StatefulWidget {
  const MedicationCheckInScreen({super.key});

  @override
  State<MedicationCheckInScreen> createState() =>
      _MedicationCheckInScreenState();
}

class _MedicationCheckInScreenState extends State<MedicationCheckInScreen> {
  List<MedicationData> _medications = [];
  bool _isLoading = true;
  Set<int> _pendingIds = {};

  @override
  void initState() {
    super.initState();
    _loadMedications(initial: true);
  }

  Future<void> _loadMedications({bool initial = false}) async {
    if (initial) {
      setState(() => _isLoading = true);
    }
    try {
      final response = await HealthService.getDashboard();
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
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
