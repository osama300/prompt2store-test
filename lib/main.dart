import 'package:flutter/material.dart';
import 'src/repository.dart';
import 'src/screens.dart';
import 'src/store.dart';

void main() {
  runApp(HabitApp(store: HabitStore(PrefsHabitRepository())..init()));
}

class HabitApp extends StatelessWidget {
  const HabitApp({super.key, required this.store});
  final HabitStore store;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Habit Streaks',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          useMaterial3: true,
          colorSchemeSeed: Colors.teal,
          brightness: Brightness.light),
      darkTheme: ThemeData(
          useMaterial3: true,
          colorSchemeSeed: Colors.teal,
          brightness: Brightness.dark),
      home: TodayScreen(store: store),
    );
  }
}
