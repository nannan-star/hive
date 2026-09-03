# Hive 消费分类：改名与级联删除

> 日期：2026-09-03  
> 状态：已确认（对话审阅）  
> 需求来源：消费模块希望分类支持删除与修改名称；删除时清除该分类下全部消费记录  
> 前置：`docs/hive-需求说明.md` §4；`docs/superpowers/specs/2026-08-31-hive-flutter-design.md`

---

## 1. 目标与约束

### 1.1 要解决的问题

分类管理里改名已有入口（编辑页名称字段），但**没有删除**。现有 DAO 仅有 `deleteIfNoEntries`（有消费笔则拒绝删除），UI 未接。用户需要能删除不需要的分类，并接受其下记账一并清除。

### 1.2 成功标准

- 编辑已有分类时可改名称并保存（沿用现有流程；同分类 ID，历史不断档）
- 编辑页可删除分类；确认对话框展示将删除的消费笔数（含 0）
- 确认后硬删该分类及其下全部 `spend_entries`（任意状态：pending / confirmed / skipped）
- 其他分类及其消费笔不受影响
- 删除成功后返回分类列表；消费首页 / 待确认 / 记一笔选择器不再出现该分类

### 1.3 明确不做

- 列表侧滑 / 长按删除
- 回收站、撤销、软删除字段
- 改表结构或 `schemaVersion`
- 本次不补「重新启用」UI（停用按钮保留）
- 备份格式变更（删后导出即不含该分类与其笔）

### 1.4 平台

Flutter；数据层 Drift。工作目录 `app/`。

---

## 2. 用户流程

入口：消费 → 分类管理 → 点某分类进入「编辑分类」。

### 2.1 改名

1. 修改「名称」→「保存」
2. `updateCategory` 写回；`pop` 回列表
3. 同比与明细仍按同一 `categoryId`

### 2.2 删除

1. 仅编辑态显示「删除此分类」（新建页不显示）
2. 点击后查询该分类笔数 N
3. 对话框：
   - 标题：删除分类
   - 正文：将删除「{名称}」及其下全部消费记录（共 N 笔），且不可恢复
   - 操作：取消 / 删除（危险色）
4. 确认 → `deleteCategoryCascade` → `pop` 回列表
5. 取消或关闭对话框 → 留在编辑页，数据不变

删除过程中按钮 busy，防止重复提交。

---

## 3. 数据层

文件：`app/lib/data/daos/categories_dao.dart`

| API | 行为 |
|---|---|
| `countEntries(String categoryId)` | 返回该分类下 `spend_entries` 行数 |
| `deleteCategoryCascade(String categoryId)` | 事务内：先删该 `categoryId` 全部消费笔，再删分类行 |

- 移除或停止使用 `deleteIfNoEntries`（语义与新产品规则冲突）
- **不改** `tables.dart`、外键、`schemaVersion`
- 级联在应用层事务完成，不依赖 SQLite `ON DELETE CASCADE`

---

## 4. UI

文件：`app/lib/features/spend/pages/category_edit_page.dart`

- 「停用此分类」下方增加「删除此分类」（`HiveTextAction`，`danger: true`）
- 仅 `isEditing == true` 时显示
- 错误：
  - 分类已不存在：提示后返回列表
  - 删除失败：SnackBar，留在编辑页

---

## 5. 需求文档同步

更新 `docs/hive-需求说明.md`：

- §4.1 / §4.4：删除改为「二次确认后硬删分类，并级联删除其下全部消费笔；确认文案展示笔数」
- 去掉「有消费笔时禁止硬删 / 软隐藏」表述
- 停用规则不变（不删历史）

---

## 6. 测试

`app/test/` 新增（或扩充分类相关测试）：

- `countEntries` 计数正确（0 与多笔）
- `deleteCategoryCascade`：有多笔时，分类与对应笔均消失
- 同库其他分类及其笔仍在
- （可选）编辑页删除按钮仅编辑态可见——以 DAO 单测为主，UI 冒烟手工

验证命令：`cd app && flutter test`

---

## 7. 实现落点（摘要）

| 路径 | 变更 |
|---|---|
| `app/lib/data/daos/categories_dao.dart` | `countEntries`、`deleteCategoryCascade`；去掉 `deleteIfNoEntries` |
| `app/lib/features/spend/pages/category_edit_page.dart` | 删除入口与确认流 |
| `app/test/...` | cascade / count 测试 |
| `docs/hive-需求说明.md` | 删除规则同步 |
