import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:fond/views/convertible_bond/models/convertible_bond.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as path;
import 'dart:convert';
import 'package:path_provider/path_provider.dart' as path_provider;

/// SQLite数据库服务类
class SqliteService {
  Database? _db;

  /// 获取数据库实例
  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDatabase();
    return _db!;
  }

  /// 初始化数据库
  Future<void> initialize() async {
    await database;
  }

  /// 初始化数据库
  Future<Database> _initDatabase() async {
    String dbFilePath;

    if (!kIsWeb && (Platform.isWindows || Platform.isLinux)) {
      // 在Windows和Linux上，我们需要使用应用文档目录
      final documentsDir =
          await path_provider.getApplicationDocumentsDirectory();
      dbFilePath = path.join(documentsDir.path, 'fond.db');
      debugPrint('SQLite数据库路径(Windows/Linux): $dbFilePath');
    } else {
      // 在其他平台上使用标准的getDatabasesPath()
      final dbPath = await getDatabasesPath();
      dbFilePath = path.join(dbPath, 'fond.db');
      debugPrint('SQLite数据库路径: $dbFilePath');
    }

    // 打开数据库，如果不存在则创建
    return await openDatabase(
      dbFilePath,
      version: 1,
      onCreate: _createDatabase,
      onUpgrade: _upgradeDatabase,
    );
  }

  /// 创建数据库表
  Future<void> _createDatabase(Database db, int version) async {
    // 创建可转债数据表
    await db.execute('''
      CREATE TABLE convertible_bonds (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        bond_code TEXT NOT NULL,
        bond_name TEXT NOT NULL,
        current_price REAL,
        trade_date TEXT NOT NULL,
        data_json TEXT NOT NULL,
        created_at INTEGER NOT NULL
      )
    ''');

    // 创建可转债响应数据表(存储完整响应)
    await db.execute('''
      CREATE TABLE bond_responses (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT UNIQUE NOT NULL,
        status INTEGER NOT NULL,
        errmsg TEXT,
        msg TEXT,
        descrs_json TEXT,
        created_at INTEGER NOT NULL
      )
    ''');

    debugPrint('数据库表创建完成');
  }

  /// 升级数据库
  Future<void> _upgradeDatabase(
    Database db,
    int oldVersion,
    int newVersion,
  ) async {
    // 未来版本升级时使用
  }

  /// 关闭数据库连接
  Future<void> close() async {
    if (_db != null) {
      await _db!.close();
      _db = null;
    }
  }

  /// 保存可转债数据列表
  Future<void> saveConvertibleBonds(
    List<ConvertibleBond> bonds,
    String date,
  ) async {
    final db = await database;
    final batch = db.batch();

    for (final bond in bonds) {
      // 将对象转换为JSON字符串存储
      final Map<String, dynamic> bondMap = {
        'bond_code': bond.bondCode,
        'bond_name': bond.bondName,
        'current_price': bond.currentPrice,
        'trade_date': date,
        'data_json': jsonEncode(_convertBondToMap(bond)),
        'created_at': DateTime.now().millisecondsSinceEpoch,
      };

      // 检查是否已存在该债券的数据
      final List<Map<String, dynamic>> existing = await db.query(
        'convertible_bonds',
        where: 'bond_code = ? AND trade_date = ?',
        whereArgs: [bond.bondCode, date],
      );

      if (existing.isNotEmpty) {
        // 更新现有记录
        batch.update(
          'convertible_bonds',
          bondMap,
          where: 'bond_code = ? AND trade_date = ?',
          whereArgs: [bond.bondCode, date],
        );
      } else {
        // 插入新记录
        batch.insert('convertible_bonds', bondMap);
      }
    }

    // 执行批处理
    await batch.commit(noResult: true);
    debugPrint('已保存 ${bonds.length} 条可转债数据到SQLite');
  }

  /// 获取可转债数据列表
  Future<List<ConvertibleBond>> getConvertibleBonds(String date) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'convertible_bonds',
      where: 'trade_date = ?',
      whereArgs: [date],
    );

    return List.generate(maps.length, (i) {
      final map = maps[i];
      final dataJson = map['data_json'] as String;
      final bondData = jsonDecode(dataJson) as Map<String, dynamic>;
      return _convertMapToBond(bondData);
    });
  }

  /// 根据日期获取可转债响应数据
  Future<ConvertibleBondResponse?> getConvertibleBondsByDate(
    String date,
  ) async {
    final db = await database;

    // 1. 查询响应数据
    final List<Map<String, dynamic>> responseMaps = await db.query(
      'bond_responses',
      where: 'date = ?',
      whereArgs: [date],
    );

    if (responseMaps.isEmpty) {
      return null;
    }

    final responseMap = responseMaps.first;

    // 2. 查询债券数据
    final bonds = await getConvertibleBonds(date);

    // 3. 解析descrs数据
    final descrsJson = responseMap['descrs_json'] as String;
    final List<dynamic> rawDescrs = jsonDecode(descrsJson);
    final List<Map<String, dynamic>> descrsList =
        rawDescrs.map((item) => Map<String, dynamic>.from(item)).toList();

    // 4. 构建响应对象
    return ConvertibleBondResponse(
      status: responseMap['status'] as int,
      errmsg: responseMap['errmsg'] as String? ?? '',
      msg: responseMap['msg'] as String? ?? '',
      bonds: bonds,
      descrs: descrsList,
    );
  }

  /// 保存完整的API响应
  Future<void> saveConvertibleBondResponse(
    ConvertibleBondResponse response,
    String date,
  ) async {
    final db = await database;

    // 1. 保存响应元数据
    final responseMap = {
      'date': date,
      'status': response.status,
      'errmsg': response.errmsg,
      'msg': response.msg,
      'descrs_json': jsonEncode(response.descrs),
      'created_at': DateTime.now().millisecondsSinceEpoch,
    };

    // 检查是否已存在该日期的响应数据
    final List<Map<String, dynamic>> existing = await db.query(
      'bond_responses',
      where: 'date = ?',
      whereArgs: [date],
    );

    if (existing.isNotEmpty) {
      // 更新现有记录
      await db.update(
        'bond_responses',
        responseMap,
        where: 'date = ?',
        whereArgs: [date],
      );
    } else {
      // 插入新记录
      await db.insert('bond_responses', responseMap);
    }

    // 2. 保存所有债券数据
    await saveConvertibleBonds(response.bonds, date);

    debugPrint('已保存可转债响应数据和${response.bonds.length}条债券数据到SQLite');
  }

  /// 检查指定日期的数据是否存在
  Future<bool> hasConvertibleBondData(String date) async {
    final db = await database;

    final List<Map<String, dynamic>> result = await db.query(
      'bond_responses',
      columns: ['id'],
      where: 'date = ?',
      whereArgs: [date],
      limit: 1,
    );

    return result.isNotEmpty;
  }

  /// 清除所有数据
  Future<void> clearAllData() async {
    final db = await database;
    await db.delete('convertible_bonds');
    await db.delete('bond_responses');
    debugPrint('已清除SQLite中的所有数据');
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
      lastClose: map['lastClose'] as double? ?? 0.0,
      openPrice: map['openPrice'] as double? ?? 0.0,
      highPrice: map['highPrice'] as double? ?? 0.0,
      lowPrice: map['lowPrice'] as double? ?? 0.0,
      currentPrice: map['currentPrice'] as double? ?? 0.0,
      change: map['change'] as double? ?? 0.0,
      changePercent: map['changePercent'] as double? ?? 0.0,
      interestDays: map['interestDays'] as double? ?? 0.0,
      accruedInterest: map['accruedInterest'] as double? ?? 0.0,
      remainingYears: map['remainingYears'] as double? ?? 0.0,
      currentYield: map['currentYield'] as double? ?? 0.0,
      ytm: map['ytm'] as double? ?? 0.0,
      pureDebtValue: map['pureDebtValue'] as double? ?? 0.0,
      premium: map['premium'] as double? ?? 0.0,
      convertPrice: map['convertPrice'] as double? ?? 0.0,
      stockCode: map['stockCode'] as String? ?? '',
      conversionRatio: map['conversionRatio'] as double? ?? 0.0,
      conversionValue: map['conversionValue'] as double? ?? 0.0,
      conversionPremium: map['conversionPremium'] as double? ?? 0.0,
      conversionPremiumRatio: map['conversionPremiumRatio'] as double? ?? 0.0,
      duration: map['duration'] as double? ?? 0.0,
      issueDate: map['issueDate'] as String? ?? '',
      couponRate: map['couponRate'] as double? ?? 0.0,
      market: map['market'] as String? ?? '',
    );
  }

  /// 执行数据库维护
  Future<Map<String, dynamic>> performMaintenance() async {
    final db = await database;
    try {
      // 1. 统计数据
      final bondCount =
          Sqflite.firstIntValue(
            await db.rawQuery('SELECT COUNT(*) FROM convertible_bonds'),
          ) ??
          0;

      final responseCount =
          Sqflite.firstIntValue(
            await db.rawQuery('SELECT COUNT(*) FROM bond_responses'),
          ) ??
          0;

      // 2. 执行清理操作

      // 2.1 执行 VACUUM 命令来整理数据库文件
      await db.execute('VACUUM');

      // 2.2 优化索引
      await db.execute('ANALYZE');

      return {
        'success': true,
        'message': '数据库维护完成',
        'bond_count': bondCount,
        'response_count': responseCount,
      };
    } catch (e) {
      debugPrint('数据库维护失败: $e');
      return {
        'success': false,
        'message': '数据库维护失败: ${e.toString().split('\n')[0]}',
      };
    }
  }
}
