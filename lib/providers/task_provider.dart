import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/task_model.dart';
import '../services/notification_service.dart';

class TaskProvider with ChangeNotifier {
  final SharedPreferences _prefs;
  List<Task> _tasks = [];
  bool _showCompleted = false;
  TaskCategory _currentCategory = TaskCategory.inbox;
  String _searchQuery = '';
  List<String> _selectedTags = [];
  bool _cloudSyncEnabled = false;

  TaskProvider(this._prefs) {
    _loadTasks();
    _loadCloudSyncPreference();
  }

  List<Task> get tasks => _tasks;
  bool get showCompleted => _showCompleted;
  TaskCategory get currentCategory => _currentCategory;
  String get searchQuery => _searchQuery;
  List<String> get selectedTags => _selectedTags;
  bool get cloudSyncEnabled => _cloudSyncEnabled;

  List<Task> get filteredTasks {
    return _tasks.where((task) {
      final categoryMatch = task.category == _currentCategory;
      final completedMatch = _showCompleted || !task.isCompleted;
      final searchMatch = _searchQuery.isEmpty ||
          task.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          (task.description?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false);
      final tagMatch = _selectedTags.isEmpty ||
          task.tags.any((tag) => _selectedTags.contains(tag));

      return categoryMatch && completedMatch && searchMatch && tagMatch;
    }).toList();
  }

  List<String> get allTags {
    final tags = <String>{};
    for (var task in _tasks) {
      tags.addAll(task.tags);
    }
    return tags.toList()..sort();
  }

  Map<TaskCategory, int> get taskCounts {
    Map<TaskCategory, int> counts = {};
    for (var category in TaskCategory.values) {
      counts[category] = _tasks
          .where((t) => t.category == category && !t.isCompleted)
          .length;
    }
    return counts;
  }

  // Analytics data
  Map<String, dynamic> get weeklyStats {
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));

    final completedThisWeek = _tasks.where((t) =>
    t.isCompleted &&
        t.completedAt != null &&
        t.completedAt!.isAfter(weekAgo)
    ).length;

    final createdThisWeek = _tasks.where((t) =>
        t.createdAt.isAfter(weekAgo)
    ).length;

    return {
      'completed': completedThisWeek,
      'created': createdThisWeek,
      'productivity': createdThisWeek > 0
          ? (completedThisWeek / createdThisWeek * 100).toStringAsFixed(0)
          : '0',
    };
  }

  void setCategory(TaskCategory category) {
    _currentCategory = category;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void toggleTag(String tag) {
    if (_selectedTags.contains(tag)) {
      _selectedTags.remove(tag);
    } else {
      _selectedTags.add(tag);
    }
    notifyListeners();
  }

  void clearTagFilter() {
    _selectedTags.clear();
    notifyListeners();
  }

  void toggleShowCompleted() {
    _showCompleted = !_showCompleted;
    notifyListeners();
  }

  Future<void> addTask(Task task) async {
    _tasks.add(task);
    await _saveTasks();

    if (task.reminderTime != null) {
      await NotificationService.scheduleNotification(task);
    }

    if (_cloudSyncEnabled) {
      await _syncToCloud(task);
    }

    notifyListeners();
  }

  Future<void> updateTask(Task task) async {
    final index = _tasks.indexWhere((t) => t.id == task.id);
    if (index != -1) {
      _tasks[index] = task;
      await _saveTasks();

      if (_cloudSyncEnabled) {
        await _syncToCloud(task);
      }

      notifyListeners();
    }
  }

  Future<void> deleteTask(String id) async {
    _tasks.removeWhere((t) => t.id == id);
    await _saveTasks();

    if (_cloudSyncEnabled) {
      await FirebaseFirestore.instance.collection('tasks').doc(id).delete();
    }

    notifyListeners();
  }

  Future<void> toggleComplete(String id) async {
    final task = _tasks.firstWhere((t) => t.id == id);
    await updateTask(task.copyWith(
      isCompleted: !task.isCompleted,
      completedAt: !task.isCompleted ? DateTime.now() : null,
    ));
  }

  Future<void> moveTask(String id, TaskCategory newCategory) async {
    final task = _tasks.firstWhere((t) => t.id == id);
    await updateTask(task.copyWith(category: newCategory));
  }

  Future<void> toggleCloudSync() async {
    _cloudSyncEnabled = !_cloudSyncEnabled;
    await _prefs.setBool('cloudSyncEnabled', _cloudSyncEnabled);

    if (_cloudSyncEnabled) {
      await _syncAllToCloud();
    }

    notifyListeners();
  }

  Future<void> _syncToCloud(Task task) async {
    try {
      await FirebaseFirestore.instance
          .collection('tasks')
          .doc(task.id)
          .set(task.toMap());
    } catch (e) {
      debugPrint('Cloud sync error: $e');
    }
  }

  Future<void> _syncAllToCloud() async {
    for (var task in _tasks) {
      await _syncToCloud(task);
    }
  }

  Future<void> _loadCloudSyncPreference() async {
    _cloudSyncEnabled = _prefs.getBool('cloudSyncEnabled') ?? false;
  }

  Future<void> _saveTasks() async {
    final tasksJson = _tasks.map((t) => t.toMap()).toList();
    await _prefs.setString('tasks', json.encode(tasksJson));
  }

  Future<void> _loadTasks() async {
    final tasksString = _prefs.getString('tasks');
    if (tasksString != null) {
      final tasksList = json.decode(tasksString) as List;
      _tasks = tasksList.map((t) => Task.fromMap(t)).toList();
      notifyListeners();
    }
  }

  // Export/Import functionality
  String exportToJson() {
    final data = {
      'exportDate': DateTime.now().toIso8601String(),
      'tasks': _tasks.map((t) => t.toMap()).toList(),
    };
    return json.encode(data);
  }

  Future<void> importFromJson(String jsonString) async {
    try {
      final data = json.decode(jsonString);
      final tasksList = data['tasks'] as List;
      _tasks = tasksList.map((t) => Task.fromMap(t)).toList();
      await _saveTasks();
      notifyListeners();
    } catch (e) {
      throw Exception('Import failed: $e');
    }
  }
}