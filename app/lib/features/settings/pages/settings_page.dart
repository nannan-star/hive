import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  static const appVersion = '1.0.0+1';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('设置')),
      body: ListView(
        children: const [
          ListTile(
            title: Text('备份 / 导出'),
            subtitle: Text('即将推出'),
          ),
          ListTile(
            title: Text('版本'),
            subtitle: Text(appVersion),
          ),
        ],
      ),
    );
  }
}
