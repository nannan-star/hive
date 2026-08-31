# Hive Flutter APK Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 在仓库 `app/` 落地 Hive 第一期全量功能（消费 + 梦想 + 分类/模板 + 设置占位），本地 Drift 持久化，产出可安装 Android APK。

**Architecture:** Flutter + go_router 底栏 Shell + Riverpod + Drift(SQLite)；业务规则（模板月生成、年同比、梦想汇总）放 Service；UI 用 Material 默认组件。规格见 `docs/superpowers/specs/2026-08-31-hive-flutter-design.md`。

**Tech Stack:** Flutter 3.44+ / Dart 3.12+，drift + drift_flutter + sqlite3_flutter_libs，flutter_riverpod，go_router，fl_chart，uuid，intl；dev: drift_dev，build_runner，flutter_test。

**Spec:** `@docs/superpowers/specs/2026-08-31-hive-flutter-design.md`  
**Requirements:** `@docs/hive-需求说明.md`

---

## File map（将创建）

```
app/
  pubspec.yaml
  lib/
    main.dart
    app.dart
    router.dart
    data/
      db/
        app_database.dart          # @DriftDatabase
        tables.dart                # Categories, SpendEntries, DreamJars, DreamDeposits
      daos/
        categories_dao.dart
        spend_entries_dao.dart
        dream_dao.dart
      seed.dart
      providers.dart               # databaseProvider
    features/
      spend/
        services/
          template_service.dart
          spend_stats_service.dart
        providers/
          spend_providers.dart
        pages/
          spend_home_page.dart
          pending_page.dart
          add_spend_page.dart
          categories_page.dart
          category_edit_page.dart
          category_detail_page.dart
      dream/
        services/
          dream_service.dart
        providers/
          dream_providers.dart
        pages/
          dream_home_page.dart
          dream_new_page.dart
          dream_detail_page.dart
          dream_deposit_page.dart
      settings/
        pages/
          settings_page.dart
    shared/
      money.dart                   # cents ↔ display
      dates.dart                   # YYYY-MM-DD helpers
      widgets/
        year_switcher.dart
  test/
    template_service_test.dart
    spend_stats_service_test.dart
    dream_service_test.dart
    seed_test.dart
```

---

### Task 1: M0 — 创建 Flutter 工程与底栏空壳

**Files:**
- Create: `app/`（flutter create）
- Create: `app/lib/app.dart`, `app/lib/router.dart`
- Modify: `app/lib/main.dart`, `app/pubspec.yaml`, `app/android/app/build.gradle.kts`（或 `.gradle`）applicationId

- [ ] **Step 1: 在仓库根创建 Flutter 项目**

```bash
cd /Users/工作/ACode/base/hive
flutter create --org com.hive --project-name hive_app --platforms=android,ios app
```

Expected: `app/` 含 `lib/main.dart`、`android/`、`ios/`。

- [ ] **Step 2: 设置 applicationId 与显示名**

将 Android `applicationId` / `namespace` 设为 `com.hive.family`；`AndroidManifest` / 标签显示名为 `Hive`。  
iOS 仅保留，不配置签名。

- [ ] **Step 3: 添加运行时依赖**

在 `app/pubspec.yaml` 的 `dependencies` 加入：

```yaml
flutter_riverpod: ^2.6.1
go_router: ^15.1.2
drift: ^2.26.0
drift_flutter: ^0.2.4
sqlite3_flutter_libs: ^0.5.32
path_provider: ^2.1.5
path: ^1.9.1
uuid: ^4.5.1
intl: ^0.20.2
fl_chart: ^0.70.2
```

`dev_dependencies`：

```yaml
drift_dev: ^2.26.0
build_runner: ^2.4.15
```

（若 pub 解析有版本冲突，以 `flutter pub get` 可解析的兼容版本为准，并在 PR/提交说明中记录最终版本。）

```bash
cd app && flutter pub get
```

