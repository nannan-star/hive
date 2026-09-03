# Hive 消费分类改名与级联删除 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 在编辑分类页支持删除：二次确认（展示笔数）后硬删分类及其下全部消费笔；改名沿用现有名称字段，仅作验收。

**Architecture:** `CategoriesDao` 提供 `countEntries` 与事务级 `deleteCategoryCascade`（先删 `spend_entries` 再删 `categories`），替换 `deleteIfNoEntries`。`CategoryEditPage` 增加危险操作「删除此分类」与确认对话框。不改表结构 / schemaVersion。

**Tech Stack:** Flutter / Dart，Drift，Riverpod，既有 `HiveTextAction` / `AlertDialog` 模式。

**Spec:** `@docs/superpowers/specs/2026-09-03-hive-category-rename-delete-design.md`

---

## File map

| 路径 | 职责 |
|---|---|
| Create: `app/test/categories_dao_delete_test.dart` | count / cascade / 不影响其他分类 |
| Modify: `app/lib/data/daos/categories_dao.dart` | 新 API；删除 `deleteIfNoEntries` |
| Modify: `app/lib/features/spend/pages/category_edit_page.dart` | 删除按钮 + 确认流 + busy |
| Modify: `docs/hive-需求说明.md` | §4.1 / §4.4 删除规则同步 |

不改 `tables.dart`、路由、备份。改名无新代码。

工作目录：所有 `flutter` 命令在 `app/` 下跑。

---

### Task 1: CategoriesDao — countEntries / deleteCategoryCascade

**Files:**
- Create: `app/test/categories_dao_delete_test.dart`
- Modify: `app/lib/data/daos/categories_dao.dart`

- [ ] **Step 1: 写失败测试**

创建 `app/test/categories_dao_delete_test.dart`：

```dart
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_app/data/daos/categories_dao.dart';
import 'package:hive_app/data/db/app_database.dart';

void main() {
  late AppDatabase db;
  late CategoriesDao dao;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    dao = CategoriesDao(db);
  });

  tearDown(() async {
    await db.close();
  });

  Future<void> insertCat(String id, String name) async {
    await db.into(db.categories).insert(
          CategoriesCompanion.insert(
            id: id,
            name: name,
            sortOrder: 1,
            createdAt: 1000,
          ),
        );
  }

  Future<void> insertEntry({
    required String id,
    required String categoryId,
    required String status,
  }) async {
    await db.into(db.spendEntries).insert(
          SpendEntriesCompanion.insert(
            id: id,
            categoryId: categoryId,
            amountCents: 1000,
            date: '2026-09-01',
            source: 'manual',
            status: status,
            createdAt: 2000,
          ),
        );
  }

  test('countEntries is 0 when empty and counts all statuses', () async {
    await insertCat('c1', '电费');
    expect(await dao.countEntries('c1'), 0);

    await insertEntry(id: 'e1', categoryId: 'c1', status: 'pending');
    await insertEntry(id: 'e2', categoryId: 'c1', status: 'confirmed');
    await insertEntry(id: 'e3', categoryId: 'c1', status: 'skipped');
    expect(await dao.countEntries('c1'), 3);
  });

  test('deleteCategoryCascade removes category and its entries only', () async {
    await insertCat('c1', '电费');
    await insertCat('c2', '水费');
    await insertEntry(id: 'e1', categoryId: 'c1', status: 'confirmed');
    await insertEntry(id: 'e2', categoryId: 'c1', status: 'pending');
    await insertEntry(id: 'e3', categoryId: 'c2', status: 'confirmed');

    await dao.deleteCategoryCascade('c1');

    expect(await dao.getById('c1'), isNull);
    expect(await dao.getById('c2'), isNotNull);
    expect(await dao.countEntries('c1'), 0);
    expect(await dao.countEntries('c2'), 1);

    final left = await db.select(db.spendEntries).get();
    expect(left.map((e) => e.id), ['e3']);
  });

  test('deleteCategoryCascade works with zero entries', () async {
    await insertCat('c1', '旅行');
    await dao.deleteCategoryCascade('c1');
    expect(await dao.getById('c1'), isNull);
  });
}
```

- [ ] **Step 2: 跑测试确认失败**

Run: `cd app && flutter test test/categories_dao_delete_test.dart`

Expected: FAIL（`countEntries` / `deleteCategoryCascade` 未定义）

- [ ] **Step 3: 实现 DAO**

在 `categories_dao.dart`：

1. **删除**整个 `deleteIfNoEntries` 方法（先 `rg deleteIfNoEntries`：应仅定义处，无调用方）。

2. **新增**：

```dart
  Future<int> countEntries(String categoryId) async {
    final count = countAll();
    final query = selectOnly(spendEntries)
      ..addColumns([count])
      ..where(spendEntries.categoryId.equals(categoryId));
    final row = await query.getSingle();
    return row.read(count) ?? 0;
  }

  Future<void> deleteCategoryCascade(String categoryId) {
    return transaction(() async {
      await (delete(spendEntries)
            ..where((t) => t.categoryId.equals(categoryId)))
          .go();
      await (delete(categories)..where((t) => t.id.equals(categoryId))).go();
    });
  }
```

