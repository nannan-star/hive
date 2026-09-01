import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/money.dart';
import '../../../shared/theme/hive_colors.dart';
import '../../../shared/widgets/hive_widgets.dart';
import '../providers/spend_providers.dart';

class CategoriesPage extends ConsumerWidget {
  const CategoriesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final showDisabled = ref.watch(showDisabledCategoriesProvider);
    final asyncCats = ref.watch(categoriesListProvider);

    return Scaffold(
      backgroundColor: HiveColors.page,
      body: SafeArea(
        child: Column(
          children: [
            const HiveBackHeader(title: '分类与模板'),
            Expanded(
              child: asyncCats.when(
                data: (cats) {
                  return ListView(
                    padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
                    children: [
                      const HiveHint(
                        '分类是年对比的维度；月度模板打开后每月自动生成 1 条待确认，同月仍可再手记多笔。不用了请「停用」。',
                      ),
                      const SizedBox(height: 12),
                      HiveChipRow(
                        children: [
                          HiveChip(
                            label: '启用中',
                            selected: !showDisabled,
                            onTap: () {
                              ref
                                  .read(
                                    showDisabledCategoriesProvider.notifier,
                                  )
                                  .state = false;
                            },
                          ),
                          HiveChip(
                            label: '含已停用',
                            selected: showDisabled,
                            onTap: () {
                              ref
                                  .read(
                                    showDisabledCategoriesProvider.notifier,
                                  )
                                  .state = true;
                            },
                          ),
                          HiveChip(
                            label: '＋ 新建分类',
                            selected: false,
                            onTap: () =>
                                context.push('/spend/categories/edit'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      if (cats.isEmpty)
                        const Padding(
                          padding: EdgeInsets.only(top: 48),
                          child: HiveEmpty('暂无分类'),
                        )
                      else
                        HiveCard(
                          child: Column(
                            children: [
                              for (var i = 0; i < cats.length; i++)
                                _CategoryRow(
                                  name: cats[i].name,
                                  enabled: cats[i].enabled,
                                  sortOrder: cats[i].sortOrder,
                                  note: cats[i].templateDefaultNote,
                                  badge: cats[i].templateEnabled
                                      ? '模板 ${formatYuan(cats[i].templateDefaultAmount ?? 0)} · ${cats[i].templateDay}日'
                                      : '仅手记',
                                  showDivider: i > 0,
                                  onTap: () => context.push(
                                    '/spend/categories/${cats[i].id}/edit',
                                  ),
                                ),
                            ],
                          ),
                        ),
                    ],
                  );
                },
                loading: () =>
                    const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('错误: $e')),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryRow extends StatelessWidget {
  const _CategoryRow({
    required this.name,
    required this.enabled,
    required this.sortOrder,
    required this.note,
    required this.badge,
    required this.showDivider,
    required this.onTap,
  });

  final String name;
  final bool enabled;
  final int sortOrder;
  final String? note;
  final String badge;
  final bool showDivider;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final status = enabled ? '启用' : '已停用';
    final extra = (note != null && note!.isNotEmpty) ? ' · $note' : '';
    return InkWell(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(16, 13, 16, 13),
        decoration: BoxDecoration(
          border: showDivider
              ? const Border(top: BorderSide(color: HiveColors.border))
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    name,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: enabled ? HiveColors.ink : HiveColors.dim,
                    ),
                  ),
                ),
                HiveBadge(label: badge),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              '$status · 排序 $sortOrder$extra',
              style: const TextStyle(fontSize: 12, color: HiveColors.dim),
            ),
          ],
        ),
      ),
    );
  }
}
