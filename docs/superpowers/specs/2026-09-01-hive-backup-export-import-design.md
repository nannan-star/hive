# Hive 本地备份导出 / 导入

> 日期：2026-09-01  
> 状态：已确认（对话审阅）  
> 需求来源：设置页「导出备份 / 从备份恢复」从占位改为可用；支持卸载重装前带走数据  
> 前置：`docs/superpowers/specs/2026-08-31-hive-flutter-design.md`（本地 Drift，无云同步）

---

## 1. 目标与约束

### 1.1 要解决的问题

数据只在本机 `hive.sqlite`。卸载（或 Android「清除数据」）会删掉沙盒，账会没。用户需要在卸载或换机前把数据拿到 App 外面，重装后再灌回来。

**覆盖安装 / 商店升级不会丢数据。** 私有目录会留下。本功能不是为升级准备的，升级路径不改库、不清表。

### 1.2 成功标准

- 设置里「导出备份」生成一份 JSON，经系统分享存到「文件」或发给别人
- 「从备份恢复」用系统文件选择器选这份 JSON，校验通过后**整库覆盖**
- 覆盖后分类、记账、梦想罐、存入记录与导出时一致（含 UUID、金额分、日期）
- 非法文件或用户取消时，当前数据不动

### 1.3 明确不做

- 云同步、账号、自动备份、卸载前提示
- 合并导入（只做整库覆盖）
- 跨 schema 自动迁移（只接受与当前 `AppDatabase.schemaVersion` 相同的备份）
- 家人权限（设置里仍占位）
- 拷贝 SQLite 文件或打 zip

### 1.4 平台

Flutter iOS / Android 都要能分享和选文件。不改包名（Android `com.hive.family`，iOS `com.hive.hiveApp`）。

---

## 2. 用户流程

设置页已有两个入口，去掉「第一期占位」文案，接上真实逻辑。家人权限仍占位。

### 2.1 导出

1. 点「导出备份」
2. 读四张表，写成 JSON，落到临时目录，文件名：`hive-backup-yyyyMMdd-HHmm.json`（本地时间）
3. 调系统分享面板
4. 用户取消分享不算失败，不弹错误
5. 分享面板本身即结果，不再额外 Toast「导出成功」
6. 写文件或拉起分享失败 → SnackBar「导出失败，请重试」

导出过程中两个备份入口禁用，避免连点。

### 2.2 导入

1. 点「从备份恢复」
2. 系统文件选择器，筛选 `.json`
3. 取消选择 → 什么都不做
4. 读文件并校验（见 §4）。失败 → SnackBar，**不弹覆盖确认、不写库**
5. 校验通过 → 确认框，文案带导出日期与条数，例如：  
   「将用 2026-09-01 的备份完全替换当前数据（分类 7、记账 12、梦想罐 2）。此操作无法撤销。」  
   存入条数不必单独强调；分类 / 记账 / 梦想罐三个数字足够。日期用备份里 `exportedAt` 的本地日历日。
6. 取消确认 → 不写库
7. 确认后同一事务清空四表再插入。成功 → SnackBar「已从备份恢复」。失败 → SnackBar「恢复失败，当前数据未改动」（事务回滚）

导入过程中同样禁用两个备份入口。

---

## 3. 备份文件

### 3.1 顶层

UTF-8 JSON。顶层键：

| 键 | 类型 | 规则 |
|---|---|---|
| `app` | string | 必须是 `"hive"` |
| `formatVersion` | int | 必须是 `1` |
| `schemaVersion` | int | 必须等于当前 `AppDatabase.schemaVersion`（现在是 `1`） |
| `exportedAt` | string | UTC ISO-8601，带 `Z` |
| `categories` | array | 见下 |
| `spendEntries` | array | 见下 |
| `dreamJars` | array | 见下 |
| `dreamDeposits` | array | 见下 |

未知顶层键忽略。缺任一必填键 → 无效备份。

键名用 camelCase，与 Drift 生成的 Dart 字段对齐，**不要**用 SQL 下划线列名。

### 3.2 行字段

每张表导出**全部列**，可空列 JSON 为 `null`。金额仍是分（int），日期仍是 `YYYY-MM-DD`，`createdAt` 仍是 epoch 毫秒。

**categories：** `id`, `name`, `sortOrder`, `enabled`, `note`, `templateEnabled`, `templateDefaultAmount`, `templateDefaultNote`, `templateDay`, `familyId`, `memberId`, `createdAt`

**spendEntries：** `id`, `categoryId`, `amountCents`, `date`, `note`, `source`, `status`, `familyId`, `memberId`, `createdAt`

**dreamJars：** `id`, `name`, `targetCents`, `status`, `description`, `familyId`, `memberId`, `createdAt`

**dreamDeposits：** `id`, `jarId`, `amountCents`, `date`, `note`, `createdAt`

行内未知键忽略。缺必填键或类型不对 → 整份备份无效。

