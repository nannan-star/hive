# Hive 本地 JSON 备份导出 / 导入 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 把设置里的「导出备份 / 从备份恢复」从占位做成可用的整库 JSON 备份：系统分享导出，选文件覆盖导入。

**Architecture:** `BackupService` 只吃 `AppDatabase`，负责拼 JSON、校验、事务覆盖。设置页负责临时文件、`share_plus`、`file_picker`、确认框。恢复成功后递增 `backupRestoreEpochProvider`，让消费/梦想页上的 `FutureBuilder` 重新拉数。不改表结构、不加路由、不做云同步。

**Tech Stack:** Flutter / Dart，Drift，Riverpod，`share_plus`，`file_picker`，`path_provider`（已有），`intl`（已有）。

**Spec:** `@docs/superpowers/specs/2026-09-01-hive-backup-export-import-design.md`

---

## File map

| 路径 | 职责 |
|---|---|
| Create: `app/lib/features/settings/services/backup_service.dart` | 导出 JSON、parse 校验、restore 事务 |
| Create: `app/test/backup_service_test.dart` | 内存库 round-trip / 覆盖 / 校验失败 |
| Modify: `app/lib/data/providers.dart` | `backupRestoreEpochProvider` |
| Modify: `app/lib/features/settings/pages/settings_page.dart` | 分享、选文件、确认、busy |
| Modify: `app/lib/features/spend/pages/spend_home_page.dart` | FutureBuilder 带上 epoch |
| Modify: `app/lib/features/spend/pages/category_detail_page.dart` | 同上 |
| Modify: `app/lib/features/dream/pages/dream_home_page.dart` | 同上 |
| Modify: `app/lib/features/dream/pages/dream_detail_page.dart` | 同上 |
| Modify: `app/pubspec.yaml` | `share_plus`、`file_picker` |
| Modify: `app/android/app/src/main/AndroidManifest.xml` | 分享用 `<queries>` |

不改 `tables.dart`、DAO、`schemaVersion`（保持 1）。

工作目录：所有 `flutter` 命令在 `app/` 下跑。

---

### Task 1: BackupService（导出 / 校验 / 覆盖）

**Files:**
- Create: `app/test/backup_service_test.dart`
- Create: `app/lib/features/settings/services/backup_service.dart`

- [ ] **Step 1: 写失败测试**

创建 `app/test/backup_service_test.dart`：

