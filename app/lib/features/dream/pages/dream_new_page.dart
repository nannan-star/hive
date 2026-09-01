import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/money.dart';
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
      appBar: AppBar(title: const Text('新建梦想罐')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nameCtrl,
              decoration: const InputDecoration(labelText: '名称'),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? '请输入名称' : null,
            ),
            TextFormField(
              controller: _targetCtrl,
              decoration: const InputDecoration(labelText: '目标金额（元）'),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              validator: (v) {
                final n = num.tryParse(v ?? '');
                if (n == null || n <= 0) return '请输入有效目标';
                return null;
              },
            ),
            const SizedBox(height: 24),
            FilledButton(onPressed: _save, child: const Text('创建')),
          ],
        ),
      ),
    );
  }
}
