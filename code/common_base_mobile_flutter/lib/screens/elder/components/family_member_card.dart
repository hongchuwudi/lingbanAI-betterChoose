import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../models/user.dart';
import '../../../config/app_config.dart';

class FamilyMemberCard extends StatelessWidget {
  final FamilyBinding binding;
  final VoidCallback onTap;
  final String? currentRole;

  const FamilyMemberCard({
    super.key,
    required this.binding,
    required this.onTap,
    this.currentRole,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;
    final effectiveRole = _getEffectiveRole();
    final displayName = binding.getDisplayName(effectiveRole);
    final displayAvatar = binding.getDisplayAvatar(effectiveRole);
    final displayGender = binding.getDisplayGender(effectiveRole);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                _buildAvatar(displayAvatar, displayGender, 52),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            displayName,
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: colorScheme.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              getDisplayRelation(),
                              style: TextStyle(
                                fontSize: 12,
                                color: colorScheme.primary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(
                            LucideIcons.phone,
                            size: 14,
                            color: isDark ? Colors.white38 : Colors.black38,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            binding.getDisplayPhone(effectiveRole) ?? '暂无电话',
                            style: TextStyle(
                              fontSize: 13,
                              color: isDark ? Colors.white54 : Colors.black45,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.05)
                        : Colors.black.withValues(alpha: 0.03),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    LucideIcons.chevronRight,
                    size: 18,
                    color: isDark ? Colors.white24 : Colors.black26,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getEffectiveRole() {
    if (currentRole != null) {
      return currentRole == 'oldMan' ? 'elderly' : 'child';
    }
    return binding.myRole ?? 'elderly';
  }

  String getDisplayRelation() {
    final effectiveRole = _getEffectiveRole();
    if (effectiveRole == 'elderly') {
      return binding.relationType ?? '家人';
    } else {
      return binding.elderlyToChildRelation ?? binding.relationType ?? '家人';
    }
  }

  Widget _buildAvatar(String? avatar, int? gender, double size) {
    final effectiveRole = _getEffectiveRole();
    final defaultAvatar = effectiveRole == 'elderly'
        ? 'assets/choose_youths.jpeg'
        : 'assets/choose_oldMans.jpeg';

    if (avatar != null && avatar.isNotEmpty) {
      return ClipOval(
        child: Image.network(
          avatar,
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              image: DecorationImage(
                image: AssetImage(defaultAvatar),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        image: DecorationImage(
          image: AssetImage(defaultAvatar),
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