```dart
import 'dart:convert';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_app/data/db/app_database.dart';
import 'package:hive_app/features/settings/services/backup_service.dart';

void main() {
  late AppDatabase db;
  late BackupService backup;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    backup = BackupService(db);
  });

  tearDown(() async {
    await db.close();
  });

  Future<void> seedSample(AppDatabase target) async {
    await target.into(target.categories).insert(
          CategoriesCompanion.insert(
            id: 'cat-1',
            name: '停车费',
            sortOrder: 1,
            templateEnabled: const Value(true),
            templateDefaultAmount: const Value(50000),
            createdAt: 1000,
          ),
        );
    await target.into(target.spendEntries).insert(
          SpendEntriesCompanion.insert(
            id: 'sp-1',
            categoryId: 'cat-1',
            amountCents: 50000,
            date: '2026-09-01',
            source: 'manual',
            status: 'confirmed',
            createdAt: 2000,
          ),
        );
    await target.into(target.dreamJars).insert(
          DreamJarsCompanion.insert(
            id: 'jar-1',
            name: '旅行',
            targetCents: 100000,
            status: 'active',
            createdAt: 3000,
          ),
        );
    await target.into(target.dreamDeposits).insert(
          DreamDepositsCompanion.insert(
            id: 'dep-1',
            jarId: 'jar-1',
            amountCents: 10000,
            date: '2026-09-01',
            createdAt: 4000,
          ),
        );
  }

  test('export then restore into empty db keeps all fields', () async {
    await seedSample(db);
    final json = await backup.exportJson();
    final payload = backup.parse(json);

    final empty = AppDatabase(NativeDatabase.memory());
    addTearDown(empty.close);
    await BackupService(empty).restore(payload);

    final cats = await empty.select(empty.categories).get();
    final spends = await empty.select(empty.spendEntries).get();
    final jars = await empty.select(empty.dreamJars).get();
    final deps = await empty.select(empty.dreamDeposits).get();

    expect(cats, hasLength(1));
    expect(cats.single.id, 'cat-1');
    expect(cats.single.name, '停车费');
    expect(cats.single.templateDefaultAmount, 50000);
    expect(spends.single.amountCents, 50000);
    expect(spends.single.date, '2026-09-01');
    expect(jars.single.id, 'jar-1');
    expect(deps.single.jarId, 'jar-1');
    expect(jsonDecode(json)['app'], 'hive');
    expect(jsonDecode(json)['schemaVersion'], 1);
    expect(jsonDecode(json)['categories'][0]['note'], isNull);
  });

  test('restore replaces existing rows', () async {
    await seedSample(db);
    final payload = backup.parse(await backup.exportJson());

    final other = AppDatabase(NativeDatabase.memory());
    addTearDown(other.close);
    await other.into(other.categories).insert(
          CategoriesCompanion.insert(
            id: 'old-cat',
            name: '旧分类',
            sortOrder: 9,
            createdAt: 1,
          ),
        );

    await BackupService(other).restore(payload);

    final cats = await other.select(other.categories).get();
    expect(cats, hasLength(1));
    expect(cats.single.id, 'cat-1');
    expect(await other.select(other.spendEntries).get(), hasLength(1));
  });

  test('parse rejects bad files with expected codes', () {
    expect(
      () => backup.parse('not-json'),
      throwsA(isA<BackupException>()
          .having((e) => e.code, 'code', BackupErrorCode.unreadable)),
    );
    expect(
      () => backup.parse('{"app":"other","formatVersion":1,"schemaVersion":1,'
          '"exportedAt":"2026-09-01T00:00:00.000Z","categories":[],'
          '"spendEntries":[],"dreamJars":[],"dreamDeposits":[]}'),
      throwsA(isA<BackupException>()
          .having((e) => e.code, 'code', BackupErrorCode.notHive)),
    );
    expect(
      () => backup.parse('{"app":"hive","formatVersion":2,"schemaVersion":1,'
          '"exportedAt":"2026-09-01T00:00:00.000Z","categories":[],'
          '"spendEntries":[],"dreamJars":[],"dreamDeposits":[]}'),
      throwsA(isA<BackupException>()
          .having((e) => e.code, 'code', BackupErrorCode.unsupportedFormat)),
    );
    expect(
      () => backup.parse('{"app":"hive","formatVersion":1,"schemaVersion":99,'
          '"exportedAt":"2026-09-01T00:00:00.000Z","categories":[],'
          '"spendEntries":[],"dreamJars":[],"dreamDeposits":[]}'),
      throwsA(isA<BackupException>()
          .having((e) => e.code, 'code', BackupErrorCode.schemaMismatch)),
    );
    expect(
      () => backup.parse('{"app":"hive","formatVersion":1,"schemaVersion":1,'
          '"exportedAt":"2026-09-01T00:00:00.000Z","categories":[],'
          '"spendEntries":[{"id":"sp-1","categoryId":"missing","amountCents":1,'
          '"date":"2026-09-01","source":"manual","status":"confirmed",'
          '"createdAt":1}],"dreamJars":[],"dreamDeposits":[]}'),
      throwsA(isA<BackupException>()
          .having((e) => e.code, 'code', BackupErrorCode.brokenReferences)),
    );
    expect(
      () => backup.parse('{"app":"hive","formatVersion":1,"schemaVersion":1,'
          '"exportedAt":"2026-09-01T00:00:00.000Z","categories":['
          '{"id":"a","name":"x","sortOrder":1,"enabled":true,'
          '"templateEnabled":false,"templateDay":1,"createdAt":1},'
          '{"id":"a","name":"y","sortOrder":2,"enabled":true,'
          '"templateEnabled":false,"templateDay":1,"createdAt":2}'
          '],"spendEntries":[],"dreamJars":[],"dreamDeposits":[]}'),
      throwsA(isA<BackupException>()
          .having((e) => e.code, 'code', BackupErrorCode.invalidPayload)),
    );
  });
}
```

