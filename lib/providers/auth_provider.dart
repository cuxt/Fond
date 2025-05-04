import 'package:flutter/material.dart';
import 'package:fond/services/auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider extends ChangeNotifier {
  bool _isLoggedIn = false;
  String _username = '';
  bool _isLoading = false;

  bool get isLoggedIn => _isLoggedIn;
  String get username => _username;
  bool get isLoading => _isLoading;

  // 检查是否已登录
  Future<void> checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    _isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    _username = prefs.getString('username') ?? '';
    notifyListeners();
  }

  // 登录
  Future<bool> login(String username, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final success = await Auth.login(username, password);
      if (success) {
        _isLoggedIn = true;
        _username = username;

        // 保存登录状态
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isLoggedIn', true);
        await prefs.setString('username', username);
      }
      return success;
    } catch (e) {
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 登出
  Future<void> logout() async {
    _isLoggedIn = false;
    _username = '';

    // 清除登录状态
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', false);
    await prefs.remove('username');

    notifyListeners();
  }
}
