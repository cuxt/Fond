import 'package:flutter/material.dart';
import 'package:fond/providers/theme_provider.dart';

class SettingsProvider extends ChangeNotifier {
  final ThemeProvider _themeProvider;

  // 各种设置项
  bool _pushNotifications = true;
  bool _emailNotifications = false;
  String _dataRefreshInterval = '实时';
  bool _autoRefresh = true;
  bool _dataSaving = false;

  // Getters
  bool get pushNotifications => _pushNotifications;
  bool get emailNotifications => _emailNotifications;
  String get dataRefreshInterval => _dataRefreshInterval;
  bool get autoRefresh => _autoRefresh;
  bool get dataSaving => _dataSaving;
  bool get isDarkMode => _themeProvider.isDarkMode;
  Color get primaryColor => _themeProvider.primaryColor;

  SettingsProvider(this._themeProvider);

  // 切换推送通知
  void togglePushNotifications(bool value) {
    _pushNotifications = value;
    notifyListeners();
  }

  // 切换邮件通知
  void toggleEmailNotifications(bool value) {
    _emailNotifications = value;
    notifyListeners();
  }

  // 设置数据刷新间隔
  void setDataRefreshInterval(String value) {
    _dataRefreshInterval = value;
    notifyListeners();
  }

  // 切换自动刷新
  void toggleAutoRefresh(bool value) {
    _autoRefresh = value;
    notifyListeners();
  }

  // 切换数据节省模式
  void toggleDataSaving(bool value) {
    _dataSaving = value;
    notifyListeners();
  }

  // 切换深色模式
  void toggleDarkMode() {
    _themeProvider.toggleDarkMode();
    notifyListeners();
  }

  // 设置主题颜色
  void setPrimaryColor(Color color) {
    _themeProvider.setPrimaryColor(color);
    notifyListeners();
  }
}