Expected: 无 error。

- [ ] **Step 4: 实现 go_router + 底栏 Shell + 占位页**

`lib/router.dart`：`StatefulShellRoute.indexedStack`，分支 `/spend`、`/dream`；额外路由 `/settings`、以及后续子路由占位先用 `Placeholder`/`Scaffold`。

`lib/app.dart`：

```dart
class HiveApp extends StatelessWidget {
  const HiveApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Hive',
      routerConfig: createRouter(),
    );
  }
}
```

`main.dart`：`ProviderScope(child: HiveApp())`。

- [ ] **Step 5: 验证 debug 运行与 APK**

```bash
cd app && flutter analyze
cd app && flutter build apk --debug
```

Expected: analyze 无 error；`build/app/outputs/flutter-apk/app-debug.apk` 生成。

- [ ] **Step 6: Commit**

```bash
git add app/
git commit -m "chore: scaffold Flutter app with tab shell and APK build"
```

---

### Task 2: M1 — Drift 四表、Database、Seed

**Files:**
- Create: `app/lib/data/db/tables.dart`
- Create: `app/lib/data/db/app_database.dart`
- Create: `app/lib/data/seed.dart`
- Create: `app/lib/data/providers.dart`
- Create: `app/lib/shared/money.dart`, `app/lib/shared/dates.dart`
- Create: `app/test/seed_test.dart`
- Modify: `app/lib/main.dart`（打开 DB 后 seed）

- [ ] **Step 1: 写失败的 seed 测试（内存库）**

`test/seed_test.dart`：构造 `AppDatabase`（`NativeDatabase.memory()` 或 drift 测试连接），调用 `ensureSeedCategories`，断言 7 行且停车费 `templateDefaultAmount == 50000`。

```bash
cd app && flutter test test/seed_test.dart
```

Expected: FAIL（类未定义）。

- [ ] **Step 2: 定义 tables**

`tables.dart` 按规格 §3：`Categories`、`SpendEntries`、`DreamJars`、`DreamDeposits`；布尔用 `BoolColumn`；金额 `IntColumn`；日期 `TextColumn`；预留 `familyId`/`memberId` 可空。

- [ ] **Step 3: 定义 AppDatabase + schemaVersion 1**

```dart
@DriftDatabase(tables: [Categories, SpendEntries, DreamJars, DreamDeposits])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? e]) : super(e ?? _open());
  @override
  int get schemaVersion => 1;
}
```

提供 `appDatabase()` 工厂：生产用 `driftDatabase(name: 'hive.sqlite')`（`drift_flutter`）。

- [ ] **Step 4: 实现 seed.dart**

规格 §3.5 七分类；仅当 `categories` 表 count==0 时插入（幂等）。

- [ ] **Step 5: build_runner**

```bash
cd app && dart run build_runner build --delete-conflicting-outputs
```

Expected: 生成 `app_database.g.dart`。

- [ ] **Step 6: 跑通 seed 测试**

```bash
cd app && flutter test test/seed_test.dart
```

Expected: PASS。

- [ ] **Step 7: 接线 providers + main**

`databaseProvider` = `Provider<AppDatabase>`（或 `Provider` + dispose `close`）；启动时 `await ensureSeedCategories(db)`。临时在 `/spend` 用 `ListView` 打印分类名验证（下一 Task 可替换）。

- [ ] **Step 8: Commit**

```bash
git add app/lib/data app/lib/shared app/test/seed_test.dart app/pubspec.yaml app/pubspec.lock
git commit -m "feat: add Drift schema and category seed data"
```

---

### Task 3: M2 — Categories DAO + 分类管理页

**Files:**
- Create: `app/lib/data/daos/categories_dao.dart`
- Create: `app/lib/features/spend/pages/categories_page.dart`
- Create: `app/lib/features/spend/pages/category_edit_page.dart`
- Create: `app/lib/features/spend/providers/spend_providers.dart`
- Modify: `app/lib/router.dart`
- Modify: `app/lib/data/db/app_database.dart`（注册 dao）

