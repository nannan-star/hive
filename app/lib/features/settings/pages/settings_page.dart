import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../data/providers.dart';
import '../../../shared/theme/hive_colors.dart';
import '../../../shared/widgets/hive_widgets.dart';
import '../services/backup_service.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  bool _busy = false;

  BackupService get _backup => BackupService(ref.read(databaseProvider));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HiveColors.page,
      body: SafeArea(
        child: Column(
          children: [
            const HiveBackHeader(title: '设置'),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                children: [
                  HiveCard(
                    child: Column(
                      children: [
                        _SettingsTile(
                          title: '导出备份',
                          subtitle: '存到文件或发给自己',
                          showDivider: false,
                          onTap: _busy ? null : _export,
                        ),
                        _SettingsTile(
                          title: '从备份恢复',
                          subtitle: '将完全替换当前数据',
                          showDivider: true,
                          onTap: _busy ? null : _import,
                        ),
                        _SettingsTile(
                          title: '家人权限',
                          subtitle: '后续版本 · 当前仅自己',
                          showDivider: true,
                          onTap: () => _snack('第一期占位，功能即将推出'),
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

  Future<void> _export() async {
    setState(() => _busy = true);
    try {
      final json = await _backup.exportJson();
      final name =
          'hive-backup-${DateFormat('yyyyMMdd-HHmm').format(DateTime.now())}.json';
      final file = File(p.join((await getTemporaryDirectory()).path, name));
      await file.writeAsString(json);
      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path, mimeType: 'application/json')],
        ),
      );
    } catch (_) {
      _snack('导出失败，请重试');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _import() async {
    setState(() => _busy = true);
    try {
      final picked = await FilePicker.pickFile(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );
      if (picked == null) return;
      if (!mounted) return;

      final bytes = await _readPickedBytes(picked);
      final String source;
      try {
        source = utf8.decode(bytes);
      } on FormatException {
        throw BackupException(BackupErrorCode.unreadable);
      }
      final payload = _backup.parse(source);
      if (!mounted) return;

      final date =
          DateFormat('yyyy-MM-dd').format(payload.exportedAt.toLocal());
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('从备份恢复'),
          content: Text(
            '将用 $date 的备份完全替换当前数据（分类 ${payload.categories.length}、'
            '记账 ${payload.spendEntries.length}、梦想罐 ${payload.dreamJars.length}）。'
            '此操作无法撤销。',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text(
                '替换',
                style: TextStyle(color: HiveColors.danger),
              ),
            ),
          ],
        ),
      );
      if (confirmed != true) return;

      final epoch = ref.read(backupRestoreEpochProvider.notifier);
      await _backup.restore(payload);
      epoch.state++;
      if (!mounted) return;
      _snack('已从备份恢复');
    } on BackupException catch (e) {
      _snack(_message(e));
    } catch (_) {
      _snack('恢复失败，当前数据未改动');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<Uint8List> _readPickedBytes(PlatformFile file) async {
    try {
      return await file.readAsBytes();
    } catch (_) {
      final path = file.path;
      if (path == null) {
        throw BackupException(BackupErrorCode.unreadable);
      }
      try {
        return await File(path).readAsBytes();
      } catch (_) {
        throw BackupException(BackupErrorCode.unreadable);
      }
    }
  }

  String _message(BackupException e) {
    switch (e.code) {
      case BackupErrorCode.unreadable:
      case BackupErrorCode.notHive:
      case BackupErrorCode.invalidPayload:
      case BackupErrorCode.brokenReferences:
        return '无法识别这份备份';
      case BackupErrorCode.unsupportedFormat:
      case BackupErrorCode.schemaMismatch:
        return '备份版本不兼容';
      case BackupErrorCode.io:
        return '恢复失败，当前数据未改动';
    }
  }

  void _snack(String text) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.title,
    required this.subtitle,
    required this.showDivider,
    this.onTap,
  });

  final String title;
  final String subtitle;
  final bool showDivider;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
        decoration: BoxDecoration(
          border: showDivider
              ? const Border(top: BorderSide(color: HiveColors.border))
              : null,
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: onTap == null ? HiveColors.dim : HiveColors.ink,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: HiveColors.dim,
                    ),
                  ),
                ],
              ),
            ),
            const Text(
              '›',
              style: TextStyle(fontSize: 18, color: HiveColors.dim),
            ),
          ],
        ),
      ),
    );
  }
}
