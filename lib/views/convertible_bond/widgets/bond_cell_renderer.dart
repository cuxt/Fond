import 'package:flutter/material.dart';
import 'package:fond/views/convertible_bond/models/convertible_bond.dart';

/// 可转债表格单元格渲染器
class BondCellRenderer {
  /// 根据字段名称渲染对应的单元格内容
  static Widget buildCellForField(
    String name,
    ConvertibleBond bond,
    BuildContext context,
  ) {
    Widget cellContent;

    // 根据不同的字段名显示不同的内容
    switch (name) {
      case 'jydm': // 代码
        cellContent = Text(bond.bondCode);
        break;
      case 'jydm_mc': // 代码简称
        cellContent = Text(bond.bondName);
        break;
      case 'p00868_f028': // 收盘价
        cellContent = Text(
          bond.currentPrice.toStringAsFixed(2),
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: bond.changePercent < 0 ? Colors.green : Colors.red,
          ),
        );
        break;
      case 'p00868_f005': // 涨跌幅(%)
        cellContent = Text(
          '${bond.changePercent.toStringAsFixed(2)}%',
          style: TextStyle(
            color: bond.changePercent < 0 ? Colors.green : Colors.red,
          ),
        );
        break;
      case 'p00868_f024': // 转股价格
        cellContent = Text(bond.convertPrice.toStringAsFixed(2));
        break;
      case 'p00868_f022': // 转股溢价率(%)
        cellContent = Text(
          '${bond.conversionPremiumRatio.toStringAsFixed(2)}%',
          style: TextStyle(
            color: bond.conversionPremiumRatio < 0 ? Colors.green : Colors.red,
          ),
        );
        break;
      case 'p00868_f023': // 纯债到期收益率(%)
        cellContent = Text(
          '${bond.ytm.toStringAsFixed(2)}%',
          style: TextStyle(color: bond.ytm < 0 ? Colors.red : Colors.green),
        );
        break;
      case 'p00868_f003': // 剩余期限(年)
        cellContent = Text('${bond.remainingYears.toStringAsFixed(2)}年');
        break;
      case 'p00868_f002': // 交易日期
        cellContent = Text(bond.tradeDate);
        break;
      case 'p00868_f029': // 发行日期
        cellContent = Text(bond.issueDate);
        break;
      case 'f004n_bond063': // 正股代码
        cellContent = Text(bond.stockCode);
        break;
      case 'p00868_f016': // 前收盘价
        cellContent = Text(bond.lastClose.toStringAsFixed(2));
        break;
      case 'p00868_f007': // 开盘价
        cellContent = Text(bond.openPrice.toStringAsFixed(2));
        break;
      case 'p00868_f006': // 最高价
        cellContent = Text(bond.highPrice.toStringAsFixed(2));
        break;
      case 'p00868_f001': // 最低价
        cellContent = Text(bond.lowPrice.toStringAsFixed(2));
        break;
      case 'p00868_f011': // 涨跌
        cellContent = Text(
          bond.change.toStringAsFixed(2),
          style: TextStyle(color: bond.change < 0 ? Colors.green : Colors.red),
        );
        break;
      case 'p00868_f014': // 已计息天数
        cellContent = Text(bond.interestDays.toStringAsFixed(0));
        break;
      case 'p00868_f008': // 应计利息
        cellContent = Text(bond.accruedInterest.toStringAsFixed(6));
        break;
      case 'p00868_f026': // 当期收益率(%)
        cellContent = Text('${bond.currentYield.toStringAsFixed(2)}%');
        break;
      case 'p00868_f004': // 纯债价值
        cellContent = Text(bond.pureDebtValue.toStringAsFixed(2));
        break;
      case 'p00868_f017': // 纯债溢价率(%)
        cellContent = Text('${bond.premium.toStringAsFixed(2)}%');
        break;
      case 'p00868_f019': // 转股比例
        cellContent = Text(bond.conversionRatio.toStringAsFixed(2));
        break;
      case 'p00868_f027': // 转换价值
        cellContent = Text(bond.conversionValue.toStringAsFixed(2));
        break;
      case 'p00868_f018': // 转股溢价
        cellContent = Text(bond.conversionPremium.toStringAsFixed(2));
        break;
      case 'p00868_f013': // 票面利率(%)
        cellContent = Text('${bond.couponRate.toStringAsFixed(2)}%');
        break;
      case 'p00868_f020': // 交易市场
        cellContent = Text(bond.market);
        break;
      case 'p00868_f009': // 期限(年)
        cellContent = Text('${bond.duration.toStringAsFixed(2)}年');
        break;
      case 'p00868_f030': // 债券类型
        cellContent = Text(bond.bondType);
        break;
      // 其他字段可以根据需要添加
      default:
        cellContent = Text('--');
    }

    return Container(
      width: 120,
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
      child: cellContent,
    );
  }
}
