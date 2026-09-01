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

class CategoryDetailPage extends ConsumerStatefulWidget {
  const CategoryDetailPage({
    super.key,
    required this.categoryId,
    required this.year,
  });

  final String categoryId;
  final int year;

  @override
  ConsumerState<CategoryDetailPage> createState() => _CategoryDetailPageState();
}

class _CategoryDetailPageState extends ConsumerState<CategoryDetailPage> {
  late int _selectedMonth;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedMonth =
        widget.year == now.year ? now.month : 12;
  }

  @override
  Widget build(BuildContext context) {
    final db = ref.watch(databaseProvider);
    final stats = SpendStatsService(db);

    return FutureBuilder<_DetailData>(
      key: ValueKey('${widget.categoryId}-${widget.year}'),
      future: () async {
        final cat =
            await ref.read(categoriesDaoProvider).getById(widget.categoryId);
        final yoy = await stats.yoy(widget.categoryId, widget.year);
        final months = await stats.monthlySums(widget.categoryId, widget.year);
        final entries =
            await stats.listYearEntries(widget.categoryId, widget.year);
        return _DetailData(cat, yoy, months, entries);
      }(),
      builder: (context, snap) {
        if (!snap.hasData) {
          return const Scaffold(
            backgroundColor: HiveColors.page,
            body: Center(child: CircularProgressIndicator()),
          );
        }
        final data = snap.data!;
        final name = data.category?.name ?? '分类';
        final monthPrefix =
            '${widget.year}-${_selectedMonth.toString().padLeft(2, '0')}';
        final monthEntries = data.entries
            .where((e) => e.date.startsWith(monthPrefix))
            .toList();
        final confirmedMonth = monthEntries
            .where((e) => e.status == 'confirmed')
            .fold<int>(0, (a, b) => a + b.amountCents);

        return Scaffold(
          backgroundColor: HiveColors.page,
          body: SafeArea(
            child: Column(
              children: [
                HiveBackHeader(
                  title: name,
                  trailing: HiveChip(
                    label: '＋ 记一笔',
                    selected: true,
                    onTap: () => context.push(
                      '/spend/add?categoryId=${widget.categoryId}',
                    ),
                  ),
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
                    children: [
                      HiveCard(
                        padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${widget.year} 年合计',
                              style: const TextStyle(
                                fontSize: 13,
                                color: HiveColors.muted,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              formatYuan(data.yoy.thisYear),
                              style: const TextStyle(
                                fontSize: 34,
                                fontWeight: FontWeight.w700,
                                color: HiveColors.ink,
                                height: 1.1,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              formatYoyText(data.yoy, vsYear: widget.year - 1),
                              style: TextStyle(
                                fontSize: 12,
                                color: yoyColor(data.yoy),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      HiveCard(
                        padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                        child: Column(
                          children: [
                            const Row(
                              children: [
                                Text(
                                  '按月',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: HiveColors.dim,
                                  ),
                                ),
                                Spacer(),
                                Text(
                                  '已确认合计',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: HiveColors.dim,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            HiveMonthBars(
                              values: data.months,
                              selectedMonth: _selectedMonth,
                              onSelect: (m) =>
                                  setState(() => _selectedMonth = m),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      const HiveHint(
                        '同月可有多笔。单柱为该月已确认合计；点柱可对照下方明细。',
                      ),
                      const SizedBox(height: 12),
                      HiveCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                              child: Text(
                                '$monthPrefix · 已确认 ${formatYuan(confirmedMonth)}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: HiveColors.dim,
                                ),
                              ),
                            ),
                            if (monthEntries.isEmpty)
                              const Padding(
                                padding: EdgeInsets.fromLTRB(16, 8, 16, 20),
                                child: Text(
                                  '该月暂无明细',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: HiveColors.dim,
                                  ),
                                ),
                              )
                            else
                              for (var i = 0; i < monthEntries.length; i++)
                                _EntryRow(
                                  entry: monthEntries[i],
                                  showDivider: i > 0,
                                ),
                          ],
                        ),
                      ),
                    ],
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

class _EntryRow extends StatelessWidget {
  const _EntryRow({required this.entry, required this.showDivider});

  final SpendEntry entry;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final md = entry.date.length >= 10 ? entry.date.substring(5) : entry.date;
    final pending = entry.status == 'pending';
    final source = entry.source == 'template' ? '模板' : '手记';
    final note = entry.note;
    final subtitle = [
      if (note != null && note.isNotEmpty) note,
      source,
    ].join(' · ');

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
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
                  formatYuan(entry.amountCents),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: HiveColors.ink,
                  ),
                ),
              ),
              Text(
                pending ? '$md · 待确认' : md,
                style: const TextStyle(fontSize: 12, color: HiveColors.dim),
              ),
            ],
          ),
          if (subtitle.isNotEmpty) ...[
            const SizedBox(height: 3),
            Text(
              subtitle,
              style: const TextStyle(fontSize: 12, color: HiveColors.muted),
            ),
          ],
        ],
      ),
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
