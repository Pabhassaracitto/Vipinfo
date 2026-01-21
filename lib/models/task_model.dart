import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';

enum TaskCategory { inbox, next, projects, waiting, calendar, someday }
enum TaskPriority { none, low, medium, high, urgent }

class Task {
  final String id;
  String title;
  String? description;
  TaskCategory category;
  bool isCompleted;
  DateTime createdAt;
  DateTime? dueDate;
  TaskPriority priority;
  List<String> tags;
  String? reminderTime;
  int? pomodoroCount;
  DateTime? completedAt;

  Task({
    required this.id,
    required this.title,
    this.description,
    required this.category,
    this.isCompleted = false,
    required this.createdAt,
    this.dueDate,
    this.priority = TaskPriority.medium,
    this.tags = const [],
    this.reminderTime,
    this.pomodoroCount = 0,
    this.completedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category.index,
      'isCompleted': isCompleted,
      'createdAt': createdAt.toIso8601String(),
      'dueDate': dueDate?.toIso8601String(),
      'priority': priority.index,
      'tags': tags,
      'reminderTime': reminderTime,
      'pomodoroCount': pomodoroCount,
      'completedAt': completedAt?.toIso8601String(),
    };
  }

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      category: TaskCategory.values[map['category'] ?? 0],
      isCompleted: map['isCompleted'] ?? false,
      createdAt: DateTime.parse(map['createdAt']),
      dueDate: map['dueDate'] != null ? DateTime.parse(map['dueDate']) : null,
      priority: TaskPriority.values[map['priority'] ?? 2],
      tags: List<String>.from(map['tags'] ?? []),
      reminderTime: map['reminderTime'],
      pomodoroCount: map['pomodoroCount'] ?? 0,
      completedAt: map['completedAt'] != null ? DateTime.parse(map['completedAt']) : null,
    );
  }

  factory Task.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    data['id'] = doc.id;
    return Task.fromMap(data);
  }

  String toJson() => json.encode(toMap());
  factory Task.fromJson(String source) => Task.fromMap(json.decode(source));

  Task copyWith({
    String? title,
    String? description,
    TaskCategory? category,
    bool? isCompleted,
    DateTime? dueDate,
    TaskPriority? priority,
    List<String>? tags,
    String? reminderTime,
    int? pomodoroCount,
    DateTime? completedAt,
  }) {
    return Task(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt,
      dueDate: dueDate ?? this.dueDate,
      priority: priority ?? this.priority,
      tags: tags ?? this.tags,
      reminderTime: reminderTime ?? this.reminderTime,
      pomodoroCount: pomodoroCount ?? this.pomodoroCount,
      completedAt: completedAt ?? this.completedAt,
    );
  }
}