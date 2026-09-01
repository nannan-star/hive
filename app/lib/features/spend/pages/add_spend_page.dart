import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../data/db/app_database.dart';
import '../../../data/providers.dart';
import '../../../shared/dates.dart';
import '../../../shared/money.dart';
import '../providers/spend_providers.dart';

class AddSpendPage extends ConsumerStatefulWidget {
  const AddSpendPage({super.key, this.categoryId});

  final String? categoryId;

  @override
  ConsumerState<AddSpendPage> createState() => _AddSpendPageState();
}

class _AddSpendPageState extends ConsumerState<AddSpendPage> {
  final _formKey = GlobalKey<FormState>();
  final _amountCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();
  DateTime _date = DateTime.now();
  String? _categoryId;
  List<Category> _categories = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _categoryId = widget.categoryId;
    _load();
  }

  Future<void> _load() async {
    final cats = await ref.read(categoriesDaoProvider).watchEnabled().first;
    if (!mounted) return;
    setState(() {
      _categories = cats;
      _categoryId ??= cats.isNotEmpty ? cats.first.id : null;
      _loading = false;
    });
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_categoryId == null) return;
    final dao = ref.read(databaseProvider).spendEntriesDao;
    await dao.insertEntry(
      categoryId: _categoryId!,
      amountCents: yuanToCents(num.parse(_amountCtrl.text.trim())),
      date: formatDateYmd(_date),
      note: _noteCtrl.text.trim().isEmpty ? null : _noteCtrl.text.trim(),
      source: 'manual',
      status: 'confirmed',
    );
    if (mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('记一笔')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            DropdownButtonFormField<String>(
              value: _categoryId,
              decoration: const InputDecoration(labelText: '分类'),
              items: [
                for (final c in _categories)
                  DropdownMenuItem(value: c.id, child: Text(c.name)),
              ],
              onChanged: (v) => setState(() => _categoryId = v),
              validator: (v) => v == null ? '请选择分类' : null,
            ),
            TextFormField(
              controller: _amountCtrl,
              decoration: const InputDecoration(labelText: '金额（元）'),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              validator: (v) {
                final n = num.tryParse(v ?? '');
                if (n == null || n <= 0) return '请输入有效金额';
                return null;
              },
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('日期'),
              subtitle: Text(formatDateYmd(_date)),
              trailing: const Icon(Icons.calendar_today),
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
            TextFormField(
              controller: _noteCtrl,
              decoration: const InputDecoration(labelText: '备注（可选）'),
            ),
            const SizedBox(height: 24),
            FilledButton(onPressed: _save, child: const Text('保存')),
          ],
        ),
      ),
    );
  }
}
