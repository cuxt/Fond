import 'package:flutter/material.dart';
import 'package:fond/views/about/widgets/about_app_info.dart';
import 'package:fond/views/about/widgets/about_features.dart';
import 'package:fond/views/about/widgets/about_contact.dart';
import 'package:package_info_plus/package_info_plus.dart';

class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  String _version = '';
  String _buildNumber = '';

  @override
  void initState() {
    super.initState();
    _getPackageInfo();
  }

  Future<void> _getPackageInfo() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      setState(() {
        _version = packageInfo.version;
        _buildNumber = packageInfo.buildNumber;
      });
    } catch (e) {
      setState(() {
        _version = '1.0.2';
        _buildNumber = '3';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 应用信息
            AboutAppInfo(version: _version, buildNumber: _buildNumber),

            const SizedBox(height: 32),

            // 功能特点
            const AboutFeatures(),

            const SizedBox(height: 32),

            // 联系信息
            const AboutContact(),

            const SizedBox(height: 40),

            // 版权信息
            Center(
              child: Text(
                '© 2025 Fond. 保留所有权利。',
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
