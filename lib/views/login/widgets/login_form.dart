import 'package:flutter/material.dart';
import 'package:fond/views/login/login_provider.dart';
import 'package:fond/widgets/fond_button.dart';
import 'package:fond/widgets/toast/fond_toast.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class LoginForm extends StatelessWidget {
  const LoginForm({super.key});

  @override
  Widget build(BuildContext context) {
    final loginProvider = Provider.of<LoginProvider>(context);
    final colorScheme = Theme.of(context).colorScheme;

    // 登录按钮点击处理
    void handleLogin() async {
      try {
        final success = await loginProvider.login();
        if (!success) {
          FondToast.show("登录失败，请检查用户名和密码");
        }
      } catch (e) {
        FondToast.show(e.toString());
      }
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 标题
        Text(
          '欢迎登录',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: colorScheme.primary,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          '请输入您的凭据继续',
          style: TextStyle(fontSize: 16, color: colorScheme.onSurfaceVariant),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 40),

        // 用户名输入框
        TextField(
          controller: loginProvider.usernameController,
          decoration: InputDecoration(
            labelText: '用户名',
            prefixIcon: const Icon(Icons.person),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        const SizedBox(height: 20),

        // 密码输入框
        TextField(
          controller: loginProvider.passwordController,
          obscureText: !loginProvider.isPasswordVisible,
          decoration: InputDecoration(
            labelText: '密码',
            prefixIcon: const Icon(Icons.lock),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            suffixIcon: IconButton(
              icon: Icon(
                loginProvider.isPasswordVisible
                    ? Icons.visibility_off
                    : Icons.visibility,
              ),
              onPressed: () => loginProvider.togglePasswordVisibility(),
            ),
          ),
        ),
        const SizedBox(height: 32),

        // 登录按钮
        loginProvider.isLoading
            ? const Center(child: CircularProgressIndicator())
            : SizedBox(
              height: 52,
              child: FondButton(onTap: handleLogin, buttonText: "登录"),
            ),
        const SizedBox(height: 24),

        // 注册链接
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("还没有账号？", style: TextStyle(fontSize: 16)),
            TextButton(
              onPressed: _openRegistrationSite,
              child: Text(
                "前往注册",
                style: TextStyle(
                  fontSize: 16,
                  color: colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),

        // 版本信息
        const SizedBox(height: 40),
        Text(
          'Fond 版本 1.0.2',
          style: TextStyle(fontSize: 12, color: colorScheme.outline),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  // 打开注册网站
  void _openRegistrationSite() async {
    const url = 'https://www.51ifind.com';
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        FondToast.show("无法打开浏览器，请自行前往 $url 注册");
      }
    } catch (e) {
      FondToast.show("跳转失败，请自行前往 $url 注册");
    }
  }
}