- [ ] **Step 1: CategoriesDao**

方法：
- `watchEnabled()` / `watchAll()`（按 `sortOrder`）
- `getById(id)`
- `insertCategory(...)` / `updateCategory(...)`
- `setEnabled(id, false)`（停用）
- `deleteIfNoEntries(id)`：若存在 spend_entries 引用则抛业务异常或返回 `false`

重新 `build_runner`。

- [ ] **Step 2: 路由挂载**

- `/spend/categories` → CategoriesPage  
- `/spend/categories/edit` → CategoryEditPage(create)  ← **必须注册在 `:id` 路由之前**  
- `/spend/categories/:id/edit` → CategoryEditPage(edit)
- （详情 `/spend/categories/:id` 在 Task 5 挂载，同样排在静态 `edit` 之后）

- [ ] **Step 3: CategoriesPage UI**

Chip：启用中 / 含已停用；ListTile 显示名称 +「模板 ¥x」或「仅手记」；FAB/按钮「新建」；点行进编辑。Material 默认即可。

- [ ] **Step 4: CategoryEditPage**

字段：名称、sort_order 数字、enabled、template 开关；模板开时显示默认金额（元输入，存分）、生成日 1–28、默认备注。校验：模板开 ⇒ 金额 > 0。保存后 `context.pop`。编辑态提供「停用」；删除按钮仅在无消费笔时可点（或失败 SnackBar）。

金额换算用 `shared/money.dart`：`yuanToCents` / `formatYuan`。

- [ ] **Step 5: 手动验收**

```bash
cd app && flutter run
```

冷启动 → 设置/消费入口进分类管理 → 新建「物业费」→ 编辑停车费默认金额 → 停用后「启用中」列表消失、「含已停用」可见。

- [ ] **Step 6: Commit**

```bash
git add app/lib
git commit -m "feat: category CRUD and template fields UI"
```

---

### Task 4: M3 — 记一笔、模板生成、待确认

**Files:**
- Create: `app/lib/data/daos/spend_entries_dao.dart`
- Create: `app/lib/features/spend/services/template_service.dart`
- Create: `app/test/template_service_test.dart`
- Create: `app/lib/features/spend/pages/add_spend_page.dart`
- Create: `app/lib/features/spend/pages/pending_page.dart`
- Modify: `app/lib/data/db/app_database.dart`（注册 SpendEntriesDao）
- Modify: providers、router、spend_home 入口

- [ ] **Step 1: 写失败的 template_service 测试**

用例：
1. 启用+模板开的分类，调用 `ensureMonthTemplates(db, DateTime(2026,8,15))` → 插入 1 条 `source=template,status=pending`，金额=种子默认分，date=`2026-08-01`（template_day=1）
2. 再调用一次 → 不新增（幂等）
3. 已 skipped 的模板笔 → 不再生成
4. `ensureMonthTemplates` 使用传入的「今天」参数的年月，**测试里显式传入**，与 UI 展示年无关

```bash
cd app && flutter test test/template_service_test.dart
```

Expected: FAIL。

- [ ] **Step 2: SpendEntriesDao + TemplateService**

DAO：`insert`、`updateFields`、`setStatus`、`watchPendingForMonth(y,m)`、`hasTemplateSlot(categoryId,y,m)`。

`TemplateService.ensureMonthTemplates(AppDatabase db, DateTime today)` 按规格 §4.1 实现。

- [ ] **Step 3: 测试 PASS**

```bash
cd app && flutter test test/template_service_test.dart
```

- [ ] **Step 4: AddSpendPage**

表单：分类下拉（仅 enabled）、金额（元）、日期（默认今天）、备注。保存：`source=manual`,`status=confirmed`。支持 query `?categoryId=`。

路由：`/spend/add`。

