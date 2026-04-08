import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/health_data.dart';
import '../../services/health_service.dart';
import '../../widgets/notification/notification_helper.dart';

class HealthDataManageScreen extends StatefulWidget {
  final bool isChildView;
  final String? elderlyProfileId;

  const HealthDataManageScreen({
    super.key,
    this.isChildView = false,
    this.elderlyProfileId,
  });

  @override
  State<HealthDataManageScreen> createState() => _HealthDataManageScreenState();
}

class _HealthDataManageScreenState extends State<HealthDataManageScreen> {
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
      final response = await HealthService.getDashboard();
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
      if (mounted) {
        NotificationHelper.showError(message: '加载数据失败');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final authStore = Provider.of<AuthStore>(context);
    final isElder = authStore.user?.roleCode == 'oldMan';

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isChildView ? '家人健康数据' : '我的健康数据'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: colorScheme.surface,
        actions: [
          IconButton(
            icon: Icon(LucideIcons.refreshCw, size: 20),
            onPressed: _loadData,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('血压数据', LucideIcons.heart, colorScheme),
                  _buildBloodPressureCard(isDark, colorScheme),
                  const SizedBox(height: 20),
                  _buildSectionTitle('血糖数据', LucideIcons.droplet, colorScheme),
                  _buildGlucoseCard(isDark, colorScheme),
                  const SizedBox(height: 20),
                  _buildSectionTitle(
                    '心率数据',
                    LucideIcons.heartPulse,
                    colorScheme,
                  ),
                  _buildHeartRateCard(isDark, colorScheme),
                  const SizedBox(height: 20),
                  _buildSectionTitle('体重数据', LucideIcons.scale, colorScheme),
                  _buildWeightCard(isDark, colorScheme),
                  const SizedBox(height: 20),
                  _buildSectionTitle('血氧数据', LucideIcons.wind, colorScheme),
                  _buildSpo2Card(isDark, colorScheme),
                  const SizedBox(height: 40),
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
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: colorScheme.primary),
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
      ),
    );
  }

  Widget _buildBloodPressureCard(bool isDark, ColorScheme colorScheme) {
    final bp = _dashboard?.bp;
    return _buildDataCard(
      isDark: isDark,
      colorScheme: colorScheme,
      icon: LucideIcons.heart,
      iconColor: const Color(0xFFE74C3C),
      title: '血压',
      value: bp != null ? '${bp.systolic}/${bp.diastolic} mmHg' : '暂无数据',
      subtitle: bp?.recordTime ?? '',
      status: bp?.status ?? '',
      onTap: () => _showBloodPressureDialog(),
    );
  }

  Widget _buildGlucoseCard(bool isDark, ColorScheme colorScheme) {
    final glucose = _dashboard?.glucose;
    return _buildDataCard(
      isDark: isDark,
      colorScheme: colorScheme,
      icon: LucideIcons.droplet,
      iconColor: const Color(0xFF3498DB),
      title: '血糖',
      value: glucose != null ? '${glucose.value} mmol/L' : '暂无数据',
      subtitle: glucose?.type ?? '',
      status: glucose?.status ?? '',
      onTap: () => _showGlucoseDialog(),
    );
  }

  Widget _buildHeartRateCard(bool isDark, ColorScheme colorScheme) {
    final heartRate = _dashboard?.heartRate;
    return _buildDataCard(
      isDark: isDark,
      colorScheme: colorScheme,
      icon: LucideIcons.heartPulse,
      iconColor: const Color(0xFFE74C3C),
      title: '心率',
      value: heartRate != null ? '${heartRate.value} bpm' : '暂无数据',
      subtitle: heartRate?.recordTime ?? '',
      status: heartRate?.status ?? '',
      onTap: () => _showHeartRateDialog(),
    );
  }

  Widget _buildWeightCard(bool isDark, ColorScheme colorScheme) {
    final weight = _dashboard?.weight;
    return _buildDataCard(
      isDark: isDark,
      colorScheme: colorScheme,
      icon: LucideIcons.scale,
      iconColor: const Color(0xFF9B59B6),
      title: '体重',
      value: weight != null ? '${weight.value} kg' : '暂无数据',
      subtitle: weight?.bmi != null ? 'BMI: ${weight!.bmi}' : '',
      status: weight?.status ?? '',
      onTap: () => _showWeightDialog(),
    );
  }

  Widget _buildSpo2Card(bool isDark, ColorScheme colorScheme) {
    final spo2 = _dashboard?.spo2;
    return _buildDataCard(
      isDark: isDark,
      colorScheme: colorScheme,
      icon: LucideIcons.wind,
      iconColor: const Color(0xFF1ABC9C),
      title: '血氧',
      value: spo2 != null ? '${spo2.value}%' : '暂无数据',
      subtitle: spo2?.recordTime ?? '',
      status: spo2?.status ?? '',
      onTap: () => _showSpo2Dialog(),
    );
  }

  Widget _buildDataCard({
    required bool isDark,
    required ColorScheme colorScheme,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String value,
    required String subtitle,
    required String status,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark
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
                color: iconColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? Colors.white54 : Colors.black45,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  if (subtitle.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.white38 : Colors.black26,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (status.isNotEmpty) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getStatusColor(status).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _getStatusText(status),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: _getStatusColor(status),
                  ),
                ),
              ),
              const SizedBox(width: 8),
            ],
            Icon(
              LucideIcons.chevronRight,
              size: 18,
              color: isDark ? Colors.white38 : Colors.black26,
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'normal':
        return const Color(0xFF00B894);
      case 'elevated':
      case 'warning':
        return const Color(0xFFFF9F43);
      case 'high':
      case 'danger':
      case 'low':
        return const Color(0xFFE74C3C);
      default:
        return const Color(0xFF9E9E9E);
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'normal':
        return '正常';
      case 'elevated':
        return '偏高';
      case 'warning':
        return '注意';
      case 'high':
        return '过高';
      case 'danger':
        return '危险';
      case 'low':
        return '偏低';
      default:
        return status;
    }
  }

  void _showBloodPressureDialog() {
    final systolicController = TextEditingController();
    final diastolicController = TextEditingController();
    final pulseController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('记录血压'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: systolicController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: '收缩压',
                suffixText: 'mmHg',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: diastolicController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: '舒张压',
                suffixText: 'mmHg',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: pulseController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: '脉搏',
                suffixText: 'bpm',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () async {
              final systolic = int.tryParse(systolicController.text);
              final diastolic = int.tryParse(diastolicController.text);
              final pulse = int.tryParse(pulseController.text);

              if (systolic == null || diastolic == null) {
                NotificationHelper.showError(message: '请输入有效的血压值');
                return;
              }

              Navigator.pop(context);
              await _saveHealthRecord({
                'type': 'blood_pressure',
                'systolic': systolic,
                'diastolic': diastolic,
                'pulse': pulse,
              });
            },
            child: const Text('保存'),
          ),
        ],
      ),
    );
  }

  void _showGlucoseDialog() {
    final valueController = TextEditingController();
    String selectedType = 'fasting';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('记录血糖'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: selectedType,
                decoration: const InputDecoration(labelText: '测量类型'),
                items: const [
                  DropdownMenuItem(value: 'fasting', child: Text('空腹血糖')),
                  DropdownMenuItem(value: 'after_meal', child: Text('餐后血糖')),
                  DropdownMenuItem(value: 'random', child: Text('随机血糖')),
                ],
                onChanged: (value) {
                  setState(() => selectedType = value ?? 'fasting');
                },
              ),
              const SizedBox(height: 12),
              TextField(
                controller: valueController,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: '血糖值',
                  suffixText: 'mmol/L',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('取消'),
            ),
            ElevatedButton(
              onPressed: () async {
                final value = double.tryParse(valueController.text);
                if (value == null) {
                  NotificationHelper.showError(message: '请输入有效的血糖值');
                  return;
                }

                Navigator.pop(context);
                await _saveHealthRecord({
                  'type': 'glucose',
                  'value': value,
                  'glucoseType': selectedType,
                });
              },
              child: const Text('保存'),
            ),
          ],
        ),
      ),
    );
  }

  void _showHeartRateDialog() {
    final valueController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('记录心率'),
        content: TextField(
          controller: valueController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: '心率', suffixText: 'bpm'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () async {
              final value = int.tryParse(valueController.text);
              if (value == null) {
                NotificationHelper.showError(message: '请输入有效的心率值');
                return;
              }

              Navigator.pop(context);
              await _saveHealthRecord({'type': 'heart_rate', 'value': value});
            },
            child: const Text('保存'),
          ),
        ],
      ),
    );
  }

  void _showWeightDialog() {
    final valueController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('记录体重'),
        content: TextField(
          controller: valueController,
          keyboardType: TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(labelText: '体重', suffixText: 'kg'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () async {
              final value = double.tryParse(valueController.text);
              if (value == null) {
                NotificationHelper.showError(message: '请输入有效的体重值');
                return;
              }

              Navigator.pop(context);
              await _saveHealthRecord({'type': 'weight', 'value': value});
            },
            child: const Text('保存'),
          ),
        ],
      ),
    );
  }

  void _showSpo2Dialog() {
    final valueController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('记录血氧'),
        content: TextField(
          controller: valueController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: '血氧饱和度',
            suffixText: '%',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () async {
              final value = int.tryParse(valueController.text);
              if (value == null || value < 0 || value > 100) {
                NotificationHelper.showError(message: '请输入有效的血氧值(0-100)');
                return;
              }

              Navigator.pop(context);
              await _saveHealthRecord({'type': 'spo2', 'value': value});
            },
            child: const Text('保存'),
          ),
        ],
      ),
    );
  }

  Future<void> _saveHealthRecord(Map<String, dynamic> data) async {
    try {
      final response = await HealthService.saveHealthRecord(data);
      if (response.isSuccess) {
        NotificationHelper.showSuccess(message: '保存成功');
        await _loadData();
      } else {
        NotificationHelper.showError(message: response.message);
      }
    } catch (e) {
      NotificationHelper.showError(message: '保存失败');
    }
  }
}
