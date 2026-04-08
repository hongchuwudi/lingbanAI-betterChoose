import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../models/user.dart';
import '../../../services/family_service.dart';
import '../../../widgets/notification/notification_helper.dart';

class AddFamilyScreen extends StatefulWidget {
  final VoidCallback onAdded;

  const AddFamilyScreen({super.key, required this.onAdded});

  @override
  State<AddFamilyScreen> createState() => _AddFamilyScreenState();
}

class _AddFamilyScreenState extends State<AddFamilyScreen> {
  final _nicknameController = TextEditingController();
  final _myRelationController = TextEditingController();
  final _targetRelationController = TextEditingController();
  String _selectedRelation = '';
  String _selectedElderlyToChildRelation = '';
  User? _foundUser;
  User? _currentUser;
  bool _isSearching = false;
  bool _isAdding = false;
  bool _isInitializing = true;

  bool _myRoleIsElderly = true;
  bool _useCustomMyRelation = false;
  bool _useCustomTargetRelation = false;

  final List<String> _childToElderlyRelationTypes = ['父亲', '母亲', '祖父', '祖母'];
  final List<String> _elderlyToChildRelationTypes = ['儿子', '女儿', '孙子', '孙女'];

  @override
  void initState() {
    super.initState();
    _initCurrentUser();
  }

  Future<void> _initCurrentUser() async {
    final user = await FamilyService.getCurrentUserInfo();
    if (mounted) {
      setState(() {
        _currentUser = user;
        _myRoleIsElderly = user?.elderlyProfile != null;
        _isInitializing = false;
      });
      _updateRelationTypes();
    }
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    _myRelationController.dispose();
    _targetRelationController.dispose();
    super.dispose();
  }

  void _updateRelationTypes() {
    _useCustomMyRelation = false;
    _useCustomTargetRelation = false;
    _myRelationController.clear();
    _targetRelationController.clear();
    if (_myRoleIsElderly) {
      _selectedRelation = _elderlyToChildRelationTypes.first;
      _selectedElderlyToChildRelation = _childToElderlyRelationTypes.first;
    } else {
      _selectedRelation = _childToElderlyRelationTypes.first;
      _selectedElderlyToChildRelation = _elderlyToChildRelationTypes.first;
    }
  }

  Future<void> _searchUser() async {
    if (_nicknameController.text.trim().isEmpty) {
      NotificationHelper.showWarning(message: '请输入用户昵称');
      return;
    }

    setState(() => _isSearching = true);

    final user = await FamilyService.searchUserByNickname(
      _nicknameController.text.trim(),
    );

    if (mounted) {
      setState(() {
        _isSearching = false;
        _foundUser = user;
      });

      if (user == null) {
        NotificationHelper.showError(message: '未找到该用户');
      } else if (user.id == _currentUser?.id) {
        setState(() => _foundUser = null);
        NotificationHelper.showWarning(message: '不能添加自己为家人');
      }
    }
  }