- [ ] **Step 5: PendingPage**

进入时先 `ensureMonthTemplates(DateTime.now())`。列表 pending：可改金额/日期/备注；按钮确认 / 跳过本月。

路由：`/spend/pending`。

- [ ] **Step 6: 消费首页入口**

SpendHomePage（可先简版）：按钮「本月待确认」「记一笔」「分类管理」；进入首页时也调用 `ensureMonthTemplates`。

- [ ] **Step 7: 手动验收闭环**

打开 App → 待确认出现停车/水/电/燃气 → 改金额确认 → 再进待确认该条消失 → 记一笔旅行 1000 成功。

- [ ] **Step 8: Commit**

```bash
git add app/lib app/test
git commit -m "feat: manual spend, monthly templates, and pending confirm"
```

---

### Task 5: M4 — 年合计、同比、分类详情柱图

**Files:**
- Create: `app/lib/features/spend/services/spend_stats_service.dart`
- Create: `app/test/spend_stats_service_test.dart`
- Create: `app/lib/features/spend/pages/category_detail_page.dart`
- Create: `app/lib/shared/widgets/year_switcher.dart`
- Modify: `spend_home_page.dart`、router、dao（汇总查询）

- [ ] **Step 1: 写失败的 stats 测试**

插入 confirmed 笔：2026 停车 50000 分、2025 停车 40000 分；断言：
- 2026 停车合计 50000
- 同比差额 +10000，百分比 +25%
- pending/skipped 不计入
- 2026 年总合计正确

去年为 0 时百分比文案策略：返回 `null` 百分比，UI 显示「新增」或「—」。

```bash
cd app && flutter test test/spend_stats_service_test.dart
```

Expected: FAIL。

- [ ] **Step 2: 实现 SpendStatsService + DAO 聚合**

- `sumByCategory(year)` → `Map<categoryId, cents>`（仅 confirmed，date 前缀 year）
- `monthlySums(categoryId, year)` → `List<int>` 长度 12
- `yoy(categoryId, year)` → `(thisYear, lastYear, delta, percent?)`
- `yearTotal(year)`
- `listConfirmedEntries(categoryId, year)` → 该年该分类全部 `confirmed` 明细，按 `date` 升序（详情列表用；含 date/amount/note/source）

- [ ] **Step 3: 测试 PASS**

- [ ] **Step 4: SpendHomePage 完整 UI + 年份状态**

用 Riverpod `StateProvider<int>`（或 `Notifier`）保存 `selectedSpendYear`，默认 `DateTime.now().year`。YearSwitcher 读写该 provider。

顶部今年已确认合计（相对 **selectedSpendYear**）；列表：默认 enabled；该展示年有 confirmed 数据的停用分类一并列出；每行名称、合计、同比文案。

**进入详情约定（写死）：** 点击分类时

```text
context.push('/spend/categories/$id?year=$selectedSpendYear')
```

即年份走 **query 参数 `year`**（整数），不依赖全局日历年。

- [ ] **Step 5: CategoryDetailPage**

路由 `/spend/categories/:id`：从 `state.uri.queryParameters['year']` 解析年份，缺省则 `DateTime.now().year`。

展示：该年合计、同比文案、`fl_chart` 单系列 BarChart（1–12）、明细用 `listConfirmedEntries(id, year)`（日期、金额、备注、来源标签 template/manual）；「记一笔」带 categoryId。点柱：`Scrollable.ensureVisible` 或滚动到对应月份分组（尽力而为）。

**路由注册顺序：** 先注册静态路径 `/spend/categories/edit`，再注册 `/spend/categories/:id` 与 `/spend/categories/:id/edit`，避免 `edit` 被当成 id。

- [ ] **Step 6: 手动验收**

切换年份；确认同比文案；详情柱与列表明细一致。

- [ ] **Step 7: Commit**

```bash
git add app/lib app/test
git commit -m "feat: yearly spend totals, YoY, and category bar chart"
```

