import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../data/db/app_database.dart';
import '../../../data/providers.dart';
import '../../../shared/money.dart';
import '../../../shared/theme/hive_colors.dart';
import '../../../shared/widgets/hive_widgets.dart';
import '../providers/spend_providers.dart';
import '../services/spend_stats_service.dart';
import '../services/template_service.dart';

class SpendHomePage extends ConsumerStatefulWidget {
  const SpendHomePage({super.key});

  @override
  ConsumerState<SpendHomePage> createState() => _SpendHomePageState();
}

class _SpendHomePageState extends ConsumerState<SpendHomePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await TemplateService.ensureMonthTemplates(
        ref.read(databaseProvider),
        DateTime.now(),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final year = ref.watch(selectedSpendYearProvider);
    final db = ref.watch(databaseProvider);
    final stats = SpendStatsService(db);
    final now = DateTime.now();
    final pendingAsync =
        ref.watch(pendingEntriesProvider((now.year, now.month)));
    final pendingCount = pendingAsync.valueOrNull?.length ?? 0;

    return Scaffold(
      backgroundColor: HiveColors.page,
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            HiveBrandHeader(
              subtitle: '消费 · 按类对照',
              trailing: HiveCircleButton(
                onPressed: () => context.push('/settings'),
                child: const HiveGearIcon(),
              ),
            ),
            Expanded(
              child: FutureBuilder(
                key: ValueKey(year),
                future: Future.wait([
                  stats.yearTotal(year),
                  stats.sumByCategory(year),
                  stats.yearYoy(year),
                  ref.read(categoriesDaoProvider).watchAll().first,
                ]),
                builder: (context, snap) {
                  if (!snap.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final total = snap.data![0] as int;
                  final byCat = snap.data![1] as Map<String, int>;
                  final yearYoy = snap.data![2] as YoyResult;
                  final allCats = snap.data![3] as List<Category>;

                  final visible = allCats.where((c) {
                    if (c.enabled) return true;
                    return (byCat[c.id] ?? 0) > 0;
                  }).toList()
                    ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

                  return HivePageBody(
                    gap: 14,
                    children: [
                      HiveYearSwitcher(
                        year: year,
                        onChanged: (y) => ref
                            .read(selectedSpendYearProvider.notifier)
                            .state = y,
                      ),
                      HiveChipRow(
                        children: [
                          HiveChip(
                            label: '本月待确认 · $pendingCount',
                            selected: true,
                            onTap: () => context.push('/spend/pending'),
                          ),
                          HiveChip(
                            label: '＋ 记一笔',
                            selected: false,
                            onTap: () => context.push('/spend/add'),
                          ),
                          HiveChip(
                            label: '分类 / 模板',
                            selected: false,
                            onTap: () => context.push('/spend/categories'),
                          ),
                        ],
                      ),
                      HiveCard(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              '今年已确认合计',
                              style: TextStyle(
                                fontSize: 13,
                                color: HiveColors.muted,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              formatYuan(total),
                              style: const TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.w700,
                                color: HiveColors.ink,
                                height: 1.1,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${formatYoyHeadline(yearYoy)} · 水/电/燃气已分列 · 不含梦想存入',
                              style: const TextStyle(
                                fontSize: 12,
                                height: 1.45,
                                color: HiveColors.muted,
                              ),
                            ),
                          ],
                        ),
                      ),
                      HiveCard(
                        child: Column(
                          children: [
                            const Padding(
                              padding: EdgeInsets.fromLTRB(16, 14, 16, 10),
                              child: Row(
                                children: [
                                  Text(
                                    '按类',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: HiveColors.dim,
                                    ),
                                  ),
                                  Spacer(),
                                  Text(
                                    '点进详情',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: HiveColors.dim,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            for (var i = 0; i < visible.length; i++)
                              _CategoryYearTile(
                                category: visible[i],
                                year: year,
                                sum: byCat[visible[i].id] ?? 0,
                                showDivider: i > 0,
                              ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryYearTile extends ConsumerWidget {
  const _CategoryYearTile({
    required this.category,
    required this.year,
    required this.sum,
    required this.showDivider,
  });

  final Category category;
  final int year;
  final int sum;
  final bool showDivider;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = SpendStatsService(ref.watch(databaseProvider));
    return FutureBuilder<YoyResult>(
      future: stats.yoy(category.id, year),
      builder: (context, snap) {
        final yoy = snap.data;
        return InkWell(
          onTap: () => context.push(
            '/spend/categories/${category.id}?year=$year',
          ),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(16, 13, 16, 13),
            decoration: BoxDecoration(
              border: showDivider
                  ? const Border(
                      top: BorderSide(color: HiveColors.borderSoft),
                    )
                  : null,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        category.name + (category.enabled ? '' : '（已停用）'),
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: HiveColors.ink,
                        ),
                      ),
                    ),
                    Text(
                      formatYuan(sum),
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: HiveColors.ink,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  yoy == null ? '…' : formatYoyText(yoy),
                  style: TextStyle(
                    fontSize: 12,
                    color: yoy == null ? HiveColors.dim : yoyColor(yoy),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
