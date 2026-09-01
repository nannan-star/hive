import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/db/app_database.dart';
import '../../../data/providers.dart';
import '../../../shared/money.dart';
import '../../../shared/theme/hive_colors.dart';
import '../../../shared/widgets/hive_widgets.dart';
import '../providers/spend_providers.dart';
import '../services/template_service.dart';

final _allCategoriesProvider = StreamProvider<List<Category>>((ref) {
  return ref.watch(categoriesDaoProvider).watchAll();
});

class PendingPage extends ConsumerStatefulWidget {
  const PendingPage({super.key});

  @override
  ConsumerState<PendingPage> createState() => _PendingPageState();
}

class _PendingPageState extends ConsumerState<PendingPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final db = ref.read(databaseProvider);
      await TemplateService.ensureMonthTemplates(db, DateTime.now());
    });
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final pendingAsync =
        ref.watch(pendingEntriesProvider((now.year, now.month)));
    final catsAsync = ref.watch(_allCategoriesProvider);

    return Scaffold(
      backgroundColor: HiveColors.page,
      body: SafeArea(
        child: Column(
          children: [
            const HiveBackHeader(title: '本月待确认'),
            Expanded(
              child: pendingAsync.when(
                data: (entries) {
                  if (entries.isEmpty) {
                    return const HiveEmpty('本月没有待确认');
                  }
                  final catMap = {
                    for (final c in catsAsync.valueOrNull ?? <Category>[])
                      c.id: c.name,
                  };
                  return ListView.separated(
                    padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
                    itemCount: entries.length + 1,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (context, i) {
                      if (i == 0) {
                        return const HiveHint(
                          '由月度模板自动生成各 1 条；确认后计入统计。同月同分类仍可再手记多笔。',
                        );
                      }
                      final e = entries[i - 1];
                      return _PendingCard(
                        entry: e,
                        categoryName: catMap[e.categoryId] ?? e.categoryId,
                      );
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, _) => Center(child: Text('错误: $err')),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PendingCard extends ConsumerStatefulWidget {
  const _PendingCard({required this.entry, required this.categoryName});

  final SpendEntry entry;
  final String categoryName;

  @override
  ConsumerState<_PendingCard> createState() => _PendingCardState();
}

class _PendingCardState extends ConsumerState<_PendingCard> {
  late final TextEditingController _amountCtrl;

  @override
  void initState() {
    super.initState();
    final yuan = centsToYuan(widget.entry.amountCents);
    _amountCtrl = TextEditingController(
      text: yuan == yuan.roundToDouble()
          ? yuan.round().toString()
          : yuan.toStringAsFixed(2),
    );
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    super.dispose();
  }

  Future<void> _persistFields() async {
    final dao = ref.read(databaseProvider).spendEntriesDao;
    await dao.updateFields(
      id: widget.entry.id,
      amountCents: yuanToCents(num.parse(_amountCtrl.text.trim())),
      date: widget.entry.date,
      note: widget.entry.note,
    );
  }

  Future<void> _confirm() async {
    await _persistFields();
    await ref
        .read(databaseProvider)
        .spendEntriesDao
        .setStatus(widget.entry.id, 'confirmed');
  }

  Future<void> _skip() async {
    await ref
        .read(databaseProvider)
        .spendEntriesDao
        .setStatus(widget.entry.id, 'skipped');
  }

  @override
  Widget build(BuildContext context) {
    final source = widget.entry.source == 'template' ? '模板' : '手记';
    return HiveCard(
      radius: 16,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.categoryName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: HiveColors.ink,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '$source · ${widget.entry.date}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: HiveColors.dim,
                      ),
                    ),
                  ],
                ),
              ),
              const HiveBadge(label: '待确认', tone: HiveBadgeTone.pending),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            decoration: BoxDecoration(
              color: HiveColors.fieldFill,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: HiveColors.border),
            ),
            child: Row(
              children: [
                const Text(
                  '金额',
                  style: TextStyle(fontSize: 13, color: HiveColors.dim),
                ),
                Expanded(
                  child: TextField(
                    controller: _amountCtrl,
                    textAlign: TextAlign.right,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: HiveColors.ink,
                    ),
                    decoration: const InputDecoration(
                      isDense: true,
                      prefixText: '¥',
                      prefixStyle: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: HiveColors.ink,
                      ),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      filled: false,
                      contentPadding: EdgeInsets.symmetric(vertical: 8),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _skip,
                  child: const Text('跳过'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: SizedBox(
                  height: 46,
                  child: FilledButton(
                    onPressed: _confirm,
                    child: const Text('确认入账'),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
