import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/task_model.dart';
import '../providers/task_provider.dart';

class TaskItem extends StatelessWidget {
  final Task task;

  const TaskItem({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TaskProvider>(context, listen: false);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      elevation: task.isCompleted ? 1 : 3,
      child: ListTile(
        leading: Checkbox(
          value: task.isCompleted,
          onChanged: (_) => provider.toggleComplete(task.id),
        ),
        title: Text(
          task.title,
          style: TextStyle(
            decoration: task.isCompleted ? TextDecoration.lineThrough : null,
            color: task.isCompleted ? Colors.grey : Colors.black,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (task.description != null && task.description!.isNotEmpty)
              Text(task.description!, maxLines: 2, overflow: TextOverflow.ellipsis),
            if (task.dueDate != null)
              Row(
                children: [
                  const Icon(Icons.calendar_today, size: 12),
                  const SizedBox(width: 4),
                  Text(
                    DateFormat('dd/MM/yyyy').format(task.dueDate!),
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
          ],
        ),
        trailing: PopupMenuButton(
          itemBuilder: (context) => [
            ...TaskCategory.values
                .where((cat) => cat != task.category)
                .map((cat) => PopupMenuItem(
              child: Text('Chuyển đến ${_getCategoryName(cat)}'),
              onTap: () => provider.moveTask(task.id, cat),
            )),
            const PopupMenuDivider(),
            PopupMenuItem(
              child: const Text('Xóa', style: TextStyle(color: Colors.red)),
              onTap: () => provider.deleteTask(task.id),
            ),
          ],
        ),
      ),
    );
  }

  String _getCategoryName(TaskCategory category) {
    switch (category) {
      case TaskCategory.inbox: return 'Inbox';
      case TaskCategory.next: return 'Next Actions';
      case TaskCategory.projects: return 'Projects';
      case TaskCategory.waiting: return 'Waiting For';
      case TaskCategory.calendar: return 'Calendar';
      case TaskCategory.someday: return 'Someday/Maybe';
    }
  }
}