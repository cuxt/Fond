import 'package:flutter/material.dart';

class HomeProvider extends ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // 市场数据列表
  final List<Map<String, dynamic>> _marketData = [
    {'name': '上证指数', 'code': '000001', 'price': 3352.31, 'change': 0.76},
    {'name': '深证成指', 'code': '399001', 'price': 11234.56, 'change': -0.45},
    {'name': '创业板指', 'code': '399006', 'price': 2289.65, 'change': -1.28},
    {'name': '沪深300', 'code': '000300', 'price': 4115.32, 'change': 0.33},
  ];

  List<Map<String, dynamic>> get marketData => _marketData;

  // 仪表盘统计数据
  final Map<String, dynamic> _dashboardStats = {
    'portfolioValue': 123456.78,
    'todayChange': 1245.67,
    'todayChangePercent': 1.12,
    'totalGain': 12578.56,
    'totalGainPercent': 11.34,
  };

  Map<String, dynamic> get dashboardStats => _dashboardStats;

  // 我的自选股列表
  final List<Map<String, dynamic>> _watchlist = [
    {'name': '贵州茅台', 'code': '600519', 'price': 1789.65, 'change': 2.15},
    {'name': '腾讯控股', 'code': '00700', 'price': 368.40, 'change': -1.35},
    {'name': '阿里巴巴', 'code': '09988', 'price': 83.25, 'change': 0.45},
    {'name': '中国平安', 'code': '601318', 'price': 48.35, 'change': -0.24},
  ];

  List<Map<String, dynamic>> get watchlist => _watchlist;

  // 刷新数据
  Future<void> refreshData() async {
    _isLoading = true;
    notifyListeners();

    // 模拟网络请求延迟
    await Future.delayed(const Duration(seconds: 1));

    // 更新数据(实际项目中应从API获取)
    _dashboardStats['portfolioValue'] += (Math.random() * 200 - 100);
    _dashboardStats['todayChange'] = (Math.random() * 400 - 200);
    _dashboardStats['todayChangePercent'] =
        _dashboardStats['todayChange'] /
        _dashboardStats['portfolioValue'] *
        100;

    // 更新完成
    _isLoading = false;
    notifyListeners();
  }
}

// 为示例添加Math类
class Math {
  static double random() {
    return DateTime.now().millisecondsSinceEpoch % 1000 / 1000;
  }
}
