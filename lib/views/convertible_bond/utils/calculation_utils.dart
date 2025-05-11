import 'package:fond/views/convertible_bond/models/convertible_bond.dart';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';

/// 计算工具类
class CalculationUtils {
  // 获取字段值
  static dynamic getFieldValue(ConvertibleBond bond, String field) {
    switch (field) {
      case 'bond_cd':
      case 'jydm':
        return bond.bondCode;
      case 'bond_nm':
      case 'jydm_mc':
        return bond.bondName;
      case 'bond_id':
        return bond.bondId;
      case 'price':
      case 'p00868_f028':
        return bond.currentPrice;
      case 'premium_rt':
      case 'p00868_f017':
        return bond.premium;
      case 'convert_value':
      case 'p00868_f027':
        return bond.conversionValue;
      case 'convert_premium_rt':
      case 'p00868_f022':
        return bond.conversionPremiumRatio;
      case 'ytm_rt':
      case 'p00868_f023':
        return bond.ytm;
      case 'year_left':
      case 'p00868_f003':
        return bond.remainingYears;
      case 'p00868_f007': // 开盘价
        return bond.openPrice;
      case 'p00868_f006': // 最高价
        return bond.highPrice;
      case 'p00868_f001': // 最低价
        return bond.lowPrice;
      case 'p00868_f011': // 涨跌
        return bond.change;
      case 'p00868_f005': // 涨跌幅(%)
        return bond.changePercent;
      case 'p00868_f014': // 已计息天数
        return bond.interestDays;
      case 'p00868_f008': // 应计利息
        return bond.accruedInterest;
      case 'p00868_f026': // 当期收益率(%)
        return bond.currentYield;
      case 'p00868_f004': // 纯债价值
        return bond.pureDebtValue;
      case 'p00868_f024': // 转股价格
        return bond.convertPrice;
      case 'p00868_f019': // 转股比例
        return bond.conversionRatio;
      case 'p00868_f018': // 转股溢价
        return bond.conversionPremium;
      case 'p00868_f016': // 前收盘价
        return bond.lastClose;
      case 'p00868_f013': // 票面利率(%)
        return bond.couponRate;
      case 'p00868_f009': // 期限(年)
        return bond.duration;
      case 'p00868_f002': // 交易日期
        return bond.tradeDate;
      case 'p00868_f029': // 发行日期
        return bond.issueDate;
      case 'f004n_bond063': // 正股代码
        return bond.stockCode;
      case 'p00868_f020': // 交易市场
        return bond.market;
      case 'p00868_f030': // 债券类型
        return bond.bondType;
      // 对于不认识的字段，尝试从表头信息获取
      default:
        debugPrint('请求未知字段: $field，将返回null');
        return null;
    }
  }

  // 获取指定字段的所有值
  static List<double> getFieldValues(
    List<ConvertibleBond> bonds,
    String field,
  ) {
    List<double> values = [];
    int nullCount = 0;
    int nanCount = 0;
    int infiniteCount = 0;

    for (var bond in bonds) {
      final value = getFieldValue(bond, field);
      if (value != null && value is num) {
        // 只有数值为有限数时才添加
        if (!value.isNaN && !value.isInfinite) {
          values.add(value.toDouble());
        } else if (value.isNaN) {
          nanCount++;
        } else if (value.isInfinite) {
          infiniteCount++;
        }
      } else if (value != null) {
        final doubleValue = double.tryParse(value.toString());
        if (doubleValue != null &&
            !doubleValue.isNaN &&
            !doubleValue.isInfinite) {
          values.add(doubleValue);
        } else {
          nullCount++;
        }
      } else {
        nullCount++;
      }
    }

    debugPrint(
      '字段 $field 总共收集到 ${values.length} 个有效值，$nullCount 个空值，$nanCount 个NaN值，$infiniteCount 个无穷值',
    );

    // 如果没有有效值但有债券数据，记录更详细的信息
    if (values.isEmpty && bonds.isNotEmpty) {
      final sample = bonds.first;
      debugPrint('示例债券数据: code=${sample.bondCode}, name=${sample.bondName}');
      final sampleValue = getFieldValue(sample, field);
      debugPrint(
        '字段 $field 的示例值类型: ${sampleValue?.runtimeType}, 值: $sampleValue',
      );
    }

    return values;
  }

  // 执行计算
  static Map<String, dynamic> calculateResult(
    List<double> values,
    String calculationType,
  ) {
    if (values.isEmpty) {
      return {
        'result': null,
        'count': 0,
        'type': calculationType,
        'min': null,
        'max': null,
      };
    }

    double result = 0;
    double minValue = values[0];
    double maxValue = values[0];

    try {
      minValue = values.reduce((a, b) => a < b ? a : b);
      maxValue = values.reduce((a, b) => a > b ? a : b);

      switch (calculationType) {
        case '平均值':
          result = values.reduce((a, b) => a + b) / values.length;
          break;
        case '中位数':
          values.sort();
          if (values.length % 2 == 0) {
            result =
                (values[values.length ~/ 2 - 1] + values[values.length ~/ 2]) /
                2;
          } else {
            result = values[values.length ~/ 2];
          }
          break;
        case '最大值':
          result = maxValue;
          break;
        case '最小值':
          result = minValue;
          break;
        case '标准差':
          final mean = values.reduce((a, b) => a + b) / values.length;
          final variance =
              values.map((x) => math.pow(x - mean, 2)).reduce((a, b) => a + b) /
              values.length;
          result = math.sqrt(variance);
          break;
        case '求和':
          result = values.reduce((a, b) => a + b);
          break;
        default:
          result = 0;
      }
    } catch (e) {
      debugPrint('计算错误: $e');
      // 如果计算过程中发生错误，返回null
      return {
        'result': null,
        'count': values.length,
        'type': calculationType,
        'min': minValue,
        'max': maxValue,
        'error': e.toString(),
      };
    }

    return {
      'result': result,
      'count': values.length,
      'type': calculationType,
      'min': minValue,
      'max': maxValue,
    };
  }
}
