import 'dart:convert';

import 'package:flutter/widgets.dart';

/// 可转债API响应模型
class ConvertibleBondResponse {
  final int status;
  final String errmsg;
  final String msg;
  final List<ConvertibleBond> bonds;
  final List<Map<String, dynamic>> descrs;

  ConvertibleBondResponse({
    required this.status,
    required this.errmsg,
    required this.msg,
    required this.bonds,
    required this.descrs,
  });

  factory ConvertibleBondResponse.fromJson(Map<String, dynamic> json) {
    List<ConvertibleBond> bondsList = [];
    List<Map<String, dynamic>> descrsList = [];

    // 解析descrs数据
    if (json['descrs'] != null) {
      try {
        final List<dynamic> descrsData = json['descrs'];
        descrsList =
            descrsData
                .map((descr) => Map<String, dynamic>.from(descr))
                .toList();
      } catch (e) {
        debugPrint('解析descrs数据出错: $e');
      }
    }

    // API返回的rows是一个JSON字符串，需要解析
    if (json['rows'] != null) {
      try {
        final List<dynamic> rowsData = jsonDecode(json['rows']);
        bondsList =
            rowsData.map((row) {
              if (row is List) {
                return ConvertibleBond.fromList(
                  row.map((e) => e.toString()).toList(),
                );
              }
              return ConvertibleBond.empty();
            }).toList();
      } catch (e) {
        debugPrint('解析rows数据出错: $e');
      }
    }

    return ConvertibleBondResponse(
      status: json['status'] ?? 0,
      errmsg: json['errmsg'] ?? '',
      msg: json['msg'] ?? '',
      bonds: bondsList,
      descrs: descrsList,
    );
  }
}

/// 可转债数据模型
class ConvertibleBond {
  final String bondCode; // 债券代码
  final String bondName; // 债券名称
  final String bondFullName; // 债券全称
  final String bondId; // 债券ID
  final String bondType; // 债券类型
  final String tradeDate; // 交易日期
  final double lastClose; // 前收盘价
  final double openPrice; // 开盘价
  final double highPrice; // 最高价
  final double lowPrice; // 最低价
  final double currentPrice; // 收盘价/当前价
  final double change; // 涨跌
  final double changePercent; // 涨跌幅(%)
  final double interestDays; // 已计息天数
  final double accruedInterest; // 应计利息
  final double remainingYears; // 剩余期限(年)
  final double currentYield; // 当期收益率(%)
  final double ytm; // 纯债到期收益率(%)
  final double pureDebtValue; // 纯债价值
  final double premium; // 纯债溢价率(%)
  final double convertPrice; // 转股价格
  final String stockCode; // 正股代码
  final double conversionRatio; // 转股比例
  final double conversionValue; // 转换价值
  final double conversionPremium; // 转股溢价
  final double conversionPremiumRatio; // 转股溢价率(%)
  final double duration; // 期限(年)
  final String issueDate; // 发行日期
  final double couponRate; // 票面利率(%)
  final String market; // 交易市场

  ConvertibleBond({
    required this.bondCode,
    required this.bondName,
    required this.bondFullName,
    required this.bondId,
    required this.bondType,
    required this.tradeDate,
    required this.lastClose,
    required this.openPrice,
    required this.highPrice,
    required this.lowPrice,
    required this.currentPrice,
    required this.change,
    required this.changePercent,
    required this.interestDays,
    required this.accruedInterest,
    required this.remainingYears,
    required this.currentYield,
    required this.ytm,
    required this.pureDebtValue,
    required this.premium,
    required this.convertPrice,
    required this.stockCode,
    required this.conversionRatio,
    required this.conversionValue,
    required this.conversionPremium,
    required this.conversionPremiumRatio,
    required this.duration,
    required this.issueDate,
    required this.couponRate,
    required this.market,
  });

  /// 创建一个空的可转债对象
  factory ConvertibleBond.empty() {
    return ConvertibleBond(
      bondCode: '',
      bondName: '',
      bondFullName: '',
      bondId: '',
      bondType: '',
      tradeDate: '',
      lastClose: 0.0,
      openPrice: 0.0,
      highPrice: 0.0,
      lowPrice: 0.0,
      currentPrice: 0.0,
      change: 0.0,
      changePercent: 0.0,
      interestDays: 0.0,
      accruedInterest: 0.0,
      remainingYears: 0.0,
      currentYield: 0.0,
      ytm: 0.0,
      pureDebtValue: 0.0,
      premium: 0.0,
      convertPrice: 0.0,
      stockCode: '',
      conversionRatio: 0.0,
      conversionValue: 0.0,
      conversionPremium: 0.0,
      conversionPremiumRatio: 0.0,
      duration: 0.0,
      issueDate: '',
      couponRate: 0.0,
      market: '',
    );
  }

  /// 从API返回的数组创建可转债对象
  factory ConvertibleBond.fromList(List<String> data) {
    // 检查数据长度
    if (data.length < 10) {
      debugPrint('可转债数据不完整: $data');
      return ConvertibleBond.empty();
    }

    return ConvertibleBond(
      bondCode: data[0], // 债券代码
      bondName: data[1], // 债券简称
      bondFullName: data[2], // 债券全称
      bondId: data[3], // 债券ID
      bondType: data[4], // 债券类型
      tradeDate: data[5], // 交易日期
      lastClose: double.tryParse(data[6]) ?? 0.0, // 前收盘价
      openPrice: double.tryParse(data[7]) ?? 0.0, // 开盘价
      highPrice: double.tryParse(data[8]) ?? 0.0, // 最高价
      lowPrice: double.tryParse(data[9]) ?? 0.0, // 最低价
      currentPrice: double.tryParse(data[10]) ?? 0.0, // 收盘价
      change: double.tryParse(data[11]) ?? 0.0, // 涨跌
      changePercent: double.tryParse(data[12]) ?? 0.0, // 涨跌幅(%)
      interestDays: double.tryParse(data[13]) ?? 0.0, // 已计息天数
      accruedInterest: double.tryParse(data[14]) ?? 0.0, // 应计利息
      remainingYears: double.tryParse(data[15]) ?? 0.0, // 剩余期限(年)
      currentYield: double.tryParse(data[16]) ?? 0.0, // 当期收益率(%)
      ytm: double.tryParse(data[17]) ?? 0.0, // 纯债到期收益率(%)
      pureDebtValue: double.tryParse(data[18]) ?? 0.0, // 纯债价值
      premium: double.tryParse(data[21]) ?? 0.0, // 纯债溢价率(%)
      convertPrice: double.tryParse(data[22]) ?? 0.0, // 转股价格
      stockCode: data[23], // 正股代码
      conversionRatio: double.tryParse(data[24]) ?? 0.0, // 转股比例
      conversionValue: double.tryParse(data[25]) ?? 0.0, // 转换价值
      conversionPremium: double.tryParse(data[26]) ?? 0.0, // 转股溢价
      conversionPremiumRatio: double.tryParse(data[27]) ?? 0.0, // 转股溢价率(%)
      duration: double.tryParse(data[33]) ?? 0.0, // 期限(年)
      issueDate: data[34], // 发行日期
      couponRate: double.tryParse(data[35]) ?? 0.0, // 票面利率/发行参考利率(%)
      market: data[36], // 交易市场
    );
  }
}