  Future<void> _addBinding() async {
    if (_foundUser == null) {
      NotificationHelper.showWarning(message: '请先搜索用户');
      return;
    }

    final myRelation = _useCustomMyRelation
        ? _myRelationController.text.trim()
        : _selectedRelation;
    final targetRelation = _useCustomTargetRelation
        ? _targetRelationController.text.trim()
        : _selectedElderlyToChildRelation;

    if (myRelation.isEmpty) {
      NotificationHelper.showWarning(message: '请输入或选择您对对方的称呼');
      return;
    }
    if (targetRelation.isEmpty) {
      NotificationHelper.showWarning(message: '请输入或选择对方对您的称呼');
      return;
    }

    setState(() => _isAdding = true);

    String elderlyProfileId;
    String childProfileId;
    String relationType;
    String elderlyToChildRelation;

    if (_myRoleIsElderly) {
      elderlyProfileId = _currentUser!.elderlyProfile!.id!;
      childProfileId = _foundUser!.childProfile?.id ?? '';
      relationType = myRelation;
      elderlyToChildRelation = targetRelation;
    } else {
      elderlyProfileId = _foundUser!.elderlyProfile?.id ?? '';
      childProfileId = _currentUser!.childProfile!.id!;
      relationType = targetRelation;
      elderlyToChildRelation = myRelation;
    }

    if (elderlyProfileId.isEmpty) {
      if (mounted) {
        setState(() => _isAdding = false);
        NotificationHelper.showWarning(
          message: '对方尚未创建老人身份档案，请让对方先在APP中创建身份后再添加家人关系',
          duration: const Duration(seconds: 4),
        );
      }
      return;
    }

    if (childProfileId.isEmpty) {
      if (mounted) {
        setState(() => _isAdding = false);
        NotificationHelper.showWarning(
          message: '对方尚未创建子女身份档案，请让对方先在APP中创建身份后再添加家人关系',
          duration: const Duration(seconds: 5),
        );
      }
      return;
    }

    final response = await FamilyService.addBinding(
      elderlyProfileId: elderlyProfileId,
      childProfileId: childProfileId,
      relationType: relationType,
      elderlyToChildRelation: elderlyToChildRelation,
    );

    if (mounted) {
      setState(() => _isAdding = false);

      if (response.isSuccess) {
        NotificationHelper.showSuccess(message: '绑定请求已发送');
        widget.onAdded();
        Navigator.of(context).pop();
      } else {
        NotificationHelper.showError(message: response.message);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('添加家人'),
        centerTitle: true,
        elevation: 0,
      ),
      body: _isInitializing
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSearchSection(isDark, colorScheme),
                  if (_foundUser != null) ...[
                    const SizedBox(height: 24),
                    _buildFoundUserCard(colorScheme),
                    const SizedBox(height: 24),
                    _buildRoleSelection(isDark, colorScheme),
                    const SizedBox(height: 24),
                    _buildMyRelationSection(isDark, colorScheme),
                    const SizedBox(height: 24),
                    _buildTargetRelationSection(isDark, colorScheme),
                    const SizedBox(height: 32),
                    _buildSubmitButton(colorScheme),
                  ],
                ],
              ),
            ),
    );
  }

  Widget _buildSearchSection(bool isDark, ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(20),
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
              Icon(LucideIcons.search, color: colorScheme.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                '搜索用户',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '输入对方昵称搜索用户',
            style: TextStyle(
              fontSize: 13,
              color: isDark ? Colors.white54 : Colors.black45,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _nicknameController,
                  decoration: InputDecoration(
                    hintText: '输入昵称',
                    prefixIcon: const Icon(LucideIcons.user, size: 20),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                  ),
                  onSubmitted: (_) => _searchUser(),
                ),
              ),
              const SizedBox(width: 12),
              Material(
                color: colorScheme.primary,
                borderRadius: BorderRadius.circular(12),
                child: InkWell(
                  onTap: _isSearching ? null : _searchUser,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 14,
                    ),
                    child: _isSearching
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(LucideIcons.search, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFoundUserCard(ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.primary.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              LucideIcons.userCheck,
              color: colorScheme.primary,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '找到用户',
                  style: TextStyle(
                    fontSize: 13,
                    color: colorScheme.primary.withValues(alpha: 0.8),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _foundUser!.nickname,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoleSelection(bool isDark, ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(20),
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
              Icon(
                LucideIcons.userCircle,
                color: colorScheme.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                '选择您的身份',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              if (_currentUser!.elderlyProfile != null)
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _myRoleIsElderly = true;
                        _updateRelationTypes();
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: _myRoleIsElderly
                            ? colorScheme.primary
                            : (isDark
                                  ? Colors.white.withValues(alpha: 0.1)
                                  : Colors.black.withValues(alpha: 0.05)),
                        borderRadius: BorderRadius.circular(12),
                        border: _myRoleIsElderly
                            ? null
                            : Border.all(
                                color: isDark ? Colors.white24 : Colors.black12,
                              ),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            LucideIcons.user,
                            color: _myRoleIsElderly
                                ? Colors.white
                                : (isDark ? Colors.white70 : Colors.black54),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '老人',
                            style: TextStyle(
                              color: _myRoleIsElderly
                                  ? Colors.white
                                  : (isDark ? Colors.white70 : Colors.black54),
                              fontWeight: _myRoleIsElderly
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              if (_currentUser!.elderlyProfile != null &&
                  _currentUser!.childProfile != null)
                const SizedBox(width: 16),
              if (_currentUser!.childProfile != null)
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _myRoleIsElderly = false;
                        _updateRelationTypes();
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: !_myRoleIsElderly
                            ? colorScheme.primary
                            : (isDark
                                  ? Colors.white.withValues(alpha: 0.1)
                                  : Colors.black.withValues(alpha: 0.05)),
                        borderRadius: BorderRadius.circular(12),
                        border: !_myRoleIsElderly
                            ? null
                            : Border.all(
                                color: isDark ? Colors.white24 : Colors.black12,
                              ),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            LucideIcons.users,
                            color: !_myRoleIsElderly
                                ? Colors.white
                                : (isDark ? Colors.white70 : Colors.black54),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '子女',
                            style: TextStyle(
                              color: !_myRoleIsElderly
                                  ? Colors.white
                                  : (isDark ? Colors.white70 : Colors.black54),
                              fontWeight: !_myRoleIsElderly
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMyRelationSection(bool isDark, ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(20),
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
              Icon(LucideIcons.heart, color: colorScheme.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                '您对对方的称呼',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children:
                (_myRoleIsElderly
                        ? _elderlyToChildRelationTypes
                        : _childToElderlyRelationTypes)
                    .map((type) {
                      final isSelected =
                          _selectedRelation == type && !_useCustomMyRelation;
                      return GestureDetector(
                        onTap: () => setState(() {
                          _useCustomMyRelation = false;
                          _selectedRelation = type;
                        }),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? colorScheme.primary
                                : (isDark
                                      ? Colors.white.withValues(alpha: 0.1)
                                      : Colors.black.withValues(alpha: 0.05)),
                            borderRadius: BorderRadius.circular(24),
                            border: isSelected
                                ? null
                                : Border.all(
                                    color: isDark
                                        ? Colors.white24
                                        : Colors.black12,
                                  ),
                          ),
                          child: Text(
                            type,
                            style: TextStyle(
                              color: isSelected
                                  ? Colors.white
                                  : (isDark ? Colors.white70 : Colors.black54),
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                            ),
                          ),
                        ),
                      );
                    })
                    .toList(),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _myRelationController,
            decoration: InputDecoration(
              hintText: '或自定义输入称呼',
              hintStyle: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.white38 : Colors.black38,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
              filled: _useCustomMyRelation,
              fillColor: _useCustomMyRelation
                  ? colorScheme.primary.withValues(alpha: 0.1)
                  : null,
              prefixIcon: Icon(
                LucideIcons.edit3,
                size: 18,
                color: _useCustomMyRelation
                    ? colorScheme.primary
                    : (isDark ? Colors.white38 : Colors.black38),
              ),
            ),
            onChanged: (value) {
              if (value.isNotEmpty && !_useCustomMyRelation) {
                setState(() => _useCustomMyRelation = true);
              } else if (value.isEmpty && _useCustomMyRelation) {
                setState(() => _useCustomMyRelation = false);
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTargetRelationSection(bool isDark, ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(20),
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
              Icon(
                LucideIcons.messageCircle,
                color: colorScheme.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                '对方对您的称呼',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children:
                (_myRoleIsElderly
                        ? _childToElderlyRelationTypes
                        : _elderlyToChildRelationTypes)
                    .map((type) {
                      final isSelected =
                          _selectedElderlyToChildRelation == type &&
                          !_useCustomTargetRelation;
                      return GestureDetector(
                        onTap: () => setState(() {
                          _useCustomTargetRelation = false;
                          _selectedElderlyToChildRelation = type;
                        }),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? colorScheme.primary
                                : (isDark
                                      ? Colors.white.withValues(alpha: 0.1)
                                      : Colors.black.withValues(alpha: 0.05)),
                            borderRadius: BorderRadius.circular(24),
                            border: isSelected
                                ? null
                                : Border.all(
                                    color: isDark
                                        ? Colors.white24
                                        : Colors.black12,
                                  ),
                          ),
                          child: Text(
                            type,
                            style: TextStyle(
                              color: isSelected
                                  ? Colors.white
                                  : (isDark ? Colors.white70 : Colors.black54),
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                            ),
                          ),
                        ),
                      );
                    })
                    .toList(),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _targetRelationController,
            decoration: InputDecoration(
              hintText: '或自定义输入称呼',
              hintStyle: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.white38 : Colors.black38,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
              filled: _useCustomTargetRelation,
              fillColor: _useCustomTargetRelation
                  ? colorScheme.primary.withValues(alpha: 0.1)
                  : null,
              prefixIcon: Icon(
                LucideIcons.edit3,
                size: 18,
                color: _useCustomTargetRelation
                    ? colorScheme.primary
                    : (isDark ? Colors.white38 : Colors.black38),
              ),
            ),
            onChanged: (value) {
              if (value.isNotEmpty && !_useCustomTargetRelation) {
                setState(() => _useCustomTargetRelation = true);
              } else if (value.isEmpty && _useCustomTargetRelation) {
                setState(() => _useCustomTargetRelation = false);
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton(ColorScheme colorScheme) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isAdding ? null : _addBinding,
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: _isAdding
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : const Text(
                '发送绑定请求',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
      ),
    );
  }
}
