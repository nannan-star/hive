import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../data/db/app_database.dart';
import '../../../data/providers.dart';
import '../../../shared/dates.dart';
import '../../../shared/money.dart';
import '../../../shared/theme/hive_colors.dart';
import '../../../shared/widgets/hive_widgets.dart';
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

  String get _categoryName {
    for (final c in _categories) {
      if (c.id == _categoryId) return c.name;
    }
    return '请选择';
  }

  Future<void> _pickCategory() async {
    if (_categories.isEmpty) return;
    final picked = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: HiveColors.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '选择分类',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: HiveColors.ink,
                  ),
                ),
              ),
            ),
            for (final c in _categories)
              ListTile(
                title: Text(c.name),
                trailing: c.id == _categoryId
                    ? const Icon(Icons.check, color: HiveColors.accent)
                    : null,
                onTap: () => Navigator.pop(ctx, c.id),
              ),
          ],
        ),
      ),
    );
    if (picked != null) setState(() => _categoryId = picked);
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _date = picked);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        backgroundColor: HiveColors.page,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: HiveColors.page,
      body: SafeArea(
        child: Column(
          children: [
            const HiveBackHeader(title: '记一笔消费'),
            Expanded(
              child: Form(
                key: _formKey,
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                  children: [
                    const HiveFieldLabel('分类'),
                    _PickerBox(
                      value: _categoryName,
                      onTap: _pickCategory,
                    ),
                    const SizedBox(height: 16),
                    const HiveFieldLabel('金额'),
                    TextFormField(
                      controller: _amountCtrl,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      style: const TextStyle(
                        fontSize: 15,
                        color: HiveColors.ink,
                      ),
                      decoration: const InputDecoration(
                        prefixText: '¥',
                      ),
                      validator: (v) {
                        final n = num.tryParse(v ?? '');
                        if (n == null || n <= 0) return '请输入有效金额';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    const HiveFieldLabel('日期'),
                    _PickerBox(
                      value: formatDateYmd(_date),
                      onTap: _pickDate,
                    ),
                    const SizedBox(height: 16),
                    const HiveFieldLabel('备注'),
                    TextFormField(
                      controller: _noteCtrl,
                      minLines: 3,
                      maxLines: 4,
                      style: const TextStyle(
                        fontSize: 15,
                        color: HiveColors.ink,
                      ),
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

class _PickerBox extends StatelessWidget {
  const _PickerBox({required this.value, required this.onTap});

  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: HiveColors.card,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: HiveColors.border),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  value,
                  style: const TextStyle(fontSize: 15, color: HiveColors.ink),
                ),
              ),
              const Text(
                '⌄',
                style: TextStyle(fontSize: 15, color: HiveColors.dim),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
