import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/auth_service.dart';
import '../services/websocket_service.dart';
import '../widgets/notification/notification_helper.dart';

/// 老人信息填写页面
///
/// 功能说明：
/// - 用户选择老人身份后进入此页面
/// - 填写老人基本信息、健康状况、紧急联系人等
/// - 提交后创建老人档案
class ElderlyProfileScreen extends StatefulWidget {
  const ElderlyProfileScreen({super.key});

  @override
  State<ElderlyProfileScreen> createState() => _ElderlyProfileScreenState();
}

class _ElderlyProfileScreenState extends State<ElderlyProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  // 表单控制器
  final _nicknameController = TextEditingController();
  final _addressController = TextEditingController();
  final _emergencyNameController = TextEditingController();
  final _emergencyPhoneController = TextEditingController();
  final _emergencyRelationController = TextEditingController();

  // 选择项
  DateTime? _selectedBirthday;
  int _selectedGender = 1; // 1: 男, 2: 女
  String _livingStatus = 'alone'; // alone: 独居, with_family: 与家人同住
  final List<String> _selectedDiseases = [];
  final List<String> _selectedAllergies = [];
  final List<String> _selectedDietRestrictions = [];

  // 慢性病选项
  final List<String> _diseaseOptions = [
    '高血压',
    '糖尿病',
    '心脏病',
    '高血脂',
    '关节炎',
    '哮喘',
    '其他',
  ];

  // 过敏史选项
  final List<String> _allergyOptions = ['青霉素', '海鲜', '花粉', '尘螨', '其他'];

  // 饮食禁忌选项
  final List<String> _dietRestrictionOptions = ['低盐', '低糖', '低脂', '素食', '其他'];

  @override
  void dispose() {
    _nicknameController.dispose();
    _addressController.dispose();
    _emergencyNameController.dispose();
    _emergencyPhoneController.dispose();
    _emergencyRelationController.dispose();
    super.dispose();
  }

  /// 选择生日
  Future<void> _selectBirthday() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(1950),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _selectedBirthday = picked;
      });
    }
  }

  /// 提交表单
  Future<void> _submitForm() async {
    // 验证表单
    if (!_formKey.currentState!.validate()) {
      debugPrint('表单验证失败');
      return;
    }

    // 验证生日是否已选择
    if (_selectedBirthday == null) {
      NotificationHelper.showWarning(message: '请选择生日');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final profileData = {
        'nickname': _nicknameController.text.trim(),
        'birthday': _selectedBirthday!.toIso8601String().split('T')[0],
        'gender': _selectedGender,
        'chronicDiseases': jsonEncode(_selectedDiseases),
        'allergies': jsonEncode(_selectedAllergies),
        'livingStatus': _livingStatus,
        'address': _addressController.text.trim().isEmpty
            ? null
            : _addressController.text.trim(),
        'emergencyContact': jsonEncode({
          'name': _emergencyNameController.text.trim(),
          'phone': _emergencyPhoneController.text.trim(),
          'relation': _emergencyRelationController.text.trim(),
        }),
        'dietRestrictions': jsonEncode(_selectedDietRestrictions),
      };

      debugPrint('提交数据: $profileData');

      final result = await AuthService.createElderlyProfile(profileData);

      debugPrint('响应结果: $result');

      if (mounted) {
        if (result['success']) {
          NotificationHelper.showSuccess(message: '档案创建成功');
          final authStore = Provider.of<AuthStore>(context, listen: false);
          await authStore.init();
          WebSocketService().connect();
          Navigator.pushReplacementNamed(context, '/main');
        } else {
          NotificationHelper.showError(
            message: result['message'] ?? '创建失败，请重试',
          );
        }
      }
    } catch (e) {
      debugPrint('提交错误: $e');
      if (mounted) {
        NotificationHelper.showError(message: '网络错误，请重试');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(LucideIcons.arrowLeft, color: colorScheme.onSurface),
        ),
        title: Text(
          '完善老人信息',
          style: TextStyle(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 标题
              Text(
                '请完善您的基本信息',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '这些信息将帮助我们更好地为您提供服务',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface.withAlpha(153),
                ),
              ),
              const SizedBox(height: 32),

              // 昵称
              _buildTextField(
                controller: _nicknameController,
                label: '昵称',
                hint: '请输入您的昵称',
                icon: LucideIcons.user,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '请输入昵称';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // 生日选择
              _buildBirthdayField(colorScheme),
              const SizedBox(height: 20),

              // 性别选择
              _buildGenderSelector(colorScheme),
              const SizedBox(height: 20),

              // 居住状态
              _buildLivingStatusSelector(colorScheme),
              const SizedBox(height: 20),

              // 地址
              _buildTextField(
                controller: _addressController,
                label: '居住地址',
                hint: '请输入您的居住地址',
                icon: LucideIcons.mapPin,
                maxLines: 2,
              ),
              const SizedBox(height: 32),

              // 慢性病选择
              _buildDiseaseSelector(colorScheme),
              const SizedBox(height: 24),

              // 过敏史选择
              _buildAllergySelector(colorScheme),
              const SizedBox(height: 24),

              // 饮食禁忌选择
              _buildDietRestrictionSelector(colorScheme),
              const SizedBox(height: 32),

              // 紧急联系人
              Text(
                '紧急联系人',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _emergencyNameController,
                label: '联系人姓名',
                hint: '请输入联系人姓名',
                icon: LucideIcons.user,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '请输入联系人姓名';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _emergencyPhoneController,
                label: '联系人电话',
                hint: '请输入联系人电话',
                icon: LucideIcons.phone,
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '请输入联系人电话';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _emergencyRelationController,
                label: '与您的关系',
                hint: '如：儿子、女儿',
                icon: LucideIcons.heart,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '请输入与您的关系';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 40),

              // 提交按钮
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: colorScheme.onPrimary,
                          ),
                        )
                      : const Text(
                          '完成',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: colorScheme.primary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.outline.withAlpha(77)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
      ),
    );
  }

  Widget _buildBirthdayField(ColorScheme colorScheme) {
    return InkWell(
      onTap: _selectBirthday,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: '生日',
          prefixIcon: Icon(LucideIcons.calendar, color: colorScheme.primary),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: Text(
          _selectedBirthday == null
              ? '请选择生日'
              : '${_selectedBirthday!.year}-${_selectedBirthday!.month.toString().padLeft(2, '0')}-${_selectedBirthday!.day.toString().padLeft(2, '0')}',
          style: TextStyle(
            color: _selectedBirthday == null
                ? colorScheme.onSurface.withAlpha(153)
                : colorScheme.onSurface,
          ),
        ),
      ),
    );
  }

  Widget _buildGenderSelector(ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '性别',
          style: TextStyle(
            fontSize: 14,
            color: colorScheme.onSurface.withAlpha(153),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildSelectableCard(
                title: '男',
                icon: LucideIcons.user,
                isSelected: _selectedGender == 1,
                onTap: () => setState(() => _selectedGender = 1),
                colorScheme: colorScheme,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildSelectableCard(
                title: '女',
                icon: LucideIcons.user,
                isSelected: _selectedGender == 2,
                onTap: () => setState(() => _selectedGender = 2),
                colorScheme: colorScheme,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLivingStatusSelector(ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '居住状态',
          style: TextStyle(
            fontSize: 14,
            color: colorScheme.onSurface.withAlpha(153),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildSelectableCard(
                title: '独居',
                icon: LucideIcons.home,
                isSelected: _livingStatus == 'alone',
                onTap: () => setState(() => _livingStatus = 'alone'),
                colorScheme: colorScheme,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildSelectableCard(
                title: '与家人同住',
                icon: LucideIcons.users,
                isSelected: _livingStatus == 'with_family',
                onTap: () => setState(() => _livingStatus = 'with_family'),
                colorScheme: colorScheme,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSelectableCard({
    required String title,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
    required ColorScheme colorScheme,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected
                ? colorScheme.primary
                : colorScheme.outline.withAlpha(77),
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
          color: isSelected ? colorScheme.primary.withAlpha(26) : null,
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected
                  ? colorScheme.primary
                  : colorScheme.onSurface.withAlpha(153),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                color: isSelected ? colorScheme.primary : colorScheme.onSurface,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDiseaseSelector(ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '慢性病（多选）',
          style: TextStyle(
            fontSize: 14,
            color: colorScheme.onSurface.withAlpha(153),
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: _diseaseOptions.map((disease) {
            final isSelected = _selectedDiseases.contains(disease);
            return FilterChip(
              label: Text(disease),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _selectedDiseases.add(disease);
                  } else {
                    _selectedDiseases.remove(disease);
                  }
                });
              },
              selectedColor: colorScheme.primary.withAlpha(51),
              checkmarkColor: colorScheme.primary,
              side: BorderSide(
                color: isSelected
                    ? colorScheme.primary
                    : colorScheme.outline.withAlpha(77),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildAllergySelector(ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '过敏史（多选）',
          style: TextStyle(
            fontSize: 14,
            color: colorScheme.onSurface.withAlpha(153),
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: _allergyOptions.map((allergy) {
            final isSelected = _selectedAllergies.contains(allergy);
            return FilterChip(
              label: Text(allergy),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _selectedAllergies.add(allergy);
                  } else {
                    _selectedAllergies.remove(allergy);
                  }
                });
              },
              selectedColor: colorScheme.primary.withAlpha(51),
              checkmarkColor: colorScheme.primary,
              side: BorderSide(
                color: isSelected
                    ? colorScheme.primary
                    : colorScheme.outline.withAlpha(77),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildDietRestrictionSelector(ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '饮食禁忌（多选）',
          style: TextStyle(
            fontSize: 14,
            color: colorScheme.onSurface.withAlpha(153),
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: _dietRestrictionOptions.map((restriction) {
            final isSelected = _selectedDietRestrictions.contains(restriction);
            return FilterChip(
              label: Text(restriction),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _selectedDietRestrictions.add(restriction);
                  } else {
                    _selectedDietRestrictions.remove(restriction);
                  }
                });
              },
              selectedColor: colorScheme.primary.withAlpha(51),
              checkmarkColor: colorScheme.primary,
              side: BorderSide(
                color: isSelected
                    ? colorScheme.primary
                    : colorScheme.outline.withAlpha(77),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
