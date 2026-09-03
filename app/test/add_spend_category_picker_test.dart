import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_app/data/db/app_database.dart';
import 'package:hive_app/features/spend/pages/add_spend_page.dart';

void main() {
  testWidgets('category picker sheet scrolls when there are many types',
      (tester) async {
    tester.view.physicalSize = const Size(390, 700);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final categories = [
      for (var i = 0; i < 30; i++)
        Category(
          id: 'id-$i',
          name: '分类-$i',
          sortOrder: i,
          enabled: true,
          templateEnabled: false,
          templateDay: 1,
          createdAt: 0,
        ),
    ];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () {
                showCategoryPicker(
                  context: context,
                  categories: categories,
                  selectedId: 'id-0',
                );
              },
              child: const Text('open'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    expect(find.text('选择分类'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.scrollUntilVisible(
      find.text('分类-29'),
      200,
      scrollable: find.descendant(
        of: find.byType(BottomSheet),
        matching: find.byType(Scrollable),
      ),
    );
    expect(find.text('分类-29'), findsOneWidget);
  });
}
