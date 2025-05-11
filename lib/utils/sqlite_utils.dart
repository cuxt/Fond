import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

/// 初始化SQLite
///
/// 在Windows和Linux上使用sqflite_common_ffi来支持SQLite
Future<void> initializeSqlite() async {
  try {
    // 在Windows和Linux上使用sqflite_ffi
    if (!kIsWeb && (Platform.isWindows || Platform.isLinux)) {
      // 初始化FFI
      sqfliteFfiInit();
      // 设置databaseFactory为FFI的factory
      databaseFactory = databaseFactoryFfi;
      debugPrint('已初始化sqflite_ffi，平台: ${Platform.operatingSystem}');
    } else {
      debugPrint('使用标准sqflite，平台: ${Platform.operatingSystem}');
    }
  } catch (e) {
    debugPrint('初始化SQLite失败: $e');
    rethrow;
  }
}
