# Habit Streaks

- **Package:** `habit_streaks`
- **Bundle ID:** `com.daeerah.habitstreaks`
- **Platforms:** android, ios

## Summary

A simple habit tracker. Add daily habits, check them off each day, and see current and best streaks. Data is stored locally on the device.

## Screens

- **Today** — List of habits with a check toggle for today and current streak badge; empty state
- **Add/Edit Habit** — Create or rename a habit
- **Habit Detail** — Current streak, best streak, last 5 weeks calendar grid, delete

## Decisions

- Provider-free: ValueNotifier/ChangeNotifier state
- Local storage via shared_preferences (JSON)
- Repository interface with in-memory implementation for tests
- Material 3 light and dark themes
- Streak = consecutive days ending today (or yesterday if today not yet done)
