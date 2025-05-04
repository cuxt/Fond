import 'package:flutter/material.dart';
import 'package:fond/views/settings/settings_provider.dart';
import 'package:provider/provider.dart';

class AppSettingsSection extends StatelessWidget {
  const AppSettingsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final settingsProvider = Provider.of<SettingsProvider>(context);
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '应用设置',
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 外观设置
                Text(
                  '外观',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 16),

                // 深色模式开关
                SwitchListTile(
                  title: const Text('深色模式'),
                  subtitle: const Text('切换应用的明暗主题'),
                  secondary: Icon(
                    settingsProvider.isDarkMode
                        ? Icons.dark_mode
                        : Icons.light_mode,
                  ),
                  value: settingsProvider.isDarkMode,
                  onChanged: (value) => settingsProvider.toggleDarkMode(),
                ),

                const SizedBox(height: 8),

                // 主题颜色选择
                ListTile(
                  leading: const Icon(Icons.color_lens),
                  title: const Text('主题颜色'),
                  subtitle: const Text('自定义应用的主色调'),
                  trailing: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: settingsProvider.primaryColor,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                  ),
                  onTap: () => _showColorPicker(context, settingsProvider),
                ),

                const Divider(height: 32),

                // 通知设置
                Text(
                  '通知',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 16),

                // 推送通知开关
                SwitchListTile(
                  title: const Text('推送通知'),
                  subtitle: const Text('接收应用内推送通知'),
                  secondary: const Icon(Icons.notifications),
                  value: settingsProvider.pushNotifications,
                  onChanged:
                      (value) =>
                          settingsProvider.togglePushNotifications(value),
                ),

                const SizedBox(height: 8),

                // 邮件通知开关
                SwitchListTile(
                  title: const Text('邮件通知'),
                  subtitle: const Text('接收重要信息的邮件提醒'),
                  secondary: const Icon(Icons.email),
                  value: settingsProvider.emailNotifications,
                  onChanged:
                      (value) =>
                          settingsProvider.toggleEmailNotifications(value),
                ),

                const Divider(height: 32),

                // 辅助功能
                Text(
                  '辅助功能',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 16),

                // 字体大小滑块
                ListTile(
                  leading: const Icon(Icons.text_fields),
                  title: const Text('字体大小'),
                  subtitle: const Text('调整应用文字大小'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {},
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // 显示颜色选择器
  void _showColorPicker(
    BuildContext context,
    SettingsProvider settingsProvider,
  ) {
    final colors = [
      Colors.deepPurple,
      Colors.blue,
      Colors.teal,
      Colors.green,
      Colors.amber,
      Colors.orange,
      Colors.red,
      Colors.pink,
    ];

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('选择主题颜色'),
            content: Wrap(
              spacing: 10,
              runSpacing: 10,
              children:
                  colors.map((color) {
                    return InkWell(
                      onTap: () {
                        settingsProvider.setPrimaryColor(color);
                        Navigator.of(context).pop();
                      },
                      child: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.grey.shade300,
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: color.withAlpha(75),
                              blurRadius: 5,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                        child:
                            settingsProvider.primaryColor == color
                                ? const Icon(Icons.check, color: Colors.white)
                                : null,
                      ),
                    );
                  }).toList(),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('取消'),
              ),
            ],
          ),
    );
  }
}
