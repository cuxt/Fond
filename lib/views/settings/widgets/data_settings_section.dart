import 'package:flutter/material.dart';
import 'package:fond/views/settings/settings_provider.dart';
import 'package:provider/provider.dart';

class DataSettingsSection extends StatelessWidget {
  const DataSettingsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final settingsProvider = Provider.of<SettingsProvider>(context);
    final colorScheme = Theme.of(context).colorScheme;

    // 数据刷新间隔选项
    final refreshIntervals = ['实时', '5秒', '10秒', '30秒', '1分钟', '5分钟'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '数据设置',
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
                // 数据刷新设置
                Text(
                  '数据刷新',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 16),

                // 刷新间隔选择
                ListTile(
                  leading: const Icon(Icons.update),
                  title: const Text('数据刷新间隔'),
                  subtitle: Text(
                    '当前设置: ${settingsProvider.dataRefreshInterval}',
                  ),
                  trailing: const Icon(Icons.arrow_drop_down),
                  onTap:
                      () => _showRefreshIntervalDialog(
                        context,
                        settingsProvider,
                        refreshIntervals,
                      ),
                ),

                const SizedBox(height: 8),

                // 自动刷新开关
                SwitchListTile(
                  title: const Text('自动刷新数据'),
                  subtitle: const Text('应用将自动按照设定的间隔刷新数据'),
                  secondary: const Icon(Icons.autorenew),
                  value: settingsProvider.autoRefresh,
                  onChanged:
                      (value) => settingsProvider.toggleAutoRefresh(value),
                ),

                const Divider(height: 32),

                // 数据使用设置
                Text(
                  '数据使用',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 16),

                // 数据节省模式开关
                SwitchListTile(
                  title: const Text('数据节省模式'),
                  subtitle: const Text('减少数据使用量，适合移动网络环境'),
                  secondary: const Icon(Icons.data_saver_on),
                  value: settingsProvider.dataSaving,
                  onChanged:
                      (value) => settingsProvider.toggleDataSaving(value),
                ),

                const SizedBox(height: 8),

                // 数据缓存管理
                ListTile(
                  leading: const Icon(Icons.storage),
                  title: const Text('缓存管理'),
                  subtitle: const Text('管理应用缓存数据'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showCacheDialog(context),
                ),

                const SizedBox(height: 8),

                // 数据导出
                ListTile(
                  leading: const Icon(Icons.file_download),
                  title: const Text('数据导出'),
                  subtitle: const Text('导出您的分析数据和设置'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {},
                ),

                const Divider(height: 32),

                // 危险操作区域
                Text(
                  '高级选项',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 16),

                // 清除所有数据按钮
                ListTile(
                  leading: Icon(Icons.delete_forever, color: colorScheme.error),
                  title: Text(
                    '清除所有数据',
                    style: TextStyle(color: colorScheme.error),
                  ),
                  subtitle: const Text('删除所有本地保存的应用数据'),
                  onTap: () => _showClearDataDialog(context),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // 显示刷新间隔选择对话框
  void _showRefreshIntervalDialog(
    BuildContext context,
    SettingsProvider settingsProvider,
    List<String> intervals,
  ) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('选择数据刷新间隔'),
            content: SizedBox(
              width: double.maxFinite,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: intervals.length,
                itemBuilder: (context, index) {
                  final interval = intervals[index];
                  final isSelected =
                      interval == settingsProvider.dataRefreshInterval;

                  return ListTile(
                    title: Text(interval),
                    trailing:
                        isSelected
                            ? Icon(
                              Icons.check,
                              color: Theme.of(context).colorScheme.primary,
                            )
                            : null,
                    onTap: () {
                      settingsProvider.setDataRefreshInterval(interval);
                      Navigator.of(context).pop();
                    },
                  );
                },
              ),
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

  // 显示缓存管理对话框
  void _showCacheDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('缓存管理'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('当前缓存使用: 24.5 MB'),
                const SizedBox(height: 24),
                const Text('清除缓存将删除暂存的图片和数据，但不会影响您的设置和个人信息。'),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('取消'),
              ),
              FilledButton(
                onPressed: () {
                  // 清除缓存操作
                  Navigator.of(context).pop();
                },
                child: const Text('清除缓存'),
              ),
            ],
          ),
    );
  }

  // 显示清除数据确认对话框
  void _showClearDataDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('确认清除所有数据'),
            content: const Text('警告：此操作将删除应用中所有本地保存的数据，包括设置、历史记录和缓存。此操作不可撤销。'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('取消'),
              ),
              FilledButton(
                style: FilledButton.styleFrom(backgroundColor: Colors.red),
                onPressed: () {
                  // 清除所有数据操作
                  Navigator.of(context).pop();
                },
                child: const Text('确认清除'),
              ),
            ],
          ),
    );
  }
}
