import 'package:flutter/material.dart';
import 'package:fond/providers/theme_provider.dart';
import 'package:fond/views/settings/settings_provider.dart';
import 'package:fond/views/settings/widgets/app_settings_section.dart';
import 'package:fond/views/settings/widgets/user_profile_section.dart';
import 'package:fond/views/settings/widgets/data_settings_section.dart';
import 'package:provider/provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return ChangeNotifierProvider(
      create: (_) => SettingsProvider(themeProvider),
      child: Builder(
        builder: (context) {
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 用户信息设置
                const UserProfileSection(),

                const SizedBox(height: 32),

                // 应用设置
                const AppSettingsSection(),

                const SizedBox(height: 32),

                // 数据设置
                const DataSettingsSection(),
              ],
            ),
          );
        },
      ),
    );
  }
}
