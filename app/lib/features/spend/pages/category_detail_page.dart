import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../data/db/app_database.dart';
import '../../../data/providers.dart';
import '../../../shared/money.dart';
import '../providers/spend_providers.dart';
import '../services/spend_stats_service.dart';

class CategoryDetailPage extends ConsumerWidget {
  const CategoryDetailPage({
    super.key,
    required this.categoryId,
    required this.year,
  });

  final String categoryId;
  final int year;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = ref.watch(databaseProvider);
    final stats = SpendStatsService(db);

    return FutureBuilder<_DetailData>(
      key: ValueKey('$categoryId-$year'),
      future: () async {
        final cat =
            await ref.read(categoriesDaoProvider).getById(categoryId);
        final yoy = await stats.yoy(categoryId, year);
        final months = await stats.monthlySums(categoryId, year);
        final entries = await stats.listConfirmedEntries(categoryId, year);
        return _DetailData(cat, yoy, months, entries);
      }(),
      builder: (context, snap) {
        if (!snap.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        final data = snap.data!;
        final name = data.category?.name ?? '分类';
        final maxY =
            data.months.fold<int>(0, (a, b) => a > b ? a : b).toDouble();

        return Scaffold(
          appBar: AppBar(
            title: Text(name),
            actions: [
              TextButton(
                onPressed: () => context.push(
                  '/spend/add?categoryId=$categoryId',
                ),
                child: const Text('记一笔'),
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                formatYuan(data.yoy.thisYear),
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              Text(formatYoyText(data.yoy)),
              const SizedBox(height: 16),
              SizedBox(
                height: 180,
                child: BarChart(
                  BarChartData(
                    maxY: maxY == 0 ? 1 : maxY * 1.2,
                    barGroups: [
                      for (var i = 0; i < 12; i++)
                        BarChartGroupData(
                          x: i + 1,
                          barRods: [
                            BarChartRodData(
                              toY: data.months[i].toDouble(),
                              width: 12,
                            ),
                          ],
                        ),
                    ],
                    titlesData: FlTitlesData(
                      topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      leftTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (v, _) => Text('${v.toInt()}'),
                        ),
                      ),
                    ),
                    gridData: const FlGridData(show: false),
                    borderData: FlBorderData(show: false),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text('明细', style: TextStyle(fontWeight: FontWeight.w600)),
              for (final e in data.entries)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(formatYuan(e.amountCents)),
                  subtitle: Text(
                    '${e.date} · ${e.source == 'template' ? '模板' : '手记'}'
                    '${e.note != null && e.note!.isNotEmpty ? ' · ${e.note}' : ''}',
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _DetailData {
  _DetailData(this.category, this.yoy, this.months, this.entries);

  final Category? category;
  final YoyResult yoy;
  final List<int> months;
  final List<SpendEntry> entries;
}
