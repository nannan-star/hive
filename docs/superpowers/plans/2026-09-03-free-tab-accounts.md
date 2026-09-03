# 自由 Tab · 账户（可存可取）Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 在现有梦想模块上落地「自由」Tab：底栏改名；同一模块两种罐子（`goal` 储蓄罐 / `fund` 账户）；账户可存可取且不可超余额；与消费继续分账。

**Architecture:** 沿用 `dream_jars` + `dream_deposits`；`DreamJars` 增加 `kind`；流水 `amount_cents` 有符号（存>0、取<0）；业务校验集中在 `DreamService`；UI 仍在 `features/dream/`（路由 path 保持 `/dream*`，仅改用户可见文案）。规格见 `@docs/superpowers/specs/2026-09-03-free-tab-accounts-design.md`。

**Tech Stack:** Flutter + Riverpod + go_router + Drift（schemaVersion 1→2）；测试 `flutter test`（工作目录 `app/`）。

**Spec:** `@docs/superpowers/specs/2026-09-03-free-tab-accounts-design.md`  
**Requirements:** `@docs/hive-需求说明.md` v0.3  
**Prototype:** `@prototypes/hive-v1/index.html`

---

## File map

```
app/lib/data/db/
  tables.dart                 # DreamJars + kind；targetCents 对 fund 写 0
  app_database.dart           # schemaVersion=2 + onUpgrade 加列
app/lib/data/daos/
  dream_dao.dart              # 按 kind 查询；insertFund；deleteJar+流水；余额汇总已支持有符号
app/lib/features/dream/
  services/dream_service.dart # deposit/withdraw/create/delete 规则
  providers/dream_providers.dart
  pages/
    dream_home_page.dart      # 类型切换 + 文案「自由」
    dream_new_page.dart       # 选类型 / 或拆 dream_type_pick + fund 表单
    dream_detail_page.dart    # goal 详情；fund 分流或新页
    fund_detail_page.dart     # 新建：账户详情
    dream_deposit_page.dart   # 支持 mode=deposit|withdraw
app/lib/router.dart           # /dream/:id/withdraw；新建 query kind=
app/lib/shared/widgets/hive_widgets.dart  # 底栏「自由」
app/lib/features/settings/services/backup_service.dart  # Task 1 同步解析 kind
app/test/
  dream_service_test.dart     # 扩展账户用例
```

**明确不做（实现期也不做）：** 划转、取出进消费、账户完成/归档、预设类别、重命名表/路由为 free。

---

### Task 1: Schema — `kind` + 迁移 schemaVersion 2

**Files:**
- Modify: `app/lib/data/db/tables.dart`
- Modify: `app/lib/data/db/app_database.dart`
- Modify: `app/lib/data/daos/dream_dao.dart`（insert 带 kind；默认 goal）
- Modify: `app/lib/features/settings/services/backup_service.dart`（**必须同提交**：`_parseJars` 增加 `kind`，否则 Drift 生成后编译失败）
- Run: `cd app && dart run build_runner build --delete-conflicting-outputs`

- [ ] **Step 1: 改表定义**

在 `DreamJars` 增加：

```dart
TextColumn get kind => text().withDefault(const Constant('goal'))(); // goal | fund
```

`targetCents` 保持 `integer()`；`fund` 插入时传 `0`。

- [ ] **Step 2: 迁移**

```dart
@override
int get schemaVersion => 2;

@override
MigrationStrategy get migration => MigrationStrategy(
  onUpgrade: (m, from, to) async {
    if (from < 2) {
      await m.addColumn(dreamJars, dreamJars.kind);
    }
  },
);
```

- [ ] **Step 3: 更新 DAO insert + 备份解析**

- `insertJar` 默认 `kind: 'goal'`；新增 `insertFund({required name, String? description})`（`targetCents: 0`, `kind: 'fund'`, `status: 'active'`）
- `backup_service.dart` `_parseJars`：`kind: _optString(r, 'kind') ?? 'goal'`（旧 JSON 无字段时当 goal）
- 导出随 `DreamJar.toJson` 自动带 `kind`；`schemaVersion` 随 db 变为 2。**本期不做跨 version restore**（v1 备份无法直接导入 v2）

- [ ] **Step 4: build_runner 生成代码**

Run: `cd app && dart run build_runner build --delete-conflicting-outputs`  
Expected: 成功，无 error

- [ ] **Step 5: 确认工程能分析通过**

Run: `cd app && dart analyze lib/features/settings/services/backup_service.dart lib/data/db/`  
Expected: No issues / 或仅既有 info

- [ ] **Step 6: Commit**

```bash
git add app/lib/data/db/tables.dart app/lib/data/db/app_database.dart \
  app/lib/data/daos/dream_dao.dart app/lib/data/db/app_database.g.dart \
  app/lib/data/daos/dream_dao.g.dart \
  app/lib/features/settings/services/backup_service.dart
git commit -m "feat(db): add dream jar kind and schema v2"
```

---

### Task 2: DreamService — 存取规则（TDD）

