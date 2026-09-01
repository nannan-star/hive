import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/db/app_database.dart';
import '../../../data/providers.dart';
import '../../../shared/dates.dart';
import '../../../shared/money.dart';
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
      appBar: AppBar(title: const Text('本月待确认')),
      body: pendingAsync.when(
        data: (entries) {
          if (entries.isEmpty) {
            return const Center(child: Text('本月没有待确认'));
          }
          final catMap = {
            for (final c in catsAsync.valueOrNull ?? <Category>[]) c.id: c.name,
          };
          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: entries.length,
            itemBuilder: (context, i) {
              final e = entries[i];
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
  late final TextEditingController _noteCtrl;
  late DateTime _date;

  @override
  void initState() {
    super.initState();
    _amountCtrl = TextEditingController(
      text: centsToYuan(widget.entry.amountCents).toString(),
    );
    _noteCtrl = TextEditingController(text: widget.entry.note ?? '');
    _date = parseDateYmd(widget.entry.date);
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  Future<void> _persistFields() async {
    final dao = ref.read(databaseProvider).spendEntriesDao;
    await dao.updateFields(
      id: widget.entry.id,
      amountCents: yuanToCents(num.parse(_amountCtrl.text.trim())),
      date: formatDateYmd(_date),
      note: _noteCtrl.text.trim().isEmpty ? null : _noteCtrl.text.trim(),
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
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              widget.categoryName,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            TextField(
              controller: _amountCtrl,
              decoration: const InputDecoration(labelText: '金额（元）'),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('日期'),
              subtitle: Text(formatDateYmd(_date)),
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _date,
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                );
                if (picked != null) setState(() => _date = picked);
              },
            ),
            TextField(
              controller: _noteCtrl,
              decoration: const InputDecoration(labelText: '备注'),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: FilledButton(
                    onPressed: _confirm,
                    child: const Text('确认'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: _skip,
                    child: const Text('跳过本月'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
