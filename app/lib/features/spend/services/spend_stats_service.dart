import 'package:drift/drift.dart';
import 'package:flutter/material.dart';

import '../../../data/db/app_database.dart';
import '../../../shared/money.dart';
import '../../../shared/theme/hive_colors.dart';

class YoyResult {
  const YoyResult({
    required this.thisYear,
    required this.lastYear,
    required this.delta,
    required this.percent,
  });

  final int thisYear;
  final int lastYear;
  final int delta;

  /// Null when lastYear is 0 (UI shows 新增 / —).
  final double? percent;
}

class SpendStatsService {
  SpendStatsService(this.db);

  final AppDatabase db;

  Future<Map<String, int>> sumByCategory(int year) async {
    final rows = await (db.select(db.spendEntries)
          ..where(
            (t) => t.status.equals('confirmed') & t.date.like('$year-%'),
          ))
        .get();
    final map = <String, int>{};
    for (final r in rows) {
      map[r.categoryId] = (map[r.categoryId] ?? 0) + r.amountCents;
    }
    return map;
  }

  Future<int> yearTotal(int year) async {
    final map = await sumByCategory(year);
    return map.values.fold<int>(0, (a, b) => a + b);
  }

  Future<List<int>> monthlySums(String categoryId, int year) async {
    final rows = await (db.select(db.spendEntries)
          ..where(
            (t) =>
                t.categoryId.equals(categoryId) &
                t.status.equals('confirmed') &
                t.date.like('$year-%'),
          ))
        .get();
    final months = List<int>.filled(12, 0);
    for (final r in rows) {
      final m = int.parse(r.date.substring(5, 7));
      months[m - 1] += r.amountCents;
    }
    return months;
  }

  Future<YoyResult> yoy(String categoryId, int year) async {
    final thisMap = await sumByCategory(year);
    final lastMap = await sumByCategory(year - 1);
    final thisYear = thisMap[categoryId] ?? 0;
    final lastYear = lastMap[categoryId] ?? 0;
    final delta = thisYear - lastYear;
    final percent = lastYear == 0 ? null : (delta / lastYear) * 100.0;
    return YoyResult(
      thisYear: thisYear,
      lastYear: lastYear,
      delta: delta,
      percent: percent,
    );
  }

  Future<List<SpendEntry>> listConfirmedEntries(String categoryId, int year) {
    return db.spendEntriesDao.listConfirmedEntries(categoryId, year);
  }

  Future<List<SpendEntry>> listYearEntries(String categoryId, int year) {
    return db.spendEntriesDao.listYearEntries(categoryId, year);
  }

  Future<YoyResult> yearYoy(int year) async {
    final thisYear = await yearTotal(year);
    final lastYear = await yearTotal(year - 1);
    final delta = thisYear - lastYear;
    final percent = lastYear == 0 ? null : (delta / lastYear) * 100.0;
    return YoyResult(
      thisYear: thisYear,
      lastYear: lastYear,
      delta: delta,
      percent: percent,
    );
  }
}

Color yoyColor(YoyResult r) {
  if (r.delta > 0) return HiveColors.danger;
  if (r.delta < 0) return HiveColors.accent;
  return HiveColors.dim;
}

String formatYoyText(YoyResult r, {int? vsYear}) {
  final vs = vsYear != null ? ' $vsYear' : '去年';
  if (r.percent == null) {
    if (r.lastYear == 0 && r.thisYear > 0) {
      return '较$vs新增 ${formatYuan(r.thisYear)}';
    }
    return vsYear != null ? '与 $vsYear 持平' : '与去年持平';
  }
  final sign = r.delta >= 0 ? '多' : '少';
  final pct = r.percent!.abs().toStringAsFixed(1);
  final prefix = vsYear != null ? '较 $vsYear ' : '较去年';
  return '$prefix$sign ${formatYuan(r.delta.abs())}（${r.delta >= 0 ? '+' : '-'}$pct%）';
}

String formatYoyHeadline(YoyResult r) {
  if (r.lastYear == 0 && r.thisYear == 0) {
    return '尚无可对比的去年数据';
  }
  if (r.delta == 0) return '与去年同类持平';
  if (r.lastYear == 0) {
    return '较去年新增 ${formatYuan(r.thisYear)}';
  }
  final sign = r.delta > 0 ? '多' : '少';
  return '较去年同类$sign ${formatYuan(r.delta.abs())}';
}
