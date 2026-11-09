import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'habit.dart';

abstract class HabitRepository {
  Future<List<Habit>> load();
  Future<void> save(List<Habit> habits);
}

class InMemoryHabitRepository implements HabitRepository {
  InMemoryHabitRepository([List<Habit>? initial]) : _habits = initial ?? [];
  List<Habit> _habits;

  @override
  Future<List<Habit>> load() async => _habits;

  @override
  Future<void> save(List<Habit> habits) async => _habits = habits;
}

class PrefsHabitRepository implements HabitRepository {
  static const _k = 'habits_v1';

  @override
  Future<List<Habit>> load() async {
    final p = await SharedPreferences.getInstance();
    final s = p.getString(_k);
    if (s == null) return [];
    return (jsonDecode(s) as List)
        .map((e) => Habit.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> save(List<Habit> habits) async {
    final p = await SharedPreferences.getInstance();
    await p.setString(_k, jsonEncode(habits.map((h) => h.toJson()).toList()));
  }
}
