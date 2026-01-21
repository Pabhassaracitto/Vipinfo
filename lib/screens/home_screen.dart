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
            Text(categoryInfo['name']!, style: const TextStyle(fontWeight: FontWeight.bold)),
            Text(categoryInfo['desc']!, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.normal)),
          ],
        ),
        backgroundColor: categoryInfo['color'] as Color,
        foregroundColor: Colors.white,
        actions: [
          // Search button
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => _showSearchDialog(context),
          ),
          // Filter tags
          if (provider.allTags.isNotEmpty)
            IconButton(
              icon: Badge(
                isLabelVisible: provider.selectedTags.isNotEmpty,
                label: Text(provider.selectedTags.length.toString()),
                child: const Icon(Icons.filter_list),
              ),
              onPressed: () => _showTagFilter(context),
            ),
          // Toggle completed
          IconButton(
            icon: Icon(provider.showCompleted ? Icons.visibility_off : Icons.visibility),
            onPressed: () => provider.toggleShowCompleted(),
          ),
        ],
      ),
      drawer: const CategoryDrawer(),
      body: Column(
        children: [
          _buildStatsBar(context, provider),
          if (provider.searchQuery.isNotEmpty || provider.selectedTags.isNotEmpty)
            _buildActiveFilters(context, provider),
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
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
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

  Widget _buildActiveFilters(BuildContext context, TaskProvider provider) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.blue.shade50,
      child: Row(
        children: [
          const Icon(Icons.filter_alt, size: 16, color: Colors.blue),
          const SizedBox(width: 8),
          Expanded(
            child: Wrap(
              spacing: 8,
              children: [
                if (provider.searchQuery.isNotEmpty)
                  Chip(
                    label: Text('Tìm: "${provider.searchQuery}"'),
                    onDeleted: () => provider.setSearchQuery(''),
                    deleteIcon: const Icon(Icons.close, size: 16),
                  ),
                ...provider.selectedTags.map((tag) => Chip(
                  label: Text(tag),
                  onDeleted: () => provider.toggleTag(tag),
                  deleteIcon: const Icon(Icons.close, size: 16),
                )),
              ],
            ),
          ),
          TextButton(
            onPressed: () {
              provider.setSearchQuery('');
              provider.clearTagFilter();
            },
            child: const Text('Xóa hết'),
          ),
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
            Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.indigo)),
          ],
        ),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      ],
    );
  }

  void _showSearchDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('🔍 Tìm kiếm'),
        content: TextField(
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Nhập từ khóa...',
            prefixIcon: Icon(Icons.search),
          ),
          onChanged: (value) => Provider.of<TaskProvider>(context, listen: false).setSearchQuery(value),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Provider.of<TaskProvider>(context, listen: false).setSearchQuery('');
              Navigator.pop(context);
            },
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }

  void _showTagFilter(BuildContext context) {
    final provider = Provider.of<TaskProvider>(context, listen: false);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('🏷️ Lọc theo tag'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView(
            shrinkWrap: true,
            children: provider.allTags.map((tag) => CheckboxListTile(
              title: Text(tag),
              value: provider.selectedTags.contains(tag),
              onChanged: (checked) {
                provider.toggleTag(tag);
                Navigator.pop(context);
                _showTagFilter(context);
              },
            )).toList(),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Đóng')),
        ],
      ),
    );
  }

  void _showAddTaskDialog(BuildContext context) {
    showDialog(context: context, builder: (context) => const AddTaskDialog());
  }

  Map<String, dynamic> _getCategoryInfo(TaskCategory category) {
    switch (category) {
      case TaskCategory.inbox: return {'name': 'Inbox', 'desc': 'Thu thập', 'color': Colors.grey[700]};
      case TaskCategory.next: return {'name': 'Next Actions', 'desc': 'Việc cần làm tiếp', 'color': Colors.blue};
      case TaskCategory.projects: return {'name': 'Projects', 'desc': 'Dự án dài hạn', 'color': Colors.purple};
      case TaskCategory.waiting: return {'name': 'Waiting For', 'desc': 'Chờ người khác', 'color': Colors.orange};
      case TaskCategory.calendar: return {'name': 'Calendar', 'desc': 'Lịch hẹn cố định', 'color': Colors.red};
      case TaskCategory.someday: return {'name': 'Someday/Maybe', 'desc': 'Có thể làm sau', 'color': Colors.green};
    }
  }
}