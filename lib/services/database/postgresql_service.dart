import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:fond/services/database/database_config.dart';
import 'package:fond/views/convertible_bond/models/convertible_bond.dart';
import 'package:postgres/postgres.dart';

/// PostgreSQL数据库服务类
class PostgresqlService {
  PostgreSQLConnection? _connection;
  bool _isConnected = false;

  /// 获取数据库连接
  Future<PostgreSQLConnection> get connection async {
    if (_connection != null && _isConnected) {
      return _connection!;
    }

    await _connect();
    return _connection!;
  }

  /// 执行数据库查询，增加错误处理
  Future<PostgreSQLResult> safeQuery(
    String query, {
    Map<String, dynamic>? substitutionValues,
  }) async {
    final conn = await connection;
    try {
      return await conn.query(query, substitutionValues: substitutionValues);
    } catch (e) {
      debugPrint(
        'PostgreSQL查询异常: ${e.runtimeType} - ${e.toString().split('\n')[0]}',
      );

      // 如果发生编码错误，尝试重新连接
      if (e.toString().contains('FormatException') ||
          e.toString().contains('encoding') ||
          e.toString().contains('UTF')) {
        debugPrint('疑似编码问题，尝试重新连接数据库...');

        // 关闭现有连接
        if (_connection != null) {
          try {
            await _connection!.close();
          } catch (_) {}
          _connection = null;
          _isConnected = false;
        }

        // 重新连接
        await _connect();

        // 重试查询
        return await _connection!.query(
          query,
          substitutionValues: substitutionValues,
        );
      }

      rethrow;
    }
  }

  /// 执行数据库命令，增加错误处理
  Future<void> safeExecute(
    String query, {
    Map<String, dynamic>? substitutionValues,
  }) async {
    final conn = await connection;
    try {
      await conn.execute(query, substitutionValues: substitutionValues);
    } catch (e) {
      debugPrint(
        'PostgreSQL执行异常: ${e.runtimeType} - ${e.toString().split('\n')[0]}',
      );

      // 如果发生编码错误，尝试重新连接
      if (e.toString().contains('FormatException') ||
          e.toString().contains('encoding') ||
          e.toString().contains('UTF')) {
        debugPrint('疑似编码问题，尝试重新连接数据库...');

        // 关闭现有连接
        if (_connection != null) {
          try {
            await _connection!.close();
          } catch (_) {}
          _connection = null;
          _isConnected = false;
        }

        // 重新连接
        await _connect();

        // 重试查询
        await _connection!.execute(
          query,
          substitutionValues: substitutionValues,
        );
      } else {
        rethrow;
      }
    }
  }

  /// 初始化数据库连接
  Future<void> initialize() async {
    await _connect();
    await _createTables();
  }

  /// 连接到数据库
  Future<void> _connect() async {
    final config = DatabaseConfig();

    // 确保已加载配置
    await config.loadConfig();

    if (!config.isPostgresql) {
      throw Exception('配置不是PostgreSQL');
    }
    _connection = PostgreSQLConnection(
      config.host,
      config.port,
      config.databaseName,
      username: config.username,
      password: config.password,
      timeoutInSeconds: 30,
      useSSL: false,
      allowClearTextPassword: true,
    );

    try {
      await _connection!.open();

      // 确保连接使用UTF-8编码
      await _connection!.execute("SET client_encoding = 'UTF8'");

      _isConnected = true;
      debugPrint('已连接到PostgreSQL数据库: ${config.databaseName}');
    } catch (e) {
      _isConnected = false;
      debugPrint('PostgreSQL连接失败: ${e.runtimeType} - $e');

      // 关闭任何可能部分打开的连接
      try {
        if (_connection != null) {
          await _connection!.close();
        }
      } catch (_) {}

      // 这里不直接抛出原异常，而是创建一个更清晰的错误消息
      throw Exception(
        '无法连接到PostgreSQL数据库: ${e.toString().replaceAll(RegExp(r'\n.*'), '')}',
      );
    }
  }

  /// 创建数据库表
  Future<void> _createTables() async {
    try {
      // 创建可转债数据表
      await safeExecute('''
        CREATE TABLE IF NOT EXISTS convertible_bonds (
          id SERIAL PRIMARY KEY,
          bond_code TEXT NOT NULL,
          bond_name TEXT NOT NULL,
          current_price REAL,
          trade_date TEXT NOT NULL,
          data_json TEXT NOT NULL,
          created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
          UNIQUE(bond_code, trade_date)
        )
      ''');

      // 创建可转债响应数据表
      await safeExecute('''
        CREATE TABLE IF NOT EXISTS bond_responses (
          id SERIAL PRIMARY KEY,
          date TEXT UNIQUE NOT NULL,
          status INTEGER NOT NULL,
          errmsg TEXT,
          msg TEXT,
          descrs_json TEXT,
          created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        )
      ''');

      // 创建索引
      await safeExecute('''
        CREATE INDEX IF NOT EXISTS idx_bond_code_date ON convertible_bonds (bond_code, trade_date)
      ''');

      await safeExecute('''
        CREATE INDEX IF NOT EXISTS idx_response_date ON bond_responses (date)
      ''');

      // 检查是否需要添加唯一约束
      await _ensureUniqueConstraint();

      debugPrint('PostgreSQL数据库表创建完成');
    } catch (e) {
      debugPrint('创建PostgreSQL数据库表失败: $e');
      rethrow;
    }
  }

