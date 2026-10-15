import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:lab5/main.dart' as lab5;

void main() {
  testWidgets('Menu opens a task and comes back', (WidgetTester tester) async {
    lab5.main();
    await tester.pumpAndSettle();

    await tester.tap(find.text('Task 1.2'));
    await tester.pumpAndSettle();
    expect(find.text('A'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.list));
    await tester.pumpAndSettle();
    expect(find.text('Task 1.2'), findsOneWidget);
  });
}
