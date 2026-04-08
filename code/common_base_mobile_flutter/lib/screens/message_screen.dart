import 'package:flutter/material.dart';

/// 消息页面组件
/// 显示用户的消息和通知
class MessageScreen extends StatelessWidget {
  const MessageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('灵伴'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: colorScheme.surface,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 消息分类
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildMessageCategory('系统通知', Icons.notifications, 3),
                _buildMessageCategory('健康提醒', Icons.health_and_safety, 5),
                _buildMessageCategory('活动消息', Icons.event, 2),
              ],
            ),

            const SizedBox(height: 24),

            // 最新消息标题
            Text(
              '最新消息',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),

            const SizedBox(height: 16),

            // 消息列表
            Expanded(
              child: ListView(
                children: [
                  _buildMessageItem(
                    '系统通知',
                    '您的健康报告已生成，请及时查看',
                    '10分钟前',
                    Icons.notifications,
                    true,
                  ),
                  _buildMessageItem(
                    '健康提醒',
                    '今日运动目标已完成，继续保持！',
                    '1小时前',
                    Icons.health_and_safety,
                    false,
                  ),
                  _buildMessageItem(
                    '活动消息',
                    '新活动：健康知识竞赛开始报名',
                    '2小时前',
                    Icons.event,
                    false,
                  ),
                  _buildMessageItem(
                    '系统通知',
                    '您的账户安全等级已提升',
                    '昨天',
                    Icons.security,
                    false,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建消息分类
  Widget _buildMessageCategory(String title, IconData icon, int count) {
    return Column(
      children: [
        Stack(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 30, color: Colors.blue),
            ),
            if (count > 0)
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    count > 99 ? '99+' : count.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        Text(title, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  /// 构建消息项
  Widget _buildMessageItem(
    String title,
    String content,
    String time,
    IconData icon,
    bool isUnread,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.blue.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 20, color: Colors.blue),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: isUnread ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        subtitle: Text(content, maxLines: 1, overflow: TextOverflow.ellipsis),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(time, style: const TextStyle(fontSize: 12)),
            if (isUnread)
              Container(
                margin: const EdgeInsets.only(top: 4),
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
        onTap: () {
          // 处理消息点击事件
        },
      ),
    );
  }
}
