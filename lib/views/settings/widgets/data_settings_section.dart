import 'package:flutter/material.dart';
import 'package:fond/services/database/database_config.dart';
import 'package:fond/services/database/database_service.dart';
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

                const SizedBox(height: 8), // 数据导出
                ListTile(
                  leading: const Icon(Icons.file_download),
                  title: const Text('数据导出'),
                  subtitle: const Text('导出您的分析数据和设置'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {},
                ),

                const SizedBox(height: 8),

                // 数据库配置
                ListTile(
                  leading: const Icon(Icons.storage),
                  title: const Text('数据库配置'),
                  subtitle: const Text('配置数据存储方式'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap:
                      () =>
                          _showDatabaseConfigDialog(context, settingsProvider),
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
                const SizedBox(height: 16), // 清除所有数据按钮
                ListTile(
                  leading: Icon(Icons.delete_forever, color: colorScheme.error),
                  title: Text(
                    '清除所有数据',
                    style: TextStyle(color: colorScheme.error),
                  ),
                  subtitle: const Text('删除所有本地保存的应用数据'),
                  onTap: () => _showClearDataDialog(context),
                ),
                // 重置数据库结构
                ListTile(
                  leading: Icon(Icons.refresh, color: Colors.orange),
                  title: Text(
                    '重置数据库结构',
                    style: TextStyle(color: Colors.orange),
                  ),
                  subtitle: const Text('删除并重新创建数据库表（故障修复）'),
                  onTap: () => _showResetDatabaseDialog(context),
                ),

                // 数据库维护
                ListTile(
                  leading: Icon(Icons.build, color: Colors.blue),
                  title: const Text('数据库维护'),
                  subtitle: const Text('优化数据库性能和空间占用'),
                  onTap: () => _showMaintenanceDatabaseDialog(context),
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
                onPressed: () async {
                  // 清除所有数据操作
                  try {
                    // 导入数据库服务
                    final databaseService = DatabaseService();
                    await databaseService.clearAllData();

                    if (context.mounted) {
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(const SnackBar(content: Text('所有数据已清除')));
                      Navigator.of(context).pop();
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text('清除数据失败: $e')));
                      Navigator.of(context).pop();
                    }
                  }
                },
                child: const Text('确认清除'),
              ),
            ],
          ),
    );
  }

  // 显示数据库配置对话框
  void _showDatabaseConfigDialog(
    BuildContext context,
    SettingsProvider settingsProvider,
  ) {
    showDialog(context: context, builder: (context) => _DatabaseConfigDialog());
  }

  // 显示重置数据库对话框
  void _showResetDatabaseDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('重置数据库结构'),
            content: const Text(
              '警告：此操作将删除数据库表并重新创建它们。所有数据将丢失，且此操作不可撤销。此功能主要用于解决数据库结构问题。',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('取消'),
              ),
              FilledButton(
                style: FilledButton.styleFrom(backgroundColor: Colors.red),
                onPressed: () async {
                  try {
                    final config = DatabaseConfig();
                    await config.loadConfig();

                    if (config.isPostgresql) {
                      // 显示正在重置的提示
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('正在重置PostgreSQL数据库...')),
                        );
                      }

                      // 重置PostgreSQL数据库
                      final databaseService = DatabaseService();
                      await databaseService.resetPostgresqlDatabase();

                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('PostgreSQL数据库已重置')),
                        );
                        Navigator.of(context).pop();
                      }
                    } else {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('您当前使用的是SQLite数据库，不需要重置。'),
                          ),
                        );
                        Navigator.of(context).pop();
                      }
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text('重置数据库失败: $e')));
                      Navigator.of(context).pop();
                    }
                  }
                },
                child: const Text('确认重置'),
              ),
            ],
          ),
    );
  }

  // 显示数据库维护对话框
  void _showMaintenanceDatabaseDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => FutureBuilder<Map<String, dynamic>>(
            future: DatabaseService().performMaintenance(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const AlertDialog(
                  title: Text('数据库维护'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text('正在执行数据库维护...'),
                    ],
                  ),
                );
              } else if (snapshot.hasError) {
                return AlertDialog(
                  title: const Text('数据库维护'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.error, color: Colors.red, size: 48),
                      const SizedBox(height: 16),
                      const Text('数据库维护失败'),
                      const SizedBox(height: 8),
                      Text('错误: ${snapshot.error}'),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('关闭'),
                    ),
                  ],
                );
              } else {
                final result =
                    snapshot.data ?? {'success': false, 'message': '未知错误'};
                final success = result['success'] as bool;
                final message = result['message'] as String;
                final bondCount = result['bond_count'] as int?;
                final responseCount = result['response_count'] as int?;

                return AlertDialog(
                  title: const Text('数据库维护'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        success ? Icons.check_circle : Icons.error,
                        color: success ? Colors.green : Colors.red,
                        size: 48,
                      ),
                      const SizedBox(height: 16),
                      Text(success ? '数据库维护完成' : '数据库维护失败'),
                      const SizedBox(height: 8),
                      Text(message),
                      if (bondCount != null && responseCount != null) ...[
                        const SizedBox(height: 16),
                        const Text('数据库统计信息:'),
                        const SizedBox(height: 8),
                        Text('可转债记录数: $bondCount'),
                        Text('响应数据记录数: $responseCount'),
                      ],
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('关闭'),
                    ),
                  ],
                );
              }
            },
          ),
    );
  }
}

