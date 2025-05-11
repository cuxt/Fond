// 数据库配置类，用于管理数据库设置
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:postgres/postgres.dart';

/// 数据库类型枚举
enum DatabaseType { sqlite, postgresql }

/// 数据库配置类
class DatabaseConfig {
  // 单例模式
  static final DatabaseConfig _instance = DatabaseConfig._internal();
  factory DatabaseConfig() => _instance;
  DatabaseConfig._internal();

  // 默认使用SQLite
  DatabaseType _type = DatabaseType.sqlite;
  String _host = 'localhost';
  int _port = 5432;
  String _databaseName = 'fond_db';
  String _username = 'postgres';
  String _password = '';

  // Getters
  DatabaseType get type => _type;
  String get host => _host;
  int get port => _port;
  String get databaseName => _databaseName;
  String get username => _username;
  String get password => _password;
  bool get isPostgresql => _type == DatabaseType.postgresql;
  bool get isSqlite => _type == DatabaseType.sqlite;

  /// 从SharedPreferences加载配置
  Future<void> loadConfig() async {
    final prefs = await SharedPreferences.getInstance();

    // 获取数据库类型 (0: SQLite, 1: PostgreSQL)
    final typeValue = prefs.getInt('db_type') ?? 0;
    _type = DatabaseType.values[typeValue];

    // 只有当类型为PostgreSQL时才需要其他配置
    if (_type == DatabaseType.postgresql) {
      _host = prefs.getString('db_host') ?? 'localhost';
      _port = prefs.getInt('db_port') ?? 5432;
      _databaseName = prefs.getString('db_name') ?? 'fond_db';
      _username = prefs.getString('db_username') ?? 'postgres';
      _password = prefs.getString('db_password') ?? '';
    }
  }

  /// 保存配置到SharedPreferences
  Future<void> saveConfig() async {
    final prefs = await SharedPreferences.getInstance();

    // 保存数据库类型
    await prefs.setInt('db_type', _type.index);

    // 只有当类型为PostgreSQL时才保存其他配置
    if (_type == DatabaseType.postgresql) {
      await prefs.setString('db_host', _host);
      await prefs.setInt('db_port', _port);
      await prefs.setString('db_name', _databaseName);
      await prefs.setString('db_username', _username);
      await prefs.setString('db_password', _password);
    }
  }

  /// 设置为PostgreSQL
  Future<void> setPostgreSQL({
    required String host,
    required int port,
    required String databaseName,
    required String username,
    required String password,
  }) async {
    _type = DatabaseType.postgresql;
    _host = host;
    _port = port;
    _databaseName = databaseName;
    _username = username;
    _password = password;

    await saveConfig();
  }

  /// 设置为SQLite
  Future<void> setSQLite() async {
    _type = DatabaseType.sqlite;
    await saveConfig();
  }

  /// 测试数据库连接
  Future<Map<String, dynamic>> testConnection() async {
    try {
      if (_type == DatabaseType.postgresql) {
        // 测试PostgreSQL连接
        PostgreSQLConnection? connection;
        try {
          connection = PostgreSQLConnection(
            _host,
            _port,
            _databaseName,
            username: _username,
            password: _password,
            timeoutInSeconds: 10, // 设置较短的超时时间用于测试
            useSSL: false,
            allowClearTextPassword: true,
          );

          await connection.open();

          // 测试基本查询
          final simpleTest = await connection.query("SELECT 1 as test");
          if (simpleTest.isEmpty || simpleTest.first[0] != 1) {
            return {'success': false, 'message': '数据库连接成功但查询测试失败'};
          }

          // 测试数据库版本
          final versionResult = await connection.query("SHOW server_version");
          final pgVersion = versionResult.first[0] as String;

          debugPrint('PostgreSQL连接测试成功，服务器版本: $pgVersion');
          return {'success': true, 'message': '连接成功', 'version': pgVersion};
        } catch (e) {
          debugPrint('PostgreSQL连接测试失败: ${e.runtimeType} - $e');
          return {'success': false, 'message': e.toString().split('\n')[0]};
        } finally {
          // 确保关闭连接
          try {
            if (connection != null) {
              await connection.close();
            }
          } catch (_) {}
        }
      } else {
        // SQLite默认总是可用的
        return {
          'success': true,
          'message': 'SQLite数据库已准备就绪',
          'version': 'SQLite',
        };
      }
    } catch (e) {
      debugPrint('测试连接失败: $e');
      return {'success': false, 'message': '测试连接时发生未知错误: ${e.toString()}'};
    }
  }
}
