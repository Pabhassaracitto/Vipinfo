import 'dart:convert';

class Habit {
  final String id;
  String name;
  String? description;
  List<DateTime> completedDates;
  int targetDays;
  String frequency; // daily, weekly, custom

  Habit({
    required this.id,
    required this.name,
    this.description,
    this.completedDates = const [],
    this.targetDays = 21,
    this.frequency = 'daily',
  });

  int get currentStreak {
    if (completedDates.isEmpty) return 0;

    int streak = 0;
    DateTime checkDate = DateTime.now();

    while (true) {
      bool found = completedDates.any((date) =>
      date.year == checkDate.year &&
          date.month == checkDate.month &&
          date.day == checkDate.day
      );

      if (!found) break;
      streak++;
      checkDate = checkDate.subtract(const Duration(days: 1));
    }

    return streak;
  }

  bool isCompletedToday() {
    final today = DateTime.now();
    return completedDates.any((date) =>
    date.year == today.year &&
        date.month == today.month &&
        date.day == today.day
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'completedDates': completedDates.map((d) => d.toIso8601String()).toList(),
      'targetDays': targetDays,
      'frequency': frequency,
    };
  }

  factory Habit.fromMap(Map<String, dynamic> map) {
    return Habit(
      id: map['id'],
      name: map['name'],
      description: map['description'],
      completedDates: (map['completedDates'] as List).map((d) => DateTime.parse(d)).toList(),
      targetDays: map['targetDays'] ?? 21,
      frequency: map['frequency'] ?? 'daily',
    );
  }
}