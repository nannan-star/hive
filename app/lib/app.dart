import 'package:flutter/material.dart';

import 'router.dart';
import 'shared/theme/hive_theme.dart';

class HiveApp extends StatelessWidget {
  const HiveApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Hive',
      debugShowCheckedModeBanner: false,
      theme: HiveTheme.light,
      routerConfig: createRouter(),
    );
  }
}
