import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/dates.dart';
import '../../../shared/money.dart';
import '../providers/dream_providers.dart';

class DreamDetailPage extends ConsumerStatefulWidget {
  const DreamDetailPage({super.key, required this.jarId});

  final String jarId;

  @override
  ConsumerState<DreamDetailPage> createState() => _DreamDetailPageState();
}

class _DreamDetailPageState extends ConsumerState<DreamDetailPage> {
  final _nameCtrl = TextEditingController();
  final _targetCtrl = TextEditingController();
  bool _loaded = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _targetCtrl.dispose();
    super.dispose();
  }

  Future<void> _ensureLoaded() async {
    if (_loaded) return;
    final jar = await ref.read(dreamDaoProvider).getJar(widget.jarId);
    if (jar == null || !mounted) return;
    _nameCtrl.text = jar.name;
    _targetCtrl.text = centsToYuan(jar.targetCents).toString();
    _loaded = true;
  }

  Future<void> _saveMeta() async {
    await ref.read(dreamDaoProvider).updateJar(
          id: widget.jarId,
          name: _nameCtrl.text.trim(),
          targetCents: yuanToCents(num.parse(_targetCtrl.text.trim())),
        );
    if (mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('已保存')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final depositsAsync = ref.watch(dreamDepositsProvider(widget.jarId));

    return FutureBuilder(
      future: () async {
        await _ensureLoaded();
        final jar = await ref.read(dreamDaoProvider).getJar(widget.jarId);
        final saved =
            await ref.read(dreamDaoProvider).sumDeposits(widget.jarId);
        return (jar, saved);
      }(),
      builder: (context, snap) {
        if (!snap.hasData || snap.data?.$1 == null) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        final jar = snap.data!.$1!;
        final saved = snap.data!.$2;
        final remain = (jar.targetCents - saved).clamp(0, 1 << 62);

        return Scaffold(
          appBar: AppBar(title: Text(jar.name)),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(formatYuan(saved),
                  style: Theme.of(context).textTheme.headlineMedium),
              Text('目标 ${formatYuan(jar.targetCents)} · 还差 ${formatYuan(remain)}'),
              const SizedBox(height: 12),
              TextField(
                controller: _nameCtrl,
                decoration: const InputDecoration(labelText: '名称'),
              ),
              TextField(
                controller: _targetCtrl,
                decoration: const InputDecoration(labelText: '目标（元）'),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton(onPressed: _saveMeta, child: const Text('保存名称/目标')),
              ),
              Wrap(
                spacing: 8,
                children: [
                  FilledButton(
                    onPressed: () =>
                        context.push('/dream/${widget.jarId}/deposit'),
                    child: const Text('存一笔'),
                  ),
                  if (jar.status == 'active')
                    OutlinedButton(
                      onPressed: () async {
                        await ref
                            .read(dreamDaoProvider)
                            .markCompleted(widget.jarId);
                        if (context.mounted) setState(() {});
                      },
                      child: const Text('标记已完成'),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              const Text('流水', style: TextStyle(fontWeight: FontWeight.w600)),
              depositsAsync.when(
                data: (rows) {
                  if (rows.isEmpty) return const Text('暂无存入');
                  return Column(
                    children: [
                      for (final d in rows)
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(formatYuan(d.amountCents)),
                          subtitle: Text(
                            '${d.date}${d.note != null ? ' · ${d.note}' : ''}',
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete_outline),
                            onPressed: () => ref
                                .read(dreamDaoProvider)
                                .deleteDeposit(d.id),
                          ),
                          onTap: () async {
                            final amountCtrl = TextEditingController(
                              text: centsToYuan(d.amountCents).toString(),
                            );
                            final noteCtrl =
                                TextEditingController(text: d.note ?? '');
                            var date = parseDateYmd(d.date);
                            final ok = await showDialog<bool>(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: const Text('修改存入'),
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    TextField(
                                      controller: amountCtrl,
                                      decoration: const InputDecoration(
                                        labelText: '金额（元）',
                                      ),
                                    ),
                                    TextField(
                                      controller: noteCtrl,
                                      decoration: const InputDecoration(
                                        labelText: '备注',
                                      ),
                                    ),
                                  ],
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(ctx, false),
                                    child: const Text('取消'),
                                  ),
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(ctx, true),
                                    child: const Text('保存'),
                                  ),
                                ],
                              ),
                            );
                            if (ok == true) {
                              await ref.read(dreamDaoProvider).updateDeposit(
                                    id: d.id,
                                    amountCents: yuanToCents(
                                      num.parse(amountCtrl.text.trim()),
                                    ),
                                    date: formatDateYmd(date),
                                    note: noteCtrl.text.trim().isEmpty
                                        ? null
                                        : noteCtrl.text.trim(),
                                  );
                            }
                          },
                        ),
                    ],
                  );
                },
                loading: () => const CircularProgressIndicator(),
                error: (e, _) => Text('$e'),
              ),
            ],
          ),
        );
      },
    );
  }
}
