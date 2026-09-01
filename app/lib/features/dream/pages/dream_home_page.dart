import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../data/providers.dart';
import '../../../shared/money.dart';
import '../../../shared/theme/hive_colors.dart';
import '../../../shared/widgets/hive_widgets.dart';
import '../providers/dream_providers.dart';

class DreamHomePage extends ConsumerWidget {
  const DreamHomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final include = ref.watch(includeCompletedDreamsProvider);
    final jarsAsync = ref.watch(dreamJarsProvider);

    return Scaffold(
      backgroundColor: HiveColors.page,
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            HiveBrandHeader(
              subtitle: '梦想 · 储蓄罐',
              trailing: HiveCircleButton(
                onPressed: () => context.push('/settings'),
                child: const HiveGearIcon(),
              ),
            ),
            Expanded(
              child: jarsAsync.when(
                data: (jars) {
                  return ListView(
                    padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
                    children: [
                      HiveChipRow(
                        children: [
                          HiveChip(
                            label: '进行中',
                            selected: !include,
                            onTap: () {
                              ref
                                  .read(
                                    includeCompletedDreamsProvider.notifier,
                                  )
                                  .state = false;
                            },
                          ),
                          HiveChip(
                            label: '含已完成',
                            selected: include,
                            onTap: () {
                              ref
                                  .read(
                                    includeCompletedDreamsProvider.notifier,
                                  )
                                  .state = true;
                            },
                          ),
                          HiveChip(
                            label: '＋ 新建罐子',
                            selected: false,
                            onTap: () => context.push('/dream/new'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      if (jars.isEmpty)
                        const Padding(
                          padding: EdgeInsets.only(top: 48),
                          child: HiveEmpty('还没有梦想罐'),
                        )
                      else
                        for (final jar in jars) ...[
                          _DreamCard(jarId: jar.id),
                          const SizedBox(height: 12),
                        ],
                    ],
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('$e')),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DreamCard extends ConsumerWidget {
  const _DreamCard({required this.jarId});

  final String jarId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final jars = ref.watch(dreamJarsProvider).valueOrNull ?? [];
    final match = jars.where((j) => j.id == jarId);
    if (match.isEmpty) return const SizedBox.shrink();
    final jar = match.first;

    return FutureBuilder<int>(
      future: ref.read(databaseProvider).dreamDao.sumDeposits(jar.id),
      builder: (context, snap) {
        final saved = snap.data ?? 0;
        final progress = jar.targetCents == 0
            ? 0.0
            : (saved / jar.targetCents).clamp(0.0, 1.0);
        final pct = (progress * 100).round();
        final done = jar.status == 'completed';

        return HiveCard(
          radius: 16,
          padding: const EdgeInsets.fromLTRB(16, 15, 16, 15),
          onTap: () => context.push('/dream/${jar.id}'),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Flexible(
                          child: Text(
                            jar.name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: HiveColors.ink,
                            ),
                          ),
                        ),
                        if (done) ...[
                          const SizedBox(width: 8),
                          const HiveBadge(
                            label: '已完成',
                            tone: HiveBadgeTone.accent,
                          ),
                        ],
                      ],
                    ),
                  ),
                  Text(
                    formatYuan(saved),
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: HiveColors.ink,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              HiveProgressBar(value: progress),
              const SizedBox(height: 12),
              Row(
                children: [
                  Text(
                    '目标 ${formatYuan(jar.targetCents)}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: HiveColors.dim,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '$pct%',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: HiveColors.accent,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
