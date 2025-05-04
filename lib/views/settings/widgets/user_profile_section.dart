import 'package:flutter/material.dart';
import 'package:fond/providers/auth_provider.dart';
import 'package:provider/provider.dart';

class UserProfileSection extends StatelessWidget {
  const UserProfileSection({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '账户信息',
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
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: colorScheme.outline.withAlpha(50)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // 用户信息卡片
                Row(
                  children: [
                    // 头像
                    CircleAvatar(
                      radius: 36,
                      backgroundColor: colorScheme.primary.withAlpha(50),
                      child: Text(
                        authProvider.username.isNotEmpty
                            ? authProvider.username[0].toUpperCase()
                            : 'U',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.primary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 24),

                    // 用户信息
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            authProvider.username,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '普通会员',
                            style: TextStyle(
                              fontSize: 14,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '上次登录: ${DateTime.now().year}年${DateTime.now().month}月${DateTime.now().day}日',
                            style: TextStyle(
                              fontSize: 12,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // 编辑按钮
                    FilledButton.tonal(
                      onPressed: () {},
                      child: const Text('编辑资料'),
                    ),
                  ],
                ),

                const SizedBox(height: 24),
                const Divider(),
                const SizedBox(height: 16),

                // 账户设置列表
                _buildSettingItem(
                  context,
                  icon: Icons.security,
                  title: '账户安全',
                  subtitle: '管理账户密码和安全选项',
                ),

                const SizedBox(height: 16),

                _buildSettingItem(
                  context,
                  icon: Icons.notifications,
                  title: '通知设置',
                  subtitle: '管理接收的通知类型和频率',
                ),

                const SizedBox(height: 16),

                _buildSettingItem(
                  context,
                  icon: Icons.verified_user,
                  title: '隐私设置',
                  subtitle: '管理个人信息和数据使用方式',
                ),

                const SizedBox(height: 16),

                _buildSettingItem(
                  context,
                  icon: Icons.credit_card,
                  title: '支付与订阅',
                  subtitle: '管理您的付款方式和订阅计划',
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSettingItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: () {},
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: colorScheme.secondaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: colorScheme.onSecondaryContainer),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: colorScheme.onSurfaceVariant),
          ],
        ),
      ),
    );
  }
}
