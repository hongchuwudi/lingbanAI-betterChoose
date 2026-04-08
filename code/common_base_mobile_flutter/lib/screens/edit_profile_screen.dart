import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:image_picker/image_picker.dart';
import '../models/user.dart';
import '../providers/auth_provider.dart';
import '../services/auth_service.dart';
import '../widgets/notification/notification_helper.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _isUploadingAvatar = false;
  bool _isLoadingElderlyProfile = false;
  bool _isElderlyUser = false;
  String? _currentUsername;
  int? _updateUnTimes;

  final _nicknameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _bioController = TextEditingController();

  int? _gender;
  String? _birthday;
  final ImagePicker _imagePicker = ImagePicker();

  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  final _addressController = TextEditingController();
  final _emergencyNameController = TextEditingController();
  final _emergencyPhoneController = TextEditingController();
  final _emergencyRelationController = TextEditingController();
  final _medicalHistoryController = TextEditingController();

  String _bloodType = 'unk';
  String _livingStatus = 'alone';
  final List<String> _selectedDiseases = [];
  final List<String> _selectedAllergies = [];
  final List<String> _selectedDietRestrictions = [];

  final List<String> _diseaseOptions = [
    '高血压',
    '糖尿病',
    '心脏病',
    '高血脂',
    '关节炎',
    '哮喘',
    '其他',
  ];

  final List<String> _allergyOptions = ['青霉素', '海鲜', '花粉', '尘螨', '其他'];

  final List<String> _dietRestrictionOptions = ['低盐', '低糖', '低脂', '素食', '其他'];

  final List<String> _bloodTypeOptions = ['A', 'B', 'AB', 'O', '未知'];

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final authStore = Provider.of<AuthStore>(context, listen: false);
    await authStore.init();

    if (mounted) {
      final user = authStore.user;
      setState(() {
        if (user != null) {
          _nicknameController.text = user.nickname;
          _phoneController.text = user.phone ?? '';
          _emailController.text = user.email ?? '';
          _bioController.text = user.bio ?? '';
          _gender = user.gender;
          _birthday = user.birthday;
          _isElderlyUser = user.roleCode == 'oldMan';
          _currentUsername = user.username;
          _updateUnTimes = user.updateUnTimes;
        }
      });

      if (_isElderlyUser) {
        _loadElderlyProfile();
      }
    }
  }

  Future<void> _loadElderlyProfile() async {
    setState(() {
      _isLoadingElderlyProfile = true;
    });

    try {
      final result = await AuthService.getElderlyProfile();

      if (mounted && result['success'] && result['data'] != null) {
        final profile = result['data'];
        setState(() {
          if (profile['height'] != null) {
            _heightController.text = profile['height'].toString();
          }
          if (profile['weight'] != null) {
            _weightController.text = profile['weight'].toString();
          }
          if (profile['address'] != null) {
            _addressController.text = profile['address'];
          }
          if (profile['bloodType'] != null) {
            _bloodType = profile['bloodType'];
          }
          if (profile['livingStatus'] != null) {
            _livingStatus = profile['livingStatus'];
          }
          if (profile['medicalHistory'] != null) {
            _medicalHistoryController.text = profile['medicalHistory'];
          }

          if (profile['chronicDiseases'] != null) {
            try {
              final diseases = jsonDecode(profile['chronicDiseases']) as List;
              _selectedDiseases.clear();
              _selectedDiseases.addAll(diseases.map((e) => e.toString()));
            } catch (e) {}
          }

          if (profile['allergies'] != null) {
            try {
              final allergies = jsonDecode(profile['allergies']) as List;
              _selectedAllergies.clear();
              _selectedAllergies.addAll(allergies.map((e) => e.toString()));
            } catch (e) {}
          }

          if (profile['dietRestrictions'] != null) {
            try {
              final restrictions =
                  jsonDecode(profile['dietRestrictions']) as List;
              _selectedDietRestrictions.clear();
              _selectedDietRestrictions.addAll(
                restrictions.map((e) => e.toString()),
              );
            } catch (e) {}
          }

          if (profile['emergencyContact'] != null) {
            try {
              final contact = jsonDecode(profile['emergencyContact']);
              _emergencyNameController.text = contact['name'] ?? '';
              _emergencyPhoneController.text = contact['phone'] ?? '';
              _emergencyRelationController.text = contact['relation'] ?? '';
            } catch (e) {}
          }
        });
      }
    } catch (e) {
      debugPrint('加载老人档案失败: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingElderlyProfile = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _bioController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _addressController.dispose();
    _emergencyNameController.dispose();
    _emergencyPhoneController.dispose();
    _emergencyRelationController.dispose();
    _medicalHistoryController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final authStore = Provider.of<AuthStore>(context, listen: false);
      final user = authStore.user;

      if (user == null) {
        if (mounted) {
          NotificationHelper.showError(message: '用户信息不存在，请重新登录');
        }
        return;
      }

      final profileData = {
        'id': user.id,
        'nickname': _nicknameController.text.trim(),
        'phone': _phoneController.text.trim().isEmpty
            ? null
            : _phoneController.text.trim(),
        'email': _emailController.text.trim().isEmpty
            ? null
            : _emailController.text.trim(),
        'bio': _bioController.text.trim().isEmpty
            ? null
            : _bioController.text.trim(),
        'gender': _gender,
        'birthday': _birthday,
      };

      final result = await AuthService.updateUserInfo(profileData);

      if (!result['success']) {
        if (mounted) {
          NotificationHelper.showError(
            message: result['message'] ?? '修改失败，请重试',
          );
        }
        return;
      }

      if (_isElderlyUser) {
        final elderlyProfileData = {
          'height': _heightController.text.trim().isEmpty
              ? null
              : double.tryParse(_heightController.text.trim()),
          'weight': _weightController.text.trim().isEmpty
              ? null
              : double.tryParse(_weightController.text.trim()),
          'address': _addressController.text.trim().isEmpty
              ? null
              : _addressController.text.trim(),
          'bloodType': _bloodType,
          'livingStatus': _livingStatus,
          'medicalHistory': _medicalHistoryController.text.trim().isEmpty
              ? null
              : _medicalHistoryController.text.trim(),
          'chronicDiseases': jsonEncode(_selectedDiseases),
          'allergies': jsonEncode(_selectedAllergies),
          'dietRestrictions': jsonEncode(_selectedDietRestrictions),
          'emergencyContact': jsonEncode({
            'name': _emergencyNameController.text.trim(),
            'phone': _emergencyPhoneController.text.trim(),
            'relation': _emergencyRelationController.text.trim(),
          }),
        };

        final elderlyResult = await AuthService.updateElderlyProfile(
          elderlyProfileData,
        );

        if (!elderlyResult['success']) {
          if (mounted) {
            NotificationHelper.showError(
              message: elderlyResult['message'] ?? '老人档案更新失败',
            );
          }
          return;
        }
      }

      if (mounted) {
        NotificationHelper.showSuccess(message: '修改成功');
        await authStore.init();
        if (context.mounted) {
          Navigator.pop(context);
        }
      }
    } catch (e) {
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
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(LucideIcons.arrowLeft, color: colorScheme.onSurface),
        ),
        title: Text(
          '编辑资料',
          style: TextStyle(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _submitForm,
            child: Text(
              '保存',
              style: TextStyle(
                color: colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildAvatarSection(context, colorScheme),
              const SizedBox(height: 24),
              _buildSectionTitle('基本信息', colorScheme),
              const SizedBox(height: 12),
              _buildUsernameField(colorScheme),
              const SizedBox(height: 16),
              _buildNicknameField(colorScheme),
              const SizedBox(height: 16),
              _buildPhoneField(colorScheme),
              const SizedBox(height: 16),
              _buildEmailField(colorScheme),
              const SizedBox(height: 16),
              _buildGenderSelector(colorScheme),
              const SizedBox(height: 16),
              _buildBirthdayField(colorScheme),
              const SizedBox(height: 16),
              _buildBioField(colorScheme),
              if (_isElderlyUser) ...[
                const SizedBox(height: 32),
                _buildSectionTitle('健康档案', colorScheme),
                const SizedBox(height: 12),
                if (_isLoadingElderlyProfile)
                  const Center(child: CircularProgressIndicator())
                else ...[
                  _buildBloodTypeSelector(colorScheme),
                  const SizedBox(height: 16),
                  _buildHeightWeightRow(colorScheme),
                  const SizedBox(height: 16),
                  _buildLivingStatusSelector(colorScheme),
                  const SizedBox(height: 16),
                  _buildAddressField(colorScheme),
                  const SizedBox(height: 16),
                  _buildDiseaseSelector(colorScheme),
                  const SizedBox(height: 16),
                  _buildAllergySelector(colorScheme),
                  const SizedBox(height: 16),
                  _buildDietRestrictionSelector(colorScheme),
                  const SizedBox(height: 16),
                  _buildMedicalHistoryField(colorScheme),
                  const SizedBox(height: 24),
                  _buildSectionTitle('紧急联系人', colorScheme),
                  const SizedBox(height: 12),
                  _buildEmergencyContactFields(colorScheme),
                ],
              ],
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, ColorScheme colorScheme) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            color: colorScheme.primary,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
      ],
    );
  }

  Widget _buildAvatarSection(BuildContext context, ColorScheme colorScheme) {
    final authStore = Provider.of<AuthStore>(context, listen: false);
    final user = authStore.user;
    final isElder = user?.roleCode == 'oldMan';
    final defaultAvatar = isElder
        ? 'assets/choose_oldMans.jpeg'
        : 'assets/choose_youths.jpeg';

    return Center(
      child: Column(
        children: [
          GestureDetector(
            onTap: _pickAndUploadAvatar,
            child: Stack(
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    shape: BoxShape.circle,
                  ),
                  child: _isUploadingAvatar
                      ? const CircularProgressIndicator()
                      : user?.avatar != null && user!.avatar!.isNotEmpty
                      ? ClipOval(
                          child: Image.network(
                            user.avatar!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Image.asset(
                                defaultAvatar,
                                fit: BoxFit.cover,
                              );
                            },
                          ),
                        )
                      : Image.asset(defaultAvatar, fit: BoxFit.cover),
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: colorScheme.primary,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.camera_alt,
                      size: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '点击更换头像',
            style: TextStyle(fontSize: 14, color: colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }

  Future<void> _pickAndUploadAvatar() async {
    if (_isUploadingAvatar) return;

    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (image == null) return;

      setState(() {
        _isUploadingAvatar = true;
      });

      final uploadResult = await AuthService.uploadFile(
        image,
        bizType: 'avatar',
      );

      if (mounted) {
        if (uploadResult['success']) {
          final fileUrl = uploadResult['data']['fileUrl'];

          final updateResult = await AuthService.updateAvatar(fileUrl);

          if (updateResult['success']) {
            NotificationHelper.showSuccess(message: '头像更新成功');
            await _loadUserData();
          } else {
            NotificationHelper.showError(
              message: updateResult['message'] ?? '头像更新失败',
            );
          }
        } else {
          NotificationHelper.showError(
            message: uploadResult['message'] ?? '上传失败',
          );
        }
      }
    } catch (e) {
      if (mounted) {
        NotificationHelper.showError(message: '选择图片失败，请重试');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUploadingAvatar = false;
        });
      }
    }
  }

  Widget _buildNicknameField(ColorScheme colorScheme) {
    return TextFormField(
      controller: _nicknameController,
      decoration: InputDecoration(
        labelText: '昵称',
        prefixIcon: Icon(LucideIcons.user, color: colorScheme.primary),
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
        filled: true,
        fillColor: colorScheme.surfaceContainerHighest,
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return '请输入昵称';
        }
        return null;
      },
    );
  }

  Widget _buildPhoneField(ColorScheme colorScheme) {
    return TextFormField(
      controller: _phoneController,
      keyboardType: TextInputType.phone,
      decoration: InputDecoration(
        labelText: '手机号',
        prefixIcon: Icon(LucideIcons.phone, color: colorScheme.primary),
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
        filled: true,
        fillColor: colorScheme.surfaceContainerHighest,
      ),
    );
  }

  Widget _buildEmailField(ColorScheme colorScheme) {
    return TextFormField(
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      decoration: InputDecoration(
        labelText: '邮箱',
        prefixIcon: Icon(LucideIcons.mail, color: colorScheme.primary),
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
        filled: true,
        fillColor: colorScheme.surfaceContainerHighest,
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
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            _buildGenderOption(
              colorScheme: colorScheme,
              value: 1,
              label: '男',
              icon: Icons.male,
            ),
            const SizedBox(width: 16),
            _buildGenderOption(
              colorScheme: colorScheme,
              value: 2,
              label: '女',
              icon: Icons.female,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildGenderOption({
    required ColorScheme colorScheme,
    required int value,
    required String label,
    required IconData icon,
  }) {
    final isSelected = _gender == value;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _gender = value;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: isSelected
                ? colorScheme.primaryContainer
                : colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? colorScheme.primary : colorScheme.outline,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: isSelected
                    ? colorScheme.onPrimaryContainer
                    : colorScheme.onSurfaceVariant,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: isSelected
                      ? colorScheme.onPrimaryContainer
                      : colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBirthdayField(ColorScheme colorScheme) {
    return GestureDetector(
      onTap: () => _selectBirthday(context, colorScheme),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: colorScheme.outline),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(LucideIcons.calendar, color: colorScheme.primary),
                const SizedBox(width: 12),
                Text(
                  '生日',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Text(
                  _birthday ?? '请选择生日',
                  style: TextStyle(
                    fontSize: 16,
                    color: _birthday != null
                        ? colorScheme.onSurface
                        : colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  LucideIcons.chevronRight,
                  size: 20,
                  color: colorScheme.onSurfaceVariant,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBioField(ColorScheme colorScheme) {
    return TextFormField(
      controller: _bioController,
      maxLines: 3,
      decoration: InputDecoration(
        labelText: '个人简介',
        prefixIcon: Icon(LucideIcons.fileText, color: colorScheme.primary),
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
        filled: true,
        fillColor: colorScheme.surfaceContainerHighest,
      ),
    );
  }

  Widget _buildBloodTypeSelector(ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '血型',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 12,
          runSpacing: 8,
          children: _bloodTypeOptions.map((type) {
            final value = type == '未知' ? 'unk' : type;
            final isSelected = _bloodType == value;
            return GestureDetector(
              onTap: () {
                setState(() {
                  _bloodType = value;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? colorScheme.primaryContainer
                      : colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected
                        ? colorScheme.primary
                        : colorScheme.outline,
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Text(
                  type,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: isSelected
                        ? colorScheme.onPrimaryContainer
                        : colorScheme.onSurface,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildHeightWeightRow(ColorScheme colorScheme) {
    return Row(
      children: [
        Expanded(
          child: TextFormField(
            controller: _heightController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: '身高(cm)',
              prefixIcon: Icon(LucideIcons.ruler, color: colorScheme.primary),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: colorScheme.surfaceContainerHighest,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: TextFormField(
            controller: _weightController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: '体重(kg)',
              prefixIcon: Icon(LucideIcons.scale, color: colorScheme.primary),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: colorScheme.surfaceContainerHighest,
            ),
          ),
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
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildLivingStatusOption(
                colorScheme: colorScheme,
                value: 'alone',
                label: '独居',
                icon: LucideIcons.home,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildLivingStatusOption(
                colorScheme: colorScheme,
                value: 'with_family',
                label: '与家人同住',
                icon: LucideIcons.users,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLivingStatusOption({
    required ColorScheme colorScheme,
    required String value,
    required String label,
    required IconData icon,
  }) {
    final isSelected = _livingStatus == value;
    return GestureDetector(
      onTap: () {
        setState(() {
          _livingStatus = value;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isSelected
              ? colorScheme.primaryContainer
              : colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? colorScheme.primary : colorScheme.outline,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected
                  ? colorScheme.onPrimaryContainer
                  : colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: isSelected
                    ? colorScheme.onPrimaryContainer
                    : colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddressField(ColorScheme colorScheme) {
    return TextFormField(
      controller: _addressController,
      maxLines: 2,
      decoration: InputDecoration(
        labelText: '居住地址',
        prefixIcon: Icon(LucideIcons.mapPin, color: colorScheme.primary),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: colorScheme.surfaceContainerHighest,
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
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 10,
          runSpacing: 8,
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
              selectedColor: colorScheme.primaryContainer,
              checkmarkColor: colorScheme.primary,
              side: BorderSide(
                color: isSelected ? colorScheme.primary : colorScheme.outline,
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
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 10,
          runSpacing: 8,
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
              selectedColor: colorScheme.primaryContainer,
              checkmarkColor: colorScheme.primary,
              side: BorderSide(
                color: isSelected ? colorScheme.primary : colorScheme.outline,
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
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 10,
          runSpacing: 8,
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
              selectedColor: colorScheme.primaryContainer,
              checkmarkColor: colorScheme.primary,
              side: BorderSide(
                color: isSelected ? colorScheme.primary : colorScheme.outline,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildMedicalHistoryField(ColorScheme colorScheme) {
    return TextFormField(
      controller: _medicalHistoryController,
      maxLines: 3,
      decoration: InputDecoration(
        labelText: '既往病史',
        prefixIcon: Icon(LucideIcons.fileText, color: colorScheme.primary),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: colorScheme.surfaceContainerHighest,
        hintText: '请输入既往病史',
      ),
    );
  }

  Widget _buildEmergencyContactFields(ColorScheme colorScheme) {
    return Column(
      children: [
        TextFormField(
          controller: _emergencyNameController,
          decoration: InputDecoration(
            labelText: '联系人姓名',
            prefixIcon: Icon(LucideIcons.user, color: colorScheme.primary),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            filled: true,
            fillColor: colorScheme.surfaceContainerHighest,
          ),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _emergencyPhoneController,
          keyboardType: TextInputType.phone,
          decoration: InputDecoration(
            labelText: '联系人电话',
            prefixIcon: Icon(LucideIcons.phone, color: colorScheme.primary),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            filled: true,
            fillColor: colorScheme.surfaceContainerHighest,
          ),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _emergencyRelationController,
          decoration: InputDecoration(
            labelText: '与您的关系',
            prefixIcon: Icon(LucideIcons.heart, color: colorScheme.primary),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            filled: true,
            fillColor: colorScheme.surfaceContainerHighest,
            hintText: '如：儿子、女儿',
          ),
        ),
      ],
    );
  }

  Future<void> _selectBirthday(
    BuildContext context,
    ColorScheme colorScheme,
  ) async {
    DateTime? initialDate;
    if (_birthday != null) {
      try {
        initialDate = DateTime.parse(_birthday!);
      } catch (e) {
        initialDate = DateTime.now();
      }
    } else {
      initialDate = DateTime.now();
    }

    final selected = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (selected != null) {
      setState(() {
        _birthday = _formatDate(selected);
      });
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  Widget _buildUsernameField(ColorScheme colorScheme) {
    final canUpdate = (_updateUnTimes ?? 0) > 0;
    return GestureDetector(
      onTap: canUpdate ? () => _showUpdateUsernameDialog(colorScheme) : null,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: colorScheme.outline),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(LucideIcons.atSign, color: colorScheme.primary),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '用户名',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    Text(
                      '剩余修改次数: ${_updateUnTimes ?? 0}次',
                      style: TextStyle(
                        fontSize: 12,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            Row(
              children: [
                Text(
                  _currentUsername ?? '',
                  style: TextStyle(fontSize: 16, color: colorScheme.onSurface),
                ),
                const SizedBox(width: 8),
                Icon(
                  canUpdate ? LucideIcons.chevronRight : LucideIcons.lock,
                  size: 20,
                  color: canUpdate
                      ? colorScheme.onSurfaceVariant
                      : colorScheme.error,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showUpdateUsernameDialog(ColorScheme colorScheme) {
    final usernameController = TextEditingController();
    final passwordController = TextEditingController();
    bool isLoading = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: const Text('修改用户名'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '当前用户名: $_currentUsername',
                    style: TextStyle(
                      color: colorScheme.onSurfaceVariant,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    '剩余修改次数: ${_updateUnTimes ?? 0}次',
                    style: TextStyle(color: colorScheme.primary, fontSize: 12),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: usernameController,
                    decoration: InputDecoration(
                      labelText: '新用户名',
                      hintText: '请输入新用户名(4-20位字母数字)',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: colorScheme.surfaceContainerHighest,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: '密码验证',
                      hintText: '请输入密码以验证身份',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: colorScheme.surfaceContainerHighest,
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('取消'),
              ),
              ElevatedButton(
                onPressed: isLoading
                    ? null
                    : () async {
                        final newUsername = usernameController.text.trim();
                        if (newUsername.isEmpty) {
                          NotificationHelper.showError(message: '请输入新用户名');
                          return;
                        }
                        if (newUsername.length < 4 || newUsername.length > 20) {
                          NotificationHelper.showError(message: '用户名长度需为4-20位');
                          return;
                        }
                        if (!RegExp(r'^[a-zA-Z0-9]+$').hasMatch(newUsername)) {
                          NotificationHelper.showError(message: '用户名只能包含字母和数字');
                          return;
                        }

                        final password = passwordController.text.trim();
                        if (password.isEmpty) {
                          NotificationHelper.showError(message: '请输入密码');
                          return;
                        }

                        setDialogState(() {
                          isLoading = true;
                        });

                        try {
                          final result = await AuthService.updateUsername(
                            newUsername,
                            password,
                            '',
                          );

                          if (result['success']) {
                            NotificationHelper.showSuccess(message: '用户名修改成功');
                            Navigator.pop(context);
                            await _loadUserData();
                          } else {
                            NotificationHelper.showError(
                              message: result['message'] ?? '修改失败',
                            );
                          }
                        } finally {
                          setDialogState(() {
                            isLoading = false;
                          });
                        }
                      },
                child: isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('确认'),
              ),
            ],
          );
        },
      ),
    );
  }
}
