import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/user.dart';
import '../models/wechat_article.dart';
import '../providers/auth_provider.dart';
import '../providers/navigation_provider.dart';
import '../services/auth_service.dart';
import '../services/websocket_service.dart';
import '../services/wechat_article_service.dart';
import '../widgets/family_member_card.dart';
import '../widgets/notification/notification_helper.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  List<FamilyMember> familyMembers = [];
  List<WechatArticle> articles = [];
  bool _isLoadingFamily = false;
  bool _isLoadingArticles = false;
  bool _isUploadingAvatar = false;
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
    _loadFamilyMembers();
    _loadArticles();
  }

  Future<void> _loadUserInfo() async {
    final authStore = Provider.of<AuthStore>(context, listen: false);
    await authStore.init();
  }

  Future<void> _loadFamilyMembers() async {
    setState(() {
      _isLoadingFamily = true;
    });

    try {
      final authStore = Provider.of<AuthStore>(context, listen: false);
      final user = authStore.user;

      if (user == null) return;

      final result = await AuthService.getMyRelations();

      if (mounted) {
        if (result['success'] && result['data'] != null) {
          final bindings = (result['data'] as List)
              .map((item) => FamilyBinding.fromJson(item))
              .toList();

          setState(() {
            familyMembers = bindings.map((binding) {
              final isElder = user.roleCode == 'oldMan';
              final name = isElder ? binding.childName : binding.elderlyName;
              final relation = isElder
                  ? (binding.relationType ?? '家人')
                  : (binding.elderlyToChildRelation ??
                        binding.relationType ??
                        '家人');
              final avatar = isElder
                  ? binding.childAvatar
                  : binding.elderlyAvatar;
              return FamilyMember(
                name: name ?? '未知',
                relation: relation,
                avatar: avatar,
              );
            }).toList();
          });
        }
      }
    } catch (e) {
      print('获取家人列表失败: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingFamily = false;
        });
      }
    }
  }

  Future<void> _loadArticles() async {
    setState(() {
      _isLoadingArticles = true;
    });

    try {
      final response = await WechatArticleService.getArticleList(size: 5);
      if (response.isSuccess && response.data != null) {
        setState(() {
          articles = response.data!;
        });
      }
    } catch (e) {
      print('获取公众号推文失败: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingArticles = false;
        });
      }
    }
  }

  Future<void> _openArticle(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        NotificationHelper.showError(message: '无法打开链接');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final authStore = Provider.of<AuthStore>(context);
    final user = authStore.user;
    final isElder = user?.roleCode == 'oldMan';

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _buildUserInfoCard(context, user, isElder),
              const SizedBox(height: 12),
              _buildFamilySection(context),
              const SizedBox(height: 12),
              _buildArticlesSection(context),
              const SizedBox(height: 24),
              _buildActionButtons(context, isElder),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserInfoCard(BuildContext context, User? user, bool isElder) {
    final colorScheme = Theme.of(context).colorScheme;
    final defaultAvatar = isElder
        ? 'assets/choose_oldMans.jpeg'
        : 'assets/choose_youths.jpeg';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => _pickAndUploadImage(),
            child: Stack(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    shape: BoxShape.circle,
                  ),
                  child: _isUploadingAvatar
                      ? const Center(
                          child: SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        )
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
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: colorScheme.primary,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.camera_alt,
                      size: 12,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      user?.nickname ?? '未设置',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    if (user?.isVip == true) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFD700),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'VIP',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  user?.phone ?? user?.email ?? '未设置',
                  style: TextStyle(
                    fontSize: 14,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: () => Navigator.pushNamed(context, '/edit-profile'),
            icon: Icon(LucideIcons.pencil, size: 20),
            color: colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 4),
          IconButton(
            onPressed: () => Navigator.pushNamed(context, '/settings'),
            icon: Icon(LucideIcons.settings, size: 20),
            color: colorScheme.onSurfaceVariant,
          ),
        ],
      ),
    );
  }

  Widget _buildFamilySection(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final authStore = Provider.of<AuthStore>(context, listen: false);
    final navigationProvider = Provider.of<NavigationProvider>(
      context,
      listen: false,
    );
    final user = authStore.user;
    final isElder = user?.roleCode == 'oldMan';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '我的家人',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
              GestureDetector(
                onTap: () {
                  navigationProvider.setCurrentIndex(1);
                },
                child: Row(
                  children: [
                    Text(
                      '查看更多',
                      style: TextStyle(
                        fontSize: 14,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      LucideIcons.chevronRight,
                      size: 16,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _isLoadingFamily
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: CircularProgressIndicator(),
                  ),
                )
              : familyMembers.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Text(
                      '暂无家人',
                      style: TextStyle(
                        fontSize: 14,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                )
              : SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      ...familyMembers.map(
                        (member) => FamilyMemberCard(
                          member: member,
                          onTap: () {
                            navigationProvider.setCurrentIndex(1);
                          },
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          navigationProvider.setCurrentIndex(1);
                        },
                        child: Container(
                          width: 100,
                          margin: const EdgeInsets.only(right: 12),
                          child: Column(
                            children: [
                              Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  color: colorScheme.surfaceContainerHighest,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.add,
                                  size: 30,
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '添加',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
        ],
      ),
    );
  }

  Widget _buildArticlesSection(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(LucideIcons.newspaper, size: 18, color: colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                '健康资讯',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _isLoadingArticles
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: CircularProgressIndicator(),
                  ),
                )
              : articles.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Text(
                      '暂无推文',
                      style: TextStyle(
                        fontSize: 14,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                )
              : Column(
                  children: articles.map((article) {
                    return _buildArticleItem(article, isDark, colorScheme);
                  }).toList(),
                ),
        ],
      ),
    );
  }

  Widget _buildArticleItem(
    WechatArticle article,
    bool isDark,
    ColorScheme colorScheme,
  ) {
    return GestureDetector(
      onTap: () {
        if (article.articleUrl != null && article.articleUrl!.isNotEmpty) {
          _openArticle(article.articleUrl!);
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark
                ? Colors.white10
                : Colors.black.withValues(alpha: 0.05),
          ),
        ),
        child: Row(
          children: [
            if (article.coverUrl != null && article.coverUrl!.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  article.coverUrl!,
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 60,
                      height: 60,
                      color: colorScheme.surfaceContainerHighest,
                      child: Icon(
                        LucideIcons.image,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    );
                  },
                ),
              )
            else
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(LucideIcons.newspaper, color: colorScheme.primary),
              ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    article.title ?? '',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    article.source ?? '公众号',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.white54 : Colors.black45,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              LucideIcons.chevronRight,
              size: 16,
              color: isDark ? Colors.white38 : Colors.black26,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, bool isElder) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 48,
          child: OutlinedButton(
            onPressed: () => _logout(context),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: colorScheme.error),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              '退出登录',
              style: TextStyle(
                color: colorScheme.error,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: OutlinedButton(
            onPressed: () => _switchRole(context, isElder),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: colorScheme.outline),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              isElder ? '切换为子女' : '切换为老人',
              style: TextStyle(
                color: colorScheme.onSurface,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _pickAndUploadImage() async {
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
            await _loadUserInfo();
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

  Future<void> _logout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('退出登录'),
        content: const Text('确定要退出登录吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('确定'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      final authStore = Provider.of<AuthStore>(context, listen: false);
      WebSocketService().disconnect();
      await authStore.logout();
      if (context.mounted) {
        Navigator.pushReplacementNamed(context, '/login');
      }
    }
  }

  Future<void> _switchRole(BuildContext context, bool isElder) async {
    final targetRole = isElder ? '子女' : '老人';
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('切换身份'),
        content: Text('确定要切换为$targetRole身份吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('确定'),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    try {
      final profiles = await AuthService.checkProfiles();
      final hasTargetProfile = isElder
          ? (profiles['hasChild'] ?? false)
          : (profiles['hasElderly'] ?? false);

      if (!hasTargetProfile) {
        final createProfile = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('提示'),
            content: Text('您尚未创建${isElder ? '子女' : '老人'}档案，是否现在创建？'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('取消'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('去创建'),
              ),
            ],
          ),
        );

        if (createProfile == true && context.mounted) {
          Navigator.pushNamed(
            context,
            isElder ? '/child-profile' : '/elderly-profile',
          );
        }
        return;
      }

      final result = await AuthService.switchRole(
        roleCode: isElder ? 'young' : 'oldMan',
        roleName: isElder ? '子女' : '老人',
      );

      if (result['success']) {
        final authStore = Provider.of<AuthStore>(context, listen: false);
        await authStore.init();

        if (context.mounted) {
          NotificationHelper.showSuccess(message: '切换成功');
          final navigationProvider = Provider.of<NavigationProvider>(
            context,
            listen: false,
          );
          navigationProvider.setCurrentIndex(0);
        }
      } else {
        if (context.mounted) {
          NotificationHelper.showError(message: result['message'] ?? '切换失败');
        }
      }
    } catch (e) {
      if (context.mounted) {
        NotificationHelper.showError(message: '切换失败，请重试');
      }
    }
  }
}
