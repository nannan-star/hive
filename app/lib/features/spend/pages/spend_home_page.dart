import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../data/db/app_database.dart';
import '../../../data/providers.dart';
import '../../../shared/money.dart';
import '../../../shared/widgets/year_switcher.dart';
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('消费'),
        actions: [
          YearSwitcher(
            year: year,
            onChanged: (y) =>
                ref.read(selectedSpendYearProvider.notifier).state = y,
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: FutureBuilder(
        key: ValueKey(year),
        future: Future.wait([
          stats.yearTotal(year),
          stats.sumByCategory(year),
          ref.read(categoriesDaoProvider).watchAll().first,
        ]),
        builder: (context, snap) {
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final total = snap.data![0] as int;
          final byCat = snap.data![1] as Map<String, int>;
          final allCats = snap.data![2] as List<Category>;

          final visible = allCats.where((c) {
            if (c.enabled) return true;
            return (byCat[c.id] ?? 0) > 0;
          }).toList()
            ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

          return ListView(
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
              Text('$year 已确认合计',
                  style: Theme.of(context).textTheme.titleSmall),
              Text(formatYuan(total),
                  style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 12),
              for (final c in visible)
                _CategoryYearTile(
                  category: c,
                  year: year,
                  sum: byCat[c.id] ?? 0,
                ),
            ],
          );
        },
      ),
    );
  }
}

class _CategoryYearTile extends ConsumerWidget {
  const _CategoryYearTile({
    required this.category,
    required this.year,
    required this.sum,
  });

  final Category category;
  final int year;
  final int sum;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = SpendStatsService(ref.watch(databaseProvider));
    return FutureBuilder<YoyResult>(
      future: stats.yoy(category.id, year),
      builder: (context, snap) {
        final yoyText =
            snap.hasData ? formatYoyText(snap.data!) : '…';
        return ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(category.name + (category.enabled ? '' : '（已停用）')),
          subtitle: Text(yoyText),
          trailing: Text(formatYuan(sum)),
          onTap: () => context.push(
            '/spend/categories/${category.id}?year=$year',
          ),
        );
      },
    );
  }
}
