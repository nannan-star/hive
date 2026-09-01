import 'package:flutter/material.dart';

import '../../../shared/theme/hive_colors.dart';
import '../../../shared/widgets/hive_widgets.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HiveColors.page,
      body: SafeArea(
        child: Column(
          children: [
            const HiveBackHeader(title: '设置'),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                children: [
                  HiveCard(
                    child: Column(
                      children: [
                        _SettingsTile(
                          title: '导出备份',
                          subtitle: '第一期占位 · 本地文件',
                          showDivider: false,
                          onTap: () => _placeholder(context),
                        ),
                        _SettingsTile(
                          title: '从备份恢复',
                          subtitle: '第一期占位',
                          showDivider: true,
                          onTap: () => _placeholder(context),
                        ),
                        _SettingsTile(
                          title: '家人权限',
                          subtitle: '后续版本 · 当前仅自己',
                          showDivider: true,
                          onTap: () => _placeholder(context),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _placeholder(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('第一期占位，功能即将推出')),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.title,
    required this.subtitle,
    required this.showDivider,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final bool showDivider;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
        decoration: BoxDecoration(
          border: showDivider
              ? const Border(top: BorderSide(color: HiveColors.border))
              : null,
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: HiveColors.ink,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: HiveColors.dim,
                    ),
                  ),
                ],
              ),
            ),
            const Text(
              '›',
              style: TextStyle(fontSize: 18, color: HiveColors.dim),
            ),
          ],
        ),
      ),
    );
  }
}