测试里 `CategoriesCompanion` 等来自 `app_database.dart` 的生成 part，需要：

```dart
import 'package:drift/drift.dart';
```

加在文件顶部（与 `Value(...)` 一起）。

- [ ] **Step 2: 跑测试，确认失败**

Run:

```bash
cd app && flutter test test/backup_service_test.dart
```

Expected: FAIL，编译错误 `backup_service.dart` 不存在，或 `BackupService` 未定义。

- [ ] **Step 3: 实现 BackupService**

创建 `app/lib/features/settings/services/backup_service.dart`：

```dart
import 'dart:convert';

import 'package:drift/drift.dart';

import '../../../data/db/app_database.dart';

enum BackupErrorCode {
  unreadable,
  notHive,
  unsupportedFormat,
  schemaMismatch,
  invalidPayload,
  brokenReferences,
  io,
}

class BackupException implements Exception {
  BackupException(this.code, [this.message]);

  final BackupErrorCode code;
  final String? message;

  @override
  String toString() => 'BackupException($code${message == null ? '' : ': $message'})';
}

class BackupPayload {
  const BackupPayload({
    required this.exportedAt,
    required this.categories,
    required this.spendEntries,
    required this.dreamJars,
    required this.dreamDeposits,
  });

  final DateTime exportedAt;
  final List<Category> categories;
  final List<SpendEntry> spendEntries;
  final List<DreamJar> dreamJars;
  final List<DreamDeposit> dreamDeposits;
}

class BackupService {
  BackupService(this.db);

  final AppDatabase db;

  static const formatVersion = 1;

  Future<String> exportJson() async {
    final categories = await db.select(db.categories).get();
    final spendEntries = await db.select(db.spendEntries).get();
    final dreamJars = await db.select(db.dreamJars).get();
    final dreamDeposits = await db.select(db.dreamDeposits).get();
    return jsonEncode({
      'app': 'hive',
      'formatVersion': formatVersion,
      'schemaVersion': db.schemaVersion,
      'exportedAt': DateTime.now().toUtc().toIso8601String(),
      'categories': categories.map((r) => r.toJson()).toList(),
      'spendEntries': spendEntries.map((r) => r.toJson()).toList(),
      'dreamJars': dreamJars.map((r) => r.toJson()).toList(),
      'dreamDeposits': dreamDeposits.map((r) => r.toJson()).toList(),
    });
  }

  BackupPayload parse(String source) {
    late final Object? decoded;
    try {
      decoded = jsonDecode(source);
    } on FormatException {
      throw BackupException(BackupErrorCode.unreadable);
    }
    if (decoded is! Map) {
      throw BackupException(BackupErrorCode.invalidPayload);
    }
    final map = Map<String, dynamic>.from(decoded);

    if (!map.containsKey('app')) {
      throw BackupException(BackupErrorCode.invalidPayload);
    }
    if (map['app'] != 'hive') {
      throw BackupException(BackupErrorCode.notHive);
    }
    if (!map.containsKey('formatVersion')) {
      throw BackupException(BackupErrorCode.invalidPayload);
    }
    if (map['formatVersion'] != formatVersion) {
      throw BackupException(BackupErrorCode.unsupportedFormat);
    }
    if (!map.containsKey('schemaVersion')) {
      throw BackupException(BackupErrorCode.invalidPayload);
    }
    if (map['schemaVersion'] != db.schemaVersion) {
      throw BackupException(BackupErrorCode.schemaMismatch);
    }

    final exportedAtRaw = map['exportedAt'];
    if (exportedAtRaw is! String) {
      throw BackupException(BackupErrorCode.invalidPayload);
    }
    final exportedAt = DateTime.tryParse(exportedAtRaw);
    if (exportedAt == null) {
      throw BackupException(BackupErrorCode.invalidPayload);
    }

    final categories = _parseCategories(_asMaps(map['categories']));
    final spendEntries = _parseSpends(_asMaps(map['spendEntries']));
    final dreamJars = _parseJars(_asMaps(map['dreamJars']));
    final dreamDeposits = _parseDeposits(_asMaps(map['dreamDeposits']));

    _assertUnique(categories.map((e) => e.id));
    _assertUnique(spendEntries.map((e) => e.id));
    _assertUnique(dreamJars.map((e) => e.id));
    _assertUnique(dreamDeposits.map((e) => e.id));

    final catIds = categories.map((e) => e.id).toSet();
    final jarIds = dreamJars.map((e) => e.id).toSet();
    for (final row in spendEntries) {
      if (!catIds.contains(row.categoryId)) {
        throw BackupException(BackupErrorCode.brokenReferences);
      }
    }
    for (final row in dreamDeposits) {
      if (!jarIds.contains(row.jarId)) {
        throw BackupException(BackupErrorCode.brokenReferences);
      }
    }

    return BackupPayload(
      exportedAt: exportedAt,
      categories: categories,
      spendEntries: spendEntries,
      dreamJars: dreamJars,
      dreamDeposits: dreamDeposits,
    );
  }

  Future<void> restore(BackupPayload payload) {
    return db.transaction(() async {
      await db.delete(db.dreamDeposits).go();
      await db.delete(db.spendEntries).go();
      await db.delete(db.dreamJars).go();
      await db.delete(db.categories).go();
      await db.batch((b) {
        b.insertAll(db.categories, payload.categories);
        b.insertAll(db.dreamJars, payload.dreamJars);
        b.insertAll(db.spendEntries, payload.spendEntries);
        b.insertAll(db.dreamDeposits, payload.dreamDeposits);
      });
    });
  }

  List<Map<String, dynamic>> _asMaps(dynamic raw) {
    if (raw is! List) {
      throw BackupException(BackupErrorCode.invalidPayload);
    }
    return [
      for (final item in raw)
        if (item is Map)
          Map<String, dynamic>.from(item)
        else
          throw BackupException(BackupErrorCode.invalidPayload),
    ];
  }

  void _assertUnique(Iterable<String> ids) {
    final seen = <String>{};
    for (final id in ids) {
      if (!seen.add(id)) {
        throw BackupException(BackupErrorCode.invalidPayload);
      }
    }
  }

  List<Category> _parseCategories(List<Map<String, dynamic>> rows) {
    return [
      for (final r in rows)
        Category(
          id: _reqString(r, 'id'),
          name: _reqString(r, 'name'),
          sortOrder: _reqInt(r, 'sortOrder'),
          enabled: _reqBool(r, 'enabled'),
          note: _optString(r, 'note'),
          templateEnabled: _reqBool(r, 'templateEnabled'),
          templateDefaultAmount: _optInt(r, 'templateDefaultAmount'),
          templateDefaultNote: _optString(r, 'templateDefaultNote'),
          templateDay: _reqInt(r, 'templateDay'),
          familyId: _optString(r, 'familyId'),
          memberId: _optString(r, 'memberId'),
          createdAt: _reqInt(r, 'createdAt'),
        ),
    ];
  }

  List<SpendEntry> _parseSpends(List<Map<String, dynamic>> rows) {
    return [
      for (final r in rows)
        SpendEntry(
          id: _reqString(r, 'id'),
          categoryId: _reqString(r, 'categoryId'),
          amountCents: _reqInt(r, 'amountCents'),
          date: _reqString(r, 'date'),
          note: _optString(r, 'note'),
          source: _reqString(r, 'source'),
          status: _reqString(r, 'status'),
          familyId: _optString(r, 'familyId'),
          memberId: _optString(r, 'memberId'),
          createdAt: _reqInt(r, 'createdAt'),
        ),
    ];
  }

  List<DreamJar> _parseJars(List<Map<String, dynamic>> rows) {
    return [
      for (final r in rows)
        DreamJar(
          id: _reqString(r, 'id'),
          name: _reqString(r, 'name'),
          targetCents: _reqInt(r, 'targetCents'),
          status: _reqString(r, 'status'),
          description: _optString(r, 'description'),
          familyId: _optString(r, 'familyId'),
          memberId: _optString(r, 'memberId'),
          createdAt: _reqInt(r, 'createdAt'),
        ),
    ];
  }

  List<DreamDeposit> _parseDeposits(List<Map<String, dynamic>> rows) {
    return [
      for (final r in rows)
        DreamDeposit(
          id: _reqString(r, 'id'),
          jarId: _reqString(r, 'jarId'),
          amountCents: _reqInt(r, 'amountCents'),
          date: _reqString(r, 'date'),
          note: _optString(r, 'note'),
          createdAt: _reqInt(r, 'createdAt'),
        ),
    ];
  }

  String _reqString(Map<String, dynamic> r, String key) {
    final v = r[key];
    if (v is! String) {
      throw BackupException(BackupErrorCode.invalidPayload);
    }
    return v;
  }

  String? _optString(Map<String, dynamic> r, String key) {
    final v = r[key];
    if (v == null) return null;
    if (v is! String) {
      throw BackupException(BackupErrorCode.invalidPayload);
    }
    return v;
  }

  int _reqInt(Map<String, dynamic> r, String key) {
    final v = r[key];
    if (v is! int) {
      throw BackupException(BackupErrorCode.invalidPayload);
    }
    return v;
  }

  int? _optInt(Map<String, dynamic> r, String key) {
    final v = r[key];
    if (v == null) return null;
    if (v is! int) {
      throw BackupException(BackupErrorCode.invalidPayload);
    }
    return v;
  }

  bool _reqBool(Map<String, dynamic> r, String key) {
    final v = r[key];
    if (v is! bool) {
      throw BackupException(BackupErrorCode.invalidPayload);
    }
    return v;
  }
}
```

