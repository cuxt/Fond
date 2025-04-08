import 'package:flutter/material.dart';
import 'package:fond/views/about.dart';
import 'package:fond/views/home.dart';
import 'package:fond/views/setting.dart';

class NavBar extends StatefulWidget {
  const NavBar({super.key});

  @override
  State<NavBar> createState() => _NavBarState();
}

class _NavBarState extends State<NavBar> {
  int _selectedIndex = 0; // 当前选中的页面索引

  // 定义不同页面的Widget
  static final List<Widget> _pages = [
    const Home(),
    const Setting(),
    const About(),
  ];

  void _onItemTapped(int index) {
    // 只有当索引变化时才执行setState
    if (_selectedIndex != index) {
      setState(() {
        _selectedIndex = index;
      });
    }

    // 使用 mounted 检查以确保 widget 仍在树中
    if (mounted && Navigator.canPop(context)) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Fond')),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue),
              child: Text(
                '菜单',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('首页'),
              selected: _selectedIndex == 0,
              onTap: () => _onItemTapped(0),
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('设置'),
              selected: _selectedIndex == 1,
              onTap: () => _onItemTapped(1),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.info),
              title: const Text('关于'),
              selected: _selectedIndex == 2,
              onTap: () => _onItemTapped(2),
            ),
          ],
        ),
      ),
      body: _pages[_selectedIndex], // 显示当前选中的页面
    );
  }
}
