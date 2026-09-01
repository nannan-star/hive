import 'package:drift/drift.dart' show OrderingTerm;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../data/db/app_database.dart';
import '../../../data/providers.dart';

/// Temporary seed verification UI (replaced in later tasks).
class SpendHomePage extends ConsumerWidget {
  const SpendHomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = ref.watch(databaseProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('消费'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: StreamBuilder<List<Category>>(
        stream: (db.select(db.categories)
              ..orderBy([(t) => OrderingTerm.asc(t.sortOrder)]))
            .watch(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('错误: ${snapshot.error}'));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final cats = snapshot.data!;
          if (cats.isEmpty) {
            return const Center(child: Text('暂无分类'));
          }
          return ListView.builder(
            itemCount: cats.length,
            itemBuilder: (context, i) {
              final c = cats[i];
              return ListTile(
                title: Text(c.name),
                subtitle: Text(
                  c.templateEnabled
                      ? '模板 · 默认 ${c.templateDefaultAmount ?? 0} 分'
                      : '仅手记',
                ),
              );
            },
          );
        },
      ),
    );
  }
}
