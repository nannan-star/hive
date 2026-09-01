import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../data/providers.dart';
import '../../../shared/money.dart';
import '../providers/dream_providers.dart';

class DreamHomePage extends ConsumerWidget {
  const DreamHomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final include = ref.watch(includeCompletedDreamsProvider);
    final jarsAsync = ref.watch(dreamJarsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('梦想'),
        actions: [
          FilterChip(
            label: const Text('含已完成'),
            selected: include,
            onSelected: (v) =>
                ref.read(includeCompletedDreamsProvider.notifier).state = v,
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/dream/new'),
        icon: const Icon(Icons.add),
        label: const Text('新建'),
      ),
      body: jarsAsync.when(
        data: (jars) {
          if (jars.isEmpty) {
            return const Center(child: Text('还没有梦想罐'));
          }
          return ListView.builder(
            itemCount: jars.length,
            itemBuilder: (context, i) {
              final jar = jars[i];
              return FutureBuilder<int>(
                future: ref.read(databaseProvider).dreamDao.sumDeposits(jar.id),
                builder: (context, snap) {
                  final saved = snap.data ?? 0;
                  final progress = jar.targetCents == 0
                      ? 0.0
                      : (saved / jar.targetCents).clamp(0.0, 1.0);
                  return ListTile(
                    title: Text(jar.name),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${formatYuan(saved)} / ${formatYuan(jar.targetCents)}'
                          '${jar.status == 'completed' ? ' · 已完成' : ''}',
                        ),
                        LinearProgressIndicator(value: progress),
                      ],
                    ),
                    isThreeLine: true,
                    onTap: () => context.push('/dream/${jar.id}'),
                  );
                },
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
      ),
    );
  }
}
