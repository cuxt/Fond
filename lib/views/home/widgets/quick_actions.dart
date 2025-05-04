import 'package:flutter/material.dart';
import 'package:fond/widgets/toast/fond_toast.dart';

class QuickActions extends StatelessWidget {
  const QuickActions({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    // 定义快速操作选项
    final actions = [
      {
        'title': '市场行情',
        'icon': Icons.show_chart,
        'color': Colors.blue,
        'onTap': () => _onActionTap('市场行情', context),
      },
      {
        'title': '自选股',
        'icon': Icons.star,
        'color': Colors.amber,
        'onTap': () => _onActionTap('自选股', context),
      },
      {
        'title': '研报中心',
        'icon': Icons.description,
        'color': Colors.indigo,
        'onTap': () => _onActionTap('研报中心', context),
      },
      {
        'title': '资金流向',
        'icon': Icons.account_balance,
        'color': Colors.green,
        'onTap': () => _onActionTap('资金流向', context),
      },
      {
        'title': '新股申购',
        'icon': Icons.fiber_new,
        'color': Colors.red,
        'onTap': () => _onActionTap('新股申购', context),
      },
      {
        'title': '数据中心',
        'icon': Icons.data_usage,
        'color': Colors.purple,
        'onTap': () => _onActionTap('数据中心', context),
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '快速操作',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 16),
        LayoutBuilder(
          builder: (context, constraints) {
            // 根据可用宽度决定一行显示多少个操作项
            final width = constraints.maxWidth;
            final crossAxisCount = width ~/ 180; // 每项最小宽度为180

            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount.clamp(2, 6), // 最少2个，最多6个
                childAspectRatio: 1.5,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: actions.length,
              itemBuilder: (context, index) {
                final action = actions[index];
                final color = action['color'] as Color;

                return Card(
                  elevation: 0,
                  color: colorScheme.surface,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: colorScheme.outline.withAlpha(50)),
                  ),
                  child: InkWell(
                    onTap: action['onTap'] as Function(),
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: color.withAlpha(25),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              action['icon'] as IconData,
                              color: color,
                              size: 24,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            action['title'] as String,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: colorScheme.onSurface,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }

  void _onActionTap(String action, BuildContext context) {
    FondToast.show('正在开发中: $action');
  }
}
