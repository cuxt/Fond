import 'package:fond/views/convertible_bond/models/convertible_bond.dart';

/// 可转债排序工具类
class BondSorter {
  /// 对可转债列表按指定列和排序方向进行排序
  static void sortBonds(
    List<ConvertibleBond> bonds,
    String column,
    bool ascending,
  ) {
    bonds.sort((a, b) {
      var aValue, bValue;

      // 根据列名获取对应的值
      switch (column) {
        case 'jydm': // 债券代码
          aValue = a.bondCode;
          bValue = b.bondCode;
          break;
        case 'jydm_mc': // 债券简称
          aValue = a.bondName;
          bValue = b.bondName;
          break;
        case 'p00868_f028': // 收盘价
          aValue = a.currentPrice;
          bValue = b.currentPrice;
          break;
        case 'p00868_f005': // 涨跌幅(%)
          aValue = a.changePercent;
          bValue = b.changePercent;
          break;
        case 'p00868_f024': // 转股价格
          aValue = a.convertPrice;
          bValue = b.convertPrice;
          break;
        case 'p00868_f022': // 转股溢价率(%)
          aValue = a.conversionPremiumRatio;
          bValue = b.conversionPremiumRatio;
          break;
        case 'p00868_f023': // 纯债到期收益率(%)
          aValue = a.ytm;
          bValue = b.ytm;
          break;
        case 'p00868_f003': // 剩余期限(年)
          aValue = a.remainingYears;
          bValue = b.remainingYears;
          break;
        case 'p00868_f002': // 交易日期
          aValue = a.tradeDate;
          bValue = b.tradeDate;
          break;
        case 'p00868_f016': // 前收盘价
          aValue = a.lastClose;
          bValue = b.lastClose;
          break;
        case 'p00868_f007': // 开盘价
          aValue = a.openPrice;
          bValue = b.openPrice;
          break;
        case 'p00868_f006': // 最高价
          aValue = a.highPrice;
          bValue = b.highPrice;
          break;
        case 'p00868_f001': // 最低价
          aValue = a.lowPrice;
          bValue = b.lowPrice;
          break;
        case 'p00868_f011': // 涨跌
          aValue = a.change;
          bValue = b.change;
          break;
        default:
          return 0;
      }

      // 字符串比较
      if (aValue is String) {
        final result = aValue.compareTo(bValue);
        return ascending ? result : -result;
      }
      // 数值比较
      else if (aValue is num) {
        final result = aValue.compareTo(bValue);
        return ascending ? result : -result;
      }
      return 0;
    });
  }
}
