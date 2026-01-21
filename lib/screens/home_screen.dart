import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/task_model.dart';
import '../providers/task_provider.dart';
import '../widgets/task_list.dart';
import '../widgets/category_drawer.dart';
import '../widgets/add_task_dialog.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TaskProvider>(context);
    final category = provider.currentCategory;
    final categoryInfo = _getCategoryInfo(category);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              categoryInfo['name']!,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              categoryInfo['desc']!,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
            ),
          ],
        ),
        backgroundColor: categoryInfo['color'] as Color,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(
              provider.showCompleted
                  ? Icons.visibility_off
                  : Icons.visibility,
            ),
            onPressed: () => provider.toggleShowCompleted(),
            tooltip: provider.showCompleted
                ? 'Ẩn đã hoàn thành'
                : 'Hiện đã hoàn thành',
          ),
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => _showGTDInfo(context),
          ),
        ],
      ),
      drawer: const CategoryDrawer(),
      body: Column(
        children: [
          _buildStatsBar(context, provider),
          const Expanded(child: TaskList()),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddTaskDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('Thêm việc'),
        backgroundColor: categoryInfo['color'] as Color,
      ),
    );
  }

  Widget _buildStatsBar(BuildContext context, TaskProvider provider) {
    final totalTasks = provider.filteredTasks.length;
    final completedTasks = provider.filteredTasks.where((t) => t.isCompleted).length;
    final percentage = totalTasks > 0 ? (completedTasks / totalTasks * 100).toStringAsFixed(0) : '0';

    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.grey[100],
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _statItem('Tổng số', totalTasks.toString(), Icons.list),
          _statItem('Đã xong', completedTasks.toString(), Icons.check_circle),
          _statItem('Hoàn thành', '$percentage%', Icons.trending_up),
        ],
      ),
    );
  }

  Widget _statItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: Colors.indigo),
            const SizedBox(width: 4),
            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.indigo,
              ),
            ),
          ],
        ),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
      ],
    );
  }

  void _showAddTaskDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const AddTaskDialog(),
    );
  }

  void _showGTDInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('💡 Quy tắc GTD'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('🎯 Quy tắc 2 phút:', style: TextStyle(fontWeight: FontWeight.bold)),
              Text('Nếu việc gì mất dưới 2 phút, làm ngay!\n'),
              Text('📋 4D Framework:', style: TextStyle(fontWeight: FontWeight.bold)),
              Text('• Do (Làm): Việc quan trọng và khẩn cấp'),
              Text('• Delegate (Giao): Việc người khác làm tốt hơn'),
              Text('• Defer (Hoãn): Lên lịch làm sau'),
              Text('• Delete (Xóa): Việc không cần thiết\n'),
              Text('🔄 Weekly Review:', style: TextStyle(fontWeight: FontWeight.bold)),
              Text('Mỗi tuần xem lại tất cả danh mục và cập nhật ưu tiên.'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }

  Map<String, dynamic> _getCategoryInfo(TaskCategory category) {
    switch (category) {
      case TaskCategory.inbox:
        return {'name': 'Inbox', 'desc': 'Thu thập', 'color': Colors.grey[700]};
      case TaskCategory.next:
        return {'name': 'Next Actions', 'desc': 'Việc cần làm tiếp', 'color': Colors.blue};
      case TaskCategory.projects:
        return {'name': 'Projects', 'desc': 'Dự án dài hạn', 'color': Colors.purple};
      case TaskCategory.waiting:
        return {'name': 'Waiting For', 'desc': 'Chờ người khác', 'color': Colors.orange};
      case TaskCategory.calendar:
        return {'name': 'Calendar', 'desc': 'Lịch hẹn cố định', 'color': Colors.red};
      case TaskCategory.someday:
        return {'name': 'Someday/Maybe', 'desc': 'Có thể làm sau', 'color': Colors.green};
    }
  }
}