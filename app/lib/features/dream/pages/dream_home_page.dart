import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../data/db/app_database.dart';
import '../../../data/providers.dart';
import '../../../shared/money.dart';
import '../../../shared/theme/hive_colors.dart';
import '../../../shared/widgets/hive_widgets.dart';
import '../providers/dream_providers.dart';

class DreamHomePage extends ConsumerWidget {
  const DreamHomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final kind = ref.watch(freeKindFilterProvider);
    final include = ref.watch(includeCompletedDreamsProvider);
    final jarsAsync = ref.watch(dreamJarsProvider);
    final isGoal = kind == 'goal';

    return Scaffold(
      backgroundColor: HiveColors.page,
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            HiveBrandHeader(
              subtitle: '自由 · 储蓄与账户',
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
                      Text(
                        isGoal
                            ? '与消费分账。储蓄罐只存不取，可标记完成。'
                            : '与消费分账。账户无目标，可存可取；取出不可超余额。',
                        style: const TextStyle(
                          fontSize: 12,
                          height: 1.45,
                          color: HiveColors.muted,
                        ),
                      ),
                      const SizedBox(height: 12),
                      HiveChipRow(
                        children: [
                          HiveChip(
                            label: '储蓄罐',
                            selected: isGoal,
                            onTap: () {
                              ref.read(freeKindFilterProvider.notifier).state =
                                  'goal';
                            },
                          ),
                          HiveChip(
                            label: '账户',
                            selected: !isGoal,
                            onTap: () {
                              ref.read(freeKindFilterProvider.notifier).state =
                                  'fund';
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      HiveChipRow(
                        children: [
                          if (isGoal) ...[
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
                              label: '＋ 新建',
                              selected: false,
                              onTap: () => context.push('/dream/new'),
                            ),
                          ] else
                            HiveChip(
                              label: '＋ 新建账户',
                              selected: false,
                              onTap: () => context.push('/dream/new'),
                            ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      if (jars.isEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 48),
                          child: HiveEmpty(isGoal ? '暂无储蓄罐' : '暂无账户'),
                        )
                      else
                        for (final jar in jars) ...[
                          isGoal
                              ? _GoalJarCard(jarId: jar.id)
                              : _FundCard(jarId: jar.id),
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

class _GoalJarCard extends ConsumerWidget {
  const _GoalJarCard({required this.jarId});

  final String jarId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final epoch = ref.watch(backupRestoreEpochProvider);
    final jar = _findJar(ref, jarId);
    if (jar == null) return const SizedBox.shrink();

    return FutureBuilder<int>(
      key: ValueKey('$epoch-$jarId'),
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

class _FundCard extends ConsumerWidget {
  const _FundCard({required this.jarId});

  final String jarId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final epoch = ref.watch(backupRestoreEpochProvider);
    final jar = _findJar(ref, jarId);
    if (jar == null) return const SizedBox.shrink();

    return FutureBuilder<int>(
      key: ValueKey('$epoch-$jarId'),
      future: ref.read(databaseProvider).dreamDao.sumDeposits(jar.id),
      builder: (context, snap) {
        final balance = snap.data ?? 0;

        return HiveCard(
          radius: 16,
          padding: const EdgeInsets.fromLTRB(16, 15, 16, 15),
          onTap: () => context.push('/dream/${jar.id}'),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      jar.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: HiveColors.ink,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      '账户 · 无目标',
                      style: TextStyle(
                        fontSize: 12,
                        color: HiveColors.dim,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                formatYuan(balance),
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: HiveColors.ink,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

DreamJar? _findJar(WidgetRef ref, String jarId) {
  final jars = ref.watch(dreamJarsProvider).valueOrNull ?? [];
  for (final jar in jars) {
    if (jar.id == jarId) return jar;
  }
  return null;
}
