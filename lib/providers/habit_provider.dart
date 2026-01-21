import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/habit_model.dart';

class HabitProvider with ChangeNotifier {
  final SharedPreferences _prefs;
  List<Habit> _habits = [];

  HabitProvider(this._prefs) {
    _loadHabits();
  }

  List<Habit> get habits => _habits;

  Future<void> addHabit(Habit habit) async {
    _habits.add(habit);
    await _saveHabits();
    notifyListeners();
  }

  Future<void> toggleHabitToday(String habitId) async {
    final habit = _habits.firstWhere((h) => h.id == habitId);
    final today = DateTime.now();

    if (habit.isCompletedToday()) {
      habit.completedDates.removeWhere((date) =>
      date.year == today.year &&
          date.month == today.month &&
          date.day == today.day
      );
    } else {
      habit.completedDates.add(DateTime(today.year, today.month, today.day));
    }

    await _saveHabits();
    notifyListeners();
  }

  Future<void> deleteHabit(String id) async {
    _habits.removeWhere((h) => h.id == id);
    await _saveHabits();
    notifyListeners();
  }

  Future<void> _saveHabits() async {
    final habitsJson = _habits.map((h) => h.toMap()).toList();
    await _prefs.setString('habits', json.encode(habitsJson));
  }

  Future<void> _loadHabits() async {
    final habitsString = _prefs.getString('habits');
    if (habitsString != null) {
      final habitsList = json.decode(habitsString) as List;
      _habits = habitsList.map((h) => Habit.fromMap(h)).toList();
      notifyListeners();
    }
  }
}
