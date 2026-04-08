import 'package:flutter/material.dart';

/// 发现页面组件
/// 显示健康资讯、活动推荐等内容
class DiscoverScreen extends StatelessWidget {
  const DiscoverScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('发现'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: colorScheme.surface,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 搜索框
            Container(
              height: 40,
              decoration: BoxDecoration(
                color: colorScheme.surfaceVariant,
                borderRadius: BorderRadius.circular(20),
              ),
              child: TextField(
                decoration: InputDecoration(
                  hintText: '搜索健康资讯、活动...',
                  hintStyle: TextStyle(color: colorScheme.onSurfaceVariant),
                  prefixIcon: Icon(Icons.search, color: colorScheme.onSurfaceVariant),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // 发现分类
            Text(
              '发现分类',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            
            const SizedBox(height: 16),
            
            // 分类网格
            GridView.count(
              shrinkWrap: true,
              crossAxisCount: 3,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: [
                _buildDiscoverCategory('健康资讯', Icons.article, Colors.blue),
                _buildDiscoverCategory('运动健身', Icons.fitness_center, Colors.green),
                _buildDiscoverCategory('营养饮食', Icons.restaurant, Colors.orange),
                _buildDiscoverCategory('心理健康', Icons.psychology, Colors.purple),
                _buildDiscoverCategory('活动推荐', Icons.event, Colors.red),
                _buildDiscoverCategory('专家问答', Icons.live_help, Colors.teal),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // 热门推荐
            Text(
              '热门推荐',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            
            const SizedBox(height: 16),
            
            // 推荐列表
            Expanded(
              child: ListView(
                children: [
                  _buildRecommendationItem(
                    '如何科学减肥',
                    '掌握科学的减肥方法，健康瘦身不反弹',
                    '健康资讯',
                    Icons.article,
                  ),
                  _buildRecommendationItem(
                    '每日运动计划',
                    '适合上班族的简单运动方案',
                    '运动健身',
                    Icons.fitness_center,
                  ),
                  _buildRecommendationItem(
                    '健康饮食指南',
                    '营养均衡的一日三餐搭配建议',
                    '营养饮食',
                    Icons.restaurant,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建发现分类
  Widget _buildDiscoverCategory(String title, IconData icon, Color color) {
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, size: 30, color: color),
        ),
        const SizedBox(height: 8),
        Text(
          title,
          style: const TextStyle(fontSize: 12),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  /// 构建推荐项
  Widget _buildRecommendationItem(
    String title,
    String description,
    String category,
    IconData icon,
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
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 12),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                category,
                style: const TextStyle(fontSize: 10, color: Colors.grey),
              ),
            ),
          ],
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          // 处理推荐项点击事件
        },
      ),
    );
  }
}