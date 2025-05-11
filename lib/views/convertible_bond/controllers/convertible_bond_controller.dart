import 'package:flutter/foundation.dart';
import 'package:fond/views/convertible_bond/models/convertible_bond.dart';
import 'package:fond/views/convertible_bond/models/filter_condition.dart';
import 'package:fond/views/convertible_bond/services/convertible_bond_service.dart';
import 'package:fond/views/convertible_bond/utils/calculation_utils.dart';
import 'package:fond/views/convertible_bond/utils/filter_utils.dart';
import 'package:intl/intl.dart';

/// 可转债计算控制器
class ConvertibleBondController {
  final ConvertibleBondService _bondService = ConvertibleBondService();

  // 加载字段信息
  Future<List<Map<String, dynamic>>> loadBondFields(String date) async {
    try {
      // 获取数据表头信息
      final response = await _bondService.getConvertibleBonds(
        date: date,
        begin: 1,
        count: 1, // 只需要获取一条数据来获取表头
        page: 1,
      );

      return response.descrs;
    } catch (e) {
      debugPrint('加载债券字段出错: $e');
      rethrow;
    }
  }

  // 执行单日计算
  Future<Map<String, dynamic>> performSingleDayCalculation({
    required String date,
    required String? selectedField,
    required String calculationType,
    required List<FilterCondition> filterConditions,
  }) async {
    if (selectedField == null) {
      throw ArgumentError('请选择要计算的字段');
    }

    try {
      // 获取数据
      debugPrint('准备获取数据，日期: $date, 字段: $selectedField');
      final response = await _bondService.getConvertibleBonds(
        date: date,
        begin: 1,
        count: 600, // 获取足够多的数据
        page: 1,
        forceRefresh: false,
      );

      if (response.bonds.isEmpty) {
        throw Exception('未获取到数据，请检查所选日期是否为交易日');
      }

      debugPrint('成功获取到 ${response.bonds.length} 条可转债数据');

      // 打印样本数据用于调试
      if (response.bonds.isNotEmpty) {
        final sampleBond = response.bonds.first;
        debugPrint(
          '样本数据: code=${sampleBond.bondCode}, name=${sampleBond.bondName}, price=${sampleBond.currentPrice}',
        );

        // 检查样本数据中请求的字段
        final fieldValue = CalculationUtils.getFieldValue(
          sampleBond,
          selectedField,
        );
        debugPrint(
          '请求的字段 $selectedField 在样本中的值：$fieldValue (${fieldValue.runtimeType})',
        );
      }

      // 应用过滤条件
      List<ConvertibleBond> filteredBonds = FilterUtils.filterBonds(
        response.bonds,
        filterConditions,
      );
      debugPrint('过滤后剩余 ${filteredBonds.length} 条数据');

      if (filteredBonds.isEmpty) {
        return {
          'result': null,
          'count': 0,
          'type': calculationType,
          'min': null,
          'max': null,
        };
      }

      // 获取要计算的数据列
      List<double> values = CalculationUtils.getFieldValues(
        filteredBonds,
        selectedField,
      );

      if (values.isEmpty) {
        return {
          'result': null,
          'count': 0,
          'type': calculationType,
          'min': null,
          'max': null,
        };
      }

      // 执行计算
      debugPrint('准备计算 $calculationType，数据集大小: ${values.length}');
      Map<String, dynamic> result = CalculationUtils.calculateResult(
        values,
        calculationType,
      );

      debugPrint('计算完成，结果: ${result['result']}');
      return result;
    } catch (e) {
      debugPrint('计算过程发生错误: $e');
      return {
        'result': null,
        'count': 0,
        'type': calculationType,
        'min': null,
        'max': null,
        'error': e.toString(),
      };
    }
  }

  // 执行批量计算
  Future<List<Map<String, dynamic>>> performBatchCalculation({
    required DateTime startDate,
    required DateTime endDate,
    required String? selectedField,
    required String calculationType,
    required List<FilterCondition> filterConditions,
  }) async {
    if (selectedField == null) {
      throw ArgumentError('请选择要计算的字段');
    }

    List<Map<String, dynamic>> results = [];
    DateTime currentDate = startDate;
    int daysProcessed = 0;

    while (currentDate.compareTo(endDate) <= 0) {
      // 跳过周末
      if (currentDate.weekday == DateTime.saturday ||
          currentDate.weekday == DateTime.sunday) {
        currentDate = currentDate.add(const Duration(days: 1));
        continue;
      }

      // 格式化日期
      String dateStr = DateFormat('yyyyMMdd').format(currentDate);
      String displayDate =
          '${dateStr.substring(0, 4)}-${dateStr.substring(4, 6)}-${dateStr.substring(6, 8)}';

      try {
        debugPrint('处理日期: $dateStr');

        // 获取当日数据
        final response = await _bondService.getConvertibleBonds(
          date: dateStr,
          begin: 1,
          count: 600,
          page: 1,
          forceRefresh: false,
        );

        if (response.bonds.isEmpty) {
          debugPrint('$dateStr 无数据，可能非交易日');
          // 添加无数据结果
          results.add({
            'date': dateStr,
            'display_date': displayDate,
            'result': null,
            'count': 0,
            'type': calculationType,
          });
        } else {
          // 应用过滤条件
          List<ConvertibleBond> filteredBonds = FilterUtils.filterBonds(
            response.bonds,
            filterConditions,
          );

          if (filteredBonds.isEmpty) {
            // 所有数据都被过滤掉
            results.add({
              'date': dateStr,
              'display_date': displayDate,
              'result': null,
              'count': 0,
              'type': calculationType,
            });
          } else {
            // 获取字段值并执行计算
            List<double> values = CalculationUtils.getFieldValues(
              filteredBonds,
              selectedField,
            );

            if (values.isEmpty) {
              // 没有有效的数值
              results.add({
                'date': dateStr,
                'display_date': displayDate,
                'result': null,
                'count': 0,
                'type': calculationType,
              });
            } else {
              // 执行计算
              Map<String, dynamic> result = CalculationUtils.calculateResult(
                values,
                calculationType,
              );

              // 添加日期信息
              result['date'] = dateStr;
              result['display_date'] = displayDate;

              results.add(result);
            }
          }
        }

        daysProcessed++;
        debugPrint('已处理 $daysProcessed 天');
      } catch (e) {
        debugPrint('处理日期 $dateStr 时发生错误: $e');
        // 添加错误结果
        results.add({
          'date': dateStr,
          'display_date': displayDate,
          'result': null,
          'count': 0,
          'type': calculationType,
          'error': e.toString(),
        });
      }

      // 移动到下一天
      currentDate = currentDate.add(const Duration(days: 1));
    }

    // 按日期排序结果
    results.sort(
      (a, b) => (a['date'] as String).compareTo(b['date'] as String),
    );

    return results;
  }
}
