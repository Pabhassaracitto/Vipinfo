import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../providers/habit_provider.dart';
import '../models/habit_model.dart';

class HabitsScreen extends StatelessWidget {
  const HabitsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<HabitProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('✨ Habit Tracker'),
        centerTitle: true,
      ),
      body: provider.habits.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.auto_awesome, size: 80, color: Colors.grey),
            const SizedBox(height: 16),
            const Text('Chưa có thói quen nào', style: TextStyle(fontSize: 18)),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: () => _showAddHabitDialog(context),
              icon: const Icon(Icons.add),
              label: const Text('Tạo thói quen mới'),
            ),
          ],
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: provider.habits.length,
        itemBuilder: (context, index) {
          final habit = provider.habits[index];
          return _HabitCard(habit: habit);
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddHabitDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('Thêm thói quen'),
      ),
    );
  }

  void _showAddHabitDialog(BuildContext context) {
    final nameController = TextEditingController();
    final descController = TextEditingController();
    int targetDays = 21;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Tạo thói quen mới'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Tên thói quen *'),
                  autofocus: true,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descController,
                  decoration: const InputDecoration(labelText: 'Mô tả'),
                  maxLines: 2,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Text('Mục tiêu:'),
                    Expanded(
                      child: Slider(
                        value: targetDays.toDouble(),
                        min: 7,
                        max: 90,
                        divisions: 83,
                        label: '$targetDays ngày',
                        onChanged: (value) => setState(() => targetDays = value.toInt()),
                      ),
                    ),
                    Text('$targetDays ngày'),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Hủy')),
            ElevatedButton(
              onPressed: nameController.text.isEmpty ? null : () {
                final habit = Habit(
                  id: const Uuid().v4(),
                  name: nameController.text,
                  description: descController.text.isEmpty ? null : descController.text,
                  targetDays: targetDays,
                );
                Provider.of<HabitProvider>(context, listen: false).addHabit(habit);
                Navigator.pop(context);
              },
              child: const Text('Tạo'),
            ),
          ],
        ),
      ),
    );
  }
}

class _HabitCard extends StatelessWidget {
  final Habit habit;

  const _HabitCard({required this.habit});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<HabitProvider>(context, listen: false);
    final streak = habit.currentStreak;
    final progress = (streak / habit.targetDays * 100).clamp(0, 100).toInt();
    final isCompletedToday = habit.isCompletedToday();

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(habit.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      if (habit.description != null)
                        Text(habit.description!, style: const TextStyle(color: Colors.grey)),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => provider.deleteHabit(habit.id),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Progress bar
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Streak: $streak/${habit.targetDays} ngày'),
                    Text('$progress%', style: const TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: progress / 100,
                  minHeight: 8,
                  borderRadius: BorderRadius.circular(4),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Check-in button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => provider.toggleHabitToday(habit.id),
                icon: Icon(isCompletedToday ? Icons.check_circle : Icons.circle_outlined),
                label: Text(isCompletedToday ? '✅ Đã hoàn thành hôm nay' : 'Check-in hôm nay'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isCompletedToday ? Colors.green : null,
                  foregroundColor: isCompletedToday ? Colors.white : null,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}