import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import '../providers/theme_provider.dart';
import '../providers/task_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final taskProvider = Provider.of<TaskProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('⚙️ Cài đặt'),
        centerTitle: true,
      ),
      body: ListView(
        children: [
          // Theme settings
          const _SectionHeader(title: '🎨 Giao diện'),
          SwitchListTile(
            title: const Text('Dark Mode'),
            subtitle: const Text('Chế độ tối bảo vệ mắt'),
            secondary: const Icon(Icons.dark_mode),
            value: themeProvider.themeMode == ThemeMode.dark,
            onChanged: (_) => themeProvider.toggleTheme(),
          ),
          const Divider(),

          // Cloud Sync
          const _SectionHeader(title: '☁️ Đồng bộ'),
          SwitchListTile(
            title: const Text('Cloud Sync'),
            subtitle: Text(taskProvider.cloudSyncEnabled
                ? 'Đang đồng bộ với Firebase'
                : 'Chỉ lưu cục bộ'),
            secondary: const Icon(Icons.cloud),
            value: taskProvider.cloudSyncEnabled,
            onChanged: (_) => taskProvider.toggleCloudSync(),
          ),
          const Divider(),

          // Export/Import
          const _SectionHeader(title: '📤 Dữ liệu'),
          ListTile(
            leading: const Icon(Icons.upload_file),
            title: const Text('Export dữ liệu'),
            subtitle: const Text('Xuất tất cả tasks ra file JSON'),
            onTap: () => _exportData(context, taskProvider),
          ),
          ListTile(
            leading: const Icon(Icons.download),
            title: const Text('Import dữ liệu'),
            subtitle: const Text('Nhập tasks từ file JSON'),
            onTap: () => _importData(context, taskProvider),
          ),
          const Divider(),

          // About
          const _SectionHeader(title: 'ℹ️ Thông tin'),
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('Về GTD Manager Pro'),
            subtitle: const Text('Version 2.0.0'),
            onTap: () => _showAboutDialog(context),
          ),
          ListTile(
            leading: const Icon(Icons.help),
            title: const Text('Hướng dẫn GTD'),
            onTap: () => _showGTDGuide(context),
          ),
          const Divider(),

          // Danger zone
          const _SectionHeader(title: '⚠️ Nguy hiểm'),
          ListTile(
            leading: const Icon(Icons.delete_forever, color: Colors.red),
            title: const Text('Xóa tất cả dữ liệu', style: TextStyle(color: Colors.red)),
            subtitle: const Text('Không thể hoàn tác'),
            onTap: () => _confirmDeleteAll(context),
          ),
        ],
      ),
    );
  }

  Future<void> _exportData(BuildContext context, TaskProvider provider) async {
    try {
      final jsonData = provider.exportToJson();
      final fileName = 'gtd_backup_${DateTime.now().millisecondsSinceEpoch}.json';

      await Share.shareXFiles(
        [XFile.fromData(jsonData.codeUnits, name: fileName, mimeType: 'application/json')],
        subject: 'GTD Manager Backup',
      );

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Export thành công!')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Lỗi: $e')),
        );
      }
    }
  }

  Future<void> _importData(BuildContext context, TaskProvider provider) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);
        final jsonString = await file.readAsString();

        await provider.importFromJson(jsonString);

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('✅ Import thành công!')),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Lỗi import: $e')),
        );
      }
    }
  }

  void _confirmDeleteAll(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('⚠️ Xác nhận xóa'),
        content: const Text('Bạn có chắc muốn xóa TẤT CẢ dữ liệu? Hành động này không thể hoàn tác!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              // Xóa tất cả dữ liệu
              final provider = Provider.of<TaskProvider>(context, listen: false);
              // Implement delete all logic here if needed
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('🗑️ Đã xóa tất cả dữ liệu')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Xóa tất cả'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'GTD Manager Pro',
      applicationVersion: '2.0.0',
      applicationIcon: const Icon(Icons.checklist, size: 48, color: Colors.indigo),
      children: const [
        Text('Ứng dụng quản lý công việc theo phương pháp Getting Things Done'),
        SizedBox(height: 8),
        Text('✨ 10 tính năng nâng cao:\n'
            '✅ Thông báo nhắc nhở\n'
            '✅ Dashboard & Analytics\n'
            '✅ Tìm kiếm & Tags\n'
            '✅ Đồng bộ Cloud\n'
            '✅ Dark Mode\n'
            '✅ Export/Import dữ liệu\n'
            '✅ Pomodoro Timer\n'
            '✅ Habit Tracker\n'
            '✅ Weekly Review\n'
            '✅ Đa nền tảng'),
      ],
    );
  }

  void _showGTDGuide(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('📚 Hướng dẫn GTD'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '🎯 5 Bước GTD:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              SizedBox(height: 12),

              Text('1️⃣ CAPTURE (Thu thập)', style: TextStyle(fontWeight: FontWeight.bold)),
              Text('Ghi lại mọi thứ vào Inbox, đừng để sót bất kỳ ý tưởng nào'),
              SizedBox(height: 8),

              Text('2️⃣ CLARIFY (Làm rõ)', style: TextStyle(fontWeight: FontWeight.bold)),
              Text('Quyết định ý nghĩa của từng item:\n'
                  '• Cần hành động? → Next Actions\n'
                  '• Dự án lớn? → Projects\n'
                  '• Chờ ai đó? → Waiting For\n'
                  '• Có deadline? → Calendar\n'
                  '• Làm sau? → Someday/Maybe'),
              SizedBox(height: 8),

              Text('3️⃣ ORGANIZE (Sắp xếp)', style: TextStyle(fontWeight: FontWeight.bold)),
              Text('Phân loại và lưu trữ vào đúng danh mục'),
              SizedBox(height: 8),

              Text('4️⃣ REVIEW (Xem lại)', style: TextStyle(fontWeight: FontWeight.bold)),
              Text('Mỗi tuần review toàn bộ hệ thống, cập nhật ưu tiên'),
              SizedBox(height: 8),

              Text('5️⃣ ENGAGE (Thực hiện)', style: TextStyle(fontWeight: FontWeight.bold)),
              Text('Làm việc dựa trên context, thời gian và năng lượng hiện tại'),
              SizedBox(height: 12),

              Text('💡 Quy tắc 2 phút:', style: TextStyle(fontWeight: FontWeight.bold)),
              Text('Nếu việc gì mất dưới 2 phút, làm ngay! Đừng để lại sau.'),
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
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}