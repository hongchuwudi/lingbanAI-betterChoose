import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../models/health_data.dart';

class AlertBanner extends StatelessWidget {
  final List<HealthAlertData> alerts;
  final VoidCallback? onTap;

  const AlertBanner({super.key, required this.alerts, this.onTap});

  String _formatAlertMessage(HealthAlertData alert) {
    final indicatorName = _getIndicatorDisplayName(alert.indicatorName ?? '');
    final alertType = _getAlertTypeDisplayName(alert.alertType ?? '');
    return '$indicatorName$alertType';
  }

  String _getIndicatorDisplayName(String code) {
    final Map<String, String> indicatorNames = {
      'blood_pressure': '血压',
      'systolic': '收缩压',
      'diastolic': '舒张压',
      'glucose': '血糖',
      'glucose_fasting': '空腹血糖',
      'glucose_after_meal': '餐后血糖',
      'glucose_random': '随机血糖',
      'heart_rate': '心率',
      'weight': '体重',
      'spo2': '血氧',
      'steps': '步数',
      'sleep': '睡眠',
    };
    return indicatorNames[code] ?? code;
  }

  String _getAlertTypeDisplayName(String code) {
    final Map<String, String> alertTypes = {
      'HIGH': '偏高',
      'LOW': '偏低',
      'ABNORMAL': '异常',
      'WARNING': '注意',
      'DANGER': '危险',
      'ELEVATED': '偏高',
      'NORMAL': '正常',
    };
    return alertTypes[code] ?? code;
  }

  @override
  Widget build(BuildContext context) {
    if (alerts.isEmpty) return const SizedBox.shrink();

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final alertCount = alerts.length;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      height: 36,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: isDark
                  ? const Color(0xFFFF6B6B).withValues(alpha: 0.15)
                  : const Color(0xFFFFF5F5),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF6B6B).withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    LucideIcons.alertCircle,
                    color: Color(0xFFFF6B6B),
                    size: 12,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    alertCount == 1
                        ? _formatAlertMessage(alerts.first)
                        : '有 $alertCount 条健康预警需要关注',
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark
                          ? const Color(0xFFFF8A8A)
                          : const Color(0xFFE53935),
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF6B6B),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '$alertCount',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Icon(
                  LucideIcons.chevronRight,
                  size: 14,
                  color: isDark
                      ? const Color(0xFFFF8A8A)
                      : const Color(0xFFE53935),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class MedicationReminder extends StatelessWidget {
  final List<MedicationData> medications;
  final Function(int)? onTake;
  final Set<int>? pendingIds;

  const MedicationReminder({
    super.key,
    required this.medications,
    this.onTake,
    this.pendingIds,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;

    if (medications.isEmpty) {
      return const SizedBox.shrink();
    }

    final pendingCount = medications.where((m) => m.taken != true).length;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
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
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      LucideIcons.pill,
                      color: colorScheme.primary,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '今日用药',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    if (pendingCount > 0) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(
                            0xFFFF9F43,
                          ).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '$pendingCount项待服',
                          style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xFFFF9F43),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                Icon(
                  LucideIcons.chevronRight,
                  size: 16,
                  color: isDark ? Colors.white38 : Colors.black26,
                ),
              ],
            ),
          ),
          ...medications
              .take(3)
              .map((med) => _buildMedicationItem(med, isDark, colorScheme)),
          if (medications.length > 3)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
              child: Text(
                '还有 ${medications.length - 3} 项',
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? Colors.white38 : Colors.black26,
                ),
              ),
            ),
          if (medications.length <= 3) const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildMedicationItem(
    MedicationData med,
    bool isDark,
    ColorScheme colorScheme,
  ) {
    final isTaken = med.taken == true;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: isTaken
                  ? const Color(0xFF00B894).withValues(alpha: 0.12)
                  : colorScheme.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              isTaken ? LucideIcons.check : LucideIcons.clock,
              color: isTaken ? const Color(0xFF00B894) : colorScheme.primary,
              size: 16,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              med.drugName ?? '',
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.white : Colors.black87,
                decoration: isTaken ? TextDecoration.lineThrough : null,
              ),
            ),
          ),
          Text(
            med.scheduledTime ?? '',
            style: TextStyle(
              fontSize: 12,
              color: isDark ? Colors.white54 : Colors.black38,
            ),
          ),
          if (!isTaken) ...[
            const SizedBox(width: 10),
            GestureDetector(
              onTap: med.id != null ? () => onTake?.call(med.id!) : null,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: colorScheme.primary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  '打卡',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
