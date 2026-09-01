import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/money.dart';
import '../providers/spend_providers.dart';

class CategoriesPage extends ConsumerWidget {
  const CategoriesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final showDisabled = ref.watch(showDisabledCategoriesProvider);
    final asyncCats = ref.watch(categoriesListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('分类与模板')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/spend/categories/edit'),
        icon: const Icon(Icons.add),
        label: const Text('新建'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Wrap(
              spacing: 8,
              children: [
                FilterChip(
                  label: const Text('启用中'),
                  selected: !showDisabled,
                  onSelected: (_) {
                    ref.read(showDisabledCategoriesProvider.notifier).state =
                        false;
                  },
                ),
                FilterChip(
                  label: const Text('含已停用'),
                  selected: showDisabled,
                  onSelected: (_) {
                    ref.read(showDisabledCategoriesProvider.notifier).state =
                        true;
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: asyncCats.when(
              data: (cats) {
                if (cats.isEmpty) {
                  return const Center(child: Text('暂无分类'));
                }
                return ListView.builder(
                  itemCount: cats.length,
                  itemBuilder: (context, i) {
                    final c = cats[i];
                    final subtitle = c.templateEnabled
                        ? '模板 ${formatYuan(c.templateDefaultAmount ?? 0)}'
                        : '仅手记';
                    return ListTile(
                      enabled: c.enabled,
                      title: Text(
                        c.name,
                        style: TextStyle(
                          color: c.enabled ? null : Theme.of(context).disabledColor,
                        ),
                      ),
                      subtitle: Text(subtitle),
                      trailing: c.enabled
                          ? null
                          : const Text('已停用', style: TextStyle(fontSize: 12)),
                      onTap: () =>
                          context.push('/spend/categories/${c.id}/edit'),
                    );
                  },
                );
              },
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('错误: $e')),
            ),
          ),
        ],
      ),
    );
  }
}
