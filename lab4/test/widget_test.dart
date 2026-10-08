import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:lab4/main.dart';
import 'package:lab4/tasks/task1_selection_controls.dart';
import 'package:lab4/tasks/task2_input_fields.dart';
import 'package:lab4/tasks/task3_buttons.dart';
import 'package:lab4/tasks/task4_indicators.dart';
import 'package:lab4/tasks/task5_dialogs.dart';
import 'package:lab4/tasks/task6_sliders_pickers.dart';
import 'package:lab4/tasks/task7_lists.dart';
import 'package:lab4/tasks/task8_grids.dart';
import 'package:lab4/tasks/task9_navigation.dart';
import 'package:lab4/tasks/task10_containers.dart';

Widget wrap(Widget page) => MaterialApp(home: page);

void main() {
  testWidgets('Home lists all tasks and opens a task page', (tester) async {
    await tester.pumpWidget(const MyApp());

    for (var i = 1; i <= 10; i++) {
      final entry = find.textContaining('Task $i:');
      await tester.scrollUntilVisible(entry, 100);
      expect(entry, findsOneWidget);
    }

    await tester.tap(find.text('Task 10: Structural Containers'));
    await tester.pumpAndSettle();
    expect(find.byType(HelpPage), findsOneWidget);
  });

  testWidgets('Task 1: terms checkbox enables the button', (tester) async {
    await tester.pumpWidget(wrap(const SettingsPage()));

    ElevatedButton button() =>
        tester.widget(find.widgetWithText(ElevatedButton, 'Continue'));
    expect(button().onPressed, isNull);

    await tester.tap(find.text('Agree to Terms'));
    await tester.pump();
    expect(button().onPressed, isNotNull);

    await tester.tap(find.text('Agree to Terms'));
    await tester.pump();
    expect(button().onPressed, isNull);

    await tester.tap(find.text('Dark Mode'));
    await tester.pump();
    final context = tester.element(find.text('Dark Mode'));
    expect(Theme.of(context).brightness, Brightness.dark);
  });

  testWidgets('Task 2: email needs @ and password can be shown', (
    tester,
  ) async {
    await tester.pumpWidget(wrap(const LoginPage()));
    final email = find.widgetWithText(TextFormField, 'Email');
    final password = find.widgetWithText(TextFormField, 'Password');

    TextField passwordField() => tester.widget(
      find.descendant(of: password, matching: find.byType(TextField)),
    );
    expect(passwordField().obscureText, isTrue);
    await tester.tap(find.byTooltip('Show password'));
    await tester.pump();
    expect(passwordField().obscureText, isFalse);

    await tester.enterText(email, 'student.example.com');
    await tester.enterText(password, 'secret');
    await tester.tap(find.text('Log In'));
    await tester.pump();
    expect(find.text('Email must contain an @ symbol'), findsOneWidget);
    expect(find.text('Logged in as student.example.com'), findsNothing);

    await tester.enterText(email, 'student@example.com');
    await tester.pump();
    expect(find.text('Email must contain an @ symbol'), findsNothing);
    await tester.tap(find.text('Log In'));
    await tester.pump();
    expect(find.text('Logged in as student@example.com'), findsOneWidget);
  });

  testWidgets('Task 3: FAB increments and Reset clears', (tester) async {
    await tester.pumpWidget(wrap(const CounterPage()));
    expect(find.text('0'), findsOneWidget);

    await tester.tap(find.byType(FloatingActionButton));
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pump();
    expect(find.text('2'), findsOneWidget);

    await tester.tap(find.text('Reset'));
    await tester.pump();
    expect(find.text('0'), findsOneWidget);
  });

  testWidgets('Task 4: spinner for 3 seconds, then undoable SnackBar', (
    tester,
  ) async {
    await tester.pumpWidget(wrap(const UploadPage()));

    await tester.tap(find.text('Upload file'));
    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 2900));
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 100));
    await tester.pumpAndSettle();
    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.text('Uploaded files: 1'), findsOneWidget);
    expect(find.text('File uploaded'), findsOneWidget);

    await tester.tap(find.text('Undo'));
    await tester.pumpAndSettle();
    expect(find.text('Uploaded files: 0'), findsOneWidget);
  });

  testWidgets('Task 5: delete confirmation and share sheet', (tester) async {
    await tester.pumpWidget(wrap(const FilesPage()));
    final deleteFirst = find.byTooltip('Delete').first;

    await tester.tap(deleteFirst);
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsOneWidget);
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(find.text('Vacation photos'), findsOneWidget);

    await tester.tap(deleteFirst);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();
    expect(find.text('Vacation photos'), findsNothing);
    expect(find.text('Deleted "Vacation photos"'), findsOneWidget);

    await tester.tap(find.byTooltip('Share').first);
    await tester.pumpAndSettle();
    expect(find.text('Share "Project report.pdf"'), findsOneWidget);
    expect(find.widgetWithText(ListTile, 'Email'), findsOneWidget);

    await tester.tap(find.text('Email'));
    await tester.pumpAndSettle();
    expect(find.byType(BottomSheet), findsNothing);
    expect(find.text('Shared "Project report.pdf" via Email'), findsOneWidget);
  });
  testWidgets('Task 6: slider updates percentage and date is shown', (
    tester,
  ) async {
    await tester.pumpWidget(wrap(const VolumePage()));
    expect(find.text('50%'), findsOneWidget);

    await tester.drag(find.byType(Slider), const Offset(-1000, 0));
    await tester.pump();
    expect(find.text('0%'), findsOneWidget);
    expect(find.byIcon(Icons.volume_off), findsOneWidget);

    await tester.drag(find.byType(Slider), const Offset(1000, 0));
    await tester.pump();
    expect(find.text('100%'), findsOneWidget);

    expect(find.text('No date selected'), findsOneWidget);
    await tester.tap(find.text('Pick a date'));
    await tester.pumpAndSettle();
    expect(find.byType(DatePickerDialog), findsOneWidget);
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();

    final localizations = MaterialLocalizations.of(
      tester.element(find.byType(VolumePage)),
    );
    expect(
      find.text(localizations.formatFullDate(DateTime.now())),
      findsOneWidget,
    );
  });

  testWidgets('Task 7: 20 lazy items that can be swiped away', (tester) async {
    await tester.pumpWidget(wrap(const ItemListPage()));
    expect(find.text('Item 1'), findsOneWidget);
    // Off-screen tiles are not built until they are scrolled into view.
    expect(find.text('Item 20'), findsNothing);
    await tester.scrollUntilVisible(find.text('Item 20'), 200);
    expect(find.text('Item 20'), findsOneWidget);
    expect(find.text('Item 21'), findsNothing);

    await tester.scrollUntilVisible(find.text('Item 1'), -200);
    await tester.drag(find.text('Item 1'), const Offset(-600, 0));
    await tester.pumpAndSettle();
    expect(find.text('Item 1'), findsNothing);
    expect(find.text('Item 1 dismissed'), findsOneWidget);

    await tester.tap(find.text('Undo'));
    await tester.pumpAndSettle();
    expect(find.text('Item 1'), findsOneWidget);
    expect(
      tester.getTopLeft(find.text('Item 1')).dy,
      lessThan(tester.getTopLeft(find.text('Item 2')).dy),
    );
  });

  testWidgets('Task 8: 2-column grid opens a full-screen preview', (
    tester,
  ) async {
    await tester.pumpWidget(wrap(const GalleryPage()));
    await tester.pumpAndSettle();

    final cells = find.byType(GestureDetector);
    final first = tester.getRect(cells.at(0));
    final second = tester.getRect(cells.at(1));
    final third = tester.getRect(cells.at(2));
    expect(second.top, first.top);
    expect(second.left - first.right, 8.0);
    expect(third.left, first.left);

    await tester.tap(cells.first);
    await tester.pumpAndSettle();
    expect(find.text('Photo 1'), findsOneWidget);
    expect(find.byType(InteractiveViewer), findsOneWidget);

    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.byType(InteractiveViewer), findsNothing);
  });

  testWidgets('Task 9: bottom navigation and top tabs', (tester) async {
    await tester.pumpWidget(wrap(const NewsPage()));
    expect(find.byType(TabBar), findsOneWidget);
    expect(find.text('World headline 1'), findsOneWidget);

    await tester.tap(find.text('Tech'));
    await tester.pumpAndSettle();
    expect(find.text('Tech headline 1'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.bookmark_border));
    await tester.pumpAndSettle();
    expect(find.byType(TabBar), findsNothing);
    expect(find.text('No saved articles yet'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.person_outline).last);
    await tester.pumpAndSettle();
    expect(find.text('Sign in to see your profile'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.newspaper_outlined));
    await tester.pumpAndSettle();
    expect(find.byType(TabBar), findsOneWidget);
    expect(find.text('Tech headline 1'), findsOneWidget);
  });

  testWidgets('Task 10: info card and expandable FAQ', (tester) async {
    await tester.pumpWidget(wrap(const HelpPage()));
    expect(find.text('Need more help?'), findsOneWidget);
    await tester.tap(find.byTooltip('Contact support'));
    await tester.pump();
    expect(find.text('Opening chat with support...'), findsOneWidget);

    expect(find.byType(ExpansionTile), findsNWidgets(5));
    final answer = find.textContaining('We will send you a link');
    expect(answer, findsNothing);

    await tester.tap(find.text('How do I reset my password?'));
    await tester.pumpAndSettle();
    expect(answer, findsOneWidget);

    await tester.tap(find.text('How do I reset my password?'));
    await tester.pumpAndSettle();
    expect(answer, findsNothing);
  });
}
