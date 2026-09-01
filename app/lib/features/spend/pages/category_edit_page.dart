import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../data/db/app_database.dart';
import '../../../shared/money.dart';
import '../providers/spend_providers.dart';

class CategoryEditPage extends ConsumerStatefulWidget {
  const CategoryEditPage({super.key, this.categoryId});

  final String? categoryId;

  bool get isEditing => categoryId != null;

  @override
  ConsumerState<CategoryEditPage> createState() => _CategoryEditPageState();
}

class _CategoryEditPageState extends ConsumerState<CategoryEditPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _sortCtrl = TextEditingController(text: '1');
  final _amountCtrl = TextEditingController();
  final _dayCtrl = TextEditingController(text: '1');
  final _noteCtrl = TextEditingController();

  bool _enabled = true;
  bool _templateEnabled = false;
  bool _loading = true;
  Category? _existing;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (!widget.isEditing) {
      setState(() => _loading = false);
      return;
    }
    final cat =
        await ref.read(categoriesDaoProvider).getById(widget.categoryId!);
    if (!mounted) return;
    if (cat == null) {
      setState(() => _loading = false);
      return;
    }
    _existing = cat;
    _nameCtrl.text = cat.name;
    _sortCtrl.text = '${cat.sortOrder}';
    _enabled = cat.enabled;
    _templateEnabled = cat.templateEnabled;
    if (cat.templateDefaultAmount != null) {
      _amountCtrl.text = centsToYuan(cat.templateDefaultAmount!).toString();
    }
    _dayCtrl.text = '${cat.templateDay}';
    _noteCtrl.text = cat.templateDefaultNote ?? '';
    setState(() => _loading = false);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _sortCtrl.dispose();
    _amountCtrl.dispose();
    _dayCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final dao = ref.read(categoriesDaoProvider);
    final name = _nameCtrl.text.trim();
    final sort = int.parse(_sortCtrl.text.trim());
    final day = int.parse(_dayCtrl.text.trim());
    final amount = _templateEnabled
        ? yuanToCents(num.parse(_amountCtrl.text.trim()))
        : null;
    final note = _noteCtrl.text.trim().isEmpty ? null : _noteCtrl.text.trim();

    if (widget.isEditing) {
      await dao.updateCategory(
        id: widget.categoryId!,
        name: name,
        sortOrder: sort,
        enabled: _enabled,
        templateEnabled: _templateEnabled,
        templateDefaultAmount: amount,
        templateDefaultNote: note,
        templateDay: day,
      );
    } else {
      await dao.insertCategory(
        name: name,
        sortOrder: sort,
        enabled: _enabled,
        templateEnabled: _templateEnabled,
        templateDefaultAmount: amount,
        templateDefaultNote: note,
        templateDay: day,
      );
    }
    if (mounted) context.pop();
  }

  Future<void> _disable() async {
    await ref.read(categoriesDaoProvider).setEnabled(widget.categoryId!, false);
    if (mounted) context.pop();
  }

  Future<void> _delete() async {
    final ok =
        await ref.read(categoriesDaoProvider).deleteIfNoEntries(widget.categoryId!);
    if (!mounted) return;
    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('已有消费记录，无法删除，请改用停用')),
      );
      return;
    }
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditing ? '编辑分类' : '新建分类'),
      ),
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
              controller: _sortCtrl,
              decoration: const InputDecoration(labelText: '排序（越小越前）'),
              keyboardType: TextInputType.number,
              validator: (v) {
                final n = int.tryParse(v ?? '');
                if (n == null) return '请输入数字';
                return null;
              },
            ),
            SwitchListTile(
              title: const Text('启用'),
              value: _enabled,
              onChanged: (v) => setState(() => _enabled = v),
            ),
            SwitchListTile(
              title: const Text('开启月度模板'),
              value: _templateEnabled,
              onChanged: (v) => setState(() => _templateEnabled = v),
            ),
            if (_templateEnabled) ...[
              TextFormField(
                controller: _amountCtrl,
                decoration: const InputDecoration(labelText: '默认金额（元）'),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                validator: (v) {
                  if (!_templateEnabled) return null;
                  final n = num.tryParse(v ?? '');
                  if (n == null || n <= 0) return '模板开启时金额须大于 0';
                  return null;
                },
              ),
              TextFormField(
                controller: _dayCtrl,
                decoration: const InputDecoration(labelText: '生成日（1–28）'),
                keyboardType: TextInputType.number,
                validator: (v) {
                  final n = int.tryParse(v ?? '');
                  if (n == null || n < 1 || n > 28) return '请输入 1–28';
                  return null;
                },
              ),
              TextFormField(
                controller: _noteCtrl,
                decoration: const InputDecoration(labelText: '默认备注（可选）'),
              ),
            ],
            const SizedBox(height: 24),
            FilledButton(onPressed: _save, child: const Text('保存')),
            if (widget.isEditing && (_existing?.enabled ?? false)) ...[
              const SizedBox(height: 8),
              OutlinedButton(
                onPressed: _disable,
                child: const Text('停用此分类'),
              ),
            ],
            if (widget.isEditing) ...[
              const SizedBox(height: 8),
              TextButton(
                onPressed: _delete,
                child: const Text('删除'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
