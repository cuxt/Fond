import 'package:flutter/material.dart';
import 'package:fond/widgets/side_navigation.dart';

class DesktopScaffold extends StatelessWidget {
  final Widget child;
  final int selectedIndex;
  final String? title;

  const DesktopScaffold({
    super.key,
    required this.child,
    required this.selectedIndex,
    this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 侧边导航栏
          SideNavigation(selectedIndex: selectedIndex),

          // 垂直分隔线
          const VerticalDivider(width: 1, thickness: 1),

          // 主内容区域
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 标题栏
                  if (title != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 16,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        boxShadow: [
                          BoxShadow(
                            color: Theme.of(context).shadowColor.withAlpha(25),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Text(
                            title!,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Spacer(),
                          // 用户头像或其他右侧控件可以添加在这里
                        ],
                      ),
                    ),

                  // 页面内容
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: child,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
