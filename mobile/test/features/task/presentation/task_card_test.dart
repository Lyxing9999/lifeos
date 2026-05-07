import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lifeos_mobile/features/task/presentation/widgets/task_card.dart';

import '../../../helpers/task_test_data.dart';

void main() {
  group('TaskCard', () {
    testWidgets('shows task title', (tester) async {
      final task = TaskTestData.inboxTask(title: 'Buy shoes');

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TaskCard(task: task, onTap: () {}),
          ),
        ),
      );

      expect(find.text('Buy shoes'), findsOneWidget);
    });

    testWidgets('shows progress bar for progress task', (tester) async {
      final task = TaskTestData.progressTask(progress: 40);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TaskCard(task: task, onTap: () {}),
          ),
        ),
      );

      expect(find.text('40%'), findsOneWidget);
    });

    testWidgets('calls onComplete when check button tapped', (tester) async {
      var completed = false;
      final task = TaskTestData.inboxTask();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TaskCard(
              task: task,
              onTap: () {},
              onComplete: () {
                completed = true;
              },
            ),
          ),
        ),
      );

      await tester.tap(find.bySemanticsLabel('Complete task'));
      await tester.pump(const Duration(milliseconds: 500));

      expect(completed, true);
    });
  });
}
