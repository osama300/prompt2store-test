import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habit_streaks/main.dart';
import 'package:habit_streaks/src/habit.dart';
import 'package:habit_streaks/src/repository.dart';
import 'package:habit_streaks/src/store.dart';

void main() {
  final today = DateTime(2026, 5, 10);
  String k(int daysAgo) =>
      Habit.key(DateTime(today.year, today.month, today.day - daysAgo));

  test('streak counts consecutive days ending today', () {
    final h = Habit(id: '1', name: 'x', done: {k(0), k(1), k(2), k(4)});
    expect(h.currentStreak(today), 3);
    expect(h.bestStreak, 3);
  });

  test('streak survives if today not done yet', () {
    final h = Habit(id: '1', name: 'x', done: {k(1), k(2)});
    expect(h.currentStreak(today), 2);
  });

  test('streak resets after a missed day', () {
    final h = Habit(id: '1', name: 'x', done: {k(2), k(3), k(4)});
    expect(h.currentStreak(today), 0);
    expect(h.bestStreak, 3);
  });

  test('json round trip', () {
    final h = Habit(id: '1', name: 'Read', done: {k(0)});
    final r = Habit.fromJson(h.toJson());
    expect(r.name, 'Read');
    expect(r.done, h.done);
  });

  testWidgets('add a habit and check it off', (tester) async {
    final store = HabitStore(InMemoryHabitRepository(), clock: () => today);
    await store.init();
    await tester.pumpWidget(HabitApp(store: store));
    expect(find.text('No habits yet'), findsOneWidget);

    await tester.tap(find.text('New habit'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Meditate');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(find.text('Meditate'), findsOneWidget);
    expect(find.text('No streak yet'), findsOneWidget);

    await tester.tap(find.byType(Checkbox));
    await tester.pumpAndSettle();
    expect(find.text('1-day streak'), findsOneWidget);
    expect(find.text('1 of 1 done'), findsOneWidget);
  });
}