**Files:**
- Modify: `app/test/dream_service_test.dart`
- Modify: `app/lib/features/dream/services/dream_service.dart`
- Modify: `app/lib/data/daos/dream_dao.dart`（`deleteJar`：先删流水再删罐；`updateJar` 对 fund 只改名）

- [ ] **Step 1: 写失败测试**

在 `dream_service_test.dart` 追加（保留原 goal 用例）：

```dart
test('fund deposit withdraw balance and reject overdraft', () async {
  final id = await service.createFund(name: '备用金');
  await service.deposit(jarId: id, amountCents: 10000, date: '2026-09-01');
  await service.withdraw(jarId: id, amountCents: 3000, date: '2026-09-02');
  expect(await service.balanceCents(id), 7000);

  await expectLater(
    () => service.withdraw(jarId: id, amountCents: 8000, date: '2026-09-03'),
    throwsA(isA<StateError>()), // 或自定义 FreeLedgerException
  );
  expect(await service.balanceCents(id), 7000);

  final spends = await db.select(db.spendEntries).get();
  expect(spends, isEmpty);
});

test('goal rejects withdraw', () async {
  final id = await db.dreamDao.insertJar(name: '滑雪', targetCents: 100000);
  await expectLater(
    () => service.withdraw(jarId: id, amountCents: 100, date: '2026-09-01'),
    throwsA(isA<StateError>()),
  );
});
```

- [ ] **Step 2: 跑测试确认失败**

Run: `cd app && flutter test test/dream_service_test.dart`  
Expected: FAIL（方法不存在）

- [ ] **Step 3: 实现 Service**

```dart
Future<String> createFund({required String name, String? description}) =>
    db.dreamDao.insertFund(name: name, description: description);

Future<int> balanceCents(String jarId) => db.dreamDao.sumDeposits(jarId);

Future<void> deposit({
  required String jarId,
  required int amountCents,
  required String date,
  String? note,
}) async {
  if (amountCents <= 0) throw StateError('amount must be positive');
  final jar = await db.dreamDao.getJar(jarId);
  if (jar == null) throw StateError('jar not found');
  await db.dreamDao.insertDeposit(
    jarId: jarId,
    amountCents: amountCents,
    date: date,
    note: note,
  );
}

Future<void> withdraw({
  required String jarId,
  required int amountCents,
  required String date,
  String? note,
}) async {
  if (amountCents <= 0) throw StateError('amount must be positive');
  final jar = await db.dreamDao.getJar(jarId);
  if (jar == null) throw StateError('jar not found');
  if (jar.kind != 'fund') throw StateError('withdraw only for fund');
  final bal = await balanceCents(jarId);
  if (amountCents > bal) throw StateError('insufficient balance');
  await db.dreamDao.insertDeposit(
    jarId: jarId,
    amountCents: -amountCents,
    date: date,
    note: note,
  );
}

Future<void> deleteFund(String jarId, {required bool confirmNonZero}) async {
  final jar = await db.dreamDao.getJar(jarId);
  if (jar == null || jar.kind != 'fund') throw StateError('not a fund');
  final bal = await balanceCents(jarId);
  if (bal != 0 && !confirmNonZero) throw StateError('balance not zero');
  await db.dreamDao.deleteJar(jarId); // 级联删流水
}
```

`complete` 仅允许 `kind == goal`。

- [ ] **Step 4: 跑测试通过**

Run: `cd app && flutter test test/dream_service_test.dart`  
Expected: All tests passed

- [ ] **Step 5: Commit**

```bash
git add app/lib/features/dream/services/dream_service.dart app/lib/data/daos/dream_dao.dart app/test/dream_service_test.dart
git commit -m "feat(free): fund deposit/withdraw rules in DreamService"
```

---

### Task 3: Providers + 底栏 / 首页文案与类型切换

**Files:**
- Modify: `app/lib/features/dream/providers/dream_providers.dart`
- Modify: `app/lib/shared/widgets/hive_widgets.dart`（`label: '自由'`）
- Modify: `app/lib/features/dream/pages/dream_home_page.dart`
- Modify: 消费首页若有「不含梦想存入」文案 →「不含自由存入/取出」

- [ ] **Step 1: Provider**

```dart
final freeKindFilterProvider = StateProvider<String>((_) => 'goal'); // goal | fund

final dreamJarsProvider = StreamProvider<List<DreamJar>>((ref) {
  final kind = ref.watch(freeKindFilterProvider);
  final include = ref.watch(includeCompletedDreamsProvider);
  return ref.watch(databaseProvider).dreamDao.watchJarsByKind(
    kind: kind,
    includeCompleted: kind == 'goal' ? include : true,
  );
});
```

DAO：`watchJarsByKind` — `where kind ==`；`fund` 忽略 completed 筛选。

- [ ] **Step 2: 首页 UI**

对齐原型：副标题「自由 · 储蓄与账户」；chip「储蓄罐 | 账户」；goal 下保留进行中/含已完成；新建进类型选择；账户行只显示余额（无进度）。

- [ ] **Step 3: 手动冒烟（模拟器或读代码自检）+ Commit**

