# Hive Flutter 第一期设计说明

> 日期：2026-08-31  
> 状态：已确认（对话审阅）  
> 需求来源：`docs/hive-需求说明.md` v0.2  
> 原型对照：`prototypes/hive-v1/index.html`（业务流程对照；视觉不追求还原）

---

## 1. 目标与约束

### 1.1 成功标准

- 需求文档第一期功能**全量落地**（消费 + 梦想 + 分类/模板 + 设置占位）
- 可产出可安装的 **Android APK**（`flutter build apk`）
- 数据**仅本地**持久化；无账号、无云同步
- UI 使用 **Material 默认组件**，业务可用即可，手账视觉后补

### 1.2 平台

- 验收只盯 Android APK
- 保留 Flutter 标准 `ios/` 目录，不配置证书/不上架 iOS

### 1.3 明确不做（本版）

- 云同步、账号、家人权限 UI
- 备份/导出的真实实现（设置页仅占位文案）
- 储蓄罐（goal）取出、罐子间划转仍不做；账户（fund）取出见 `2026-09-03-free-tab-accounts-design.md`
- 进账/结余、银行同步、亲子模块
- 推送通知、双柱对比图、手账视觉精修

---

## 2. 架构

### 2.1 选型

| 层 | 选择 |
|---|---|
| 客户端 | Flutter（稳定渠道） |
| 路由 | go_router + `ShellRoute` 底栏 |
| 状态 | flutter_riverpod |
| 持久化 | Drift（SQLite） |
| 图表 | fl_chart（分类详情单系列月柱） |
| 工程路径 | 仓库根下 `app/` |
| 应用 ID | `com.hive.family`（可在实现时微调，需与文档同步） |

### 2.2 目录结构

```
hive/
├── docs/
├── prototypes/hive-v1/
└── app/
    └── lib/
        ├── main.dart
        ├── app.dart
        ├── router.dart
        ├── data/
        │   ├── db/           # tables, database, migrations
        │   ├── daos/
        │   └── seed.dart
        ├── features/
        │   ├── spend/
        │   ├── dream/
        │   └── settings/
        └── shared/
```

按功能分包（spend / dream / settings），共享 `data/` 与 `shared/`。不采用全局严格三层 Clean Architecture，避免一期样板过重。

### 2.3 数据流

1. UI 通过 Riverpod 读写  
2. Notifier 调用 DAO 或薄 Service（如模板月生成）  
3. Drift 读写本机 SQLite；列表优先 `watch`  
4. 无网络层  

### 2.4 本地库与后续扩展

- **第一期**：库文件仅在设备私有目录；随 APK 分发的是 schema + migration，不是「部署数据库」
- **预留**：`family_id` / `member_id` 可空字段；业务主键用 UUID  
- **后续可选**：JSON/文件导出 → 自建 API 同步 → 或 PowerSync 等挂本地 SQLite  
- 汇总与模板规则放 Service，便于以后换 Repository 实现  

---

## 3. 数据模型

金额一律 **分（int）** 存储；日期用 `YYYY-MM-DD` 文本。

### 3.1 categories

| 字段 | 类型 | 说明 |
|---|---|---|
| id | TEXT PK | UUID |
| name | TEXT | |
| sort_order | INT | 越小越前 |
| enabled | BOOL | |
| note | TEXT? | |
| template_enabled | BOOL | |
| template_default_amount | INT? | 分；模板开时必填 |
| template_default_note | TEXT? | |
| template_day | INT | 1–28，默认 1 |
| family_id | TEXT? | 预留 |
| member_id | TEXT? | 预留 |
| created_at | INT | epoch ms |

### 3.2 spend_entries

| 字段 | 类型 | 说明 |
|---|---|---|
| id | TEXT PK | UUID |
| category_id | TEXT FK → categories | |
| amount_cents | INT | |
| date | TEXT | YYYY-MM-DD |
| note | TEXT? | |
| source | TEXT | `template` \| `manual` |
| status | TEXT | `pending` \| `confirmed` \| `skipped` |
| family_id | TEXT? | 预留 |
| member_id | TEXT? | 预留 |
| created_at | INT | |

### 3.3 dream_jars

| 字段 | 类型 | 说明 |
|---|---|---|
| id | TEXT PK | |
| name | TEXT | |
| target_cents | INT | |
| status | TEXT | `active` \| `completed` |
| description | TEXT? | |
| family_id | TEXT? | |
| member_id | TEXT? | |
| created_at | INT | |

### 3.4 dream_deposits

| 字段 | 类型 | 说明 |
|---|---|---|
| id | TEXT PK | |
| jar_id | TEXT FK → dream_jars | |
| amount_cents | INT | |
| date | TEXT | YYYY-MM-DD |
| note | TEXT? | |
| created_at | INT | |

### 3.5 种子分类（首次空库）

写入时金额字段为**分**（需求文档示例「元」× 100）：

| sort_order | name | template_enabled | template_default_amount（分） | template_day |
|---:|---|---|---:|---:|
| 1 | 停车费 | true | 50000 | 1 |
| 2 | 水费 | true | 5000 | 1 |
| 3 | 电费 | true | 30000 | 1 |
| 4 | 燃气费 | true | 8000 | 1 |
| 5 | 保险费 | false | null | 1 |
| 6 | 旅行 | false | null | 1 |
| 7 | 生活大额 | false | null | 1 |

