import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/task_model.dart';
import '../providers/task_provider.dart';

class CategoryDrawer extends StatelessWidget {
  const CategoryDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TaskProvider>(context);
    final counts = provider.taskCounts;

    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.indigo, Colors.purple.shade400],
              ),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Icon(Icons.checklist, size: 48, color: Colors.white),
                SizedBox(height: 8),
                Text(
                  'GTD Manager',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Getting Things Done',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: TaskCategory.values.map((category) {
                final info = _getCategoryInfo(category);
                final count = counts[category] ?? 0;
                final isSelected = provider.currentCategory == category;

                return ListTile(
                  selected: isSelected,
                  selectedTileColor: (info['color'] as Color).withOpacity(0.1),
                  leading: Icon(
                    info['icon'] as IconData,
                    color: info['color'] as Color,
                  ),
                  title: Text(info['name'] as String),
                  subtitle: Text(info['desc'] as String),
                  trailing: count > 0
                      ? Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: info['color'] as Color,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      count.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  )
                      : null,
                  onTap: () {
                    provider.setCategory(category);
                    Navigator.pop(context);
                  },
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Map<String, dynamic> _getCategoryInfo(TaskCategory category) {
    switch (category) {
      case TaskCategory.inbox:
        return {'name': 'Inbox', 'desc': 'Thu thập', 'icon': Icons.inbox, 'color': Colors.grey[700]};
      case TaskCategory.next:
        return {'name': 'Next Actions', 'desc': 'Làm tiếp', 'icon': Icons.flash_on, 'color': Colors.blue};
      case TaskCategory.projects:
        return {'name': 'Projects', 'desc': 'Dự án', 'icon': Icons.folder_open, 'color': Colors.purple};
      case TaskCategory.waiting:
        return {'name': 'Waiting For', 'desc': 'Chờ đợi', 'icon': Icons.schedule, 'color': Colors.orange};
      case TaskCategory.calendar:
        return {'name': 'Calendar', 'desc': 'Lịch hẹn', 'icon': Icons.calendar_today, 'color': Colors.red};
      case TaskCategory.someday:
        return {'name': 'Someday/Maybe', 'desc': 'Sau này', 'icon': Icons.star_outline, 'color': Colors.green};
    }
  }
}