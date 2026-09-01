import 'package:drift/drift.dart';

import '../../../data/db/app_database.dart';
import '../../../shared/dates.dart';

class TemplateService {
  /// Ensures one template pending entry per enabled+templated category
  /// for the natural month of [today].
  static Future<void> ensureMonthTemplates(
    AppDatabase db,
    DateTime today,
  ) async {
    final year = today.year;
    final month = today.month;
    final cats = await (db.select(db.categories)
          ..where(
            (t) => t.enabled.equals(true) & t.templateEnabled.equals(true),
          ))
        .get();

    for (final cat in cats) {
      final hasSlot =
          await db.spendEntriesDao.hasTemplateSlot(cat.id, year, month);
      if (hasSlot) continue;

      final day = cat.templateDay.clamp(1, 28);
      final date = formatDateYmd(DateTime(year, month, day));
      await db.spendEntriesDao.insertEntry(
        categoryId: cat.id,
        amountCents: cat.templateDefaultAmount ?? 0,
        date: date,
        note: cat.templateDefaultNote,
        source: 'template',
        status: 'pending',
      );
    }
  }
}
