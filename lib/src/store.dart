import 'package:flutter/foundation.dart';
import 'habit.dart';
import 'repository.dart';

class HabitStore extends ChangeNotifier {
  HabitStore(this.repo, {DateTime Function()? clock})
      : now = clock ?? DateTime.now;

  final HabitRepository repo;
  final DateTime Function() now;
  List<Habit> habits = [];
  bool loaded = false;

  Future<void> init() async {
    habits = await repo.load();
    loaded = true;
    notifyListeners();
  }

  Future<void> _persist() async {
    notifyListeners();
    await repo.save(habits);
  }

  Future<void> add(String name) async {
    final n = name.trim();
    if (n.isEmpty) return;
    habits.add(Habit(id: DateTime.now().microsecondsSinceEpoch.toString(), name: n));
    await _persist();
  }

  Future<void> rename(Habit h, String name) async {
    final n = name.trim();
    if (n.isEmpty) return;
    h.name = n;
    await _persist();
  }

  Future<void> toggle(Habit h, DateTime day) async {
    final k = Habit.key(day);
    if (!h.done.remove(k)) h.done.add(k);
    await _persist();
  }

  Future<void> remove(Habit h) async {
    habits.remove(h);
    await _persist();
  }
}
