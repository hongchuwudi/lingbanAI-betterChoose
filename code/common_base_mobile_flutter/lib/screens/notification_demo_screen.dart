import 'package:flutter/material.dart';
import '../widgets/notification/notification_helper.dart';

/// 通知演示页面
class NotificationDemoScreen extends StatelessWidget {
  const NotificationDemoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final onSurface = colorScheme.onSurface;
    final onSurfaceVariant = colorScheme.onSurfaceVariant;
    final surface = colorScheme.surface;
    final surfaceVariant = colorScheme.surfaceVariant;

    return Scaffold(
      appBar: AppBar(
        title: Text('通知组件演示', style: TextStyle(color: onSurface)),
        backgroundColor: surface,
        elevation: 0,
      ),
      backgroundColor: colorScheme.background,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 成功通知演示
            _buildDemoButton(
              context,
              '显示成功通知',
              Icons.check_circle,
              Colors.green,
              () => NotificationHelper.showSuccess(
                message: '操作成功完成！',
                onTap: () => _showToast('成功通知被点击'),
              ),
            ),
            const SizedBox(height: 12),

            // 错误通知演示
            _buildDemoButton(
              context,
              '显示错误通知',
              Icons.error,
              Colors.red,
              () => NotificationHelper.showError(
                message: '网络连接失败，请检查网络设置',
                onTap: () => _showToast('错误通知被点击'),
              ),
            ),
            const SizedBox(height: 12),

            // 警告通知演示
            _buildDemoButton(
              context,
              '显示警告通知',
              Icons.warning,
              Colors.orange,
              () => NotificationHelper.showWarning(
                message: '您的账号即将过期，请及时续费',
                onTap: () => _showToast('警告通知被点击'),
              ),
            ),
            const SizedBox(height: 12),

            // 普通信息通知演示
            _buildDemoButton(
              context,
              '显示普通信息',
              Icons.info,
              Colors.blue,
              () => NotificationHelper.showInfo(
                message: '系统已更新到最新版本',
                onTap: () => _showToast('信息通知被点击'),
              ),
            ),
            const SizedBox(height: 12),

            // 自定义内容通知演示
            _buildDemoButton(
              context,
              '显示自定义内容',
              Icons.notifications,
              Colors.purple,
              () => NotificationHelper.showCustom(
                child: Row(
                  children: [
                    const Icon(Icons.favorite, color: Colors.red),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '自定义通知',
                            style: TextStyle(
                              color: onSurface,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '这是一个包含图标和文字的自定义通知',
                            style: TextStyle(
                              color: onSurfaceVariant,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                onTap: () => _showToast('自定义通知被点击'),
              ),
            ),
            const SizedBox(height: 12),

            // 位置演示
            _buildDemoButton(
              context,
              '显示底部通知',
              Icons.vertical_align_bottom,
              Colors.teal,
              () => NotificationHelper.showInfo(
                message: '这是显示在底部的通知',
                position: NotificationPosition.bottom,
                onTap: () => _showToast('底部通知被点击'),
              ),
            ),
            const SizedBox(height: 12),

            // 手动关闭演示
            _buildDemoButton(
              context,
              '显示手动关闭通知',
              Icons.close,
              Colors.grey,
              () => NotificationHelper.showInfo(
                message: '点击关闭按钮或等待自动消失',
                autoDismiss: false,
                onTap: () => _showToast('手动关闭通知被点击'),
              ),
            ),
            const SizedBox(height: 12),

            // 队列演示
            _buildDemoButton(
              context,
              '显示多个通知队列',
              Icons.queue,
              Colors.indigo,
              () {
                NotificationHelper.showSuccess(message: '第一个通知');
                NotificationHelper.showError(message: '第二个通知');
                NotificationHelper.showWarning(message: '第三个通知');
                NotificationHelper.showInfo(message: '第四个通知');
              },
            ),
            const SizedBox(height: 12),

            // 清除所有通知
            _buildDemoButton(
              context,
              '清除所有通知',
              Icons.clear_all,
              Colors.red,
              () => NotificationHelper.clearAll(),
            ),
            const SizedBox(height: 24),

            // 功能说明
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: surfaceVariant,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '功能特性：',
                    style: TextStyle(
                      color: onSurface,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildFeatureItem(context, '单例模式，全局只有一个实例'),
                  _buildFeatureItem(context, '支持多种通知类型：成功、错误、警告、信息'),
                  _buildFeatureItem(context, '支持显示位置：顶部、中部、底部'),
                  _buildFeatureItem(context, '支持自定义样式和内容'),
                  _buildFeatureItem(context, '支持手动关闭和自动消失'),
                  _buildFeatureItem(context, '多个通知自动排队显示'),
                  _buildFeatureItem(context, '点击事件和回调支持'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDemoButton(
    BuildContext context,
    String text,
    IconData icon,
    Color color,
    VoidCallback onPressed,
  ) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, color: Colors.white),
      label: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  Widget _buildFeatureItem(BuildContext context, String text) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Text(
        text,
        style: TextStyle(
          color: colorScheme.onSurface.withValues(alpha: 0.8),
          fontSize: 14,
        ),
      ),
    );
  }

  void _showToast(String message) {
    debugPrint('Toast: $message');
  }
}
