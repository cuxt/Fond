import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:fond/services/database/database_config.dart';
import 'package:fond/services/database/sqlite_service.dart';
import 'package:fond/services/database/postgresql_service.dart';
import 'package:fond/views/convertible_bond/models/convertible_bond.dart';

/// 数据库服务类
/// 负责管理数据库连接并提供数据访问方法
class DatabaseService {
  // 单例模式
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  // 数据库接口
  SqliteService? _sqliteService;
  PostgresqlService? _postgresqlService;

  // 当前使用的数据库服务
  dynamic get _currentDb {
    final config = DatabaseConfig();
    return config.isPostgresql ? _postgresqlService : _sqliteService;
  }

  bool _initialized = false;
  bool get isInitialized => _initialized;

  /// 初始化数据库服务
  Future<void> initialize() async {
    if (_initialized) return;

    try {
      final config = DatabaseConfig();
      await config.loadConfig();

      // 初始化SQLite(默认总是初始化SQLite作为备选)
      _sqliteService = SqliteService();
      await _sqliteService!.initialize();
      debugPrint('SQLite数据库初始化完成');

      // 如果配置为PostgreSQL，则尝试初始化PostgreSQL
      if (config.isPostgresql) {
        debugPrint('尝试初始化PostgreSQL数据库...');
        _postgresqlService = PostgresqlService();
        try {
          await _postgresqlService!.initialize();
          debugPrint('PostgreSQL数据库初始化成功');
        } catch (e) {
          debugPrint(
            '初始化PostgreSQL失败(${e.runtimeType})，将使用SQLite: ${e.toString().split('\n')[0]}',
          );
          // 通知用户连接失败并切换到SQLite
          await config.setSQLite();
        }
      }

      _initialized = true;
      debugPrint('数据库服务初始化完成，使用: ${config.type}');
    } catch (e) {
      debugPrint('数据库服务初始化失败: $e');
      rethrow;
    }
  }

  /// 关闭数据库连接
  Future<void> close() async {
    try {
      if (_sqliteService != null) {
        await _sqliteService!.close();
      }
      if (_postgresqlService != null) {
        await _postgresqlService!.close();
      }
      _initialized = false;
    } catch (e) {
      debugPrint('关闭数据库连接失败: $e');
    }
  }

  /// 保存可转债数据列表
  Future<void> saveConvertibleBonds(
    List<ConvertibleBond> bonds,
    String date,
  ) async {
    if (!_initialized) await initialize();
    await _currentDb.saveConvertibleBonds(bonds, date);
  }

  /// 获取可转债数据列表
  Future<List<ConvertibleBond>> getConvertibleBonds(String date) async {
    if (!_initialized) await initialize();
    return await _currentDb.getConvertibleBonds(date);
  }

  /// 根据日期获取可转债数据
  Future<ConvertibleBondResponse?> getConvertibleBondsByDate(
    String date,
  ) async {
    if (!_initialized) await initialize();
    return await _currentDb.getConvertibleBondsByDate(date);
  }

  /// 检查指定日期的数据是否存在
  Future<bool> hasConvertibleBondData(String date) async {
    if (!_initialized) await initialize();
    return await _currentDb.hasConvertibleBondData(date);
  }

  /// 保存完整的API响应
  Future<void> saveConvertibleBondResponse(
    ConvertibleBondResponse response,
    String date,
  ) async {
    if (!_initialized) await initialize();
    await _currentDb.saveConvertibleBondResponse(response, date);
  }

  /// 清除所有数据
  Future<void> clearAllData() async {
    if (!_initialized) await initialize();
    await _sqliteService!.clearAllData();
    if (_postgresqlService != null) {
      await _postgresqlService!.clearAllData();
    }
  }

  /// 重置 PostgreSQL 数据库（删除并重建表）
  Future<void> resetPostgresqlDatabase() async {
    if (!_initialized) await initialize();

    // 确保已初始化 PostgreSQL 服务
    if (_postgresqlService == null) {
      throw Exception('PostgreSQL服务未初始化');
    }

    await _postgresqlService!.resetDatabase();
    debugPrint('PostgreSQL数据库已重置');
  }

  /// 执行数据库维护
  Future<Map<String, dynamic>> performMaintenance() async {
    if (!_initialized) await initialize();

    try {
      final config = DatabaseConfig();
      final result =
          config.isPostgresql
              ? await _postgresqlService!.performMaintenance()
              : await _sqliteService!.performMaintenance();

      debugPrint('数据库维护完成: ${result['message']}');
      return result;
    } catch (e) {
      debugPrint('数据库维护失败: $e');
      return {'success': false, 'message': '数据库维护失败: $e'};
    }
  }
}
