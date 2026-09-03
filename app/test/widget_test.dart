import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_app/app.dart';
import 'package:hive_app/data/db/app_database.dart';
import 'package:hive_app/data/providers.dart';
import 'package:hive_app/data/seed.dart';

void main() {
  testWidgets('HiveApp shows spend tab shell', (WidgetTester tester) async {
    final db = AppDatabase(NativeDatabase.memory());
    await ensureSeedCategories(db);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [databaseProvider.overrideWithValue(db)],
        child: const HiveApp(),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('消费'), findsWidgets);
    expect(find.text('自由'), findsOneWidget);

    await db.close();
  });
}
