import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/dates.dart';
import '../../../shared/money.dart';
import '../../../shared/theme/hive_colors.dart';
import '../../../shared/widgets/hive_widgets.dart';
import '../providers/dream_providers.dart';

class DreamDepositPage extends ConsumerStatefulWidget {
  const DreamDepositPage({super.key, required this.jarId});

  final String jarId;

  @override
  ConsumerState<DreamDepositPage> createState() => _DreamDepositPageState();
}

class _DreamDepositPageState extends ConsumerState<DreamDepositPage> {
  final _formKey = GlobalKey<FormState>();
  final _amountCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();
  DateTime _date = DateTime.now();
  String _jarName = '';

  @override
  void initState() {
    super.initState();
    _loadJar();
  }

  Future<void> _loadJar() async {
    final jar = await ref.read(dreamDaoProvider).getJar(widget.jarId);
    if (!mounted) return;
    setState(() => _jarName = jar?.name ?? '');
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    await ref.read(dreamDaoProvider).insertDeposit(
          jarId: widget.jarId,
          amountCents: yuanToCents(num.parse(_amountCtrl.text.trim())),
          date: formatDateYmd(_date),
          note: _noteCtrl.text.trim().isEmpty ? null : _noteCtrl.text.trim(),
        );
    if (mounted) context.pop();
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
    return Scaffold(
      backgroundColor: HiveColors.page,
      body: SafeArea(
        child: Column(
          children: [
            const HiveBackHeader(title: '存入梦想'),
            Expanded(
              child: Form(
                key: _formKey,
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                  children: [
                    const HiveFieldLabel('罐子'),
                    _ReadBox(value: _jarName.isEmpty ? '…' : _jarName),
                    const SizedBox(height: 16),
                    const HiveFieldLabel('金额'),
                    TextFormField(
                      controller: _amountCtrl,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: const InputDecoration(prefixText: '¥'),
                      validator: (v) {
                        final n = num.tryParse(v ?? '');
                        if (n == null || n <= 0) return '请输入有效金额';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    const HiveFieldLabel('日期'),
                    Material(
                      color: HiveColors.card,
                      borderRadius: BorderRadius.circular(14),
                      child: InkWell(
                        onTap: _pickDate,
                        borderRadius: BorderRadius.circular(14),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 13,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: HiveColors.border),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  formatDateYmd(_date),
                                  style: const TextStyle(
                                    fontSize: 15,
                                    color: HiveColors.ink,
                                  ),
                                ),
                              ),
                              const Text(
                                '⌄',
                                style: TextStyle(
                                  fontSize: 15,
                                  color: HiveColors.dim,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const HiveFieldLabel('备注'),
                    TextFormField(
                      controller: _noteCtrl,
                      minLines: 3,
                      maxLines: 4,
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

class _ReadBox extends StatelessWidget {
  const _ReadBox({required this.value});

  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      decoration: BoxDecoration(
        color: HiveColors.card,
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
    );
  }
}
