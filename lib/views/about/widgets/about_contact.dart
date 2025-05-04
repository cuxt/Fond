import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:fond/widgets/toast/fond_toast.dart';

class AboutContact extends StatelessWidget {
  const AboutContact({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    // 定义联系方式
    final contactMethods = [
      {
        'icon': Icons.language,
        'title': '官方网站',
        'value': 'https://www.51ifind.com',
        'action': () => _launchUrl('https://www.51ifind.com'),
      },
      {
        'icon': Icons.email,
        'title': '联系邮箱',
        'value': 'support@51ifind.com',
        'action': () => _launchUrl('mailto:support@51ifind.com'),
      },
      {
        'icon': Icons.phone,
        'title': '客服电话',
        'value': '400-123-4567',
        'action': () => _launchUrl('tel:4001234567'),
      },
      {
        'icon': Icons.help_outline,
        'title': '帮助中心',
        'value': '查看常见问题解答',
        'action': () {},
      },
      {
        'icon': Icons.chat,
        'title': '在线客服',
        'value': '工作时间: 9:00-18:00',
        'action': () {},
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '联系我们',
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
            child: Column(
              children: [
                LayoutBuilder(
                  builder: (context, constraints) {
                    // 响应式布局：宽度大于600时使用双列
                    final useDoubleColumn = constraints.maxWidth > 600;

                    if (useDoubleColumn) {
                      // 双列布局
                      return Wrap(
                        spacing: 16,
                        runSpacing: 16,
                        children:
                            contactMethods.map((contact) {
                              return SizedBox(
                                width: (constraints.maxWidth - 16) / 2,
                                child: _buildContactItem(context, contact),
                              );
                            }).toList(),
                      );
                    } else {
                      // 单列布局
                      return Column(
                        children:
                            contactMethods.map((contact) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 16),
                                child: _buildContactItem(context, contact),
                              );
                            }).toList(),
                      );
                    }
                  },
                ),

                const SizedBox(height: 24),
                const Divider(),
                const SizedBox(height: 24),

                // 社交媒体链接
                Text(
                  '关注我们',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 16),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildSocialButton(
                      context,
                      icon: Icons.face,
                      color: const Color(0xFF1877F2),
                      onTap: () {},
                    ),
                    const SizedBox(width: 24),
                    _buildSocialButton(
                      context,
                      icon: Icons.wb_cloudy,
                      color: const Color(0xFF1DA1F2),
                      onTap: () {},
                    ),
                    const SizedBox(width: 24),
                    _buildSocialButton(
                      context,
                      icon: Icons.wechat,
                      color: const Color(0xFF07C160),
                      onTap: () {},
                    ),
                    const SizedBox(width: 24),
                    _buildSocialButton(
                      context,
                      icon: Icons.chat_bubble,
                      color: const Color(0xFFFA7199),
                      onTap: () {},
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContactItem(BuildContext context, Map<String, dynamic> contact) {
    final colorScheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: contact['action'] as Function(),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: colorScheme.outline.withAlpha(100)),
        ),
        child: Row(
          children: [
            Icon(contact['icon'] as IconData, color: colorScheme.primary),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    contact['title'] as String,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    contact['value'] as String,
                    style: TextStyle(
                      fontSize: 12,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSocialButton(
    BuildContext context, {
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withAlpha(50),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: color, size: 24),
      ),
    );
  }

  Future<void> _launchUrl(String urlString) async {
    try {
      final Uri url = Uri.parse(urlString);
      if (await canLaunchUrl(url)) {
        await launchUrl(url);
      } else {
        FondToast.show('无法打开链接: $urlString');
      }
    } catch (e) {
      FondToast.show('链接错误: $e');
    }
  }
}
