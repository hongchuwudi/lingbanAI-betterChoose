import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../models/user.dart';
import '../../../config/app_config.dart';

class FamilyMemberDetailSheet extends StatelessWidget {
  final FamilyBinding binding;
  final VoidCallback onDelete;
  final String? currentRole;

  const FamilyMemberDetailSheet({
    super.key,
    required this.binding,
    required this.onDelete,
    this.currentRole,
  });

  String _getEffectiveRole() {
    if (currentRole != null) {
      return currentRole == 'oldMan' ? 'elderly' : 'child';
    }
    return binding.myRole ?? 'elderly';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;
    final effectiveRole = _getEffectiveRole();
    final displayName = binding.getDisplayName(effectiveRole);
    final displayAvatar = binding.getDisplayAvatar(effectiveRole);
    final displayGender = binding.getDisplayGender(effectiveRole);
    final displayPhone = binding.getDisplayPhone(effectiveRole);

    final isElderly = effectiveRole == 'elderly';

    return Container(
      padding: const EdgeInsets.all(24),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[400],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                _buildAvatar(displayAvatar, displayGender),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        displayName,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: colorScheme.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          isElderly
                              ? (binding.relationType ?? '家人')
                              : (binding.elderlyToChildRelation ??
                                    binding.relationType ??
                                    '家人'),
                          style: TextStyle(
                            fontSize: 14,
                            color: colorScheme.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildSection(context, '基本信息', [
              _buildInfoRow(
                context,
                LucideIcons.phone,
                '电话',
                displayPhone ?? '暂无',
              ),
              const Divider(height: 20),
              _buildInfoRow(
                context,
                LucideIcons.calendar,
                '生日',
                (isElderly ? binding.childBirthday : binding.elderlyBirthday) ??
                    '暂无',
              ),
              const Divider(height: 20),
              _buildInfoRow(
                context,
                LucideIcons.user,
                '性别',
                displayGender == 1 ? '男' : (displayGender == 2 ? '女' : '未知'),
              ),
            ]),
            if (!isElderly) ...[
              const SizedBox(height: 16),
              _buildElderlyProfileSection(context),
            ],
            if (isElderly) ...[
              const SizedBox(height: 16),
              _buildChildProfileSection(context),
            ],
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: onDelete,
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: const BorderSide(color: Colors.red),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(LucideIcons.userMinus, size: 18),
                label: const Text('删除关系', style: TextStyle(fontSize: 16)),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(
    BuildContext context,
    String title,
    List<Widget> children,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withValues(alpha: 0.05)
                : Colors.black.withValues(alpha: 0.02),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildElderlyProfileSection(BuildContext context) {
    final items = <Widget>[];

    if (binding.elderlyBloodType != null &&
        binding.elderlyBloodType!.isNotEmpty &&
        binding.elderlyBloodType != 'unk') {
      items.add(
        _buildInfoRow(
          context,
          LucideIcons.droplet,
          '血型',
          _getBloodTypeText(binding.elderlyBloodType!),
        ),
      );
    }

    if (binding.elderlyHeight != null || binding.elderlyWeight != null) {
      final heightWeight =
          '${binding.elderlyHeight?.toStringAsFixed(0) ?? '--'}cm / ${binding.elderlyWeight?.toStringAsFixed(1) ?? '--'}kg';
      items.add(
        _buildInfoRow(context, LucideIcons.ruler, '身高/体重', heightWeight),
      );
    }

    if (binding.elderlyLivingStatus != null &&
        binding.elderlyLivingStatus!.isNotEmpty) {
      items.add(
        _buildInfoRow(
          context,
          LucideIcons.home,
          '居住状态',
          _getLivingStatusText(binding.elderlyLivingStatus!),
        ),
      );
    }

    if (binding.elderlyAddress != null && binding.elderlyAddress!.isNotEmpty) {
      items.add(
        _buildInfoRow(
          context,
          LucideIcons.mapPin,
          '地址',
          binding.elderlyAddress!,
        ),
      );
    }

    if (binding.elderlyChronicDiseases != null &&
        binding.elderlyChronicDiseases != '[]') {
      items.add(
        _buildInfoRow(
          context,
          LucideIcons.heartPulse,
          '慢性病',
          _parseJsonList(binding.elderlyChronicDiseases),
        ),
      );
    }

    if (binding.elderlyAllergies != null && binding.elderlyAllergies != '[]') {
      items.add(
        _buildInfoRow(
          context,
          LucideIcons.shieldAlert,
          '过敏史',
          _parseJsonList(binding.elderlyAllergies),
        ),
      );
    }

    if (binding.elderlyDietRestrictions != null &&
        binding.elderlyDietRestrictions != '[]') {
      items.add(
        _buildInfoRow(
          context,
          LucideIcons.utensils,
          '饮食禁忌',
          _parseJsonList(binding.elderlyDietRestrictions),
        ),
      );
    }

    if (binding.elderlyMedicalHistory != null &&
        binding.elderlyMedicalHistory!.isNotEmpty) {
      items.add(
        _buildInfoRow(
          context,
          LucideIcons.fileText,
          '既往病史',
          binding.elderlyMedicalHistory!,
        ),
      );
    }

    if (binding.elderlyEmergencyContact != null &&
        binding.elderlyEmergencyContact!.isNotEmpty) {
      items.add(
        _buildInfoRow(
          context,
          LucideIcons.phoneCall,
          '紧急联系人',
          _parseEmergencyContact(binding.elderlyEmergencyContact!),
        ),
      );
    }

    if (items.isEmpty) {
      return const SizedBox.shrink();
    }

    return _buildSection(context, '老人档案信息', _insertDividers(items));
  }

  Widget _buildChildProfileSection(BuildContext context) {
    final items = <Widget>[];

    if (binding.childGuardianSettings != null &&
        binding.childGuardianSettings!.isNotEmpty) {
      final settings = _parseGuardianSettings(binding.childGuardianSettings!);
      if (settings.isNotEmpty) {
        items.add(_buildInfoRow(context, LucideIcons.bell, '通知设置', settings));
      }
    }

    if (items.isEmpty) {
      return const SizedBox.shrink();
    }

    return _buildSection(context, '子女档案信息', _insertDividers(items));
  }

  List<Widget> _insertDividers(List<Widget> items) {
    final result = <Widget>[];
    for (var i = 0; i < items.length; i++) {
      result.add(items[i]);
      if (i < items.length - 1) {
        result.add(const Divider(height: 20));
      }
    }
    return result;
  }

  String _getBloodTypeText(String bloodType) {
    switch (bloodType.toUpperCase()) {
      case 'A':
        return 'A型';
      case 'B':
        return 'B型';
      case 'AB':
        return 'AB型';
      case 'O':
        return 'O型';
      default:
        return '未知';
    }
  }

  String _getLivingStatusText(String status) {
    switch (status) {
      case 'alone':
        return '独居';
      case 'empty_nest':
        return '空巢';
      case 'with_family':
        return '与子女同住';
      case 'community':
        return '社区养老';
      default:
        return status;
    }
  }

  String _parseJsonList(String? jsonStr) {
    if (jsonStr == null || jsonStr.isEmpty || jsonStr == '[]') {
      return '暂无';
    }
    try {
      final list = jsonDecode(jsonStr) as List;
      return list.join('、');
    } catch (e) {
      return jsonStr;
    }
  }

  String _parseEmergencyContact(String? jsonStr) {
    if (jsonStr == null || jsonStr.isEmpty) {
      return '暂无';
    }
    try {
      final map = jsonDecode(jsonStr) as Map<String, dynamic>;
      final name = map['name'] ?? '';
      final phone = map['phone'] ?? '';
      final relation = map['relation'] ?? '';
      if (name.isEmpty && phone.isEmpty) return '暂无';
      return '$name ($relation) $phone';
    } catch (e) {
      return jsonStr;
    }
  }

  String _parseGuardianSettings(String? jsonStr) {
    if (jsonStr == null || jsonStr.isEmpty) {
      return '暂无';
    }
    try {
      final map = jsonDecode(jsonStr) as Map<String, dynamic>;
      final settings = <String>[];
      if (map['receive_sos'] == true) settings.add('SOS通知');
      if (map['receive_alert'] == true) settings.add('异常提醒');
      if (map['receive_weekly_report'] == true) settings.add('周报');
      if (map['receive_checkin_reminder'] == true) settings.add('签到提醒');
      if (map['receive_medication_reminder'] == true) settings.add('用药提醒');
      return settings.isEmpty ? '暂无' : settings.join('、');
    } catch (e) {
      return '暂无';
    }
  }

  Widget _buildAvatar(String? avatar, int? gender) {
    final effectiveRole = _getEffectiveRole();
    final defaultAvatar = effectiveRole == 'elderly'
        ? 'assets/choose_youths.jpeg'
        : 'assets/choose_oldMans.jpeg';

    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        image: DecorationImage(
          image: avatar != null && avatar.isNotEmpty
              ? NetworkImage('${AppConfig.apiBaseUrl}$avatar') as ImageProvider
              : AssetImage(defaultAvatar),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: isDark ? Colors.white54 : Colors.black45),
        const SizedBox(width: 12),
        SizedBox(
          width: 70,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.white54 : Colors.black45,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
        ),
      ],
    );
  }
}
