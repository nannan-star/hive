import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../data/db/app_database.dart';
import '../../../shared/dates.dart';
import '../../../shared/money.dart';
import '../../../shared/theme/hive_colors.dart';
import '../../../shared/widgets/hive_widgets.dart';
import '../providers/dream_providers.dart';

class DreamDetailPage extends ConsumerStatefulWidget {
  const DreamDetailPage({super.key, required this.jarId});

  final String jarId;

  @override
  ConsumerState<DreamDetailPage> createState() => _DreamDetailPageState();
}

class _DreamDetailPageState extends ConsumerState<DreamDetailPage> {
  @override
  Widget build(BuildContext context) {
    final depositsAsync = ref.watch(dreamDepositsProvider(widget.jarId));

    return FutureBuilder(
      future: () async {
        final jar = await ref.read(dreamDaoProvider).getJar(widget.jarId);
        final saved =
            await ref.read(dreamDaoProvider).sumDeposits(widget.jarId);
        return (jar, saved);
      }(),
      builder: (context, snap) {
        if (!snap.hasData || snap.data?.$1 == null) {
          return const Scaffold(
            backgroundColor: HiveColors.page,
            body: Center(child: CircularProgressIndicator()),
          );
        }
        final jar = snap.data!.$1!;
        final saved = snap.data!.$2;
        final remain = (jar.targetCents - saved).clamp(0, 1 << 62);
        final progress = jar.targetCents == 0
            ? 0.0
            : (saved / jar.targetCents).clamp(0.0, 1.0);
        final status = jar.status == 'completed' ? '已完成' : '进行中';

        return Scaffold(
          backgroundColor: HiveColors.page,
          body: SafeArea(
            child: Column(
              children: [
                HiveBackHeader(title: jar.name),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
                    children: [
                      HiveCard(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              '已存 / 目标',
                              style: TextStyle(
                                fontSize: 13,
                                color: HiveColors.muted,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text.rich(
                              TextSpan(
                                children: [
                                  TextSpan(
                                    text: formatYuan(saved),
                                    style: const TextStyle(
                                      fontSize: 36,
                                      fontWeight: FontWeight.w700,
                                      color: HiveColors.ink,
                                      height: 1.1,
                                    ),
                                  ),
                                  TextSpan(
                                    text:
                                        ' / ${formatYuan(jar.targetCents).replaceFirst('¥', '')}',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: HiveColors.dim,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 10),
                            HiveProgressBar(value: progress, height: 10),
                            const SizedBox(height: 10),
                            Text(
                              '还差 ${formatYuan(remain)} · $status',
                              style: const TextStyle(
                                fontSize: 12,
                                color: HiveColors.muted,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                      HiveChipRow(
                        children: [
                          HiveChip(
                            label: '＋ 存一笔',
                            selected: true,
                            onTap: () => context.push(
                              '/dream/${widget.jarId}/deposit',
                            ),
                          ),
                          if (jar.status == 'active')
                            HiveChip(
                              label: '标记已完成',
                              selected: false,
                              onTap: () async {
                                await ref
                                    .read(dreamDaoProvider)
                                    .markCompleted(widget.jarId);
                                if (context.mounted) setState(() {});
                              },
                            ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      HiveCard(
                        child: Column(
                          children: [
                            const Padding(
                              padding: EdgeInsets.fromLTRB(16, 14, 16, 10),
                              child: Row(
                                children: [
                                  Text(
                                    '存入记录',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: HiveColors.dim,
                                    ),
                                  ),
                                  Spacer(),
                                  Text(
                                    '到天',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: HiveColors.dim,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            depositsAsync.when(
                              data: (rows) {
                                if (rows.isEmpty) {
                                  return const Padding(
                                    padding: EdgeInsets.fromLTRB(16, 8, 16, 20),
                                    child: Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        '暂无存入',
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: HiveColors.dim,
                                        ),
                                      ),
                                    ),
                                  );
                                }
                                return Column(
                                  children: [
                                    for (var i = 0; i < rows.length; i++)
                                      _DepositRow(
                                        amount: formatYuan(rows[i].amountCents),
                                        date: rows[i].date.length >= 10
                                            ? rows[i].date.substring(5)
                                            : rows[i].date,
                                        note: rows[i].note,
                                        showDivider: i > 0,
                                        onLongPress: () => _editDeposit(rows[i]),
                                      ),
                                  ],
                                );
                              },
                              loading: () => const Padding(
                                padding: EdgeInsets.all(16),
                                child: CircularProgressIndicator(),
                              ),
                              error: (e, _) => Padding(
                                padding: const EdgeInsets.all(16),
                                child: Text('$e'),
                              ),
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

  Future<void> _editDeposit(DreamDeposit row) async {
    final amountCtrl = TextEditingController(
      text: centsToYuan(row.amountCents).toString(),
    );
    final noteCtrl = TextEditingController(text: row.note ?? '');
    final date = parseDateYmd(row.date);
    final action = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('修改存入'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: amountCtrl,
              decoration: const InputDecoration(labelText: '金额（元）'),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: noteCtrl,
              decoration: const InputDecoration(labelText: '备注'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, 'delete'),
            child: const Text(
              '删除',
              style: TextStyle(color: HiveColors.danger),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, 'cancel'),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, 'save'),
            child: const Text('保存'),
          ),
        ],
      ),
    );
    if (action == 'delete') {
      await ref.read(dreamDaoProvider).deleteDeposit(row.id);
      if (mounted) setState(() {});
    } else if (action == 'save') {
      await ref.read(dreamDaoProvider).updateDeposit(
            id: row.id,
            amountCents: yuanToCents(num.parse(amountCtrl.text.trim())),
            date: formatDateYmd(date),
            note: noteCtrl.text.trim().isEmpty ? null : noteCtrl.text.trim(),
          );
      if (mounted) setState(() {});
    }
  }
}

class _DepositRow extends StatelessWidget {
  const _DepositRow({
    required this.amount,
    required this.date,
    required this.note,
    required this.showDivider,
    required this.onLongPress,
  });

  final String amount;
  final String date;
  final String? note;
  final bool showDivider;
  final VoidCallback onLongPress;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onLongPress: onLongPress,
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
                    amount,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: HiveColors.ink,
                    ),
                  ),
                ),
                Text(
                  date,
                  style: const TextStyle(fontSize: 13, color: HiveColors.dim),
                ),
              ],
            ),
            if (note != null && note!.isNotEmpty) ...[
              const SizedBox(height: 3),
              Text(
                note!,
                style: const TextStyle(fontSize: 12, color: HiveColors.muted),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