`enabled` 在样本插入时用了表默认值。导出 JSON 里必须带 `enabled: true`。若 round-trip 测失败是缺 `enabled`，在 `seedSample` 里显式写 `enabled: const Value(true)`。

- [ ] **Step 4: 再跑测试，确认通过**

Run:

```bash
cd app && flutter test test/backup_service_test.dart
```

Expected: All tests passed.

若 `Value` 未导入，测试文件补 `import 'package:drift/drift.dart';`。

- [ ] **Step 5: Commit**

```bash
git add app/lib/features/settings/services/backup_service.dart app/test/backup_service_test.dart
git commit -m "$(cat <<'EOF'
feat: add JSON backup export and restore service

Serialize the four Drift tables into a versioned JSON payload and replace the whole database in one transaction after validation.
EOF
)"
```

---

### Task 2: 恢复后刷新 FutureBuilder

**Files:**
- Modify: `app/lib/data/providers.dart`
- Modify: `app/lib/features/spend/pages/spend_home_page.dart`
- Modify: `app/lib/features/spend/pages/category_detail_page.dart`
- Modify: `app/lib/features/dream/pages/dream_home_page.dart`
- Modify: `app/lib/features/dream/pages/dream_detail_page.dart`

消费首页、分类详情、梦想列表卡片、梦想详情用了 `FutureBuilder`，Drift `watch` 不会让它们重跑。加一个 epoch，设置页恢复成功后 +1。

