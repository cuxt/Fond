import 'package:flutter/material.dart';
import 'package:fond/providers/auth_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginProvider extends ChangeNotifier {
  final AuthProvider _authProvider;

  // 表单控制器
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  // 状态变量
  bool _isPasswordVisible = false;
  bool get isPasswordVisible => _isPasswordVisible;

  bool _rememberPassword = false;
  bool get rememberPassword => _rememberPassword;

  bool get isLoading => _authProvider.isLoading;
  LoginProvider(this._authProvider) {
    // 初始化时加载记住密码的设置和保存的凭据
    _loadRememberPasswordSetting();
    _loadSavedCredentials();
  }

  // 切换密码可见性
  void togglePasswordVisibility() {
    _isPasswordVisible = !_isPasswordVisible;
    notifyListeners();
  }

  // 切换记住密码状态
  void toggleRememberPassword() {
    _rememberPassword = !_rememberPassword;
    // 保存记住密码的设置
    _saveRememberPasswordSetting();
    notifyListeners();
  }

  // 保存记住密码设置
  Future<void> _saveRememberPasswordSetting() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('rememberPassword', _rememberPassword);
  }

  // 加载记住密码设置
  Future<void> _loadRememberPasswordSetting() async {
    final prefs = await SharedPreferences.getInstance();
    _rememberPassword = prefs.getBool('rememberPassword') ?? false;
    notifyListeners();
  }

  // 加载保存的凭据
  Future<void> _loadSavedCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    final savedUsername = prefs.getString('savedUsername') ?? '';
    final savedPassword = prefs.getString('savedPassword') ?? '';

    if (savedUsername.isNotEmpty && savedPassword.isNotEmpty) {
      usernameController.text = savedUsername;
      passwordController.text = savedPassword;
    }
  }

  // 执行登录
  Future<bool> login() async {
    final username = usernameController.text;
    final password = passwordController.text;

    if (username.isEmpty || password.isEmpty) {
      return false;
    }

    final success = await _authProvider.login(
      username,
      password,
      _rememberPassword,
    );

    // 如果成功登录且选择记住密码，保存凭据
    if (success && _rememberPassword) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('savedUsername', username);
      await prefs.setString('savedPassword', password);
    }

    return success;
  }

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}
