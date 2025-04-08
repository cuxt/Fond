import 'package:oktoast/oktoast.dart';

class Auth {
  static Future<void> login(String username, String password) async {
    if (username.isEmpty || password.isEmpty) {
      throw Exception("用户名或密码不能为空");
    }

    String baseUrl = "https://quantapi.51ifind.com/api/v1";

    showToast("登录成功");
  }
}
