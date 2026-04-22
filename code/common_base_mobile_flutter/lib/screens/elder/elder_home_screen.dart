import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../../models/health_data.dart';
import '../../providers/auth_provider.dart';
import '../../services/health_service.dart';
import '../../widgets/health_card.dart';

class ElderHomeScreen extends StatefulWidget {
  const ElderHomeScreen({super.key});

  @override
  State<ElderHomeScreen> createState() => _ElderHomeScreenState();
}

class _ElderHomeScreenState extends State<ElderHomeScreen> {
  HealthDashboard? _dashboard;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadDashboard();
  }

  Future<void> _loadDashboard() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await HealthService.getDashboard();
      if (response.isSuccess && response.data != null) {
        setState(() {
          _dashboard = HealthDashboard.fromJson(response.data!);
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = response.message;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = '加载失败: $e';
        _isLoading = false;
      });
    }
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 6) return '夜深了';
    if (hour < 12) return '上午好';
    if (hour < 14) return '中午好';
    if (hour < 18) return '下午好';
    return '晚上好';
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF0A0A0A)
          : const Color(0xFFF5F5F7),
      body: RefreshIndicator(
        onRefresh: _loadDashboard,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(child: _buildHeader(context, colorScheme, isDark)),

            if (_isLoading)
              const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_error != null)
              SliverFillRemaining(child: _buildErrorState(colorScheme, isDark))
            else ...[
              if (_dashboard?.alerts.isNotEmpty == true)
                SliverToBoxAdapter(
                  child: AlertBanner(alerts: _dashboard!.alerts, onTap: () {}),
                ),

              SliverToBoxAdapter(
                child: _buildHealthSection(isDark, colorScheme),
              ),

              SliverToBoxAdapter(
                child: _buildActivitySection(isDark, colorScheme),
              ),

              SliverToBoxAdapter(
                child: MedicationReminder(
                  medications: _dashboard?.medications ?? [],
                  onTake: (id) async {
                    final scaffoldMessenger = ScaffoldMessenger.of(context);
                    final response = await HealthService.recordMedication(id);
                    if (response.isSuccess) {
                      await Future.delayed(const Duration(milliseconds: 300));
                      _loadDashboard();
                      if (mounted) {
                        scaffoldMessenger.showSnackBar(
                          const SnackBar(
                            content: Text('打卡成功'),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                    }
                  },
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ColorScheme colorScheme, bool isDark) {
    final user = Provider.of<AuthStore>(context, listen: false).user;
    final displayName = user?.nickname?.isNotEmpty == true
        ? user!.nickname
        : (user?.username ?? '用户');
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 56, 20, 16),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(LucideIcons.user, color: colorScheme.primary, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${_getGreeting()}，$displayName',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${DateTime.now().month}月${DateTime.now().day}日 ${_getWeekday()}',
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? Colors.white54 : Colors.black45,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getWeekday() {
    const weekdays = ['周一', '周二', '周三', '周四', '周五', '周六', '周日'];
    return weekdays[DateTime.now().weekday - 1];
  }

  Widget _buildErrorState(ColorScheme colorScheme, bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(LucideIcons.wifiOff, size: 48, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              '加载失败',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _error ?? '请检查网络连接后重试',
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.white60 : Colors.black54,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadDashboard,
              icon: const Icon(LucideIcons.refreshCw, size: 18),
              label: const Text('重新加载'),
              style: ElevatedButton.styleFrom(
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
        ),
      ),
    );
  }

  Widget _buildHealthSection(bool isDark, ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('健康指标', isDark),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: isDark
                  ? null
                  : [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
            ),
            child: Column(
              children: [
                _buildHealthRow(
                  icon: LucideIcons.heartPulse,
                  title: '血压',
                  value: _dashboard?.bp != null
                      ? '${_dashboard!.bp!.systolic}/${_dashboard!.bp!.diastolic}'
                      : '--',
                  unit: 'mmHg',
                  status: _dashboard?.bp?.status,
                  color: const Color(0xFFFF6B6B),
                  isDark: isDark,
                ),
                _buildDivider(isDark),
                _buildHealthRow(
                  icon: LucideIcons.droplets,
                  title: '血糖',
                  value: _dashboard?.glucose?.value?.toStringAsFixed(1) ?? '--',
                  unit: 'mmol/L',
                  status: _dashboard?.glucose?.status,
                  color: const Color(0xFF4ECDC4),
                  subtitle: _dashboard?.glucose?.type,
                  isDark: isDark,
                ),
                _buildDivider(isDark),
                _buildHealthRow(
                  icon: LucideIcons.activity,
                  title: '心率',
                  value: _dashboard?.heartRate?.value?.toString() ?? '--',
                  unit: 'bpm',
                  status: _dashboard?.heartRate?.status,
                  color: const Color(0xFFFF8A5B),
                  isDark: isDark,
                ),
                _buildDivider(isDark),
                _buildHealthRow(
                  icon: LucideIcons.scale,
                  title: '体重',
                  value: _dashboard?.weight?.value?.toStringAsFixed(1) ?? '--',
                  unit: 'kg',
                  status: _dashboard?.weight?.status,
                  color: const Color(0xFF6C5CE7),
                  subtitle: _dashboard?.weight?.bmi != null
                      ? 'BMI ${_dashboard!.weight!.bmi!.toStringAsFixed(1)}'
                      : null,
                  isDark: isDark,
                ),
                _buildDivider(isDark),
                _buildHealthRow(
                  icon: LucideIcons.wind,
                  title: '血氧',
                  value: _dashboard?.spo2?.value?.toString() ?? '--',
                  unit: '%',
                  status: _dashboard?.spo2?.status,
                  color: const Color(0xFF00B894),
                  isDark: isDark,
                ),
                _buildDivider(isDark),
                _buildStepRow(isDark, colorScheme),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, bool isDark) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: isDark ? Colors.white : Colors.black87,
      ),
    );
  }

  Widget _buildDivider(bool isDark) {
    return Divider(
      height: 1,
      indent: 56,
      endIndent: 16,
      color: isDark
          ? Colors.white.withValues(alpha: 0.08)
          : Colors.black.withValues(alpha: 0.05),
    );
  }

  Widget _buildHealthRow({
    required IconData icon,
    required String title,
    required String value,
    required String unit,
    String? status,
    required Color color,
    String? subtitle,
    required bool isDark,
  }) {
    Color statusColor;
    String statusText;
    switch (status) {
      case 'normal':
        statusColor = const Color(0xFF00B894);
        statusText = '正常';
        break;
      case 'high':
        statusColor = const Color(0xFFFF7675);
        statusText = '偏高';
        break;
      case 'low':
        statusColor = const Color(0xFF74B9FF);
        statusText = '偏低';
        break;
      case 'warning':
        statusColor = const Color(0xFFFDCB6E);
        statusText = '注意';
        break;
      default:
        statusColor = Colors.grey;
        statusText = '--';
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? Colors.white70 : Colors.black54,
                  ),
                ),
                if (subtitle != null && subtitle.isNotEmpty)
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark ? Colors.white38 : Colors.black26,
                    ),
                  ),
              ],
            ),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              const SizedBox(width: 2),
              Text(
                unit,
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? Colors.white54 : Colors.black38,
                ),
              ),
            ],
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              statusText,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: statusColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepRow(bool isDark, ColorScheme colorScheme) {
    final count = _dashboard?.steps?.count ?? 0;
    final goal = _dashboard?.steps?.goal ?? 8000;
    final percentage = _dashboard?.steps?.percentage ?? 0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFF00B894).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              LucideIcons.footprints,
              color: Color(0xFF00B894),
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '今日步数',
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? Colors.white70 : Colors.black54,
                  ),
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(3),
                  child: LinearProgressIndicator(
                    value: (percentage / 100).clamp(0.0, 1.0),
                    backgroundColor: isDark
                        ? Colors.white.withValues(alpha: 0.1)
                        : Colors.grey.shade200,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      percentage >= 100
                          ? const Color(0xFF00B894)
                          : colorScheme.primary,
                    ),
                    minHeight: 4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    count.toString(),
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(width: 2),
                  Text(
                    '步',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.white54 : Colors.black38,
                    ),
                  ),
                ],
              ),
              Text(
                '目标 $goal',
                style: TextStyle(
                  fontSize: 11,
                  color: isDark ? Colors.white38 : Colors.black26,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActivitySection(bool isDark, ColorScheme colorScheme) {
    final duration = _dashboard?.sleep?.duration ?? 0;
    final quality = _dashboard?.sleep?.quality ?? 0;

    String qualityText;
    Color qualityColor;
    switch (quality) {
      case 5:
        qualityText = '极好';
        qualityColor = const Color(0xFF00B894);
        break;
      case 4:
        qualityText = '良好';
        qualityColor = const Color(0xFF55EFC4);
        break;
      case 3:
        qualityText = '一般';
        qualityColor = const Color(0xFFFDCB6E);
        break;
      case 2:
        qualityText = '较差';
        qualityColor = const Color(0xFFE17055);
        break;
      default:
        qualityText = '很差';
        qualityColor = const Color(0xFFFF7675);
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('活动与睡眠', isDark),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  icon: LucideIcons.moon,
                  title: '昨夜睡眠',
                  value: duration.toStringAsFixed(1),
                  unit: '小时',
                  subtitle: qualityText,
                  subtitleColor: qualityColor,
                  color: const Color(0xFF6C5CE7),
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  icon: LucideIcons.flame,
                  title: '本周消耗',
                  value: '1,850',
                  unit: '千卡',
                  subtitle: '较上周 +12%',
                  subtitleColor: const Color(0xFF00B894),
                  color: const Color(0xFFFF7675),
                  isDark: isDark,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required String unit,
    required String subtitle,
    required Color subtitleColor,
    required Color color,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
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
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 16),
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 13,
                  color: isDark ? Colors.white60 : Colors.black45,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                unit,
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? Colors.white54 : Colors.black38,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 12,
              color: subtitleColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
