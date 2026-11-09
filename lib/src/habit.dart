class Habit {
  Habit({required this.id, required this.name, Set<String>? done})
      : done = done ?? <String>{};

  final String id;
  String name;

  /// Completed days as yyyy-MM-dd keys.
  final Set<String> done;

  static String key(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  static DateTime _parse(String k) {
    final p = k.split('-').map(int.parse).toList();
    return DateTime(p[0], p[1], p[2]);
  }

  bool isDone(DateTime d) => done.contains(key(d));

  /// Consecutive days ending today, or yesterday if today isn't done yet.
  int currentStreak(DateTime today) {
    var day = DateTime(today.year, today.month, today.day);
    if (!isDone(day)) day = DateTime(day.year, day.month, day.day - 1);
    var n = 0;
    while (isDone(day)) {
      n++;
      day = DateTime(day.year, day.month, day.day - 1);
    }
    return n;
  }

  int get bestStreak {
    final days = done.map(_parse).toList()..sort();
    var best = 0, run = 0;
    DateTime? prev;
    for (final d in days) {
      if (prev != null && DateTime(prev.year, prev.month, prev.day + 1) == d) {
        run++;
      } else {
        run = 1;
      }
      if (run > best) best = run;
      prev = d;
    }
    return best;
  }

  Map<String, dynamic> toJson() =>
      {'id': id, 'name': name, 'done': done.toList()};

  factory Habit.fromJson(Map<String, dynamic> j) => Habit(
        id: j['id'] as String,
        name: j['name'] as String,
        done: (j['done'] as List).cast<String>().toSet(),
      );
}
