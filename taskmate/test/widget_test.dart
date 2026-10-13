import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taskmate/main.dart';

void main() {
  Future<void> pumpDashboard(
    WidgetTester tester, {
    Size size = const Size(1280, 900),
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(const TaskMateApp());
    await tester.pumpAndSettle();
  }

  testWidgets('dashboard shows summary and seeded tasks', (tester) async {
    await pumpDashboard(tester);

    expect(find.text('Good morning, Alex 👋'), findsOneWidget);
    expect(find.text('Total tasks'), findsOneWidget);
    expect(find.text('Review Q3 product roadmap'), findsOneWidget);
    expect(find.text('Pick up groceries'), findsOneWidget);
  });

  testWidgets('dashboard adapts to small and large screen constraints', (
    tester,
  ) async {
    await pumpDashboard(tester, size: Size.zero);
    expect(tester.takeException(), isNull);

    tester.view.physicalSize = const Size(320, 568);
    await tester.pumpAndSettle();
    expect(find.text('Good morning, Alex 👋'), findsOneWidget);
    expect(tester.takeException(), isNull);

    tester.view.physicalSize = const Size(1600, 1000);
    await tester.pumpAndSettle();
    expect(find.text('Good morning, Alex 👋'), findsOneWidget);
    expect(tester.takeException(), isNull);

    tester.view.physicalSize = const Size(320, 568);
    await tester.pumpAndSettle();
    expect(find.text('Good morning, Alex 👋'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('user can add a task with a valid title', (tester) async {
    await pumpDashboard(tester);

    await tester.tap(find.byKey(const Key('add-task-button')));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('task-title-field')),
      'Plan sprint retro',
    );
    await tester.tap(find.byKey(const Key('save-task-button')));
    await tester.pumpAndSettle();

    expect(find.text('Plan sprint retro'), findsOneWidget);
    expect(find.text('Total tasks'), findsOneWidget);
    expect(
      tester.widget<Text>(find.byKey(const Key('summary-total-tasks'))).data,
      '6',
    );
  });

  testWidgets('user can mark a task complete', (tester) async {
    await pumpDashboard(tester);

    await tester.tap(find.byKey(const Key('task-checkbox-1')));
    await tester.pumpAndSettle();

    expect(find.text('Task completed'), findsOneWidget);
    expect(
      tester.widget<Checkbox>(find.byKey(const Key('task-checkbox-1'))).value,
      isTrue,
    );
    expect(find.text('2'), findsOneWidget);
  });

  testWidgets('task filters show only the selected status', (tester) async {
    await pumpDashboard(tester);

    await tester.tap(find.byKey(const Key('filter-completed')));
    await tester.pumpAndSettle();

    expect(find.text('Book a table for dinner'), findsOneWidget);
    expect(find.text('Review Q3 product roadmap'), findsNothing);
  });

  testWidgets('user can reset tasks to the demo data', (tester) async {
    await pumpDashboard(tester, size: const Size(390, 844));

    await tester.tap(find.byKey(const Key('add-task-button')));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('task-title-field')),
      'Temporary task',
    );
    await tester.tap(find.byKey(const Key('save-task-button')));
    await tester.pumpAndSettle();
    expect(find.text('Temporary task'), findsOneWidget);

    await tester.tap(find.byTooltip('Open navigation'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Settings').last);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('reset-demo-data-button')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Reset tasks'));
    await tester.pumpAndSettle();

    expect(find.text('Temporary task'), findsNothing);
    expect(find.text('Good morning, Alex 👋'), findsOneWidget);
    expect(
      tester.widget<Text>(find.byKey(const Key('summary-total-tasks'))).data,
      '5',
    );
  });
}
