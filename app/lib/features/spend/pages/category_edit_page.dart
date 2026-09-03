import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../data/db/app_database.dart';
import '../../../shared/money.dart';
import '../../../shared/theme/hive_colors.dart';
import '../../../shared/widgets/hive_widgets.dart';
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
  bool _busy = false;
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
    if (_busy || !widget.isEditing) return;
    setState(() => _busy = true);
    final id = widget.categoryId!;
    final dao = ref.read(categoriesDaoProvider);
    final name = _existing?.name ?? _nameCtrl.text.trim();
    try {
      final n = await dao.countEntries(id);
      if (!mounted) return;

      final confirmed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('删除分类'),
          content: Text(
            '将删除「$name」及其下全部消费记录（共 $n 笔），且不可恢复',
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
      if (confirmed != true || !mounted) {
        if (mounted) setState(() => _busy = false);
        return;
      }

      final still = await dao.getById(id);
      if (still == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('分类已不存在')),
          );
          context.pop();
        }
        return;
      }
      await dao.deleteCategoryCascade(id);
      if (mounted) context.pop();
    } catch (_) {
      if (mounted) {
        setState(() => _busy = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('删除失败，请重试')),
        );
      }
    }
  }

  InputDecoration _innerDeco() {
    return InputDecoration(
      filled: true,
      fillColor: HiveColors.page,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: HiveColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: HiveColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: HiveColors.accent),
      ),
    );
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
            HiveBackHeader(
              title: widget.isEditing ? '编辑分类' : '新建分类',
            ),
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
                    const HiveFieldLabel('排序（数字越小越靠前）'),
                    TextFormField(
                      controller: _sortCtrl,
                      keyboardType: TextInputType.number,
                      validator: (v) {
                        final n = int.tryParse(v ?? '');
                        if (n == null) return '请输入数字';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    HiveCard(
                      radius: 16,
                      padding: const EdgeInsets.fromLTRB(16, 15, 16, 15),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '月度模板',
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w500,
                                        color: HiveColors.ink,
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      '每月自动生成 1 条待确认',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: HiveColors.dim,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Switch(
                                value: _templateEnabled,
                                onChanged: (v) =>
                                    setState(() => _templateEnabled = v),
                              ),
                            ],
                          ),
                          if (_templateEnabled) ...[
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 14),
                              child: Divider(height: 1, color: HiveColors.border),
                            ),
                            const HiveFieldLabel('默认金额（元）', small: true),
                            TextFormField(
                              controller: _amountCtrl,
                              decoration: _innerDeco(),
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                decimal: true,
                              ),
                              validator: (v) {
                                if (!_templateEnabled) return null;
                                final n = num.tryParse(v ?? '');
                                if (n == null || n <= 0) {
                                  return '模板开启时金额须大于 0';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 12),
                            const HiveFieldLabel(
                              '生成日（每月几号，1–28）',
                              small: true,
                            ),
                            TextFormField(
                              controller: _dayCtrl,
                              decoration: _innerDeco(),
                              keyboardType: TextInputType.number,
                              validator: (v) {
                                final n = int.tryParse(v ?? '');
                                if (n == null || n < 1 || n > 28) {
                                  return '请输入 1–28';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 12),
                            const HiveFieldLabel('默认备注（可选）', small: true),
                            TextFormField(
                              controller: _noteCtrl,
                              decoration: _innerDeco(),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    HivePrimaryButton(label: '保存', onPressed: _save),
                    if (widget.isEditing && (_existing?.enabled ?? false))
                      HiveTextAction(
                        label: '停用此分类',
                        danger: true,
                        onPressed: _disable,
                      ),
                    if (widget.isEditing)
                      HiveTextAction(
                        label: '删除此分类',
                        danger: true,
                        onPressed: _busy ? null : _delete,
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
