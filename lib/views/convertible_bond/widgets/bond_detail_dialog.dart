import 'package:flutter/material.dart';
import 'package:fond/views/convertible_bond/models/convertible_bond.dart';

/// 可转债详情对话框
class BondDetailDialog extends StatelessWidget {
  final ConvertibleBond bond;

  const BondDetailDialog({super.key, required this.bond});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('${bond.bondName}(${bond.bondCode})'),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _detailItem('债券全称', bond.bondFullName),
            _detailItem('交易日期', bond.tradeDate),
            _detailItem('收盘价', bond.currentPrice.toStringAsFixed(2)),
            _detailItem(
              '涨跌幅',
              '${bond.changePercent.toStringAsFixed(2)}%',
              color: bond.changePercent < 0 ? Colors.green : Colors.red,
            ),
            _detailItem('转股价格', bond.convertPrice.toStringAsFixed(2)),
            _detailItem('正股代码', bond.stockCode),
            _detailItem(
              '转股溢价率',
              '${bond.conversionPremiumRatio.toStringAsFixed(2)}%',
            ),
            _detailItem('纯债到期收益率', '${bond.ytm.toStringAsFixed(2)}%'),
            _detailItem('纯债价值', bond.pureDebtValue.toStringAsFixed(2)),
            _detailItem('纯债溢价率', '${bond.premium.toStringAsFixed(2)}%'),
            _detailItem('转股比例', bond.conversionRatio.toStringAsFixed(2)),
            _detailItem('转换价值', bond.conversionValue.toStringAsFixed(2)),
            _detailItem('转股溢价', bond.conversionPremium.toStringAsFixed(2)),
            _detailItem('剩余期限', '${bond.remainingYears.toStringAsFixed(2)}年'),
            _detailItem('发行日期', bond.issueDate),
            _detailItem('期限', '${bond.duration.toStringAsFixed(2)}年'),
            _detailItem('票面利率', '${bond.couponRate.toStringAsFixed(2)}%'),
            _detailItem('交易市场', bond.market),
            _detailItem('债券类型', bond.bondType),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('关闭'),
        ),
      ],
    );
  }

  /// 详情项辅助方法
  Widget _detailItem(String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value, style: TextStyle(color: color))),
        ],
      ),
    );
  }
}

/// 显示可转债详情对话框的辅助方法
void showBondDetails(BuildContext context, ConvertibleBond bond) {
  showDialog(
    context: context,
    builder: (context) => BondDetailDialog(bond: bond),
  );
}
