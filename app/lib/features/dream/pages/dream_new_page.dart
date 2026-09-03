import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/money.dart';
import '../../../shared/theme/hive_colors.dart';
import '../../../shared/widgets/hive_widgets.dart';
import '../providers/dream_providers.dart';

class DreamTypePickPage extends ConsumerWidget {
  const DreamTypePickPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: HiveColors.page,
      body: SafeArea(
        child: Column(
          children: [
            const HiveBackHeader(title: '新建'),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                children: [
                  const Text(
                    '选择类型，与消费分账。',
                    style: TextStyle(
                      fontSize: 12,
                      height: 1.45,
                      color: HiveColors.muted,
                    ),
                  ),
                  const SizedBox(height: 16),
                  HiveCard(
                    radius: 16,
                    padding: const EdgeInsets.fromLTRB(16, 15, 16, 15),
                    onTap: () => context.push('/dream/new/goal'),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '储蓄罐',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: HiveColors.ink,
                          ),
                        ),
                        SizedBox(height: 6),
                        Text(
                          '有目标金额，只存不取，可标记完成。',
                          style: TextStyle(
                            fontSize: 12,
                            height: 1.45,
                            color: HiveColors.dim,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  HiveCard(
                    radius: 16,
                    padding: const EdgeInsets.fromLTRB(16, 15, 16, 15),
                    onTap: () => context.push('/dream/new/fund'),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '账户',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: HiveColors.ink,
                          ),
                        ),
                        SizedBox(height: 6),
                        Text(
                          '无目标，可存可取；取出不可超余额。',
                          style: TextStyle(
                            fontSize: 12,
                            height: 1.45,
                            color: HiveColors.dim,
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
  }
}

class DreamGoalNewPage extends ConsumerStatefulWidget {
  const DreamGoalNewPage({super.key});

  @override
  ConsumerState<DreamGoalNewPage> createState() => _DreamGoalNewPageState();
}

class _DreamGoalNewPageState extends ConsumerState<DreamGoalNewPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _targetCtrl = TextEditingController();

  @override
  void dispose() {
    _nameCtrl.dispose();
    _targetCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    await ref.read(dreamDaoProvider).insertJar(
          name: _nameCtrl.text.trim(),
          targetCents: yuanToCents(num.parse(_targetCtrl.text.trim())),
        );
    ref.read(freeKindFilterProvider.notifier).state = 'goal';
    if (mounted) context.go('/dream');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HiveColors.page,
      body: SafeArea(
        child: Column(
          children: [
            const HiveBackHeader(title: '新建储蓄罐'),
            Expanded(
              child: Form(
                key: _formKey,
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                  children: [
                    const HiveFieldLabel('名称'),
                    TextFormField(
                      controller: _nameCtrl,
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? '请输入名称' : null,
                    ),
                    const SizedBox(height: 16),
                    const HiveFieldLabel('目标金额'),
                    TextFormField(
                      controller: _targetCtrl,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: const InputDecoration(prefixText: '¥'),
                      validator: (v) {
                        final n = num.tryParse(v ?? '');
                        if (n == null || n <= 0) return '请输入有效目标';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    HivePrimaryButton(label: '保存', onPressed: _save),
                    HiveTextAction(
                      label: '取消',
                      onPressed: () => context.pop(),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DreamFundNewPage extends ConsumerStatefulWidget {
  const DreamFundNewPage({super.key});

  @override
  ConsumerState<DreamFundNewPage> createState() => _DreamFundNewPageState();
}

class _DreamFundNewPageState extends ConsumerState<DreamFundNewPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    await ref.read(dreamServiceProvider).createFund(
          name: _nameCtrl.text.trim(),
        );
    ref.read(freeKindFilterProvider.notifier).state = 'fund';
    if (mounted) context.go('/dream');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HiveColors.page,
      body: SafeArea(
        child: Column(
          children: [
            const HiveBackHeader(title: '新建账户'),
            Expanded(
              child: Form(
                key: _formKey,
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                  children: [
                    const HiveFieldLabel('名称'),
                    TextFormField(
                      controller: _nameCtrl,
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? '请输入名称' : null,
                    ),
                    const SizedBox(height: 16),
                    HivePrimaryButton(label: '保存', onPressed: _save),
                    HiveTextAction(
                      label: '取消',
                      onPressed: () => context.pop(),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
