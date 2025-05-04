import 'package:flutter/material.dart';
import 'package:fond/providers/auth_provider.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class SideNavigation extends StatefulWidget {
  final int selectedIndex;

  const SideNavigation({super.key, required this.selectedIndex});

  @override
  State<SideNavigation> createState() => _SideNavigationState();
}

class _SideNavigationState extends State<SideNavigation> {
  bool _isExpanded = true;

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: _isExpanded ? 220 : 70,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withAlpha(25),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // 顶部Logo和应用名
          _buildHeader(colorScheme),

          // 用户信息
          if (authProvider.username.isNotEmpty && _isExpanded)
            _buildUserInfo(authProvider.username, colorScheme),

          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 16),

          // 导航项目
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildNavItem(
                  index: 0,
                  icon: Icons.home_outlined,
                  selectedIcon: Icons.home,
                  label: '首页',
                  colorScheme: colorScheme,
                ),
                _buildNavItem(
                  index: 3,
                  icon: Icons.credit_card_outlined,
                  selectedIcon: Icons.credit_card,
                  label: '可转债',
                  colorScheme: colorScheme,
                ),
                _buildNavItem(
                  index: 1,
                  icon: Icons.settings_outlined,
                  selectedIcon: Icons.settings,
                  label: '设置',
                  colorScheme: colorScheme,
                ),
                _buildNavItem(
                  index: 2,
                  icon: Icons.info_outlined,
                  selectedIcon: Icons.info,
                  label: '关于',
                  colorScheme: colorScheme,
                ),
              ],
            ),
          ),

          // 底部退出按钮
          const Divider(height: 1),
          _buildLogoutButton(colorScheme),
        ],
      ),
    );
  }

  // 构建统一样式的折叠/展开按钮
  Widget _buildToggleButton(ColorScheme colorScheme, {bool isCollapse = true}) {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withAlpha(25),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
        border: Border.all(
          color: colorScheme.outlineVariant.withAlpha(50),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            setState(() {
              _isExpanded = !_isExpanded;
            });
          },
          borderRadius: BorderRadius.circular(14),
          splashColor: colorScheme.primaryContainer.withAlpha(50),
          highlightColor: colorScheme.primaryContainer.withAlpha(50),
          child: Icon(
            // 根据不同状态显示不同方向的图标
            isCollapse
                ? Icons.keyboard_double_arrow_left
                : Icons.keyboard_double_arrow_right,
            size: 16,
            color: colorScheme.primary,
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(ColorScheme colorScheme) {
    if (_isExpanded) {
      // 展开状态：使用行布局排列Logo、应用名和折叠按钮
      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
        child: Row(
          children: [
            // Logo容器
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Image.asset(
                'assets/images/logo.png',
                width: 24,
                height: 24,
              ),
            ),
            const SizedBox(width: 12),
            // 应用名
            Expanded(
              child: Text(
                'Fond',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.primary,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            // 折叠按钮与Logo对齐
            _buildToggleButton(colorScheme, isCollapse: true),
          ],
        ),
      );
    } else {
      // 折叠状态：Logo居中显示，底部有展开按钮
      return Column(
        children: [
          // Logo居中显示
          Padding(
            padding: const EdgeInsets.only(top: 16, bottom: 10),
            child: Center(
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Image.asset(
                  'assets/images/logo.png',
                  width: 24,
                  height: 24,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
          // 展开按钮
          Center(child: _buildToggleButton(colorScheme, isCollapse: false)),
          const SizedBox(height: 4),
        ],
      );
    }
  }

  Widget _buildUserInfo(String username, ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      child: Row(
        children: [
          Icon(Icons.person, size: 16, color: colorScheme.onSurfaceVariant),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              username,
              style: TextStyle(
                fontSize: 14,
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required IconData selectedIcon,
    required String label,
    required ColorScheme colorScheme,
  }) {
    final isSelected = widget.selectedIndex == index;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: InkWell(
        onTap: () => _onItemTapped(index, context),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            color:
                isSelected ? colorScheme.primaryContainer : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child:
              _isExpanded
                  ? Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isSelected ? selectedIcon : icon,
                        size: 18,
                        color:
                            isSelected
                                ? colorScheme.primary
                                : colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          label,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight:
                                isSelected ? FontWeight.w600 : FontWeight.w400,
                            color:
                                isSelected
                                    ? colorScheme.primary
                                    : colorScheme.onSurfaceVariant,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  )
                  : Center(
                    // 折叠模式下居中显示
                    child: Icon(
                      isSelected ? selectedIcon : icon,
                      size: 18,
                      color:
                          isSelected
                              ? colorScheme.primary
                              : colorScheme.onSurfaceVariant,
                    ),
                  ),
        ),
      ),
    );
  }

  Widget _buildLogoutButton(ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: InkWell(
        onTap: () => _showLogoutDialog(context),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
          child:
              _isExpanded
                  ? Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.logout, size: 18, color: colorScheme.error),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          '退出登录',
                          style: TextStyle(
                            color: colorScheme.error,
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  )
                  : Center(
                    // 折叠模式下居中显示
                    child: Icon(
                      Icons.logout,
                      size: 18,
                      color: colorScheme.error,
                    ),
                  ),
        ),
      ),
    );
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        GoRouter.of(context).go('/');
        break;
      case 1:
        GoRouter.of(context).go('/settings');
        break;
      case 2:
        GoRouter.of(context).go('/about');
        break;
      case 3:
        GoRouter.of(context).go('/convertible-bonds');
        break;
    }
  }

  // 显示退出登录确认对话框
  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('确认退出'),
            content: const Text('您确定要退出登录吗？'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('取消'),
              ),
              FilledButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Provider.of<AuthProvider>(context, listen: false).logout();
                },
                child: const Text('确认'),
              ),
            ],
          ),
    );
  }
}