  /// 确保唯一约束存在
  Future<void> _ensureUniqueConstraint() async {
    try {
      // 检查表是否存在
      final tableCheck = await safeQuery('''
        SELECT EXISTS (
          SELECT FROM information_schema.tables 
          WHERE table_schema = 'public' 
          AND table_name = 'convertible_bonds'
        );
      ''');

      if (tableCheck.isEmpty || !(tableCheck.first[0] as bool)) {
        debugPrint('convertible_bonds表不存在，无需添加约束');
        return;
      }

      // 检查是否已存在bond_code_trade_date_key约束
      final constraintCheck = await safeQuery('''
        SELECT COUNT(*) FROM pg_constraint 
        WHERE conrelid = 'convertible_bonds'::regclass 
        AND conname = 'convertible_bonds_bond_code_trade_date_key';
      ''');

      final constraintExists =
          constraintCheck.isNotEmpty && (constraintCheck.first[0] as int) > 0;

      if (!constraintExists) {
        debugPrint('未检测到唯一约束，尝试添加...');

        // 检查是否有数据，如果有数据，需要确保没有重复记录
        final duplicateCheck = await safeQuery('''
          SELECT bond_code, trade_date, COUNT(*)
          FROM convertible_bonds
          GROUP BY bond_code, trade_date
          HAVING COUNT(*) > 1;
        ''');

        if (duplicateCheck.isNotEmpty) {
          debugPrint('检测到${duplicateCheck.length}组重复数据，清理中...');

          // 对于每组重复数据，保留最新的一条
          for (final row in duplicateCheck) {
            final bondCode = row[0] as String;
            final tradeDate = row[1] as String;

            debugPrint('处理重复数据: bondCode=$bondCode, tradeDate=$tradeDate');

            await safeExecute(
              '''
              DELETE FROM convertible_bonds
              WHERE id NOT IN (
                SELECT MAX(id) FROM convertible_bonds
                WHERE bond_code = @bondCode AND trade_date = @tradeDate
              ) AND bond_code = @bondCode AND trade_date = @tradeDate;
            ''',
              substitutionValues: {
                'bondCode': bondCode,
                'tradeDate': tradeDate,
              },
            );
          }
        }

        // 添加唯一约束
        await safeExecute('''
          ALTER TABLE convertible_bonds
          ADD CONSTRAINT convertible_bonds_bond_code_trade_date_key 
          UNIQUE (bond_code, trade_date);
        ''');

        debugPrint('成功添加唯一约束');
      } else {
        debugPrint('唯一约束已存在');
      }
    } catch (e) {
      debugPrint('添加唯一约束失败: $e');
      // 这不是致命错误，不抛出异常
    }
  }

  /// 关闭数据库连接
  Future<void> close() async {
    if (_connection != null && _isConnected) {
      await _connection!.close();
      _isConnected = false;
      _connection = null;
    }
  }

  /// 保存可转债数据列表
  Future<void> saveConvertibleBonds(
    List<ConvertibleBond> bonds,
    String date,
  ) async {
    try {
      for (final bond in bonds) {
        // 将对象转换为JSON字符串存储
        final dataJson = jsonEncode(_convertBondToMap(bond));

        // 使用upsert语法(INSERT ... ON CONFLICT DO UPDATE)
        await safeExecute(
          '''
          INSERT INTO convertible_bonds (bond_code, bond_name, current_price, trade_date, data_json, created_at)
          VALUES (@bondCode, @bondName, @currentPrice, @tradeDate, @dataJson, NOW())
          ON CONFLICT (bond_code, trade_date) DO UPDATE 
          SET current_price = @currentPrice, data_json = @dataJson, created_at = NOW()
        ''',
          substitutionValues: {
            'bondCode': bond.bondCode,
            'bondName': bond.bondName,
            'currentPrice': bond.currentPrice,
            'tradeDate': date,
            'dataJson': dataJson,
          },
        );
      }

      debugPrint('已保存 ${bonds.length} 条可转债数据到PostgreSQL');
    } catch (e) {
      debugPrint('保存可转债数据到PostgreSQL失败: $e');
      rethrow;
    }
  }