// 数据库配置对话框
class _DatabaseConfigDialog extends StatefulWidget {
  @override
  State<_DatabaseConfigDialog> createState() => _DatabaseConfigDialogState();
}

class _DatabaseConfigDialogState extends State<_DatabaseConfigDialog> {
  final _formKey = GlobalKey<FormState>();

  // 数据库配置
  bool _isPostgresql = false;
  String _host = 'localhost';
  int _port = 5432;
  String _dbName = 'fond_db';
  String _username = 'postgres';
  String _password = '';

  @override
  void initState() {
    super.initState();
    _loadConfig();
  }

  // 加载当前配置
  Future<void> _loadConfig() async {
    final dbConfig = DatabaseConfig();
    await dbConfig.loadConfig();

    setState(() {
      _isPostgresql = dbConfig.isPostgresql;
      _host = dbConfig.host;
      _port = dbConfig.port;
      _dbName = dbConfig.databaseName;
      _username = dbConfig.username;
      _password = dbConfig.password;
    });
  }

  // 保存配置
  Future<void> _saveConfig() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final dbConfig = DatabaseConfig();

    if (_isPostgresql) {
      await dbConfig.setPostgreSQL(
        host: _host,
        port: _port,
        databaseName: _dbName,
        username: _username,
        password: _password,
      );
    } else {
      await dbConfig.setSQLite();
    }

    // 显示保存成功提示
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('数据库配置已保存')));
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AlertDialog(
      title: const Text('数据库配置'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 数据库类型选择
              const Text(
                '数据库类型',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),

              Row(
                children: [
                  Expanded(
                    child: RadioListTile<bool>(
                      title: const Text('SQLite'),
                      value: false,
                      groupValue: _isPostgresql,
                      onChanged: (value) {
                        setState(() {
                          _isPostgresql = value!;
                        });
                      },
                    ),
                  ),
                  Expanded(
                    child: RadioListTile<bool>(
                      title: const Text('PostgreSQL'),
                      value: true,
                      groupValue: _isPostgresql,
                      onChanged: (value) {
                        setState(() {
                          _isPostgresql = value!;
                        });
                      },
                    ),
                  ),
                ],
              ),

              // PostgreSQL配置
              if (_isPostgresql) ...[
                const SizedBox(height: 16),
                const Text(
                  'PostgreSQL配置',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),

                // 主机
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: '主机',
                    hintText: 'localhost',
                  ),
                  initialValue: _host,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '请输入主机地址';
                    }
                    return null;
                  },
                  onChanged: (value) {
                    _host = value;
                  },
                ),

                const SizedBox(height: 8),

                // 端口
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: '端口',
                    hintText: '5432',
                  ),
                  initialValue: _port.toString(),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '请输入端口';
                    }
                    if (int.tryParse(value) == null) {
                      return '端口必须是数字';
                    }
                    return null;
                  },
                  onChanged: (value) {
                    _port = int.tryParse(value) ?? 5432;
                  },
                ),

                const SizedBox(height: 8),

                // 数据库名
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: '数据库名',
                    hintText: 'fond_db',
                  ),
                  initialValue: _dbName,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '请输入数据库名';
                    }
                    return null;
                  },
                  onChanged: (value) {
                    _dbName = value;
                  },
                ),

                const SizedBox(height: 8),

                // 用户名
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: '用户名',
                    hintText: 'postgres',
                  ),
                  initialValue: _username,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '请输入用户名';
                    }
                    return null;
                  },
                  onChanged: (value) {
                    _username = value;
                  },
                ),

                const SizedBox(height: 8),

                // 密码
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: '密码',
                    hintText: '可选',
                  ),
                  initialValue: _password,
                  obscureText: true,
                  onChanged: (value) {
                    _password = value;
                  },
                ),
              ],
              if (!_isPostgresql) ...[
                const SizedBox(height: 16),
                Text(
                  'SQLite是一个轻量级的本地数据库，数据将存储在设备上。',
                  style: TextStyle(
                    fontStyle: FontStyle.italic,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('取消'),
        ),
        FilledButton(onPressed: _saveConfig, child: const Text('保存')),
        if (_isPostgresql)
          OutlinedButton(
            onPressed: () async {
              if (!_formKey.currentState!.validate()) {
                return;
              } // 测试连接
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('正在测试连接...')));

              final dbConfig = DatabaseConfig();
              await dbConfig.setPostgreSQL(
                host: _host,
                port: _port,
                databaseName: _dbName,
                username: _username,
                password: _password,
              );

              final result = await dbConfig.testConnection();
              final success = result['success'] as bool;
              final message = result['message'] as String;
              final version = result['version'] as String?;

              if (mounted) {
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      success
                          ? '连接成功${version != null ? " (服务器版本: $version)" : ""}'
                          : '连接失败: $message',
                    ),
                    backgroundColor: success ? Colors.green : Colors.red,
                  ),
                );
              }
            },
            child: const Text('测试连接'),
          ),
      ],
    );
  }
}
