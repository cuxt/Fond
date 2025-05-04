import 'package:go_router/go_router.dart';
import 'package:fond/providers/auth_provider.dart';
import 'package:fond/views/about/about_screen.dart';
import 'package:fond/views/convertible_bond/convertible_bond_screen.dart';
import 'package:fond/views/home/home_screen.dart';
import 'package:fond/views/login/login_screen.dart';
import 'package:fond/views/settings/settings_screen.dart';
import 'package:fond/widgets/desktop_scaffold.dart';

class AppRouter {
  final AuthProvider authProvider;

  AppRouter(this.authProvider);

  late final GoRouter router = GoRouter(
    initialLocation: '/',
    refreshListenable: authProvider,
    redirect: (context, state) {
      final isLoggedIn = authProvider.isLoggedIn;
      final isGoingToLogin = state.matchedLocation == '/login';

      // 如果未登录且不是去登录页面，则重定向到登录页面
      if (!isLoggedIn && !isGoingToLogin) {
        return '/login';
      }

      // 如果已登录且去登录页面，则重定向到首页
      if (isLoggedIn && isGoingToLogin) {
        return '/';
      }

      return null;
    },
    routes: [
      // 登录页面
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),

      // 首页
      GoRoute(
        path: '/',
        pageBuilder:
            (context, state) => NoTransitionPage(
              child: DesktopScaffold(
                selectedIndex: 0,
                title: '首页',
                child: const HomeScreen(),
              ),
            ),
      ),

      // 可转债页面
      GoRoute(
        path: '/convertible-bonds',
        pageBuilder:
            (context, state) => NoTransitionPage(
              child: DesktopScaffold(
                selectedIndex: 3,
                title: '可转债',
                child: const ConvertibleBondScreen(),
              ),
            ),
      ),

      // 设置页面
      GoRoute(
        path: '/settings',
        pageBuilder:
            (context, state) => NoTransitionPage(
              child: DesktopScaffold(
                selectedIndex: 1,
                title: '设置',
                child: const SettingsScreen(),
              ),
            ),
      ),

      // 关于页面
      GoRoute(
        path: '/about',
        pageBuilder:
            (context, state) => NoTransitionPage(
              child: DesktopScaffold(
                selectedIndex: 2,
                title: '关于',
                child: const AboutScreen(),
              ),
            ),
      ),
    ],
  );
}