- [ ] **Step 1: 在 `providers.dart` 增加 epoch**

`app/lib/data/providers.dart` 改为：

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'db/app_database.dart';

final databaseProvider = Provider<AppDatabase>((ref) {
  throw UnimplementedError(
    'databaseProvider must be overridden in main with a real AppDatabase',
  );
});

final backupRestoreEpochProvider = StateProvider<int>((ref) => 0);
```

- [ ] **Step 2: 四个页面的 FutureBuilder 带上 epoch**

`spend_home_page.dart` 的 `build` 里 `watch` epoch，主 `FutureBuilder` 的 key 从 `ValueKey(year)` 改为 `ValueKey('$year-$epoch')`。分类同比行组件是 `_CategoryYearTile`（不是 `_SpendRow`），给它的 `FutureBuilder<YoyResult>` 加 `key: ValueKey('$epoch-${category.id}-$year')`，并 `ref.watch(backupRestoreEpochProvider)`。

`category_detail_page.dart`：`final epoch = ref.watch(backupRestoreEpochProvider);`，FutureBuilder key 改为 `ValueKey('${widget.categoryId}-${widget.year}-$epoch')`。

`dream_home_page.dart` `_DreamCard`：`final epoch = ref.watch(backupRestoreEpochProvider);`，`FutureBuilder<int>` 加 `key: ValueKey('$epoch-$jarId')`。

`dream_detail_page.dart`：`final epoch = ref.watch(backupRestoreEpochProvider);`，给现有 `FutureBuilder` 加 `key: ValueKey('$epoch-${widget.jarId}')`。

四处都 `import '../../../data/providers.dart';`（spend_home 已有）。

- [ ] **Step 3: 确认分析通过**

Run:

```bash
cd app && dart analyze lib/data/providers.dart lib/features/spend/pages/spend_home_page.dart lib/features/spend/pages/category_detail_page.dart lib/features/dream/pages/dream_home_page.dart lib/features/dream/pages/dream_detail_page.dart
```

Expected: `No issues found!`（或仅既有 info，无 error）。

- [ ] **Step 4: Commit**

```bash
git add app/lib/data/providers.dart app/lib/features/spend/pages/spend_home_page.dart app/lib/features/spend/pages/category_detail_page.dart app/lib/features/dream/pages/dream_home_page.dart app/lib/features/dream/pages/dream_detail_page.dart
git commit -m "$(cat <<'EOF'
fix: rebuild spend and dream stats after backup restore