```bash
git add app/lib/features/dream/providers/dream_providers.dart \
  app/lib/features/dream/pages/dream_home_page.dart \
  app/lib/shared/widgets/hive_widgets.dart \
  app/lib/data/daos/dream_dao.dart
git commit -m "feat(free): tab rename and kind filter on home"
```

---

### Task 4: 新建分流（储蓄罐 / 账户）

**Files:**
- Modify: `app/lib/features/dream/pages/dream_new_page.dart`（或新建 `free_new_page.dart` + `fund_new_page.dart`）
- Modify: `app/lib/router.dart`

- [ ] **Step 1: 路由**

- `/dream/new` → 类型选择页  
- `/dream/new/goal` → 现有名称+目标表单（调用 `insertJar`）  
- `/dream/new/fund` → 仅名称（调用 `createFund`）

- [ ] **Step 2: 实现页面，保存后 `context.go('/dream')` 并切到对应 `freeKindFilterProvider`**

- [ ] **Step 3: Commit**

```bash
git commit -m "feat(free): create goal jar or fund account"
```

---

### Task 5: 账户详情 + 存/取页

**Files:**
- Create: `app/lib/features/dream/pages/fund_detail_page.dart`
- Modify: `app/lib/features/dream/pages/dream_detail_page.dart`（若误开 fund id，redirect 到 fund 详情）
- Modify: `app/lib/features/dream/pages/dream_deposit_page.dart`（`mode`: deposit|withdraw）
- Modify: `app/lib/router.dart`

- [ ] **Step 1: 路由**

```
/dream/:id          → 按 kind 渲染 DreamDetailPage 或 FundDetailPage（推荐在 builder 内用 FutureBuilder/Provider 分支）
/dream/:id/deposit  → DreamDepositPage(mode: deposit)
/dream/:id/withdraw → DreamDepositPage(mode: withdraw)  // 仅 fund
```

- [ ] **Step 2: FundDetailPage**

- 余额、流水列表（正数「存入」/负数「取出」）
- 按钮：存一笔、取一笔、改名（Dialog）、删除（余额≠0 时 AlertDialog 二次确认后 `deleteFund(..., confirmNonZero: true)`）
- 无「标记完成」

- [ ] **Step 3: Deposit/Withdraw 页**

- 页面 `_save` **必须**走 `DreamService.deposit` / `withdraw`（勿直写 DAO），以便余额校验生效；若尚无 `dreamServiceProvider`，在 `dream_providers.dart` 增加
- withdraw：Service 抛错时 SnackBar「余额不足」
- 金额输入为正数；Service 负责变号
- goal 的 deposit 页拦截 withdraw 路由（或直接不注册给 goal）

- [ ] **Step 4: goal 详情文案**「存入梦想」→「存入储蓄罐」；编辑流水仍只允许正数

- [ ] **Step 5: `cd app && flutter test` + Commit**

```bash
git commit -m "feat(free): fund detail with deposit and withdraw UI"
```

---

### Task 6: 旧 design 文档小同步

**Files:**
- Modify: `docs/superpowers/specs/2026-08-31-hive-flutter-design.md` §1.3：改为「储蓄罐取出、罐子间划转」仍不做；账户取出见 `2026-09-03-free-tab-accounts-design.md`
- （备份 `kind` 已在 Task 1 完成；本任务不再改 backup_service）

- [ ] **Step 1: 改一行「明确不做」文案**

- [ ] **Step 2: Run `cd app && flutter test`**

Expected: All tests passed

- [ ] **Step 3: Commit**

```bash
git add docs/superpowers/specs/2026-08-31-hive-flutter-design.md
git commit -m "docs: clarify dream withdraw vs fund withdraw in flutter design"
```

---

### Task 7: 验收冒烟

- [ ] **Step 1: 清单（对照 spec §5）**

1. 底栏「消费 | 自由」  
2. 自由首页切换储蓄罐 / 账户  
3. 新建两种类型  
4. 储蓄罐只存、可完成  
5. 账户存/取；超额失败  
6. 账户无完成；删除确认  
7. 存取不产生 spend_entries（测试已覆盖）  
8. 无划转入口  

- [ ] **Step 2:（可选）`cd app && flutter build apk --release` 装机点按**

- [ ] **Step 3: 若尚未提交文档/原型，单独 commit（勿混入无关 `add_spend` 改动）**

```bash
git add docs/hive-需求说明.md \
  docs/superpowers/specs/2026-09-03-free-tab-accounts-design.md \
  docs/superpowers/plans/2026-09-03-free-tab-accounts.md \
  prototypes/hive-v1/index.html
git commit -m "docs: free tab accounts spec, plan, and prototype"
```

---

## 风险与注意

- **迁移：** 真机已有 schema v1 库必须走 `onUpgrade`；内存测试库每次新建无历史包袱。  
- **有符号流水：** goal 详情编辑存入时禁止改为 ≤0。  
- **无关工作区改动：** `add_spend_page.dart` / `add_spend_category_picker_test.dart` 不在本 plan，提交时排除。  
- **路由：** 对外文案「自由」，path 仍 `/dream`，避免无谓深链断裂。
