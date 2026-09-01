import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/money.dart';
import '../../../shared/theme/hive_colors.dart';
import '../../../shared/widgets/hive_widgets.dart';
import '../providers/dream_providers.dart';

class DreamNewPage extends ConsumerStatefulWidget {
  const DreamNewPage({super.key});

  @override
  ConsumerState<DreamNewPage> createState() => _DreamNewPageState();
}

class _DreamNewPageState extends ConsumerState<DreamNewPage> {
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
    final id = await ref.read(dreamDaoProvider).insertJar(
          name: _nameCtrl.text.trim(),
          targetCents: yuanToCents(num.parse(_targetCtrl.text.trim())),
        );
    if (mounted) context.go('/dream/$id');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HiveColors.page,
      body: SafeArea(
        child: Column(
          children: [
            const HiveBackHeader(title: '新建罐子'),
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