---

## 4. 业务规则

### 4.1 模板月生成

`ensureMonthTemplates()`：进入消费首页或待确认页时调用；**`year`/`month` 始终取设备「今天」的自然月**，与消费首页所选展示年份无关（避免按 UI 年份误生成历史月模板笔）。

对每个 `enabled && template_enabled` 的分类：若该自然月尚无 `source=template` 且 `status ∈ {pending, confirmed, skipped}` 的记录，则插入 1 条，字段为：

| 字段 | 取值 |
|---|---|
| source | `template` |
| status | `pending` |
| amount_cents | 该分类 `template_default_amount` |
| note | 该分类 `template_default_note`（可空） |
| date | 当年当月 + `template_day`（`YYYY-MM-DD`；上限 28） |
| category_id | 该分类 id |

关闭模板或停用分类：已生成的本月 pending 仍可确认/跳过；下月不再生成。

### 4.2 记一笔（手动）

「记一笔」保存时写入：

- `source = manual`
- `status = confirmed`（**立即计入**年/月统计与同比，不经待确认）
- `date` 默认**当天**，可改
- 分类须为当前启用分类（从详情带入 `categoryId` 时可预填）

### 4.3 待确认操作

| 操作 | 结果 |
|---|---|
| 确认 | → `confirmed`，计入统计 |
| 跳过本月 | → `skipped`，不计入统计，本月模板槽占用 |
| 改金额/日期/备注 | 仍为 `pending` |

### 4.4 统计与展示

- 年/月合计、柱图、同比：**仅 `status=confirmed`**
- 同比按 `category_id`（改名不断档）
- 同比展示：**差额与百分比并存**（如「较去年多 ¥400（+10.5%）」；去年为 0 时百分比显示「—」或「新增」）
- 消费首页展示**今年已确认消费合计**（各类之和）
- 停用：记一笔/首页默认不展示；历史与对比可查（分类管理「含已停用」、详情深链）
- 梦想存入**不计入**消费统计

### 4.5 分类管理

- `sort_order`：编辑页用**数字输入**（越小越前）；不做拖拽
- 模板开启时：`template_default_amount` 必填（>0）
- 有关联消费笔时禁止硬删，仅可停用；无消费笔时可删

### 4.6 梦想

- 已存 = 该罐 deposits 求和；无取出
- 存入可删/改（纠错）；存入 `date` 默认**当天**，可改
- 详情可**编辑罐子名称与目标金额**（保存写回 `dream_jars`）
- 「标记已完成」只改 `dream_jars.status = completed`，不写消费
- 新建罐子：使用路由 `/dream/new`（表单页）

---

## 5. 页面与路由

| 路径 | 页面 |
|---|---|
| `/spend` | 消费首页：年份切换、今年合计、各类合计+同比、入口 |
| `/spend/pending` | 本月待确认 |
| `/spend/add` | 记一笔（可选 `categoryId`）→ 直接 confirmed |
| `/spend/categories` | 分类列表（启用中 / 含已停用） |
| `/spend/categories/edit` | 新建分类 |
| `/spend/categories/:id/edit` | 编辑分类（含排序数字、模板字段） |
| `/spend/categories/:id` | 分类详情：同比文案 + 月柱 + 明细（日期、金额、备注、来源模板/手记） |
| `/dream` | 梦想列表（可含已完成） |
| `/dream/new` | 新建梦想罐 |
| `/dream/:id` | 梦想详情（含改名称/目标、标记完成；存入改/删在详情内联） |
| `/dream/:id/deposit` | 存一笔 |
| `/settings` | 设置占位 |

底栏：**消费 / 梦想**。设置从顶栏图标进入。罐子名称/目标在详情页内联编辑（不单独强制 `/dream/:id/edit` 路由）。

柱图：单系列 1–12 月；点柱可滚动到该月明细（第一期尽力而为）。

---

## 6. 实现里程碑

| 阶段 | 交付 | 验收 |
|---|---|---|
| M0 | `app/` 工程 + 底栏空壳 + `flutter build apk` | APK 可装 |
| M1 | Drift 四表 + seed + migration | 冷启动 7 分类 |
| M2 | 分类 CRUD + 模板字段 | 管理页可用 |
| M3 | 记一笔 + 模板生成 + 待确认 | 消费主闭环 |
| M4 | 年合计/同比 + 详情柱图与明细 | 统计闭环 |
| M5 | 梦想罐 + 存入 + 完成 | 梦想闭环 |
| M6 | 设置占位 + 边界用例 + release APK | 对齐需求 §1 |

---

## 7. 测试策略

- 优先：**Service / DAO 单元测试**（模板生成幂等、同比口径、梦想汇总）
- Widget 测试覆盖关键表单校验（模板开时默认金额必填等）可选
- 人工：按需求 §8 页面走查 + 真机/模拟器装 APK

---

## 8. 参考

- 需求：`docs/hive-需求说明.md`
- 原型：`prototypes/hive-v1/index.html`
