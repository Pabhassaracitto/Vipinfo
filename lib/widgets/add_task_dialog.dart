import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/task_model.dart';
import '../providers/task_provider.dart';

class AddTaskDialog extends StatefulWidget {
  const AddTaskDialog({super.key});

  @override
  State<AddTaskDialog> createState() => _AddTaskDialogState();
}

class _AddTaskDialogState extends State<AddTaskDialog> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  DateTime? _dueDate;
  int _priority = 3;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Thêm công việc mới'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Tiêu đề *',
                border: OutlineInputBorder(),
              ),
              autofocus: true,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _descController,
              decoration: const InputDecoration(
                labelText: 'Mô tả',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 12),
            ListTile(
              leading: const Icon(Icons.calendar_today),
              title: Text(_dueDate == null
                  ? 'Chọn hạn hoàn thành'
                  : 'Hạn: ${_dueDate!.day}/${_dueDate!.month}/${_dueDate!.year}'),
              trailing: _dueDate != null
                  ? IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () => setState(() => _dueDate = null),
              )
                  : null,
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (date != null) setState(() => _dueDate = date);
              },
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Text('Độ ưu tiên:'),
                Expanded(
                  child: Slider(
                    value: _priority.toDouble(),
                    min: 1,
                    max: 5,
                    divisions: 4,
                    label: _priority.toString(),
                    onChanged: (value) => setState(() => _priority = value.toInt()),
                  ),
                ),
                Text(_priority.toString()),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Hủy'),
        ),
        ElevatedButton(
          onPressed: _titleController.text.isEmpty ? null : () {
            final provider = Provider.of<TaskProvider>(context, listen: false);
            final task = Task(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              title: _titleController.text,
              description: _descController.text.isEmpty ? null : _descController.text,
              category: provider.currentCategory,
              createdAt: DateTime.now(),
              dueDate: _dueDate,
              priority: _priority,
            );
            provider.addTask(task);
            Navigator.pop(context);
          },
          child: const Text('Thêm'),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }
}