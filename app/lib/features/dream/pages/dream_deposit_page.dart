import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/dates.dart';
import '../../../shared/money.dart';
import '../../../shared/theme/hive_colors.dart';
import '../../../shared/widgets/hive_widgets.dart';
import '../providers/dream_providers.dart';

enum DreamDepositMode { deposit, withdraw }

class DreamDepositPage extends ConsumerStatefulWidget {
  const DreamDepositPage({
    super.key,
    required this.jarId,
    this.mode = DreamDepositMode.deposit,
  });

  final String jarId;
  final DreamDepositMode mode;

  @override
  ConsumerState<DreamDepositPage> createState() => _DreamDepositPageState();
}

class _DreamDepositPageState extends ConsumerState<DreamDepositPage> {
  final _formKey = GlobalKey<FormState>();
  final _amountCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();
  DateTime _date = DateTime.now();
  String _jarName = '';
  String _jarKind = 'goal';
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    _loadJar();
  }

  Future<void> _loadJar() async {
    final jar = await ref.read(dreamDaoProvider).getJar(widget.jarId);
    if (!mounted) return;
    if (widget.mode == DreamDepositMode.withdraw && jar?.kind != 'fund') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('储蓄罐不支持取出')),
      );
      context.pop();
      return;
    }
    setState(() {
      _jarName = jar?.name ?? '';
      _jarKind = jar?.kind ?? 'goal';
      _ready = true;
    });
  }

  String get _title {
    if (widget.mode == DreamDepositMode.withdraw) return '取出账户';
    return _jarKind == 'fund' ? '存入账户' : '存入储蓄罐';
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final amountCents = yuanToCents(num.parse(_amountCtrl.text.trim()));
    final date = formatDateYmd(_date);
    final note =
        _noteCtrl.text.trim().isEmpty ? null : _noteCtrl.text.trim();
    final service = ref.read(dreamServiceProvider);
    try {
      if (widget.mode == DreamDepositMode.withdraw) {
        await service.withdraw(
          jarId: widget.jarId,
          amountCents: amountCents,
          date: date,
          note: note,
        );
      } else {
        await service.deposit(
          jarId: widget.jarId,
          amountCents: amountCents,
          date: date,
          note: note,
        );
      }
      if (mounted) context.pop();
    } on StateError catch (e) {
      if (!mounted) return;
      final message = e.message == 'insufficient balance'
          ? '余额不足'
          : e.message;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
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
    if (!_ready) {
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
            HiveBackHeader(title: _title),
            Expanded(
              child: Form(
                key: _formKey,
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                  children: [
                    HiveFieldLabel(_jarKind == 'fund' ? '账户' : '储蓄罐'),
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
