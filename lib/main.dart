import 'package:flutter/material.dart';
import 'package:fond/providers/auth_provider.dart';
import 'package:fond/providers/theme_provider.dart';
import 'package:fond/routes/app_router.dart';
import 'package:fond/widgets/toast/fond_toast.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const FondApp());
}

class FondApp extends StatelessWidget {
  const FondApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // 主题状态
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        // 认证状态
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: const AppWithProviders(),
    );
  }
}

class AppWithProviders extends StatefulWidget {
  const AppWithProviders({super.key});

  @override
  State<AppWithProviders> createState() => _AppWithProvidersState();
}

class _AppWithProvidersState extends State<AppWithProviders> {
  late AppRouter _appRouter;

  @override
  void initState() {
    super.initState();
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    // 初始化路由
    _appRouter = AppRouter(authProvider);
    // 检查登录状态
    authProvider.checkLoginStatus();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp.router(
      title: 'Fond',
      scaffoldMessengerKey: FondToast.navigatorKey,
      theme: themeProvider.currentTheme,
      // 使用GoRouter配置
      routerConfig: _appRouter.router,
      // 去除右上角的Debug标签
      debugShowCheckedModeBanner: false,
    );
  }
}