---

### Task 6: M5 — 梦想模块

**Files:**
- Create: `app/lib/data/daos/dream_dao.dart`
- Create: `app/lib/features/dream/services/dream_service.dart`
- Create: `app/test/dream_service_test.dart`
- Create: `app/lib/features/dream/providers/dream_providers.dart`
- Create: dream pages ×4
- Modify: `app/lib/data/db/app_database.dart`（注册 DreamDao）
- Modify: router

- [ ] **Step 1: 写失败的 dream 测试**

建罐目标 2000000 分；存入 500000+300000；`savedCents == 800000`；`complete` 后 status=completed；断言无 spend_entries 新增。

```bash
cd app && flutter test test/dream_service_test.dart
```

Expected: FAIL。

- [ ] **Step 2: DreamDao + DreamService**

CRUD jar；deposits insert/update/delete；`watchJars(includeCompleted)`；`watchDeposits(jarId)`；`sumDeposits`；`markCompleted`。

- [ ] **Step 3: 测试 PASS**

- [ ] **Step 4: UI 页面**

- `/dream` 列表：进度条、筛选含已完成、FAB 新建  
- `/dream/new` 名称+目标  
- `/dream/:id` 进度、差额、流水、内联改名称/目标、标记已完成、存入改删  
- `/dream/:id/deposit` 金额/日期默认今天/备注  

确认梦想存入**不会**出现在消费统计中（可在 stats 测试加一条负例，可选）。

- [ ] **Step 5: 手动验收**

新建「换车」→ 存两笔 → 进度正确 → 标记完成 → 列表筛选可见。

- [ ] **Step 6: Commit**

```bash
git add app/lib app/test
git commit -m "feat: dream jars, deposits, and completion"
```

---

### Task 7: M6 — 设置占位、边界、Release APK

**Files:**
- Create: `app/lib/features/settings/pages/settings_page.dart`
- Modify: router（设置入口）、README
- Optional: 少量边界测试

- [ ] **Step 1: SettingsPage**

文案：「备份 / 导出（即将推出）」；版本号**硬编码或读自常量**（本阶段不引入 `package_info_plus`，除非实现时已顺便加上）。路由 `/settings`；消费/梦想 AppBar actions 齿轮进入。

- [ ] **Step 2: 边界验收清单（手工）**

- [ ] 模板关/分类停用后本月已有 pending 仍可确认或跳过，下月（改系统日期或单测）不再生成  
- [ ] 有消费笔的分类删除失败，只能停用  
- [ ] 分类改名后同比仍连续  
- [ ] 记一笔立即进年合计；pending 不进  
- [ ] 梦想与消费分账  

- [ ] **Step 3: 全量测试 + release APK**

```bash
cd app && flutter test
cd app && flutter analyze
cd app && flutter build apk --release
```

Expected: tests PASS；`app-release.apk` 生成于 `app/build/app/outputs/flutter-apk/`。

- [ ] **Step 4: 更新仓库 README**

简述：如何 `cd app && flutter pub get && flutter run` / `flutter build apk`；指向需求与规格文档。

- [ ] **Step 5: Commit**

```bash
git add app/ README.md
git commit -m "feat: settings placeholder and release APK build"
```

---

## 风险与注意

1. **金额单位**：UI 元 ↔ 库分，种子必须用分（停车 50000）。所有表单进出都走 `money.dart`。  
2. **模板月**：只针对设备当前自然月；首页切年不触发历史月生成。  
3. **Drift codegen**：改表后必须 `build_runner`；生成文件纳入 git（便于 CI/他机）。  
4. **minSdk**：`sqlite3_flutter_libs` 要求核对 Android minSdk（通常 ≥ 21 即可，以插件说明为准）。  
5. **测试 DB**：单测用内存 executor，勿碰真机文件。

---

## 执行交接

计划完成后由用户选择执行方式（见下）。