  /// 获取可转债数据列表
  Future<List<ConvertibleBond>> getConvertibleBonds(String date) async {
    try {
      final results = await safeQuery(
        '''
        SELECT data_json FROM convertible_bonds
        WHERE trade_date = @date
      ''',
        substitutionValues: {'date': date},
      );

      return results.map((row) {
        final dataJson = row[0] as String;
        final bondData = jsonDecode(dataJson) as Map<String, dynamic>;
        return _convertMapToBond(bondData);
      }).toList();
    } catch (e) {
      debugPrint('从PostgreSQL获取可转债数据失败: $e');
      return [];
    }
  }

  /// 根据日期获取可转债响应数据
  Future<ConvertibleBondResponse?> getConvertibleBondsByDate(
    String date,
  ) async {
    try {
      // 1. 查询响应数据
      final responseResults = await safeQuery(
        '''
        SELECT status, errmsg, msg, descrs_json FROM bond_responses
        WHERE date = @date
      ''',
        substitutionValues: {'date': date},
      );

      if (responseResults.isEmpty) {
        return null;
      }

      final responseRow = responseResults.first;

      // 2. 查询债券数据
      final bonds = await getConvertibleBonds(date);

      // 3. 解析descrs数据
      final descrsJson = responseRow[3] as String;
      final List<dynamic> descrs = jsonDecode(descrsJson);
      final List<Map<String, dynamic>> descrsList =
          descrs.map((item) => Map<String, dynamic>.from(item)).toList();

      // 4. 构建响应对象
      return ConvertibleBondResponse(
        status: responseRow[0] as int,
        errmsg: responseRow[1] as String? ?? '',
        msg: responseRow[2] as String? ?? '',
        bonds: bonds,
        descrs: descrsList,
      );
    } catch (e) {
      debugPrint('从PostgreSQL获取可转债响应数据失败: $e');
      return null;
    }
  }

  /// 保存完整的API响应
  Future<void> saveConvertibleBondResponse(
    ConvertibleBondResponse response,
    String date,
  ) async {
    try {
      // 1. 保存响应元数据
      final descrsJson = jsonEncode(response.descrs);

      await safeExecute(
        '''
        INSERT INTO bond_responses (date, status, errmsg, msg, descrs_json, created_at)
        VALUES (@date, @status, @errmsg, @msg, @descrsJson, NOW())
        ON CONFLICT (date) DO UPDATE 
        SET status = @status, errmsg = @errmsg, msg = @msg, descrs_json = @descrsJson, created_at = NOW()
      ''',
        substitutionValues: {
          'date': date,
          'status': response.status,
          'errmsg': response.errmsg,
          'msg': response.msg,
          'descrsJson': descrsJson,
        },
      );

      // 2. 保存所有债券数据
      await saveConvertibleBonds(response.bonds, date);

      debugPrint('已保存可转债响应数据和${response.bonds.length}条债券数据到PostgreSQL');
    } catch (e) {
      debugPrint('保存可转债响应数据到PostgreSQL失败: $e');
      rethrow;
    }
  }

  /// 检查指定日期的数据是否存在
  Future<bool> hasConvertibleBondData(String date) async {
    try {
      final results = await safeQuery(
        '''
        SELECT 1 FROM bond_responses
        WHERE date = @date
        LIMIT 1
      ''',
        substitutionValues: {'date': date},
      );

      return results.isNotEmpty;
    } catch (e) {
      debugPrint('检查PostgreSQL数据存在性失败: $e');
      return false;
    }
  }

  /// 清除所有数据
  Future<void> clearAllData() async {
    try {
      await safeExecute('DELETE FROM convertible_bonds');
      await safeExecute('DELETE FROM bond_responses');

      debugPrint('已清除PostgreSQL中的所有数据');
    } catch (e) {
      debugPrint('清除PostgreSQL数据失败: $e');
      rethrow;
    }
  }

  /// 完全重置数据库（删除并重建表）
  Future<void> resetDatabase() async {
    try {
      // 删除现有表
      await safeExecute('DROP TABLE IF EXISTS convertible_bonds CASCADE');
      await safeExecute('DROP TABLE IF EXISTS bond_responses CASCADE');

      debugPrint('数据库表已删除');

      // 重新创建表
      await _createTables();

      debugPrint('数据库重置完成');
    } catch (e) {
      debugPrint('重置数据库失败: $e');
      rethrow;
    }
  }

