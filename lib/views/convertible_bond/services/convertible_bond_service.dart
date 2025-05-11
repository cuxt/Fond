import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:fond/services/database/database_service.dart';
import 'package:fond/views/convertible_bond/models/convertible_bond.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 可转债服务类
class ConvertibleBondService {
  final Dio _dio = Dio();
  final String _baseUrl =
      'http://ft.10jqka.com.cn/standardgwapi/api/iFindService/query/v1/ifind_web';
  final DatabaseService _databaseService = DatabaseService();

  /// 获取可转债列表数据
  Future<ConvertibleBondResponse> getConvertibleBonds({
    required String date, // 日期，格式：yyyyMMdd
    String bondType = '全部', // 债券类型
    int begin = 1, // 开始位置
    int count = 100, // 数量
    int page = 1, // 页码
    bool forceRefresh = false, // 强制刷新，不使用缓存
  }) async {
    try {
      // 初始化数据库服务
      if (!_databaseService.isInitialized) {
        await _databaseService.initialize();
      }

      // 1. 如果不强制刷新，先尝试从数据库获取数据
      if (!forceRefresh) {
        final hasData = await _databaseService.hasConvertibleBondData(date);
        if (hasData) {
          debugPrint('从数据库获取$date的可转债数据');
          final cachedResponse = await _databaseService
              .getConvertibleBondsByDate(date);
          if (cachedResponse != null) {
            return cachedResponse;
          }
        }
      }

      // 2. 如果数据库中没有数据或强制刷新，则从API获取
      debugPrint('从API获取$date的可转债数据');

      // 获取 cookie 数据
      final prefs = await SharedPreferences.getInstance();
      final cookie = prefs.getString('cookie') ?? '';
      String jgbsessid = '';

      if (cookie.isNotEmpty) {
        try {
          final cookieJson = jsonDecode(cookie);
          jgbsessid = cookieJson['jgbsessid'] ?? '';
          debugPrint('成功获取Cookie: jgbsessid=$jgbsessid');
        } catch (e) {
          debugPrint('Cookie解析错误: $e');
        }
      } else {
        debugPrint('未找到Cookie信息，将使用默认值');
        jgbsessid = 'f4f8d14449551207d9878e659683660a';
      }

      // 设置请求头
      _dio.options.headers = {
        'User-Agent':
            'Mozilla/5.0 (Windows NT 6.2; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/84.0.4147.105 Safari/537.36',
        'Accept': 'application/json, text/plain, */*',
        'Accept-Encoding': 'gzip, deflate',
        'Content-Type': 'application/x-www-form-urlencoded',
        'Origin': 'http://ft.10jqka.com.cn',
        'Referer':
            'http://ft.10jqka.com.cn/standardgwapi/bff/thematic_bff/topic/B0005.html?version=1.10.12.415&mac=00-00-00-00-00-00',
        'Accept-Language': 'zh-CN,zh;q=0.9,zh-TW;q=0.8,en;q=0.7',
        'Cookie': 'jgbsessid=$jgbsessid;',
      };

      // 构建请求数据
      final formData = {
        'edate': date,
        'zqlx': bondType,
        'begin': begin,
        'count': count,
        'webPage': page,
      };

      debugPrint(
        '准备发送请求，参数: date=$date, begin=$begin, count=$count, page=$page',
      );

      // 设置超时时间和重试
      _dio.options.connectTimeout = const Duration(seconds: 10);
      _dio.options.receiveTimeout = const Duration(seconds: 30);
      _dio.options.sendTimeout = const Duration(seconds: 10);

      // 发送请求
      final response = await _dio.post(
        '$_baseUrl?reqtype=p00868',
        data: formData,
        options: Options(
          contentType: Headers.formUrlEncodedContentType,
          responseType: ResponseType.json,
        ),
      );

      debugPrint('获取到响应，状态码: ${response.statusCode}');

      // 解析返回数据
      if (response.statusCode == 200) {
        // API直接返回一个包含status、errmsg、msg和rows字段的JSON对象
        if (response.data is Map) {
          final responseData = response.data as Map<String, dynamic>;

          // 保存原始响应数据以便调试
          if (kDebugMode) {
            prefs.setString('last_bonds_response', jsonEncode(responseData));
          }
          final resultResponse = ConvertibleBondResponse.fromJson(responseData);
          debugPrint('成功解析数据，获取到${resultResponse.bonds.length}条可转债信息');

          // 3. 将API获取的数据保存到数据库中
          try {
            await _databaseService.saveConvertibleBondResponse(
              resultResponse,
              date,
            );
            debugPrint('成功将可转债数据保存到数据库');
          } catch (dbError) {
            // 数据库保存失败不影响正常功能，仅记录错误
            debugPrint('保存数据到数据库失败，但API数据获取成功: $dbError');
          }

          return resultResponse;
        } else {
          final errorMsg = 'API返回的数据格式不正确: ${response.data.runtimeType}';
          debugPrint(errorMsg);
          throw Exception(errorMsg);
        }
      } else {
        final errorMsg = '获取可转债数据失败: ${response.statusCode}';
        debugPrint(errorMsg);
        throw Exception(errorMsg);
      }
    } on DioException catch (e) {
      String errorMessage;
      switch (e.type) {
        case DioExceptionType.connectionTimeout:
          errorMessage = '连接超时，请检查网络';
          break;
        case DioExceptionType.sendTimeout:
          errorMessage = '发送请求超时，请稍后重试';
          break;
        case DioExceptionType.receiveTimeout:
          errorMessage = '接收响应超时，请稍后重试';
          break;
        case DioExceptionType.badResponse:
          errorMessage = '服务器返回错误: ${e.response?.statusCode ?? "未知"}';
          break;
        case DioExceptionType.cancel:
          errorMessage = '请求被取消';
          break;
        default:
          errorMessage = '网络错误: ${e.message}';
      }
      debugPrint('API请求异常: $errorMessage');
      throw Exception(errorMessage);
    } catch (e) {
      debugPrint('获取可转债数据异常: $e');
      throw Exception('获取可转债数据失败: $e');
    }
  }

  /// 清除数据库中的所有数据
  Future<void> clearAllCachedData() async {
    try {
      if (!_databaseService.isInitialized) {
        await _databaseService.initialize();
      }
      await _databaseService.clearAllData();
      debugPrint('已清除所有缓存的可转债数据');
    } catch (e) {
      debugPrint('清除缓存数据失败: $e');
      throw Exception('清除缓存数据失败: $e');
    }
  }
}