若 `selectOnly`/`countAll` 写法与项目 Drift 版本不顺，可用等价实现：

```dart
  Future<int> countEntries(String categoryId) async {
    final rows = await (select(spendEntries)
          ..where((t) => t.categoryId.equals(categoryId)))
        .get();
    return rows.length;
  }
```

- [ ] **Step 4: 跑测试确认通过**

Run: `cd app && flutter test test/categories_dao_delete_test.dart`

Expected: All tests passed

- [ ] **Step 5: Commit**

```bash
git add app/test/categories_dao_delete_test.dart app/lib/data/daos/categories_dao.dart
git commit -m "$(cat <<'EOF'
feat: cascade-delete spend category with its entries

Replace deleteIfNoEntries with transactional deleteCategoryCascade and countEntries for confirm UI.
EOF
)"
```

---

### Task 2: CategoryEditPage — 删除确认流

**Files:**
- Modify: `app/lib/features/spend/pages/category_edit_page.dart`

改名：无新逻辑；手工冒烟「改名称 → 保存」即可。

- [ ] **Step 1: 增加 busy 状态与 `_delete`**

在 `_CategoryEditPageState` 增加 `bool _busy = false;`。

在 `_disable` 旁新增：

```dart
  Future<void> _delete() async {
    if (_busy || !widget.isEditing) return;
    final id = widget.categoryId!;
    final dao = ref.read(categoriesDaoProvider);
    final name = _existing?.name ?? _nameCtrl.text.trim();
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
    if (confirmed != true || !mounted) return;

    setState(() => _busy = true);
    try {
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
```

对照 `settings_page.dart` 的 `AlertDialog` 危险操作样式（`HiveColors.danger`）。

- [ ] **Step 2: 挂上删除按钮**

在「停用此分类」`HiveTextAction` **下方**（同级 ListView children）：

```dart
                    if (widget.isEditing)
                      HiveTextAction(
                        label: '删除此分类',
                        danger: true,
                        onPressed: _busy ? null : _delete,
                      ),
```

若 `HiveTextAction.onPressed` 不接受 `null`，改为 `_busy ? () {} : _delete` 或给组件加 `enabled`——以现有 `HiveTextAction` 签名为准（读 `hive_widgets.dart`）。

新建页（`!isEditing`）不得出现该按钮。停用按钮逻辑不变。

- [ ] **Step 3: 静态检查**

Run: `cd app && dart analyze lib/features/spend/pages/category_edit_page.dart lib/data/daos/categories_dao.dart`

Expected: No issues

- [ ] **Step 4: Commit**

```bash
git add app/lib/features/spend/pages/category_edit_page.dart
git commit -m "$(cat <<'EOF'
feat: add category delete confirm with entry count

Wire edit-page danger action to cascade delete after showing spend entry count.
EOF
)"
```

---

### Task 3: 同步需求说明 + 回归测试

**Files:**
- Modify: `docs/hive-需求说明.md`

- [ ] **Step 1: 更新删除表述**

将约 L94：

- 旧：`支持停用（不删历史）、删除仅当无消费笔时或二次确认后软隐藏`
- 新：`支持停用（不删历史）；删除经二次确认后硬删分类并级联删除其下全部消费笔（确认文案展示笔数）`

将约 L154 操作行：

- 旧：`保存；停用；删除（有消费笔时：禁止硬删或改为「停用并隐藏」，避免同比断档）`
- 新：`保存；停用；删除（二次确认，展示笔数；硬删分类并级联删除其下全部消费笔）`

§4.3 **改名** / **停用** 段落保持不变。

- [ ] **Step 2: 跑相关测试**

Run: `cd app && flutter test test/categories_dao_delete_test.dart test/seed_test.dart`

Expected: All tests passed

- [ ] **Step 3: Commit**

```bash
git add docs/hive-需求说明.md
git commit -m "$(cat <<'EOF'
docs: allow cascade hard-delete for spend categories

Align product requirements with confirmed delete-with-entries behavior.
EOF
)"
```

- [ ] **Step 4: 手工验收（实现后）**

1. 消费 → 分类管理 → 编辑某分类 → 改名保存，列表名称更新  
2. 编辑有记录的分类 → 删除 → 对话框笔数正确 → 确认后列表无该类，首页统计不再含其金额  
3. 新建分类页无「删除此分类」  
4. 取消删除后数据仍在  

交付：`cd app && flutter run`（或起 Chrome / 已有设备），把本地 URL / 设备交给用户测。

---

## 执行注意

- Commit 后本仓库有 post-commit 自动 push；网络失败时本地 commit 保留，需补推。  
- 勿把无关脏文件（如进行中的 `add_spend_page.dart` 改动）打进本功能 commit。