  /// 执行数据库维护
  Future<Map<String, dynamic>> performMaintenance() async {
    try {
      // 1. 统计数据
      final bondCountResult = await safeQuery(
        'SELECT COUNT(*) FROM convertible_bonds',
      );
      final bondCount =
          bondCountResult.isNotEmpty ? (bondCountResult.first[0] as int) : 0;

      final responseCountResult = await safeQuery(
        'SELECT COUNT(*) FROM bond_responses',
      );
      final responseCount =
          responseCountResult.isNotEmpty
              ? (responseCountResult.first[0] as int)
              : 0;

      // 2. 执行清理操作

      // 2.1 整理表空间
      await safeExecute('VACUUM ANALYZE convertible_bonds');
      await safeExecute('VACUUM ANALYZE bond_responses');

      // 2.2 优化索引
      await safeExecute('REINDEX TABLE convertible_bonds');
      await safeExecute('REINDEX TABLE bond_responses');

      return {
        'success': true,
        'message': 'PostgreSQL数据库维护完成',
        'bond_count': bondCount,
        'response_count': responseCount,
      };
    } catch (e) {
      debugPrint('PostgreSQL数据库维护失败: $e');
      return {
        'success': false,
        'message': '数据库维护失败: ${e.toString().split('\n')[0]}',
      };
    }
  }

  /// 将可转债对象转换为Map
  Map<String, dynamic> _convertBondToMap(ConvertibleBond bond) {
    return {
      'bondCode': bond.bondCode,
      'bondName': bond.bondName,
      'bondFullName': bond.bondFullName,
      'bondId': bond.bondId,
      'bondType': bond.bondType,
      'tradeDate': bond.tradeDate,
      'lastClose': bond.lastClose,
      'openPrice': bond.openPrice,
      'highPrice': bond.highPrice,
      'lowPrice': bond.lowPrice,
      'currentPrice': bond.currentPrice,
      'change': bond.change,
      'changePercent': bond.changePercent,
      'interestDays': bond.interestDays,
      'accruedInterest': bond.accruedInterest,
      'remainingYears': bond.remainingYears,
      'currentYield': bond.currentYield,
      'ytm': bond.ytm,
      'pureDebtValue': bond.pureDebtValue,
      'premium': bond.premium,
      'convertPrice': bond.convertPrice,
      'stockCode': bond.stockCode,
      'conversionRatio': bond.conversionRatio,
      'conversionValue': bond.conversionValue,
      'conversionPremium': bond.conversionPremium,
      'conversionPremiumRatio': bond.conversionPremiumRatio,
      'duration': bond.duration,
      'issueDate': bond.issueDate,
      'couponRate': bond.couponRate,
      'market': bond.market,
    };
  }

  /// 将Map转换为可转债对象
  ConvertibleBond _convertMapToBond(Map<String, dynamic> map) {
    return ConvertibleBond(
      bondCode: map['bondCode'] as String? ?? '',
      bondName: map['bondName'] as String? ?? '',
      bondFullName: map['bondFullName'] as String? ?? '',
      bondId: map['bondId'] as String? ?? '',
      bondType: map['bondType'] as String? ?? '',
      tradeDate: map['tradeDate'] as String? ?? '',
      lastClose: (map['lastClose'] as num?)?.toDouble() ?? 0.0,
      openPrice: (map['openPrice'] as num?)?.toDouble() ?? 0.0,
      highPrice: (map['highPrice'] as num?)?.toDouble() ?? 0.0,
      lowPrice: (map['lowPrice'] as num?)?.toDouble() ?? 0.0,
      currentPrice: (map['currentPrice'] as num?)?.toDouble() ?? 0.0,
      change: (map['change'] as num?)?.toDouble() ?? 0.0,
      changePercent: (map['changePercent'] as num?)?.toDouble() ?? 0.0,
      interestDays: (map['interestDays'] as num?)?.toDouble() ?? 0.0,
      accruedInterest: (map['accruedInterest'] as num?)?.toDouble() ?? 0.0,
      remainingYears: (map['remainingYears'] as num?)?.toDouble() ?? 0.0,
      currentYield: (map['currentYield'] as num?)?.toDouble() ?? 0.0,
      ytm: (map['ytm'] as num?)?.toDouble() ?? 0.0,
      pureDebtValue: (map['pureDebtValue'] as num?)?.toDouble() ?? 0.0,
      premium: (map['premium'] as num?)?.toDouble() ?? 0.0,
      convertPrice: (map['convertPrice'] as num?)?.toDouble() ?? 0.0,
      stockCode: map['stockCode'] as String? ?? '',
      conversionRatio: (map['conversionRatio'] as num?)?.toDouble() ?? 0.0,
      conversionValue: (map['conversionValue'] as num?)?.toDouble() ?? 0.0,
      conversionPremium: (map['conversionPremium'] as num?)?.toDouble() ?? 0.0,
      conversionPremiumRatio:
          (map['conversionPremiumRatio'] as num?)?.toDouble() ?? 0.0,
      duration: (map['duration'] as num?)?.toDouble() ?? 0.0,
      issueDate: map['issueDate'] as String? ?? '',
      couponRate: (map['couponRate'] as num?)?.toDouble() ?? 0.0,
      market: map['market'] as String? ?? '',
    );
  }
}
