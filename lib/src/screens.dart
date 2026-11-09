import 'package:flutter/material.dart';
import 'habit.dart';
import 'store.dart';

class TodayScreen extends StatelessWidget {
  const TodayScreen({super.key, required this.store});
  final HabitStore store;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: store,
      builder: (context, _) {
        final today = store.now();
        final doneCount = store.habits.where((h) => h.isDone(today)).length;
        return Scaffold(
          appBar: AppBar(title: const Text('Today')),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => EditHabitScreen(store: store))),
            icon: const Icon(Icons.add),
            label: const Text('New habit'),
          ),
          body: !store.loaded
              ? const Center(child: CircularProgressIndicator())
              : store.habits.isEmpty
                  ? const _Empty()
                  : ListView(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Text(
                              '$doneCount of ${store.habits.length} done',
                              style: Theme.of(context).textTheme.titleMedium),
                        ),
                        for (final h in store.habits)
                          _HabitTile(store: store, habit: h, today: today),
                      ],
                    ),
        );
      },
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty();
  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.local_fire_department_outlined,
              size: 72, color: t.colorScheme.primary),
          const SizedBox(height: 16),
          Text('No habits yet', style: t.textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(
              'Add your first habit and check it off every day to build a streak.',
              textAlign: TextAlign.center,
              style: t.textTheme.bodyMedium),
        ]),
      ),
    );
  }
}

class _HabitTile extends StatelessWidget {
  const _HabitTile(
      {required this.store, required this.habit, required this.today});
  final HabitStore store;
  final Habit habit;
  final DateTime today;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final streak = habit.currentStreak(today);
    final done = habit.isDone(today);
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) =>
                    HabitDetailScreen(store: store, habit: habit))),
        leading: Checkbox(
          value: done,
          onChanged: (_) => store.toggle(habit, today),
        ),
        title: Text(habit.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: done
                ? const TextStyle(decoration: TextDecoration.lineThrough)
                : null),
        subtitle: Text(streak == 0 ? 'No streak yet' : '$streak-day streak'),
        trailing: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.local_fire_department,
              color: streak > 0 ? Colors.orange : t.disabledColor),
          const SizedBox(width: 2),
          Text('$streak', style: t.textTheme.titleMedium),
        ]),
      ),
    );
  }
}

class EditHabitScreen extends StatefulWidget {
  const EditHabitScreen({super.key, required this.store, this.habit});
  final HabitStore store;
  final Habit? habit;

  @override
  State<EditHabitScreen> createState() => _EditHabitScreenState();
}

class _EditHabitScreenState extends State<EditHabitScreen> {
  late final TextEditingController c =
      TextEditingController(text: widget.habit?.name ?? '');

  @override
  void dispose() {
    c.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (c.text.trim().isEmpty) return;
    final h = widget.habit;
    if (h == null) {
      await widget.store.add(c.text);
    } else {
      await widget.store.rename(h, c.text);
    }
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(widget.habit == null ? 'New habit' : 'Edit habit')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          TextField(
            controller: c,
            autofocus: true,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(
                labelText: 'Habit name',
                hintText: 'e.g. Read 10 pages',
                border: OutlineInputBorder()),
            onSubmitted: (_) => _save(),
          ),
          const SizedBox(height: 16),
          SizedBox(
              width: double.infinity,
              child: FilledButton(onPressed: _save, child: const Text('Save'))),
        ]),
      ),
    );
  }
}

class HabitDetailScreen extends StatelessWidget {
  const HabitDetailScreen(
      {super.key, required this.store, required this.habit});
  final HabitStore store;
  final Habit habit;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: store,
      builder: (context, _) {
        final t = Theme.of(context);
        final today = store.now();
        final start = DateTime(today.year, today.month, today.day - 34);
        return Scaffold(
          appBar: AppBar(
              title: Text(habit.name, overflow: TextOverflow.ellipsis),
              actions: [
                IconButton(
                  tooltip: 'Edit',
                  icon: const Icon(Icons.edit_outlined),
                  onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) =>
                              EditHabitScreen(store: store, habit: habit))),
                ),
                IconButton(
                  tooltip: 'Delete',
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () async {
                    await store.remove(habit);
                    if (context.mounted) Navigator.pop(context);
                  },
                ),
              ]),
          body: ListView(padding: const EdgeInsets.all(16), children: [
            Row(children: [
              Expanded(
                  child: _Stat(
                      label: 'Current streak',
                      value: habit.currentStreak(today))),
              const SizedBox(width: 12),
              Expanded(
                  child: _Stat(label: 'Best streak', value: habit.bestStreak)),
            ]),
            const SizedBox(height: 24),
            Text('Last 5 weeks', style: t.textTheme.titleMedium),
            const SizedBox(height: 12),
            GridView.count(
              crossAxisCount: 7,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 6,
              crossAxisSpacing: 6,
              children: [
                for (var i = 0; i < 35; i++)
                  Builder(builder: (_) {
                    final d =
                        DateTime(start.year, start.month, start.day + i);
                    final done = habit.isDone(d);
                    return InkWell(
                      borderRadius: BorderRadius.circular(8),
                      onTap: () => store.toggle(habit, d),
                      child: Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: done
                              ? t.colorScheme.primary
                              : t.colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text('${d.day}',
                            style: TextStyle(
                                color: done
                                    ? t.colorScheme.onPrimary
                                    : t.colorScheme.onSurfaceVariant)),
                      ),
                    );
                  }),
              ],
            ),
            const SizedBox(height: 8),
            Text('Tap a day to mark or unmark it.',
                style: t.textTheme.bodySmall),
          ]),
        );
      },
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value});
  final String label;
  final int value;
  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            const Icon(Icons.local_fire_department, color: Colors.orange),
            const SizedBox(width: 4),
            Text('$value', style: t.textTheme.headlineMedium),
          ]),
          Text(label, style: t.textTheme.bodyMedium),
        ]),
      ),
    );
  }
}
