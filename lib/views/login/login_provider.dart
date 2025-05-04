import 'package:flutter/material.dart';
import 'package:fond/providers/auth_provider.dart';

class LoginProvider extends ChangeNotifier {
  final AuthProvider _authProvider;

  // 表单控制器
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  // 状态变量
  bool _isPasswordVisible = false;
  bool get isPasswordVisible => _isPasswordVisible;

  bool get isLoading => _authProvider.isLoading;

  LoginProvider(this._authProvider);

  // 切换密码可见性
  void togglePasswordVisibility() {
    _isPasswordVisible = !_isPasswordVisible;
    notifyListeners();
  }

  // 执行登录
  Future<bool> login() async {
    final username = usernameController.text;
    final password = passwordController.text;

    if (username.isEmpty || password.isEmpty) {
      return false;
    }

    return await _authProvider.login(username, password);
  }

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}
