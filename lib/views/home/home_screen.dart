import 'package:flutter/material.dart';
import 'package:fond/views/home/home_provider.dart';
import 'package:fond/views/home/widgets/home_dashboard.dart';
import 'package:fond/views/home/widgets/home_stats.dart';
import 'package:fond/views/home/widgets/quick_actions.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => HomeProvider(),
      child: Builder(
        builder: (context) {
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 欢迎信息
                const HomeDashboard(),

                const SizedBox(height: 24),

                // 快速操作区域
                const QuickActions(),

                const SizedBox(height: 32),

                // 统计图表区域
                const HomeStats(),
              ],
            ),
          );
        },
      ),
    );
  }
}
