import 'package:flutter/foundation.dart';
import 'package:fond/views/convertible_bond/models/convertible_bond.dart';
import 'package:fond/views/convertible_bond/models/filter_condition.dart';
import 'package:fond/views/convertible_bond/utils/calculation_utils.dart';
import 'package:fond/views/convertible_bond/utils/string_field_utils.dart';

/// 过滤工具类
class FilterUtils {
  /// 应用过滤条件
  static List<ConvertibleBond> filterBonds(
    List<ConvertibleBond> bonds,
    List<FilterCondition> filterConditions,
  ) {
    if (filterConditions.isEmpty) {
      return bonds;
    }

    return bonds.where((bond) {
      // 所有条件必须满足
      for (var condition in filterConditions) {
        final dynamic fieldValue = CalculationUtils.getFieldValue(
          bond,
          condition.field,
        );
        if (fieldValue == null) continue;

        // 使用辅助方法判断字段是否为字符串类型
        bool isString = StringFieldUtils.isStringField(condition.field);

        // 特殊处理：如果字段值是字符串但不是我们预定义的字符串字段，并且不能转换为数字，也视为字符串类型
        if (!isString &&
            fieldValue is String &&
            ![
              'p00868_f002',
              'p00868_f029',
            ].contains(condition.field) && // 日期字段特殊处理
            double.tryParse(fieldValue.toString()) == null) {
          isString = true;
          debugPrint('检测到未预定义的字符串字段: ${condition.field}, 值: $fieldValue');
        }

        // 根据字段类型不同分别处理
        if (isString) {
          // 字符串类型比较
          String actualValue = fieldValue.toString().toLowerCase();
          String targetValue = condition.value.toLowerCase();

          debugPrint(
            '字符串比较: 字段=${condition.field}, 实际值=$actualValue, 目标值=$targetValue, 操作符=${condition.operator}',
          );

          switch (condition.operator) {
            case '等于':
              if (actualValue != targetValue) return false;
              break;
            case '不等于':
              if (actualValue == targetValue) return false;
              break;
            case '包含':
              if (!actualValue.contains(targetValue)) return false;
              break;
            case '不包含':
              if (actualValue.contains(targetValue)) return false;
              break;
            case '开头是':
              if (!actualValue.startsWith(targetValue)) return false;
              break;
            case '结尾是':
              if (!actualValue.endsWith(targetValue)) return false;
              break;
            default:
              // 如果使用了不支持的字符串操作符，尝试数值比较（容错处理）
              debugPrint('不支持对字符串使用操作符: ${condition.operator}，尝试数值比较');
              double? numValue = double.tryParse(fieldValue.toString());
              if (numValue == null) continue;

              double? condValue = double.tryParse(condition.value);
              if (condValue == null) continue;

              // 执行数值比较
              switch (condition.operator) {
                case '大于':
                  if (!(numValue > condValue)) return false;
                  break;
                case '小于':
                  if (!(numValue < condValue)) return false;
                  break;
                case '等于':
                  if (!(numValue == condValue)) return false;
                  break;
                case '大于等于':
                  if (!(numValue >= condValue)) return false;
                  break;
                case '小于等于':
                  if (!(numValue <= condValue)) return false;
                  break;
                case '不等于':
                  if (!(numValue != condValue)) return false;
                  break;
                default:
                  continue;
              }
          }
        } else {
          // 数值类型比较
          double? numValue =
              fieldValue is double
                  ? fieldValue
                  : double.tryParse(fieldValue.toString());

          if (numValue == null) continue;

          double? condValue = double.tryParse(condition.value);
          if (condValue == null) continue;

          switch (condition.operator) {
            case '大于':
              if (!(numValue > condValue)) return false;
              break;
            case '小于':
              if (!(numValue < condValue)) return false;
              break;
            case '等于':
              if (!(numValue == condValue)) return false;
              break;
            case '大于等于':
              if (!(numValue >= condValue)) return false;
              break;
            case '小于等于':
              if (!(numValue <= condValue)) return false;
              break;
            case '不等于':
              if (!(numValue != condValue)) return false;
              break;
            default:
              // 如果使用了不支持的数值操作符，尝试字符串比较（容错处理）
              debugPrint('不支持对数值使用操作符: ${condition.operator}，尝试字符串比较');
              String actualValue = fieldValue.toString().toLowerCase();
              String targetValue = condition.value.toLowerCase();

              switch (condition.operator) {
                case '等于':
                  if (actualValue != targetValue) return false;
                  break;
                case '不等于':
                  if (actualValue == targetValue) return false;
                  break;
                case '包含':
                  if (!actualValue.contains(targetValue)) return false;
                  break;
                case '不包含':
                  if (actualValue.contains(targetValue)) return false;
                  break;
                case '开头是':
                  if (!actualValue.startsWith(targetValue)) return false;
                  break;
                case '结尾是':
                  if (!actualValue.endsWith(targetValue)) return false;
                  break;
                default:
                  continue;
              }
          }
        }
      }
      return true;
    }).toList();
  }
}
