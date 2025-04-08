import 'package:flutter/material.dart';
import 'package:fond/services/auth.dart';
import 'package:fond/views/nav_bar.dart';
import 'package:fond/widgets/fond_button.dart';
import 'package:oktoast/oktoast.dart';
import 'package:url_launcher/url_launcher.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isPasswordVisible = true;
  bool _isLoading = false;

  // 登录
  void _login() async {
    String username = _usernameController.text;
    String password = _passwordController.text;

    setState(() {
      _isLoading = true;
    });

    try {
      await Auth.login(username, password);
      showToast("登录成功");
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const NavBar(),
        ),
      );
    } catch (e) {
      showToast(e.toString());
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            children: [
              Image.asset("assets/images/logo.png", width: 100, height: 100),
              Text(
                "Fond",
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              SizedBox(height: 20),
              // 用户名
              TextField(
                controller: _usernameController,
                decoration: InputDecoration(
                  labelText: '用户名',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 20),
              // 密码
              TextField(
                controller: _passwordController,
                obscureText: _isPasswordVisible,
                decoration: InputDecoration(
                  labelText: '密码',
                  border: OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isPasswordVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _isPasswordVisible = !_isPasswordVisible;
                      });
                    },
                  ),
                ),
              ),
              SizedBox(height: 20),
              // 登录按钮
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : SizedBox(
                    width: double.infinity,
                    child: FondButton(onTap: _login, buttonText: "登录"),
                  ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text("还没有账号？", style: TextStyle(fontSize: 18)),
                  TextButton(
                    onPressed: () async {
                      // 跳转 https://www.51ifind.com/
                      final Uri url = Uri.parse('https://www.51ifind.com');
                      try {
                        if (await canLaunchUrl(url)) {
                          await launchUrl(url);
                        } else {
                          showToast("无法打开浏览器，请自行前往 ${url.toString()} 注册");
                        }
                      } catch (e) {
                        showToast("跳转失败，请自行前往 ${url.toString()} 注册");
                        throw Exception(e.toString());
                      }
                    },
                    child: Text(
                      "前往注册",
                      style: TextStyle(
                        fontSize: 18,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