### 3.3 示例（节选）

```json
{
  "app": "hive",
  "formatVersion": 1,
  "schemaVersion": 1,
  "exportedAt": "2026-09-01T10:52:00.000Z",
  "categories": [],
  "spendEntries": [],
  "dreamJars": [],
  "dreamDeposits": []
}
```

---

## 4. 校验与错误

导入在打开覆盖确认**之前**做完校验。任一失败抛出带码的错误，UI 映射文案。不写库。

| 码 | 条件 | SnackBar |
|---|---|---|
| `unreadable` | 读文件失败或不是合法 JSON | 无法识别这份备份 |
| `notHive` | `app` ≠ `"hive"` | 无法识别这份备份 |
| `unsupportedFormat` | `formatVersion` ≠ `1` | 备份版本不兼容 |
| `schemaMismatch` | `schemaVersion` ≠ 当前库版本 | 备份版本不兼容 |
| `invalidPayload` | 缺键、类型错、同表 `id` 重复 | 无法识别这份备份 |
| `brokenReferences` | `spendEntries.categoryId` 不在本次 `categories`；或 `dreamDeposits.jarId` 不在本次 `dreamJars` | 无法识别这份备份 |
| `io` | 导出写临时文件 / 拉起分享失败；或确认后写入抛错（非校验） | 导出失败，请重试 / 恢复失败，当前数据未改动 |

`source` / `status` 只要求是 string，不在导入时枚举校验（与现库写入口径一致，避免把历史脏数据挡在门外）。

---

## 5. 写入语义

### 5.1 覆盖事务

确认后在 **一条 Drift transaction** 里：

1. 删除顺序：`dream_deposits` → `spend_entries` → `dream_jars` → `categories`（先子后父）
2. 插入顺序：`categories` → `dream_jars` → `spend_entries` → `dream_deposits`（先父后子）
3. 用备份里的原 `id` 插入，不重新生成 UUID

失败则整笔回滚。成功后 Drift `watch` 会把消费/梦想各页刷成新数据，不必重启 App，也不必手动 `invalidate` StreamProvider。

### 5.2 与 seed 的关系

`ensureSeedCategories` 仍只在 `main()` 里、分类表为空时跑。本功能不改这条。

含义：

- 备份里有分类 → 恢复后下次冷启动不会再种 7 个默认分类
- 备份里分类为空 → 本次进程保持空表；**杀掉 App 再开会种回 7 个默认分类**。接受这个边界，不为空备份单独加标记

### 5.3 升级

覆盖安装不调用恢复、不清表。以后加列必须另做 Drift migration，并再决定是否抬 `schemaVersion` / 是否接受旧备份。本版 `schemaVersion` 保持 `1`。

---

## 6. 代码落点

| 路径 | 职责 |
|---|---|
| `app/lib/features/settings/services/backup_service.dart` | 拼 JSON、校验、事务覆盖。纯 Dart，不依赖分享/选文件 |
| `app/lib/features/settings/pages/settings_page.dart` | 分享、选文件、确认框、SnackBar、busy 态 |
| `app/pubspec.yaml` | 增加 `share_plus`、`file_picker`（`path_provider` 已有） |

`BackupService` 只吃 `AppDatabase`。建议表面：

- `Future<String> exportJson()` → 完整 JSON 文本
- `BackupPayload parse(String json)` → 校验，失败抛错
- `Future<void> restore(BackupPayload payload)` → 事务覆盖

页面负责：临时文件、`Share.shareXFiles`、`FilePicker.platform.pickFiles`。

不改 `tables.dart`、不改 DAO 对外 API、不加新路由。

iOS / Android 若插件要求补 Info.plist / FileProvider，按 `share_plus` / `file_picker` 官方说明加最小项，不为 JSON 注册自定义 URL scheme。

---

## 7. 测试

内存 `NativeDatabase.memory()`，与现有 `seed_test` 同风格。不测系统分享面板。

必须覆盖：

1. 有数据时 `exportJson` → `parse` → 空库 `restore`，四表行与字段一致
2. 目标库已有不同数据时 `restore`，旧行全部消失，只剩备份内容
3. 非法 JSON、`app` 错误、`formatVersion` / `schemaVersion` 错误、外键对不上 → `parse` 抛错；若误调用 `restore` 前的库未被测试直接写（只测 parse 抛错即可）
4. 同表重复 `id` → `invalidPayload`

不强制 Widget 测试确认框。

人工验收：

- 导出 → 存到「文件」→ 卸载或清数据 → 重装 → 选文件恢复 → 分类/记账/梦想与导出时一致
- 不恢复、只升级安装 → 原数据仍在

---

## 8. 参考

- 第一期设计：`docs/superpowers/specs/2026-08-31-hive-flutter-design.md`
- 需求：`docs/hive-需求说明.md`（后续里程碑「导出备份（JSON/文件）」）
- 设置占位：`app/lib/features/settings/pages/settings_page.dart`
