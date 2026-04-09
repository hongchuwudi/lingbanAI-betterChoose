import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/user.dart';
import '../../services/family_service.dart';
import '../../widgets/notification/notification_helper.dart';
import '../health/health_data_manage_screen.dart';
import '../health/medication_check_in_screen.dart';

class ChildHealthScreen extends StatefulWidget {
  const ChildHealthScreen({super.key});

  @override
  State<ChildHealthScreen> createState() => _ChildHealthScreenState();
}

class _ChildHealthScreenState extends State<ChildHealthScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<FamilyBinding> _familyMembers = [];
  FamilyBinding? _selectedElderly;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadFamilyMembers();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadFamilyMembers() async {
    setState(() => _isLoading = true);
    try {
      final response = await FamilyService.getMyRelations();
      if (response.isSuccess && response.data != null) {
        final relations = response.data!;
        setState(() {
          _familyMembers = relations.where((b) => b.myRole == 'child').toList();
          if (_familyMembers.isNotEmpty && _selectedElderly == null) {
            _selectedElderly = _familyMembers.first;
          }
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        NotificationHelper.showError(message: '加载家人数据失败');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF1A1A2E)
          : const Color(0xFFF8F9FA),
      body: Column(
        children: [
          _buildHeader(isDark, colorScheme),
          if (_familyMembers.isNotEmpty)
            _buildElderlySelector(isDark, colorScheme),
          _buildTabBar(isDark, colorScheme),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _familyMembers.isEmpty
                ? _buildEmptyState(isDark, colorScheme)
                : TabBarView(
                    controller: _tabController,
                    children: [
                      HealthDataManageScreen(
                        isChildView: true,
                        elderlyProfileId: _selectedElderly?.elderlyProfileId
                            ?.toString(),
                      ),
                      MedicationCheckInScreen(),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(bool isDark, ColorScheme colorScheme) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 16,
        bottom: 16,
        left: 16,
        right: 16,
      ),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A2E) : const Color(0xFFF8F9FA),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              LucideIcons.heartPulse,
              size: 24,
              color: colorScheme.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '家人健康',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                Text(
                  '关爱家人，守护健康',
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
            onPressed: _loadFamilyMembers,
          ),
        ],
      ),
    );
  }

  Widget _buildElderlySelector(bool isDark, ColorScheme colorScheme) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF252542) : Colors.white,
        borderRadius: BorderRadius.circular(12),
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
                  setState(() => _selectedElderly = value);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar(bool isDark, ColorScheme colorScheme) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF252542) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
        ],
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: colorScheme.primary,
          borderRadius: BorderRadius.circular(10),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        indicatorPadding: const EdgeInsets.all(4),
        labelColor: Colors.white,
        unselectedLabelColor: isDark ? Colors.white54 : Colors.black45,
        labelStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        unselectedLabelStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.normal,
        ),
        tabs: const [
          Tab(icon: Icon(LucideIcons.activity, size: 18), text: '健康数据'),
          Tab(icon: Icon(LucideIcons.pill, size: 18), text: '用药情况'),
        ],
      ),
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
}
