// Unit tests cho models: kiểm tra serialize/deserialize (toMap/fromMap)
// vì đây là nền tảng của lưu trữ local (shared_preferences) và cloud sync.

import 'package:flutter_test/flutter_test.dart';
import 'package:vipinfo/models/task_model.dart';
import 'package:vipinfo/models/habit_model.dart';

void main() {
  group('Task model', () {
    test('toMap → fromMap giữ nguyên dữ liệu', () {
      final task = Task(
        id: 't1',
        title: 'Viết báo cáo',
        description: 'Báo cáo tuần',
        category: TaskCategory.next,
        createdAt: DateTime(2026, 10, 23, 8, 30),
        dueDate: DateTime(2026, 10, 25),
        priority: TaskPriority.high,
        tags: const ['work', 'urgent'],
        pomodoroCount: 3,
      );

      final restored = Task.fromMap(task.toMap());

      expect(restored.id, task.id);
      expect(restored.title, task.title);
      expect(restored.description, task.description);
      expect(restored.category, TaskCategory.next);
      expect(restored.isCompleted, false);
      expect(restored.createdAt, task.createdAt);
      expect(restored.dueDate, task.dueDate);
      expect(restored.priority, TaskPriority.high);
      expect(restored.tags, task.tags);
      expect(restored.pomodoroCount, 3);
      expect(restored.completedAt, isNull);
    });

    test('fromMap chịu được dữ liệu thiếu (giá trị mặc định)', () {
      final restored = Task.fromMap({
        'id': 't2',
        'title': 'Task tối thiểu',
        'createdAt': DateTime(2026, 1, 1).toIso8601String(),
      });

      expect(restored.category, TaskCategory.inbox);
      expect(restored.isCompleted, false);
      expect(restored.priority, TaskPriority.medium);
      expect(restored.tags, isEmpty);
      expect(restored.pomodoroCount, 0);
    });

    test('copyWith chỉ thay trường được truyền', () {
      final task = Task(
        id: 't3',
        title: 'Gốc',
        category: TaskCategory.inbox,
        createdAt: DateTime(2026, 1, 1),
      );

      final moved = task.copyWith(category: TaskCategory.projects);

      expect(moved.id, 't3');
      expect(moved.title, 'Gốc');
      expect(moved.category, TaskCategory.projects);
    });
  });

  group('Habit model', () {
    test('currentStreak = 0 khi chưa hoàn thành ngày nào', () {
      final habit = Habit(id: 'h1', name: 'Thiền');
      expect(habit.currentStreak, 0);
    });

    test('currentStreak đếm chuỗi ngày liên tiếp tính đến hôm nay', () {
      final today = DateTime.now();
      final habit = Habit(
        id: 'h2',
        name: 'Đọc sách',
        completedDates: [
          today,
          today.subtract(const Duration(days: 1)),
          today.subtract(const Duration(days: 2)),
          // đứt chuỗi: thiếu ngày -3
          today.subtract(const Duration(days: 5)),
        ],
      );
      expect(habit.currentStreak, 3);
    });
  });
}
