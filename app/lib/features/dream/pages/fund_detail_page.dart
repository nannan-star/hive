import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../data/db/app_database.dart';
import '../../../data/providers.dart';
import '../../../shared/money.dart';
import '../../../shared/theme/hive_colors.dart';
import '../../../shared/widgets/hive_widgets.dart';
import '../providers/dream_providers.dart';
import 'dream_detail_page.dart';

/// Routes `/dream/:id` to goal or fund detail by jar kind.
class DreamJarDetailPage extends ConsumerWidget {
  const DreamJarDetailPage({super.key, required this.jarId});

  final String jarId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final epoch = ref.watch(backupRestoreEpochProvider);

    return FutureBuilder<DreamJar?>(
      key: ValueKey('$epoch-$jarId'),
      future: ref.read(dreamDaoProvider).getJar(jarId),
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return const Scaffold(
            backgroundColor: HiveColors.page,
            body: Center(child: CircularProgressIndicator()),
          );
        }
        final jar = snap.data;
        if (jar == null) {
          return Scaffold(
            backgroundColor: HiveColors.page,
            body: SafeArea(
              child: Column(
                children: [
                  const HiveBackHeader(title: '未找到'),
                  const Expanded(
                    child: Center(
                      child: Text(
                        '账户或储蓄罐不存在',
                        style: TextStyle(color: HiveColors.dim),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }
        if (jar.kind == 'fund') {
          return FundDetailPage(jarId: jarId);
        }
        return DreamDetailPage(jarId: jarId);
      },
    );
  }
}

class FundDetailPage extends ConsumerStatefulWidget {
  const FundDetailPage({super.key, required this.jarId});

  final String jarId;

  @override
  ConsumerState<FundDetailPage> createState() => _FundDetailPageState();
}

class _FundDetailPageState extends ConsumerState<FundDetailPage> {
  @override
  Widget build(BuildContext context) {
    final depositsAsync = ref.watch(dreamDepositsProvider(widget.jarId));
    final epoch = ref.watch(backupRestoreEpochProvider);

    return FutureBuilder(
      key: ValueKey('$epoch-${widget.jarId}'),
      future: () async {
        final jar = await ref.read(dreamDaoProvider).getJar(widget.jarId);
        final balance =
            await ref.read(dreamDaoProvider).sumDeposits(widget.jarId);
        return (jar, balance);
      }(),
      builder: (context, snap) {
        if (!snap.hasData || snap.data?.$1 == null) {
          return const Scaffold(
            backgroundColor: HiveColors.page,
            body: Center(child: CircularProgressIndicator()),
          );
        }
        final jar = snap.data!.$1!;
        final balance = snap.data!.$2;

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
                              '当前余额',
                              style: TextStyle(
                                fontSize: 13,
                                color: HiveColors.muted,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              formatYuan(balance),
                              style: const TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.w700,
                                color: HiveColors.ink,
                                height: 1.1,
                              ),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              '账户 · 无目标 · 可存可取',
                              style: TextStyle(
                                fontSize: 12,
                                color: HiveColors.dim,
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
                          HiveChip(
                            label: '－ 取一笔',
                            selected: false,
                            onTap: () => context.push(
                              '/dream/${widget.jarId}/withdraw',
                            ),
                          ),
                          HiveChip(
                            label: '改名',
                            selected: false,
                            onTap: () => _renameFund(jar.name),
                          ),
                          HiveChip(
                            label: '删除',
                            selected: false,
                            onTap: () => _deleteFund(balance),
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
                                    '流水',
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
                                        '暂无流水',
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
                                      _LedgerRow(
                                        row: rows[i],
                                        showDivider: i > 0,
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

  Future<void> _renameFund(String currentName) async {
    final nameCtrl = TextEditingController(text: currentName);
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('改名'),
        content: TextField(
          controller: nameCtrl,
          decoration: const InputDecoration(labelText: '名称'),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('保存'),
          ),
        ],
      ),
    );
    if (ok != true || nameCtrl.text.trim().isEmpty) return;
    await ref.read(dreamServiceProvider).renameFund(
          id: widget.jarId,
          name: nameCtrl.text.trim(),
        );
    if (mounted) setState(() {});
  }

  Future<void> _deleteFund(int balance) async {
    if (balance != 0) {
      final ok = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('删除账户'),
          content: Text(
            '当前余额 ${formatYuan(balance)}，删除后流水不可恢复。确定删除？',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text(
                '删除',
                style: TextStyle(color: HiveColors.danger),
              ),
            ),
          ],
        ),
      );
      if (ok != true) return;
      await ref.read(dreamServiceProvider).deleteFund(
            widget.jarId,
            confirmNonZero: true,
          );
    } else {
      await ref.read(dreamServiceProvider).deleteFund(
            widget.jarId,
            confirmNonZero: false,
          );
    }
    if (mounted) context.go('/dream');
  }
}

class _LedgerRow extends StatelessWidget {
  const _LedgerRow({required this.row, required this.showDivider});

  final DreamDeposit row;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final isDeposit = row.amountCents > 0;
    final label = isDeposit ? '存入' : '取出';
    final amount = formatYuan(row.amountCents.abs());
    final date = row.date.length >= 10 ? row.date.substring(5) : row.date;

    return Container(
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
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: isDeposit ? HiveColors.accent : HiveColors.dim,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  amount,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: isDeposit ? HiveColors.ink : HiveColors.danger,
                  ),
                ),
              ),
              Text(
                date,
                style: const TextStyle(fontSize: 13, color: HiveColors.dim),
              ),
            ],
          ),
          if (row.note != null && row.note!.isNotEmpty) ...[
            const SizedBox(height: 3),
            Text(
              row.note!,
              style: const TextStyle(fontSize: 12, color: HiveColors.muted),
            ),
          ],
        ],
      ),
    );
  }
}