Watch a restore epoch in FutureBuilder keys so totals refresh when the database is replaced.
EOF
)"
```

---

### Task 3: 设置页接上导出 / 导入

**Files:**
- Modify: `app/pubspec.yaml`
- Modify: `app/lib/features/settings/pages/settings_page.dart`

- [ ] **Step 1: 加依赖**

Run:

```bash
cd app && flutter pub add share_plus file_picker
```

Expected: `pubspec.yaml` 出现 `share_plus`、`file_picker`，`flutter pub get` 成功。

- [ ] **Step 2: 重写设置页**

把 `settings_page.dart` 换成 `ConsumerStatefulWidget`。保留现有 `_SettingsTile` / `HiveCard` / `HiveBackHeader` 视觉。要点：

- 副标题：导出「存到文件或发给自己」；恢复「将完全替换当前数据」；家人权限不变。
- `_busy == true` 时两个备份入口 `onTap` 为 `null`（家人权限仍走占位 SnackBar）。
- 导出：`BackupService(ref.read(databaseProvider)).exportJson()` → 写入 `getTemporaryDirectory()`，文件名 `hive-backup-yyyyMMdd-HHmm.json`（`DateFormat('yyyyMMdd-HHmm')`，本地时间）→ `SharePlus.instance.share(ShareParams(files: [XFile(path, mimeType: 'application/json')]))`。`ShareResultStatus.dismissed` 不报错。其它异常 →「导出失败，请重试」。
- 导入：`FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['json'], withData: true)`。`null` 即取消。读 `files.single.bytes`，不要只用 `path`。`utf8.decode(bytes)` 后 `parse`。校验失败按码映射 SnackBar，不弹确认。
- 确认框：`AlertDialog`，正文  
  `将用 ${DateFormat('yyyy-MM-dd').format(payload.exportedAt.toLocal())} 的备份完全替换当前数据（分类 ${n}、记账 ${m}、梦想罐 ${k}）。此操作无法撤销。`  
  按钮「取消」「替换」（替换用 `HiveColors.danger`）。
- 确认后 `restore`；成功：`ref.read(backupRestoreEpochProvider.notifier).state++`，SnackBar「已从备份恢复」；失败：「恢复失败，当前数据未改动」。
- `parse` 的 `BackupException` 文案：

| code | 文案 |
|---|---|
| unreadable / notHive / invalidPayload / brokenReferences | 无法识别这份备份 |
| unsupportedFormat / schemaMismatch | 备份版本不兼容 |
| io | 导出：「导出失败，请重试」；恢复：「恢复失败，当前数据未改动」 |

完整页面实现：

```dart
import 'dart:convert';
import 'dart:io';

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
      final result = await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path, mimeType: 'application/json')],
        ),
      );
      if (result.status == ShareResultStatus.unavailable) {
        _snack('导出失败，请重试');
      }
    } catch (_) {
      _snack('导出失败，请重试');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _import() async {
    final picked = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
      withData: true,
    );
    if (picked == null || picked.files.isEmpty) return;

    setState(() => _busy = true);
    try {
      final file = picked.files.single;
      final bytes = file.bytes ??
          (file.path != null ? await File(file.path!).readAsBytes() : null);
      if (bytes == null) {
        throw BackupException(BackupErrorCode.unreadable);
      }
      final payload = _backup.parse(utf8.decode(bytes));
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

      await _backup.restore(payload);
      ref.read(backupRestoreEpochProvider.notifier).state++;
      _snack('已从备份恢复');
    } on BackupException catch (e) {
      _snack(_message(e));
    } catch (_) {
      _snack('恢复失败，当前数据未改动');
    } finally {
      if (mounted) setState(() => _busy = false);
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
```

若当前 `share_plus` 没有 `SharePlus.instance.share` / `ShareParams`，改用仍可用的 `Share.shareXFiles([XFile(...)])`，取消分享同样不当成失败。

- [ ] **Step 3: 分析 + 单测**

Run:

```bash
cd app && dart analyze lib/features/settings && flutter test test/backup_service_test.dart test/widget_test.dart
```

Expected: 无 error；测试通过。`widget_test` 仍只断言底栏。

- [ ] **Step 4: Commit**

```bash
git add app/pubspec.yaml app/pubspec.lock app/lib/features/settings/pages/settings_page.dart
git commit -m "$(cat <<'EOF'
feat: wire settings backup share and restore picker

Export a JSON backup through the system share sheet and restore by replacing the local database after confirmation.
EOF
)"
```

---

### Task 4: Android 分享可见性 + 验收

**Files:**
- Modify: `app/android/app/src/main/AndroidManifest.xml`

- [ ] **Step 1: 补分享 queries**

在现有 `<queries>` 里追加（保留原来的 `PROCESS_TEXT`）：

```xml
        <intent>
            <action android:name="android.intent.action.SEND"/>
            <data android:mimeType="*/*"/>
        </intent>
```

iOS 不注册自定义 URL scheme。`file_picker` / `share_plus` 若 `flutter run` 时提示还要改 Info.plist / FileProvider，只加插件文档要求的最小项。

- [ ] **Step 2: 全量测试**

Run:

```bash
cd app && flutter test
```

Expected: All tests passed.

- [ ] **Step 3: Commit**

```bash
git add app/android/app/src/main/AndroidManifest.xml
git commit -m "$(cat <<'EOF'
fix: allow Android share sheet to see SEND targets

Declare package-visibility queries so backup export can hand the JSON file to Files or other apps.
EOF
)"
```

- [ ] **Step 4: 人工验收（真机或模拟器）**

1. 记一笔 + 建一个梦想罐并存入。
2. 设置 → 导出备份 → 存到「文件」。
3. 设置 → 从备份恢复 → 选刚导出的文件 → 确认替换 → 出现「已从备份恢复」，消费/梦想数字与导出前一致。
4. 选一个乱 JSON →「无法识别这份备份」，数据不变。
5. 覆盖安装（不卸载）→ 数据还在，不必恢复。
6. （主路径）卸载或清数据 → 重装 → 从备份恢复 → 与导出时一致。

不在本计划做：云同步、合并导入、卸载自动提示、schema 迁移。

---

## 执行备注

- `@docs/superpowers/specs/2026-09-01-hive-backup-export-import-design.md`
- TDD：Task 1 必须先红后绿再提交。
- 空分类备份恢复后，下次冷启动仍会跑 `ensureSeedCategories`（规格已接受，不要加标记位）。
