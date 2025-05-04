import 'package:flutter/material.dart';

class AboutFeatures extends StatelessWidget {
  const AboutFeatures({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    // 定义功能列表
    final features = [
      {
        'icon': Icons.show_chart,
        'title': '实时行情',
        'description': '提供实时市场数据和行情走势',
        'color': Colors.blue,
      },
      {
        'icon': Icons.analytics,
        'title': '数据分析',
        'description': '强大的数据分析工具和图表',
        'color': Colors.purple,
      },
      {
        'icon': Icons.article,
        'title': '研报资讯',
        'description': '专业研究报告和市场资讯',
        'color': Colors.teal,
      },
      {
        'icon': Icons.notifications,
        'title': '行情提醒',
        'description': '自定义价格和新闻提醒功能',
        'color': Colors.orange,
      },
      {
        'icon': Icons.add_chart,
        'title': '自选股管理',
        'description': '关注和追踪您感兴趣的股票',
        'color': Colors.green,
      },
      {
        'icon': Icons.laptop,
        'title': '跨平台支持',
        'description': '在桌面和移动设备上使用',
        'color': Colors.indigo,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '主要功能',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 16),

        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: colorScheme.outline.withAlpha(100)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: LayoutBuilder(
              builder: (context, constraints) {
                // 根据可用宽度决定一行显示多少个功能
                final width = constraints.maxWidth;
                final crossAxisCount = width ~/ 320; // 每项最小宽度为320

                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount.clamp(1, 3), // 最少1个，最多3个
                    childAspectRatio: 3.0,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: features.length,
                  itemBuilder: (context, index) {
                    final feature = features[index];
                    final color = feature['color'] as Color;

                    return _buildFeatureItem(
                      context,
                      icon: feature['icon'] as IconData,
                      title: feature['title'] as String,
                      description: feature['description'] as String,
                      color: color,
                    );
                  },
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFeatureItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
    required Color color,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outline.withAlpha(100)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withAlpha(50),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
