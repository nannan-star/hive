import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_app/data/db/app_database.dart';
import 'package:hive_app/data/seed.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  test('ensureSeedCategories inserts 7 defaults with parking 50000 cents',
      () async {
    await ensureSeedCategories(db);

    final rows = await db.select(db.categories).get();
    expect(rows, hasLength(7));

    final parking = rows.firstWhere((c) => c.name == '停车费');
    expect(parking.templateEnabled, isTrue);
    expect(parking.templateDefaultAmount, 50000);
    expect(parking.templateDay, 1);
  });

  test('ensureSeedCategories is idempotent', () async {
    await ensureSeedCategories(db);
    await ensureSeedCategories(db);

    final rows = await db.select(db.categories).get();
    expect(rows, hasLength(7));
  });
}
