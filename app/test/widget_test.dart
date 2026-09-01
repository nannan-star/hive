import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_app/app.dart';

void main() {
  testWidgets('HiveApp shows spend tab shell', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: HiveApp()));
    await tester.pumpAndSettle();

    expect(find.text('消费'), findsWidgets);
    expect(find.text('梦想'), findsOneWidget);
  });
}
