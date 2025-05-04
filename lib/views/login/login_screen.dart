import 'package:flutter/material.dart';
import 'package:fond/providers/auth_provider.dart';
import 'package:fond/views/login/login_provider.dart';
import 'package:fond/views/login/widgets/login_form.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 使用独立的登录页面Provider
    return ChangeNotifierProvider(
      create:
          (context) =>
              LoginProvider(Provider.of<AuthProvider>(context, listen: false)),
      child: Builder(
        builder: (context) {
          final colorScheme = Theme.of(context).colorScheme;

          return Scaffold(
            body: Row(
              children: [
                // 左侧装饰区域
                Expanded(
                  flex: 5,
                  child: Container(
                    color: colorScheme.primaryContainer.withAlpha(50),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // 应用Logo
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.rectangle,
                              borderRadius: BorderRadius.circular(24),
                              color: colorScheme.surface,
                              boxShadow: [
                                BoxShadow(
                                  color: colorScheme.shadow.withAlpha(50),
                                  blurRadius: 12,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            padding: const EdgeInsets.all(16),
                            child: Image.asset(
                              'assets/images/logo.png',
                              width: 120,
                              height: 120,
                            ),
                          ),
                          const SizedBox(height: 24),
                          // 应用名称
                          Text(
                            'Fond',
                            style: TextStyle(
                              fontSize: 48,
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onPrimaryContainer,
                            ),
                          ),
                          const SizedBox(height: 16),
                          // 应用标语
                          Text(
                            '专业的金融数据分析工具',
                            style: TextStyle(
                              fontSize: 20,
                              color: colorScheme.onPrimaryContainer.withAlpha(
                                150,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // 右侧登录表单区域
                Expanded(
                  flex: 4,
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 400),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 40),
                        child: LoginForm(),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
