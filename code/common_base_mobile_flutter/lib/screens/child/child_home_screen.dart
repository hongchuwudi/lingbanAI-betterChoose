import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../../models/user.dart';
import '../../models/health_data.dart';
import '../../providers/auth_provider.dart';
import '../../services/family_service.dart';
import '../../services/health_service.dart';
import '../../widgets/notification/notification_helper.dart';

class ChildHomeScreen extends StatefulWidget {
  const ChildHomeScreen({super.key});

  @override
  State<ChildHomeScreen> createState() => _ChildHomeScreenState();
}

class _ChildHomeScreenState extends State<ChildHomeScreen> {
  List<FamilyBinding> _familyMembers = [];
  FamilyBinding? _selectedElderly;
  HealthDashboard? _dashboard;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final response = await FamilyService.getMyRelations();
      if (response.isSuccess && response.data != null) {
        final relations = response.data!;
        final elderlyList =
            relations.where((b) => b.myRole == 'child').toList();
        setState(() {
          _familyMembers = elderlyList;
          if (elderlyList.isNotEmpty && _selectedElderly == null) {
            _selectedElderly = elderlyList.first;
          }
        });
        if (_selectedElderly != null &&
            _selectedElderly!.elderlyProfileId != null) {
          await _loadElderlyHealth();
        } else {
          setState(() => _isLoading = false);
        }
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        NotificationHelper.showError(message: '加载数据失败');
      }
    }
  }

  Future<void> _loadElderlyHealth() async {
    if (_selectedElderly?.elderlyProfileId == null) return;
    try {
      final response = await HealthService.getChildElderlyDashboard(
        _selectedElderly!.elderlyProfileId!,
      );
      if (response.isSuccess && response.data != null) {
        setState(() {
          _dashboard = HealthDashboard.fromJson(
            response.data as Map<String, dynamic>,
          );
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  void _selectElderly(FamilyBinding elderly) {
    if (_selectedElderly?.elderlyProfileId == elderly.elderlyProfileId) return;
    setState(() {
      _selectedElderly = elderly;
      _dashboard = null;
    });
    _loadElderlyHealth();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF1A1A2E) : const Color(0xFFF8F9FA),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _familyMembers.isEmpty
              ? _buildEmptyState(isDark, colorScheme)
              : _buildDashboard(isDark, colorScheme),
    );
  }

  Widget _buildEmptyState(bool isDark, ColorScheme colorScheme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            LucideIcons.users,
            size: 80,
            color: colorScheme.primary.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            '暂无关联的老人',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: isDark ? Colors.white70 : Colors.black54,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '请先在关怀页面添加家人',
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.white54 : Colors.black45,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboard(bool isDark, ColorScheme colorScheme) {
    return RefreshIndicator(
      onRefresh: _loadData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.only(
          top: MediaQuery.of(context).padding.top + 16,
          bottom: 24,
          left: 16,
          right: 16,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(isDark, colorScheme),
            const SizedBox(height: 20),
            if (_familyMembers.length > 1) ...[
              _buildElderlySelector(isDark, colorScheme),
              const SizedBox(height: 20),
            ],
            _buildHealthOverview(isDark, colorScheme),
            const SizedBox(height: 20),
            _buildMedicationSection(isDark, colorScheme),
            const SizedBox(height: 20),
            if (_dashboard?.alerts != null && _dashboard!.alerts.isNotEmpty)
              _buildAlertsSection(isDark, colorScheme),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDark, ColorScheme colorScheme) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: colorScheme.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(
            LucideIcons.heartPulse,
            size: 28,
            color: colorScheme.primary,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '家人健康概览',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '实时关注家人健康状况',
                style: TextStyle(
                  fontSize: 13,
                  color: isDark ? Colors.white54 : Colors.black45,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          icon: Icon(
            LucideIcons.refreshCw,
            size: 20,
            color: colorScheme.primary,
          ),
          onPressed: _loadData,
        ),
      ],
    );
  }

  Widget _buildElderlySelector(bool isDark, ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF252542) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
        ],
      ),
      child: Row(
        children: [
          Icon(LucideIcons.users, size: 18, color: colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<FamilyBinding>(
                value: _selectedElderly,
                isExpanded: true,
                hint: const Text('选择家人'),
                items: _familyMembers.map((member) {
                  return DropdownMenuItem(
                    value: member,
                    child: Text(
                      member.elderlyName ?? '老人',
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) _selectElderly(value);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHealthOverview(bool isDark, ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '健康指标',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildHealthCard(
                icon: LucideIcons.heart,
                iconColor: const Color(0xFFE74C3C),
                title: '血压',
                value: _dashboard?.bp != null
                    ? '${_dashboard!.bp!.systolic}/${_dashboard!.bp!.diastolic}'
                    : '--',
                unit: 'mmHg',
                status: _dashboard?.bp?.status,
                isDark: isDark,
                colorScheme: colorScheme,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildHealthCard(
                icon: LucideIcons.droplet,
                iconColor: const Color(0xFF42A5F5),
                title: '血糖',
                value: _dashboard?.glucose?.value?.toString() ?? '--',
                unit: 'mmol/L',
                status: _dashboard?.glucose?.status,
                isDark: isDark,
                colorScheme: colorScheme,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildHealthCard(
                icon: LucideIcons.heartPulse,
                iconColor: const Color(0xFFE74C3C),
                title: '心率',
                value: _dashboard?.heartRate?.value?.toString() ?? '--',
                unit: 'bpm',
                status: _dashboard?.heartRate?.status,
                isDark: isDark,
                colorScheme: colorScheme,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildHealthCard(
                icon: LucideIcons.wind,
                iconColor: const Color(0xFF4FC3F7),
                title: '血氧',
                value: _dashboard?.spo2?.value?.toString() ?? '--',
                unit: '%',
                status: _dashboard?.spo2?.status,
                isDark: isDark,
                colorScheme: colorScheme,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildHealthCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String value,
    required String unit,
    required String? status,
    required bool isDark,
    required ColorScheme colorScheme,
  }) {
    Color statusColor;
    String statusText;
    switch (status) {
      case 'normal':
        statusColor = const Color(0xFF00B894);
        statusText = '正常';
        break;
      case 'elevated':
      case 'warning':
        statusColor = const Color(0xFFFF9F43);
        statusText = '注意';
        break;
      case 'high':
      case 'danger':
      case 'low':
        statusColor = const Color(0xFFE74C3C);
        statusText = status == 'low' ? '偏低' : '偏高';
        break;
      default:
        statusColor = Colors.grey;
        statusText = '--';
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF252542) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: iconColor, size: 18),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: TextStyle(
                  fontSize: 13,
                  color: isDark ? Colors.white54 : Colors.black45,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              const SizedBox(width: 4),
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  unit,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.white54 : Colors.black45,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              statusText,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: statusColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMedicationSection(bool isDark, ColorScheme colorScheme) {
    final medications = _dashboard?.medications ?? [];
    final takenCount = medications.where((m) => m.taken == true).length;
    final totalCount = medications.length;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF252542) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(LucideIcons.pill, size: 18, color: colorScheme.primary),
                  const SizedBox(width: 8),
                  Text(
                    '今日用药',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$takenCount/$totalCount 已完成',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: colorScheme.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (medications.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Text(
                  '暂无用药计划',
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? Colors.white54 : Colors.black45,
                  ),
                ),
              ),
            )
          else
            ...medications
                .take(3)
                .map((med) => _buildMedicationItem(med, isDark)),
          if (medications.length > 3)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Center(
                child: Text(
                  '还有 ${medications.length - 3} 项用药计划',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.white54 : Colors.black45,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMedicationItem(MedicationData med, bool isDark) {
    final isTaken = med.taken == true;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.05)
            : Colors.black.withValues(alpha: 0.02),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: isTaken
                  ? const Color(0xFF00B894).withValues(alpha: 0.12)
                  : Colors.orange.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isTaken ? LucideIcons.check : LucideIcons.clock,
              size: 16,
              color: isTaken ? const Color(0xFF00B894) : Colors.orange,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  med.drugName ?? '',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                Text(
                  '${med.scheduledTime ?? ''} ${med.dosage ?? ''}',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.white54 : Colors.black45,
                  ),
                ),
              ],
            ),
          ),
          Text(
            isTaken ? '已服用' : '待服用',
            style: TextStyle(
              fontSize: 12,
              color: isTaken ? const Color(0xFF00B894) : Colors.orange,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlertsSection(bool isDark, ColorScheme colorScheme) {
    final alerts = _dashboard?.alerts ?? [];
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFE74C3C).withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFE74C3C).withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                LucideIcons.alertTriangle,
                size: 18,
                color: Color(0xFFE74C3C),
              ),
              const SizedBox(width: 8),
              Text(
                '健康预警',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFE74C3C).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${alerts.length} 条',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFFE74C3C),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...alerts.take(3).map((alert) => _buildAlertItem(alert, isDark)),
        ],
      ),
    );
  }

  Widget _buildAlertItem(HealthAlertData alert, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: Color(0xFFE74C3C),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  alert.indicatorName ?? '',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '当前值: ${alert.actualValue ?? ''} | 正常范围: ${alert.normalRange ?? ''}',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.white54 : Colors.black45,
                  ),
                ),
              ],
            ),
          ),
          Text(
            alert.alertTime ?? '',
            style: TextStyle(
              fontSize: 11,
              color: isDark ? Colors.white38 : Colors.black26,
            ),
          ),
        ],
      ),
    );
  }
}
