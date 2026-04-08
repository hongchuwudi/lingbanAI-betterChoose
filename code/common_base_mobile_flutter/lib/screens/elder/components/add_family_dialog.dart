import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../models/user.dart';
import '../../../services/family_service.dart';
import '../../../widgets/notification/notification_helper.dart';

class AddFamilyDialog extends StatefulWidget {
  final VoidCallback onAdded;

  const AddFamilyDialog({super.key, required this.onAdded});

  @override
  State<AddFamilyDialog> createState() => _AddFamilyDialogState();
}

class _AddFamilyDialogState extends State<AddFamilyDialog> {
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
      } else {
        NotificationHelper.showError(message: response.message);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;

    if (_isInitializing) {
      return AlertDialog(
        title: const Text(
          '添加家人',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: const SizedBox(
          height: 60,
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    return AlertDialog(
      title: const Text('添加家人', style: TextStyle(fontWeight: FontWeight.w600)),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '输入对方昵称搜索用户',
              style: TextStyle(
                fontSize: 13,
                color: isDark ? Colors.white54 : Colors.black45,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _nicknameController,
                    decoration: InputDecoration(
                      hintText: '输入昵称',
                      prefixIcon: const Icon(LucideIcons.search, size: 20),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: _isSearching ? null : _searchUser,
                  icon: _isSearching
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(LucideIcons.search),
                  style: IconButton.styleFrom(
                    backgroundColor: colorScheme.primary.withValues(alpha: 0.1),
                    foregroundColor: colorScheme.primary,
                  ),
                ),
              ],
            ),
            if (_foundUser != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(LucideIcons.userCheck, color: colorScheme.primary),
                    const SizedBox(width: 10),
                    Text(
                      '找到用户：${_foundUser!.nickname}',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Text(
                '选择您的身份',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: isDark ? Colors.white70 : Colors.black54,
                ),
              ),
              const SizedBox(height: 12),
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
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: _myRoleIsElderly
                                ? colorScheme.primary
                                : (isDark
                                      ? Colors.white.withValues(alpha: 0.1)
                                      : Colors.black.withValues(alpha: 0.05)),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '老人',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: _myRoleIsElderly
                                  ? Colors.white
                                  : (isDark ? Colors.white70 : Colors.black54),
                              fontWeight: _myRoleIsElderly
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                            ),
                          ),
                        ),
                      ),
                    ),
                  if (_currentUser!.elderlyProfile != null &&
                      _currentUser!.childProfile != null)
                    const SizedBox(width: 12),
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
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: !_myRoleIsElderly
                                ? colorScheme.primary
                                : (isDark
                                      ? Colors.white.withValues(alpha: 0.1)
                                      : Colors.black.withValues(alpha: 0.05)),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '子女',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: !_myRoleIsElderly
                                  ? Colors.white
                                  : (isDark ? Colors.white70 : Colors.black54),
                              fontWeight: !_myRoleIsElderly
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                '您对对方的称呼',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: isDark ? Colors.white70 : Colors.black54,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children:
                    (_myRoleIsElderly
                            ? _elderlyToChildRelationTypes
                            : _childToElderlyRelationTypes)
                        .map((type) {
                          final isSelected =
                              _selectedRelation == type &&
                              !_useCustomMyRelation;
                          return GestureDetector(
                            onTap: () => setState(() {
                              _useCustomMyRelation = false;
                              _selectedRelation = type;
                            }),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 18,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? colorScheme.primary
                                    : (isDark
                                          ? Colors.white.withValues(alpha: 0.1)
                                          : Colors.black.withValues(
                                              alpha: 0.05,
                                            )),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                type,
                                style: TextStyle(
                                  color: isSelected
                                      ? Colors.white
                                      : (isDark
                                            ? Colors.white70
                                            : Colors.black54),
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
              const SizedBox(height: 10),
              TextField(
                controller: _myRelationController,
                decoration: InputDecoration(
                  hintText: '或自定义输入称呼',
                  hintStyle: TextStyle(
                    fontSize: 13,
                    color: isDark ? Colors.white38 : Colors.black38,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  filled: _useCustomMyRelation,
                  fillColor: _useCustomMyRelation
                      ? colorScheme.primary.withValues(alpha: 0.1)
                      : null,
                ),
                onChanged: (value) {
                  if (value.isNotEmpty && !_useCustomMyRelation) {
                    setState(() => _useCustomMyRelation = true);
                  } else if (value.isEmpty && _useCustomMyRelation) {
                    setState(() => _useCustomMyRelation = false);
                  }
                },
              ),
              const SizedBox(height: 20),
              Text(
                '对方对您的称呼',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: isDark ? Colors.white70 : Colors.black54,
                ),
              ),
              const SizedBox(height: 12),
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
                                horizontal: 18,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? colorScheme.primary
                                    : (isDark
                                          ? Colors.white.withValues(alpha: 0.1)
                                          : Colors.black.withValues(
                                              alpha: 0.05,
                                            )),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                type,
                                style: TextStyle(
                                  color: isSelected
                                      ? Colors.white
                                      : (isDark
                                            ? Colors.white70
                                            : Colors.black54),
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
              const SizedBox(height: 10),
              TextField(
                controller: _targetRelationController,
                decoration: InputDecoration(
                  hintText: '或自定义输入称呼',
                  hintStyle: TextStyle(
                    fontSize: 13,
                    color: isDark ? Colors.white38 : Colors.black38,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  filled: _useCustomTargetRelation,
                  fillColor: _useCustomTargetRelation
                      ? colorScheme.primary.withValues(alpha: 0.1)
                      : null,
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
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('取消'),
        ),
        ElevatedButton(
          onPressed: _isAdding || _foundUser == null ? null : _addBinding,
          style: ElevatedButton.styleFrom(
            backgroundColor: colorScheme.primary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: _isAdding
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Text('发送请求'),
        ),
      ],
    );
  }
}
