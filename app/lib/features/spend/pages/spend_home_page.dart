import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/spend_providers.dart';

class SpendHomePage extends ConsumerWidget {
  const SpendHomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncCats = ref.watch(categoriesListProvider);

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
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              FilledButton.tonal(
                onPressed: () => context.push('/spend/pending'),
                child: const Text('本月待确认'),
              ),
              FilledButton.tonal(
                onPressed: () => context.push('/spend/add'),
                child: const Text('记一笔'),
              ),
              FilledButton.tonal(
                onPressed: () => context.push('/spend/categories'),
                child: const Text('分类管理'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text('分类（种子数据）', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          asyncCats.when(
            data: (cats) {
              if (cats.isEmpty) return const Text('暂无分类');
              return Column(
                children: [
                  for (final c in cats)
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(c.name),
                      subtitle: Text(
                        c.templateEnabled ? '模板开' : '仅手记',
                      ),
                      onTap: () =>
                          context.push('/spend/categories/${c.id}/edit'),
                    ),
                ],
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Text('错误: $e'),
          ),
        ],
      ),
    );
  }
}
