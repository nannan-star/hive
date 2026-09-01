import 'package:flutter/material.dart';

import 'router.dart';

class HiveApp extends StatelessWidget {
  const HiveApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Hive',
      routerConfig: createRouter(),
    );
  }
}
